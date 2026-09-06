---
description: Review finished changes for quality — run /code-review and the reviewer agent as a first or recheck round, save their full output to a report file, and report only what must be fixed.
argument-hint: "[branch | commit range | path] [first | recheck] (empty = current branch against main, uncommitted included)"
---

# /quality-review

Review target: $ARGUMENTS

This command reviews; it never edits code. Run the steps in order. A step is not
started until the previous one is complete.

0. Determine the scope and the round. Scope: if `$ARGUMENTS` names a target, use it verbatim; otherwise the base is `main`, or `origin/main` when the current branch *is* `main`, or the working tree alone when neither ref exists. Round: use the round named in `$ARGUMENTS` if there is one. Otherwise it is `first` when `~/.claude/reviews/<repo>/` holds no report for the current branch, and `recheck` when it does, where `<repo>` is the basename of the repository root. The round number is the count of existing reports for the branch plus one.
1. `first` only. List the files in `git diff <base>...HEAD` plus the files reported by `git status`. Give one sentence per file describing what changed in it.
2. Run the built-in `/code-review` with effort `medium`, which reports only findings it is confident in. On `first` the target is the whole scope; on `recheck` it is only the files the fix touched. It runs as a background subagent — wait for it to finish.
3. `first` only. For every function the diff changes, read its call sites and its existing test files — the diff alone is not enough. For each function, state whether its callers are affected and whether the existing tests cover the change.
4. Run the `reviewer` agent in the round's mode. Give it the results of steps 1–3 and the full set of `/code-review` findings, and ask it to confirm or dismiss each Important finding one at a time. On `recheck`, also give it the path of the previous round's report; it reads the Reject findings to check from there.
5. Write the full output of steps 2 and 4 to `~/.claude/reviews/<repo>/<branch>-<round>.md`, creating the directory if it is missing and replacing `/` in the branch name with `-`. Give the path in the chat and paste none of the content.
6. Final report in the chat, three sections and nothing else. Every item uses the reviewer's four-line Finding format; add no prose around them.
   - **Must fix**: the reviewer's Reject findings, and nothing else. An Important finding from `/code-review` belongs here only when the reviewer confirmed it; for each one the reviewer dismissed, write one line giving the reason.
   - **Fix next**: the single highest-value remaining item.
   - **Before this goes live**, in two groups:
     - *You decide*: each item with a recommended option.
     - *You verify*: what the user has to check for themselves.

Nothing outside the three sections in step 6 goes in the chat.
