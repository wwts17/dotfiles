---
name: performance
description: Performance tuning workflow. Use when a running system has become slower or misses a measured performance target — not while writing new code.
---

# Performance

## When to use

A running system got slower, or a measured metric misses its target.
Not for: speculative optimization while writing new code — write the direct implementation first (see the coding skill).

## Steps

1. Measure. Profile or benchmark to establish a baseline; keep the numbers and the command that produced them.
2. Find the part of the code that overwhelms the rest. If no single part does, stop and report that — don't tune.
3. Prefer changing data structures and algorithms over micro-tuning; the former moves numbers, the latter usually doesn't.
4. Re-measure with the same method and report before/after numbers.
5. Leave everything else untouched.

## Anti-patterns

- Optimizing where you guess time is spent — bottlenecks occur in surprising places.
- Claiming an optimization without before/after measurements.
- Rewriting for speed when n is small and will stay small.

## Output

- Baseline: [metric, value, measurement command]
- Hotspot: [file/function, share of total time]
- Change: [data structure or algorithm change, and why]
- Result: [before → after, same measurement]
