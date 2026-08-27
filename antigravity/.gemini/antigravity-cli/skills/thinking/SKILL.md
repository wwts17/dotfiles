---
name: thinking
description: Runs the four reasoning models in order — MECE, first principles, systems thinking, probabilistic decision. Use for a major refactor, a technology choice, or an incident root-cause analysis, where one model alone is not enough.
---

# Thinking

## When to use

A problem worth four rounds of analysis: a major refactor, a technology choice, an
incident root-cause analysis.
Not for: a problem one model already answers — trigger that model directly
(mece, first-principles, systems-thinking, probabilistic).

## The chain

Run in order; each step's output is the next step's input.

1. `mece` — split the problem into non-overlapping, exhaustive dimensions.
   Output: the dimension list.
2. `first-principles` — for each dimension, strip inherited assumptions down to
   hard constraints. Output: the constraint list.
3. `systems-thinking` — under those constraints, find the feedback loops and the
   highest-leverage intervention point. Output: the intervention point.
4. `probabilistic` — compare interventions by expected value and set measurable
   triggers to revisit. Output: the decision and its triggers.

Each step's method lives in its own skill; this file only fixes the order.
