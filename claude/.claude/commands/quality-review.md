---
description: Review finished changes for quality — run /code-review and the reviewer agent as a first or recheck round, save their full output to a report file, and report only what must be fixed.
argument-hint: "[branch | commit range | path] [first | recheck] (empty = current branch against main, uncommitted included)"
---

# /quality-review

Review target: $ARGUMENTS

This command reviews; it never edits code. Run the steps in order. A step is not
started until the previous one is complete.

0. Determine the scope and the round. Scope: if `$ARGUMENTS` names a target, use it verbatim; otherwise the base is `main`, or `origin/main` when the current branch *is* `main`, or the working tree alone when neither ref exists. Round: use the round named in `$ARGUMENTS` if there is one. Otherwise it is `first` when `~/.claude/reviews/<repo>/` holds no report for the current branch, and `recheck` when it does, where `<repo>` is the basename of the repository root. The round number is the count of existing reports for the branch plus one.
   On `recheck` the scope is the diff from the sha recorded in the previous report to the current HEAD, plus the working tree changes. When deciding the round automatically, if that diff touches a file outside the previous report's file list, the round is `first`, not `recheck`.
   When the branch already has two `recheck` reports and `$ARGUMENTS` did not name a round, stop here and say: "该分支已 recheck 两轮，继续请显式传 `first` 重开。" Do not start a third round on your own.
1. `first` only. List the files in `git diff <base>...HEAD` plus the files reported by `git status`. Give one sentence per file describing what changed in it.
2. Run the built-in `/code-review` with effort `medium`, which reports only findings it is confident in. On `first` the target is the whole scope; on `recheck` it is only the files the fix touched. It runs as a background subagent — wait for it to finish.
3. `first` only. For every function the diff changes, read its call sites and its existing test files — the diff alone is not enough. For each function, state whether its callers are affected and whether the existing tests cover the change.
4. Run the `reviewer` agent in the round's mode. Give it the results of the steps that ran this round and the full set of `/code-review` findings, and ask it to confirm or dismiss each Important finding one at a time. On `recheck`, also give it the path of the previous round's report; it reads the Reject findings to check and the `## Decisions` ledger from there.
5. Write the full output of steps 2 and 4 to `~/.claude/reviews/<repo>/<branch>-<round>.md`, creating the directory if it is missing and replacing `/` in the branch name with `-`. Open the file with a header recording `git rev-parse HEAD`, the review scope, and the list of files under review, then a `## Decisions` ledger, then the outputs. Give the path in the chat and paste none of the content.
   `## Decisions` carries one line per item that went to the user under **你定**, in any round: `round N | <Where> | fix | defer | won't fix | <the user's own words>`. Copy every line from the previous report's ledger forward, then append this round's. Leave the verdict blank until the user answers, and fill it in when they do.
6. Final report in the chat: four sections, these four headings and no others. `/code-review`'s Important and Nit and the reviewer's Reject appear in the report file only — never in the chat.
   - **要修**: every finding with `Severity: Reject` and `Introduced: yes`. Nothing else.
   - **你定**: every `Pre-existing` finding whose Outcome is serious, and every `/code-review` Important the reviewer confirmed but that this change did not introduce. Each one carries a recommendation — 修 or 不修 — and its cost.
   - **上线前你去核实**: what the user has to check for themselves.
   - **已驳回**: one line, `N 项，理由见报告文件`. Do not argue any of them in the chat.

   Each item in the first two sections shows four lines in this order — `Outcome`, `Introduced`, `Fix`, `Where` — plus `Status: new | open since round N | deferred by user in round N`, then the `diff` block from the shared Finding format. Every item carries one, in all four sections: `-` lines copied verbatim out of the file, `+` lines the rewritten code itself. Add no prose around them.

   On `recheck`, apply the previous report's `## Decisions` ledger before writing anything: an item the user deferred appears as the single line `已推迟：<Where>` and gets no card; an item the user marked won't fix does not appear at all; and when `/code-review` reports an item the ledger already covers, carry the previous round's verdict forward instead of dismissing it again.

Nothing outside the four sections in step 6 goes in the chat.
