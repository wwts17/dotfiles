---
name: thinking
description: Structured reasoning for hard problems — decomposing ambiguous requirements, challenging inherited assumptions, recurring systemic issues, decisions under uncertainty, or major trade-off and root-cause analysis.
---

# Thinking Models

## When to use

Problems that are complex, novel, or high-risk.
Not for: routine tasks a direct answer serves.

## Picking a model

| Signal | Model | Details |
|---|---|---|
| Ambiguous or sprawling problem, unclear scope | MECE decomposition | references/mece.md |
| A design justified mainly by precedent ("we've always done it this way") | First principles | references/first-principles.md |
| The same problem keeps coming back after fixes | Systems thinking | references/systems-thinking.md |
| A decision under uncertainty with real stakes | Probabilistic decision | references/probabilistic.md |

Read the reference file only when applying that model.

## Hard problems: chain all four

For major refactors, technology selection, or incident root-cause analysis, run in order, each step feeding the next:

1. MECE: split the problem into non-overlapping, exhaustive dimensions.
2. First principles: strip inherited assumptions down to hard constraints.
3. Systems thinking: find the feedback loops and the highest-leverage intervention point.
4. Probabilistic decision: compare options by expected value; set measurable triggers to revisit.
