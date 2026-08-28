import json
import os
import subprocess
import unittest

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
HOOK_SCRIPT = os.path.join(SCRIPT_DIR, "pre_tool_use.py")


class TestPreToolUseHook(unittest.TestCase):
    def evaluate(self, cmd_line: str) -> str:
        payload = {
            "toolCall": {
                "name": "run_command",
                "args": {
                    "CommandLine": cmd_line
                }
            }
        }
        process = subprocess.Popen(
            ["python3", HOOK_SCRIPT],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        stdout, _ = process.communicate(input=json.dumps(payload))
        result = json.loads(stdout)
        return result["decision"]

    def test_safe_single_commands(self):
        safe_commands = [
            "ls -la",
            "cat /Users/hugo/.zshrc",
            "head -n 20 file.txt",
            "tail -f log.txt",
            "rg 'pattern' src/",
            "find . -name '*.py'",
            "fd -e md",
            "git status",
            "git log -n 10 --oneline",
            "git diff HEAD~1",
            "git show 5c9ee50",
            "git blame file.py",
            "git branch",
            "git branch -a",
            "git branch -r",
            "git tag",
            "git tag -l",
            "git remote",
            "git remote -v",
            "git config --get user.name",
            "git config -l",
            "pwd",
            "echo hello",
            "which agy",
            "stat file.txt",
            "file image.png",
            "wc -l file.txt",
        ]
        for cmd in safe_commands:
            with self.subTest(cmd=cmd):
                self.assertEqual(self.evaluate(cmd), "allow")

    def test_block_shell_metacharacters(self):
        metachar_commands = [
            "ls\nrm -rf /tmp/test",
            "ls\r\nrm -rf /tmp/test",
            "ls & rm -rf /tmp/test",
            "cat file.txt > out.txt",
            "echo evil>>~/.zshrc",
            "cat /etc/passwd>>/tmp/leak",
            "cat <(id)",
            "echo $(git status)",
            "echo `date`",
            "echo ${USER}",
            "grep foo | head",
            "find . | xargs grep test",
            "ls; git status",
            "git status && git log",
            "ls || echo fail",
            "cat << EOF",
        ]
        for cmd in metachar_commands:
            with self.subTest(cmd=cmd):
                self.assertEqual(self.evaluate(cmd), "ask")

    def test_block_pager_and_sudo_privilege_escalation(self):
        escalation_commands = [
            "sudo cat /etc/sudoers",
            "sudo ls -la",
            "less /var/log/system.log",
            "more /var/log/system.log",
            "sudo less /etc/hosts",
        ]
        for cmd in escalation_commands:
            with self.subTest(cmd=cmd):
                self.assertEqual(self.evaluate(cmd), "ask")

    def test_block_git_c_and_mutating_git_arguments(self):
        mutating_git = [
            "git -c core.pager='touch /tmp/x' log",
            "git -c user.name=evil commit",
            "git branch -d feature-x",
            "git branch -D feature-x",
            "git branch -m old new",
            "git branch new-branch",
            "git tag v1.0.0",
            "git tag -d v1.0.0",
            "git tag -a v1.0.0 -m release",
            "git remote add origin https://evil.com/repo.git",
            "git remote set-url origin git@evil:x.git",
            "git remote remove origin",
            "git config --unset user.email",
            "git config --add user.email test@test.com",
            "git config user.name newname",
        ]
        for cmd in mutating_git:
            with self.subTest(cmd=cmd):
                self.assertEqual(self.evaluate(cmd), "ask")

    def test_block_mutating_find_and_fd_flags(self):
        mutating_find = [
            "find . -name *.log -delete",
            "find . -exec rm {} \\;",
            "find . -ok rm {} \\;",
            "find . -fprintf /tmp/out %p",
            "find . -fprint /tmp/out",
            "find . -fls /tmp/out",
            "fd . -x rm",
            "fd . -X rm",
            "fd . --exec rm",
            "fd . --exec-batch rm",
        ]
        for cmd in mutating_find:
            with self.subTest(cmd=cmd):
                self.assertEqual(self.evaluate(cmd), "ask")

    def test_hard_deny_commands(self):
        deny_commands = [
            "git " + "push origin main",
            "git " + "push",
            "rm *",
            "rm -rf *",
            "rm -r foo/*",
        ]
        for cmd in deny_commands:
            with self.subTest(cmd=cmd):
                self.assertEqual(self.evaluate(cmd), "deny")

    def test_general_modifying_commands(self):
        modifying = [
            "git commit -m 'feat: test'",
            "git add .",
            "touch newfile.txt",
            "pnpm install",
            "rm specific_file.txt",
            "npm test",
        ]
        for cmd in modifying:
            with self.subTest(cmd=cmd):
                self.assertEqual(self.evaluate(cmd), "ask")


if __name__ == "__main__":
    unittest.main()
