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
5. Implement one step at a time, following `~/.claude/skills/coding/SKILL.md`. After each step, verify it, then report: what changed, the verification result, the steps that remain.
6. Run the `/quality-review` flow (`~/.claude/commands/quality-review.md`) on the finished work.
7. Final report: files changed; steps skipped and why; what the user must do before this goes live.
