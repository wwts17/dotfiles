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
- Reader: a product person, or a developer who is not senior in this codebase. Explain a term in one sentence the first time it appears. No abbreviation that only the author would recognize. ❌ "bump the TTL on the LRU" ✅ "raise the cache expiry (TTL — how long an entry is kept) from 60 s to 300 s"
- Section length: at most 10 lines per section, Spec and Stages excepted. Over the limit, remove content; do not compress the wording.
- Only a decision the user has answered explicitly counts as decided. A trade-off the
  author made, however well reasoned, stays under Decisions needed with a recommended
  option. Renaming Decisions needed, or replacing it with a "Decided" table, to skip the
  confirmation violates this rule.
- Every document has a "Decisions needed" section and a "How to verify" section.
  - Decisions needed lists only trade-off questions — business, cost, risk, compatibility — each with a recommended option and its reason. Write "none" when there are none. Implementation choices (naming, data structures, how a test is written) are not questions for the reader: decide them, and state the choice in the body.
  - How to verify: a command to run or an observable outcome, one that comes out true or false.

## Choosing a skeleton

Plan when the change touches at most 3 files and adds no new data model. Design otherwise. Count the files before choosing; if the count passes 3 while writing, switch to Design.

## Plan

```markdown
# <Title>

## Conclusion        — one sentence
## Plain summary     — at most 3 sentences: what changes, what the user notices, the biggest risk
## Changes           — one line per file: `path` → what is done to it
## Impact            — one line per caller, one line per dependency
## Risks             — only high likelihood × high impact
## Decisions needed  — trade-off questions, each with a recommendation, or "none"
## How to verify     — a command or an observable outcome
```

## Design

All Plan sections, plus:

```markdown
## Spec              — the reference for the reviewer and the tests; exact, no gaps
## Stages            — the implementation split into independently reviewable stages
## Trade-offs        — options considered, and why they were rejected
## Non-goals         — what this deliberately does not solve
```

Spec contains, in this order:

- Behavior contract table, one row per case: `input → expected output → on error`. Include empty input and the failure path.
- Interface signatures, as they will appear in the code.
- Data structure definitions, with the type and meaning of every field.

Stages splits the implementation into parts that can be verified and reviewed on their
own, ordered by dependency: the foundation before what sits on it — queue semantics
before the service that calls them, the backend before the frontend. Each stage states:

- The changes it contains.
- Its passing condition: the tests that must go green, or the observable result.
- One sentence on what an error in this stage would cause if it leaked into the next.

The split is right when a reviewer can judge one stage's changes without reading the
others. The Plan skeleton has no Stages section — a Plan is a single stage.

## Change plans

A plan's reader must be able to execute it without guessing, and to tell afterwards
whether the result matches it.

- **Where**: name the file paths. For a change to existing content, give a before/after down to the sentence, marked with `-` / `+`. For a new file, give the final content or its skeleton. For a deletion or a move, name the target and its destination — do not paste the whole file.
- **What**: put the final wording in the plan. "Add a rule about X" is not wording; it becomes a different thing at execution time.
- **Who it affects**: list every consumer or call site of the change and say what happens to each. For text and configuration changes, this replaces enumerating runtime boundaries.
- **Runtime boundaries**: only for changes with behavior (empty input, extremes, concurrency, downstream failure and retry). Do not list them for a text-only change — writing "none" is filling in a form.
