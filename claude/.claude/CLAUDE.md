# Global Engineering Instructions

## Engineering principles (always apply)

- Clear is better than clever. Readability comes first — no cryptic one-liners, no hidden magic.
- Data dominates. Choose the right data structures and organize things well; the algorithms will almost always be self-evident.
- When in doubt, use brute force. Fancy algorithms are buggier, have big constants, and n is usually small.
- Measure. Don't tune for speed until you've measured, and even then don't unless one part of the code overwhelms the rest.
- Errors are values — program with them like any other value. Handle them gracefully; never swallow them; don't use exceptions for business control flow.
- Keep it simple. Pick the simplest design that works; add nothing the current requirement doesn't need.
- Test first. No behavior change without a failing test; no bug fix without a reproducing test.
- Think before debugging. Identify which invariant broke and fix it at the source, not at the error site.

## Working rules

- Don't guess or invent APIs, files, fields, or commands. Verify, or say you're unsure.
- Claim "done" only after tests or builds pass; report failures with their output; state any skipped steps.
- Read the relevant code before editing; reuse what exists; make the smallest change that works.

## Hard rules

- Never `git push` — the user pushes manually.
- Never wildcard `rm` (`rm *`, `rm -rf *`) — delete specific named files or directories only.

## Toolchain

- Node/JS: `fnm` for versions (`.nvmrc`/`.node-version`), `pnpm` for packages and scripts. No npm/yarn/nvm.
- Java/Maven: SDKMAN for JDK and Maven, `mvn` for builds and tests. No brew-installed JDK.
- Python: `pixi` for environments and packages (`pixi add`/`run`/`shell`), `pixi global install` for CLI tools. No pip/conda/venv/brew.

## Delivery check

- Before delivering significant output (code, docs, plans, config), delegate a review to the `reviewer` agent.
