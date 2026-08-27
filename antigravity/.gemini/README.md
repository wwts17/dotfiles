# Antigravity configuration

Stow package deployed to `~/.gemini/`. Two layers, following the memory/skills split:

- `GEMINI.md` / `ANTIGRAVITY.md` — hard rules, the three silent-failure rules, and the toolchain; loaded every session. A rule earns its place here only if breaking it fails without anyone noticing.
- `skills/` — everything that loads on demand: coding, debugging, performance, tech-doc, git-commits, thinking and its four models (mece, first-principles, systems-thinking, probabilistic), and reviewer.

## Maintenance conventions

- Single source of truth: define content in one place; other files reference it by path only. The cross-references are: reviewer → `skills/coding`, `skills/git-commits`, `skills/tech-doc`; thinking → the four model skills by name; debugging and performance → the coding skill.
- Conventions and "always do X" content go in GEMINI.md; multi-step procedures go in skills. Don't copy one layer into the other.
- Anything that must apply while writing code belongs in a skill, not in a user-level `rules/` directory — that directory is not loaded automatically.
- A skill description states when to use the skill. It never lists the body's rules — copies drift apart.
- GEMINI.md never maintains a list of skills. Descriptions are already visible to Antigravity; hand-written lists go stale.
- Every rule carries its own test: a countable threshold, an observable trigger, or a pair of ❌/✅ examples. A rule that cannot answer "how would I know I broke it" is not admitted — it takes up room without changing behavior.
- Apart from the hard rules and the silent failures, every rule is a default rather than a prohibition. Deviate when there is a reason, and state the reason. The point of a rule is to make deviation a deliberate decision, not to prevent it.
- Wording: plain professional English; quote original authors verbatim where their phrasing is the point; no invented shorthand.
