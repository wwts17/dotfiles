#!/usr/bin/env python3
import json
import re
import shlex
import sys
from typing import Dict, Any, List, Tuple

DENY_COMMAND_PATTERNS = [
    re.compile(r"\bgit\s+push\b"),
    re.compile(r"\brm\s+-[a-zA-Z]*r[a-zA-Z]*\s+.*\*"),
    re.compile(r"\brm\s+.*\*"),
]

SHELL_METACHARACTERS_PATTERN = re.compile(r"[\r\n><|&;`$(){}]")

MUTATING_FIND_FLAGS = {
    "-delete", "-exec", "-execdir", "-ok", "-okdir",
    "-fprintf", "-fprint", "-fprint0", "-fls"
}

MUTATING_FD_FLAGS = {"-x", "-X", "--exec", "--exec-batch"}

MUTATING_GIT_BRANCH_FLAGS = {
    "-d", "-D", "-m", "-M", "-c", "-C",
    "--delete", "--move", "--copy", "--set-upstream-to", "-u"
}

MUTATING_GIT_TAG_FLAGS = {
    "-d", "--delete", "-a", "-s", "-u", "-f", "--force"
}

MUTATING_GIT_CONFIG_FLAGS = {
    "--unset", "--unset-all", "--replace-all", "--add", "--edit", "-e"
}

SAFE_GIT_CONFIG_READ_FLAGS = {
    "-l", "--list", "--get", "--get-all", "--get-regexp"
}

SAFE_STANDALONE_BINARIES = {
    "ls", "cat", "head", "tail", "wc", "stat", "file", "tree",
    "grep", "rg", "cut", "sort", "uniq", "tr", "column",
    "which", "whereis", "where", "type", "alias",
    "pwd", "echo", "printf", "date", "uname", "whoami", "id", "hostname", "env", "printenv",
    "readlink", "realpath", "basename", "dirname", "shasum", "md5sum",
    "jq", "yq"
}

SAFE_GIT_INSPECTION_SUBCOMMANDS = {
    "status", "log", "diff", "show", "blame", "rev-parse",
    "ls-files", "describe", "shortlog", "reflog"
}


def has_deny_pattern(command_line: str) -> Tuple[bool, str]:
    for pattern in DENY_COMMAND_PATTERNS:
        if pattern.search(command_line):
            return True, f"Command matches blocked pattern: {pattern.pattern}"
    return False, ""


def has_shell_metacharacters(command_line: str) -> bool:
    return bool(SHELL_METACHARACTERS_PATTERN.search(command_line))


def is_safe_find_command(tokens: List[str]) -> bool:
    return not any(token in MUTATING_FIND_FLAGS for token in tokens)


def is_safe_fd_command(tokens: List[str]) -> bool:
    return not any(token in MUTATING_FD_FLAGS for token in tokens)


def is_safe_git_branch_command(arguments: List[str]) -> bool:
    if any(arg in MUTATING_GIT_BRANCH_FLAGS for arg in arguments):
        return False
    positional_args = [arg for arg in arguments if not arg.startswith("-")]
    return len(positional_args) == 0


def is_safe_git_tag_command(arguments: List[str]) -> bool:
    if any(arg in MUTATING_GIT_TAG_FLAGS for arg in arguments):
        return False
    positional_args = [arg for arg in arguments if not arg.startswith("-")]
    return len(positional_args) == 0


def is_safe_git_remote_command(arguments: List[str]) -> bool:
    positional_args = [arg for arg in arguments if not arg.startswith("-")]
    return len(positional_args) == 0


def is_safe_git_config_command(arguments: List[str]) -> bool:
    if any(arg in MUTATING_GIT_CONFIG_FLAGS for arg in arguments):
        return False
    return any(arg in SAFE_GIT_CONFIG_READ_FLAGS for arg in arguments)


def is_safe_git_command(tokens: List[str]) -> bool:
    if len(tokens) == 1:
        return True

    subcommand_index = 1
    while subcommand_index < len(tokens) and tokens[subcommand_index].startswith("-"):
        flag = tokens[subcommand_index]
        if flag in ("-c", "--config-env"):
            return False
        if flag in ("-C", "--git-dir", "--work-tree") and subcommand_index + 1 < len(tokens):
            subcommand_index += 2
        else:
            subcommand_index += 1

    if subcommand_index >= len(tokens):
        return True

    subcommand = tokens[subcommand_index]
    remaining_args = tokens[subcommand_index + 1:]

    if subcommand in SAFE_GIT_INSPECTION_SUBCOMMANDS:
        return True
    if subcommand == "branch":
        return is_safe_git_branch_command(remaining_args)
    if subcommand == "tag":
        return is_safe_git_tag_command(remaining_args)
    if subcommand == "remote":
        return is_safe_git_remote_command(remaining_args)
    if subcommand == "config":
        return is_safe_git_config_command(remaining_args)

    return False


def is_safe_xargs_command(tokens: List[str]) -> bool:
    forwarded_tokens = [t for t in tokens[1:] if not t.startswith("-")]
    if not forwarded_tokens:
        return False
    return is_safe_single_command(forwarded_tokens)


def is_safe_single_command(tokens: List[str]) -> bool:
    if not tokens:
        return True

    executable = tokens[0]

    if executable == "git":
        return is_safe_git_command(tokens)

    if executable == "find":
        return is_safe_find_command(tokens)

    if executable == "fd":
        return is_safe_fd_command(tokens)

    if executable == "xargs":
        return is_safe_xargs_command(tokens)

    if executable in SAFE_STANDALONE_BINARIES:
        return True

    return False


def evaluate_tool_call(payload: Dict[str, Any]) -> Dict[str, str]:
    tool_call = payload.get("toolCall", {})
    tool_name = tool_call.get("name", "")

    if tool_name != "run_command":
        return {"decision": "allow", "reason": f"Tool '{tool_name}' is allowed."}

    arguments = tool_call.get("args", {})
    command_line = arguments.get("CommandLine", "")

    if not command_line:
        return {"decision": "ask", "reason": "Empty command line requires confirmation."}

    is_denied, deny_reason = has_deny_pattern(command_line)
    if is_denied:
        return {"decision": "deny", "reason": deny_reason}

    if has_shell_metacharacters(command_line):
        return {
            "decision": "ask",
            "reason": f"Command contains shell metacharacters: {command_line}"
        }

    try:
        tokens = shlex.split(command_line)
    except ValueError:
        return {
            "decision": "ask",
            "reason": "Failed to parse command arguments safely."
        }

    if is_safe_single_command(tokens):
        return {
            "decision": "allow",
            "reason": "Read-only inspection command automatically approved."
        }

    return {
        "decision": "ask",
        "reason": f"Command '{command_line}' requires manual approval."
    }


def main():
    try:
        raw_input = sys.stdin.read()
        if not raw_input.strip():
            print(json.dumps({"decision": "ask", "reason": "No input received."}))
            return

        payload = json.loads(raw_input)
        evaluation_result = evaluate_tool_call(payload)
        print(json.dumps(evaluation_result))
    except Exception as error:
        sys.stderr.write(f"PreToolUse Hook Error: {str(error)}\n")
        print(json.dumps({"decision": "ask", "reason": f"Hook exception: {str(error)}"}))


if __name__ == "__main__":
    main()
