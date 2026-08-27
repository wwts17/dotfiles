---
name: tech-doc
description: Technical writing conventions. Use when writing or reviewing design docs, proposals, API contracts, or mechanism explanations.
---

# Technical Documents

## Rules

- Conclusion first: the recommendation and its reason in the first paragraph; details after.
- Progressive layering: summary → architecture → detailed design → appendix; each layer complete at its own depth.
- Precision: paths, commands, and parameters must be exact and runnable; no "probably", "should be", or hand-waving.
- Completeness: state non-goals explicitly; every chosen option comes with the trade-off that was accepted.
- Plain, complete sentences. Spell out an abbreviation the first time it appears. Delete "should", "probably", and "may be" — replace them with a definite statement, or mark the item as unverified and say how to verify it.

## Example skeleton

```markdown
# <Title>

**Conclusion**: We will do X because Y; the accepted cost is Z.

## Background    — the problem and its constraints
## Design        — data structures and flows first, then components
## Trade-offs    — options considered, and why they were rejected
## Non-goals     — what this deliberately does not solve
```

## Plans

A plan's reader must be able to execute it without guessing, and to tell afterwards
whether the result matches it.

- **Where**: name the file paths. For a change to existing content, give a before/after down to the sentence, marked with `-` / `+`. For a new file, give the final content or its skeleton. For a deletion or a move, name the target and its destination — do not paste the whole file.
- **What**: put the final wording in the plan. "Add a rule about X" is not wording; it becomes a different thing at execution time.
- **Who it affects**: list every consumer or call site of the change and say what happens to each. For text and configuration changes, this replaces enumerating runtime boundaries.
- **Runtime boundaries**: only for changes with behavior (empty input, extremes, concurrency, downstream failure and retry). Do not list them for a text-only change — writing "none" is filling in a form.
- **How to verify**: a command to run or an observable outcome, one that comes out true or false.
