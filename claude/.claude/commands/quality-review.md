---
description: Review finished changes for quality — list the changed scope, run /code-review, read callers and existing tests, hand everything to the reviewer agent, then report only what must be fixed.
argument-hint: "[branch | commit range | path] (empty = current branch against main, uncommitted included)"
---

# /quality-review

Review target: $ARGUMENTS

This command reviews; it never edits code. Run the steps in order. A step is not
started until the previous one is complete.

0. Determine the scope. If `$ARGUMENTS` is non-empty, use it verbatim as the target and skip the rest of this step. If it is empty, the base is `main`; if the current branch *is* `main`, the base is `origin/main`; if neither ref exists, review the working tree changes only.
1. List the files in `git diff <base>...HEAD` plus the files reported by `git status`. Give one sentence per file describing what changed in it.
2. Run the built-in `/code-review` with effort `high` against the scope from step 1. It runs as a background subagent — wait for it to finish before continuing. List its findings verbatim under their own Important / Nit headings: do not drop, merge, reword, or rank them.
3. For every function the diff changes, read its call sites and its existing test files — the diff alone is not enough. For each function, state whether its callers are affected and whether the existing tests cover the change.
4. Run the `reviewer` agent. Give it the results of steps 1–3 and the full set of `/code-review` findings as input, and ask it which of them must be fixed. Show its verdict as written; do not summarize it.
5. Final report, three sections and nothing else:
   - **Must fix**: the reviewer's Reject blockers plus every Important finding from `/code-review`.
   - **Fix next**: the single highest-value remaining item.
   - **Before this goes live**: what the user has to do.

Steps 2 and 4 are shown verbatim. Outside the three sections in step 5, add no further summary.
