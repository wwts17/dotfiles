# Global Engineering Instructions

## Hard rules

- Never `git push` — the user pushes manually.
- Never wildcard `rm` (`rm *`, `rm -rf *`) — delete specific named files or directories only.

## Silent failures

These fail without anyone noticing, so they stay loaded even when no skill is triggered.

- Errors are values — handle them explicitly; never swallow them. ❌ `try { ... } catch {}` ✅ propagate, or catch the specific error with a stated reason.
- Don't guess or invent APIs, files, fields, or commands. Verify, or say you're unsure.
- Claim "done" only after tests or builds pass; report failures with their output; state any skipped steps.

## Toolchain

- Node/JS: `fnm` for versions (`.nvmrc`/`.node-version`), `pnpm` for packages and scripts. No npm/yarn/nvm.
- Java/Maven: SDKMAN for JDK and Maven, `mvn` for builds and tests. No brew-installed JDK.
- Python: `pixi` for environments and packages (`pixi add`/`run`/`shell`), `pixi global install` for CLI tools. No pip/conda/venv/brew.
