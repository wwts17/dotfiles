---
description: Deliver a feature end to end — clarify, read, plan, confirm, implement step by step, review, report. Each step finishes before the next starts.
argument-hint: <feature description>
---

# /feature

Feature request: $ARGUMENTS

Run the steps in order. A step is not started until the previous one is complete.
Do not apply an analysis framework (MECE, first principles, systems thinking,
probabilistic decision) at any step — the output is a plan, not an analysis.

1. Restate the request in your own words. List every point that is uncertain or could be read two ways. Ask the user, and wait for the answers.
2. Read the affected code: every caller of what changes, everything it depends on, and the existing tests. List the files involved and what each has to do with the change.
3. Write the document following `~/.claude/skills/tech-doc/SKILL.md`: Plan if the change touches at most 3 files and adds no new data model, Design otherwise.
4. Stop and wait for confirmation. Every item under Decisions needed requires an explicit answer from the user before continuing; a general "go ahead" does not answer them.
5. Implement, following `~/.claude/skills/coding/SKILL.md`.
   A Plan is implemented one step at a time: after each step, verify it, then report what changed, the verification result, and the steps that remain. When every step is done, run the `/quality-review` flow (`~/.claude/commands/quality-review.md`) as `first`. If it returns Reject findings, fix them and run `/quality-review` as `recheck` once; whatever that round returns, hand it to the user and stop — do not run a third round.
   A Design is implemented stage by stage: finish one stage, run its passing condition, then run `/quality-review` as `first`, with the scope limited to that stage's changes. While Must fix is non-empty, fix it and run `/quality-review` as `recheck` — at most twice. If Reject findings survive the second recheck, stop and hand the list to the user to decide; do not run a third round. When Must fix is empty and every item under "Before this goes live" that needs a user decision has been answered, commit the stage following `~/.claude/skills/git-commits/SKILL.md`, then start the next stage.
6. Design only — a Plan's step-5 review is its whole review. When every stage is done, review all the changes once for problems that cross stage boundaries: `/code-review` at effort `medium`, plus the `reviewer` agent limited to the Problems introduced and Internal consistency dimensions. This is not a `first` round. Write the full output to `~/.claude/reviews/<repo>/<branch>-final.md` and report it in the chat as the three-section report from step 6 of `/quality-review`.
7. Final report: files changed; steps skipped and why; what the user must do before this goes live.
