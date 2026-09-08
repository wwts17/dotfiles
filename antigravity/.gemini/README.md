# Antigravity configuration

Stow package deployed to `~/.gemini/`.

Most of this package is symlinks into `claude/.claude/`. The content lives there and is
maintained there; only what is genuinely Antigravity-specific is a real file here. Two
copies of the same rules drift apart — `coding`, `debugging` and `tech-doc` had already
fallen several revisions behind before they were linked.

## Shared with Claude (symlinks — do not edit through this path)

| Here | Source |
|---|---|
| `GEMINI.md`, and `ANTIGRAVITY.md` through it | `claude/.claude/CLAUDE.md` |
| `antigravity-cli/skills/{coding,debugging,git-commits,performance,tech-doc}` | `claude/.claude/skills/<name>` |
| `shared/` | `claude/.claude/shared/` |

`shared/` carries both `review-standards.md` and `writing.md`; the symlink is on the
directory, so a new file added there arrives here with no change to this package.
`writing.md` reaches Claude because `CLAUDE.md` imports it with `@shared/writing.md`.
Whether Antigravity expands that same `@` line in `GEMINI.md` is unverified — the path
resolves (`~/.gemini/shared/writing.md` exists through the symlink), but the import
syntax has not been tested here.

What gets shared is decided by whether the content is about engineering or about the
harness, not by whether the two models resemble each other. Engineering content — what
good code is, how a comment earns its place, what a commit message says, what a review
judges — is the same under both tools and lives in `claude/.claude/` once. Anything that
names a command, a mode, or a report path belongs to one tool and stays in that tool's
own file.

`config/agents/reviewer/agent.md` is the case in point: a real file, not a symlink, but a
thin one. It points at the shared `shared/review-standards.md` for everything a review
judges, and adds nothing else. Claude's `agents/reviewer.md` is the same shell over the
same file, plus the `first`/`recheck` mode its `/quality-review` command drives — machinery
Antigravity has no use for, which is why the whole file is not shared.

## Antigravity-only (real files)

- `antigravity-cli/skills/thinking` and its four models — `mece`, `first-principles`, `systems-thinking`, `probabilistic`. Claude parks these (`claude/.claude/skills-parked/`) because they fired on ordinary implementation tasks; keeping them here is deliberate, not drift.
- `config/hooks.json` + `antigravity-cli/hooks/pre_tool_use.py` — permission guardrails: auto-approves read-only inspection commands, hard-blocks dangerous ones.
- `antigravity-cli/settings.json`, `statusline.sh`, `statusline.py`.

## Layout, per the official docs

- Global rules: `~/.gemini/GEMINI.md`, capped at 12,000 characters. Antigravity also reads `~/.gemini/AGENTS.md` and lets `GEMINI.md` win on conflicts; this package uses `GEMINI.md` only.
- Skills: a folder per skill with `SKILL.md`, YAML frontmatter, `description` required and `name` optional. The CLI reads `~/.gemini/antigravity-cli/skills/`; the IDE reads `~/.gemini/config/skills/`, which this package does not populate.
- Custom agents: `~/.gemini/config/agents/<name>/agent.md`. Antigravity's own concept for what Claude calls a subagent; `~/.gemini/agents` is the gemini-cli location and is not compatible.

Unverified: whether this CLI version reads `config/agents/` at all — that directory did
not exist before this package created it — and whether skill discovery follows a
symlinked skill folder (the symlinked `skills/` parent is known to work).

## Maintenance conventions

The conventions for the shared content live in `claude/.claude/README.md`. Only the rules
specific to this package are here:

- Edit shared content in `claude/.claude/`, never through a symlink in this tree.
- A new skill that both tools should follow goes in `claude/.claude/skills/` and gets a symlink here. A skill only Antigravity should follow is a real file here, and this README says why.
- An agent is a thin file on each side over a shared standards file. When an agent grows something only one tool can act on, that part stays in that tool's file — do not push it into the shared one.
- After changing the set of files (not their content), run `stow -R antigravity` — new symlinks inside an already-linked directory need no restow.
