# Claude configuration

Stow package deployed to `~/.claude/`. Three layers, following the official memory/skills split:

- `CLAUDE.md` — engineering principles and hard rules; loaded every session.
- `rules/coding.md` — coding conventions (data first, test discipline, style); loads automatically when Claude reads a matching code file.
- `skills/` — one procedure per working scenario: debugging, performance, thinking, tech-doc, git-commits.
- `agents/reviewer.md` — pre-delivery review in an isolated context.

## Maintenance conventions

- Single source of truth: define content in one place; other files reference it by name only. The cross-references are: CLAUDE.md → the `reviewer` agent; reviewer → `~/.claude/rules/coding.md` and its `skills:` list; thinking → its own `references/` files; skills naming each other for boundaries (debugging/performance → coding rules, thinking).
- Conventions and "always do X" content go in CLAUDE.md or a rule; multi-step procedures go in skills. Don't copy one layer into the other.
- A skill description states when to use the skill. It never lists the body's rules — copies drift apart.
- CLAUDE.md never maintains a list of skills. Descriptions are already visible to Claude; hand-written lists go stale.
- Before adding anything, ask which existing scenario it belongs to. Only a genuinely new scenario justifies a new file.
- Wording: plain professional English; quote original authors verbatim where their phrasing is the point; no invented shorthand.
- After changes: run `/doctor` (config health) and `/context` (resident context cost) in a fresh session; rules visibility in `/context` is undocumented, verify by testing.
