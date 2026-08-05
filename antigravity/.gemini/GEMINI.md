# Antigravity Global Instructions

## Core Principles

- **No Speculation:** Never infer or invent unverified APIs, file paths, parameters, or schemas. Inspect authoritative source code or state uncertainty explicitly.
- **Verification Before Completion:** Never claim a task or bug fix is complete without empirical proof (e.g., passing builds, successful tests, or verified runtime logs).
- **Read & Reuse:** Inspect existing architecture and established code conventions before making edits. Prefer reusing pre-existing helpers over writing redundant abstractions.
- **Minimal Interventions:** Scope code edits strictly to what was requested. Avoid unsolicited refactoring, formatting changes, or speculative features.
- **Simplicity First:** Select the simplest solution that cleanly fulfills requirements without unnecessary complexity.

## Strict Boundaries

- **Never Execute `git push`:** Push operations are strictly reserved for manual user execution.
- **Never Execute Wildcard Deletions:** Destructive commands like `rm *` or `rm -rf *` are strictly prohibited. Always target explicit, named file paths.

## Toolchain Standard

- **JavaScript / Node.js:** Managed via `fnm` (`.nvmrc` / `.node-version`), packages and scripts executed via `pnpm`. Do NOT use `npm`, `yarn`, or `nvm`.
- **Java / Maven:** Managed via `SDKMAN!`, builds executed via `mvn`. Do NOT use Homebrew for JDK installations.
- **Python:** Managed via `pixi` (`pixi add`, `pixi run`, `pixi shell`, `pixi global install`). Do NOT use `pip`, `conda`, `venv`, or Homebrew for Python packages.

## Analytical Thinking Skills

Invoke specialized cognitive skills on demand for complex or high-uncertainty tasks:

- `/mece-decomposition` — Deconstruct ambiguous problems into Mutually Exclusive, Collectively Exhaustive sub-problems.
- `/first-principles` — Deconstruct assumptions to fundamental axioms and rebuild solutions bottom-up.
- `/systems-thinking` — Analyze feedback loops, stocks, flows, and leverage points.
- `/probabilistic-thinking` — Evaluate uncertain decisions via base rates, expected values, and Bayesian updates.
- `/deep-analysis` — Execute a comprehensive 4-stage analytical pipeline for critical problems.
- `/quality-review` — Pre-delivery audit against correctness, minimal edits, and simplicity.
- `/tech-doc` — Write clear, structured technical design documents and architectural plans.
- `/code-style` — Apply software craftsmanship and clean code principles.
