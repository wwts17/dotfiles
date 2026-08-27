# Claude configuration

Stow package deployed to `~/.claude/`. Three layers, following the official memory/skills split:

- `CLAUDE.md` — hard rules, the three silent-failure rules, and the toolchain; loaded every session. A rule earns its place here only if breaking it fails without anyone noticing.
- `skills/` — everything that loads on demand: coding, debugging, performance, tech-doc, git-commits, thinking and its four models.
- `agents/reviewer.md` — pre-delivery review in an isolated context; reads the skill files it needs rather than restating them.

## Maintenance conventions

- Single source of truth: define content in one place; other files reference it by path only. The cross-references are: reviewer → `skills/coding`, `skills/git-commits`, `skills/tech-doc`; thinking → the four model skills by name; debugging and performance → the coding skill.
- Conventions and "always do X" content go in CLAUDE.md; multi-step procedures go in skills. Don't copy one layer into the other.
- Anything that must apply while writing code belongs in a skill, not in a user-level `rules/` directory — that directory is not loaded automatically. `.claude/rules/*.md` with `paths` frontmatter is a project-scoped mechanism.
- An agent's `skills:` frontmatter does not put the skill body in the agent's context. Verified against 2.1.247 with a marker-phrase probe: the agent reported it had nothing preloaded. An agent that needs a skill must read its file.
- A skill description states when to use the skill. It never lists the body's rules — copies drift apart.
- CLAUDE.md never maintains a list of skills. Descriptions are already visible to Claude; hand-written lists go stale.
- A skill fires on its description alone, so it will not fire for work that does not look like its trigger. `disable-model-invocation: true` in the frontmatter would hide a skill from the model and leave only `/name`; this repo deliberately does not use it.
- Every rule carries its own test: a countable threshold, an observable trigger, or a pair of ❌/✅ examples. A rule that cannot answer "how would I know I broke it" is not admitted — it takes up room without changing behavior.
- Apart from the hard rules and the silent failures, every rule is a default rather than a prohibition. Deviate when there is a reason, and state the reason. The point of a rule is to make deviation a deliberate decision, not to prevent it.
- A long prompt typed over and over means a missing entry point, not a missing skill. Put the content in the existing units and the call sequence in a `.claude/commands/` macro: skills carry content, commands carry invocation.
- Before adding anything, ask which existing scenario it belongs to. Only a genuinely new scenario justifies a new file.
- Wording: plain professional English; quote original authors verbatim where their phrasing is the point; no invented shorthand.
- After changes: run `/doctor` (config health) and `/context` (resident context cost) in a fresh session.
