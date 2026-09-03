---
name: debugging
description: Root-cause localization for defects and test failures. Use when something fails and it is not yet clear why.
---

# Debugging

## When to use

A defect or failing test whose cause is unknown.
Not for: fixes whose cause is already known (follow the test discipline in the coding skill), or the same class of problem recurring after fixes — that is a structural issue, not a debugging one.

## Steps

1. Build a minimal reproduction before touching any code.
2. State the invariant: what should the system guarantee here, and which guarantee is broken?
3. Form a mental model of the path from input to failure; bisect along it to where the invariant first breaks.
4. Stop at the source. Fix it there, following the test discipline in the coding skill — the reproduction becomes the regression test.

## Anti-patterns

- Scattering breakpoints or print statements at the error line, hoping something shows up.
- Wrapping the failure in try-catch so the symptom disappears.
- Patching the symptom where it surfaced instead of where the invariant broke.

## Output

- Broken invariant: [what should hold, and what actually happened]
- Root cause: [file:line and the reasoning chain that led there]
- Fix location and why: [source-level fix, not a symptom patch]
- Regression test: [the minimal reproduction, kept permanently]
