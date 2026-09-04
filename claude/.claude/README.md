# Claude configuration

Stow package deployed to `~/.claude/`. Three layers, following the official memory/skills split:

- `CLAUDE.md` — hard rules, the three silent-failure rules, and the toolchain; loaded every session. A rule earns its place here only if breaking it fails without anyone noticing.
- `skills/` — everything that loads on demand: coding, debugging, performance, tech-doc, git-commits.
- `skills-parked/` — skills removed from `~/.claude/skills` but kept in the repo: thinking and its four models (mece, first-principles, systems-thinking, probabilistic). Parked because they fired on ordinary implementation tasks and produced an analysis framework instead of a plan. Not stowed (`claude/.stow-local-ignore`); to restore one, move its directory back into `skills/`.
- `agents/reviewer.md` — pre-delivery review in an isolated context; reads the skill files it needs rather than restating them.
- `commands/feature.md` — `/feature`: the fixed sequence for delivering a feature. Order of calls: clarify with the user → read affected code → `skills/tech-doc` (Plan or Design) → wait for confirmation, Decisions needed answered one by one → implement with `skills/coding`: a Plan one verified step at a time, a Design one stage at a time with `commands/quality-review` after each stage and the next stage gated on Must fix being empty → a final `commands/quality-review` over all the changes for cross-stage problems → final report.
- `commands/quality-review.md` — `/quality-review`: review finished changes without editing them. Order of calls: determine the scope (argument, or the current branch against `main` with uncommitted work included) → list the changed files, one sentence each → built-in `/code-review` at effort `high`, findings listed verbatim → read the callers and existing tests of every changed function → `agents/reviewer` with the `/code-review` findings as input, verdict shown verbatim → a report of must-fix, fix-next, and what the user must do before going live.

## Plan or Design

Plan when the change touches at most 3 files and adds no new data model; Design otherwise. Design adds a Spec section (behavior contract table, interface signatures, data structures) that the reviewer and the tests are checked against. Defined in `skills/tech-doc`; the `/feature` command applies it at step 3. Design also adds Stages — the implementation split into independently reviewable stages — and the per-stage review gate that `/feature` enforces at step 5.

## Maintenance conventions

- Single source of truth: define content in one place; other files reference it by path only. The cross-references are: reviewer → `skills/coding`, `skills/git-commits`, `skills/tech-doc`; `commands/feature` → `skills/tech-doc`, `skills/coding`, `commands/quality-review`; `commands/quality-review` → the built-in `/code-review`, `agents/reviewer`; debugging and performance → the coding skill.
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
