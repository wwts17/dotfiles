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

## Example skeleton

```markdown
# <Title>

**Conclusion**: We will do X because Y; the accepted cost is Z.

## Background    — the problem and its constraints
## Design        — data structures and flows first, then components
## Trade-offs    — options considered, and why they were rejected
## Non-goals     — what this deliberately does not solve
```
