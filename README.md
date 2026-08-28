# dotfiles

Personal macOS config repo. Uses GNU stow for symlink farming, Homebrew for system tools, SDKMAN for JVM toolchain, fnm for Node, pixi for Python.

## Structure

| Package    | Lays down                                                                                                          | Notes                                |
| ---------- | ------------------------------------------------------------------------------------------------------------------ | ------------------------------------ |
| `zsh/`     | `~/.zshrc` · `~/.zprofile` · `~/.zsh_plugins.txt`                                                                  | antidote-managed plugins; `localprox` proxy toggle |
| `claude/`  | `~/.claude/{CLAUDE.md, settings.json, statusline-command.sh, agents/, skills/}`                                    | global prefs + skills                |
| `nvim/`    | `~/.config/nvim/`                                                                                                  | NvChad base, lazy.nvim + Mason       |
| `starship/`| `~/.config/starship.toml`                                                                                          |                                      |
| `ghostty/` | `~/.config/ghostty/`                                                                                               |                                      |
| `cmux/`    | `~/.config/cmux/cmux.json`                                                                                         | JSONC; keys here override the app's Settings UI |
| `lazygit/` | `~/.config/lazygit/config.yml`                                                                                     |                                      |
| `tig/`     | `~/.tigrc`                                                                                                         |                                      |
| `git/`     | `~/.gitconfig`                                                                                                     | delta + `[include] ~/.gitconfig.local` for identity |
| `pixi/`    | `~/.pixi/manifests/pixi-global.toml`                                                                              | global CLI envs (python, uv); `pixi global sync` to apply |
| `scripts/` | —                                                                                                                  | `install.sh` (bootstrap) · `doctor.sh` (environment check) |
| `Brewfile` | —                                                                                                                  | consumed by `brew bundle`, not stow  |
| `.github/` | —                                                                                                                  | GitHub Actions CI syntax & lint workflows |

## Software

Brew-managed tools (CLI + GUI casks) live in `Brewfile`, grouped by purpose with a note on each. That file is the catalog — read it directly.

Runtimes live outside brew, managed by version managers:

| Tool | Installer | What |
| --- | --- | --- |
| SDKMAN | curl script (install step 5) | JDK / Maven / Gradle version manager |
| JDK | `sdk install java <ver>` | currently Temurin 17 by default |
| Maven | `sdk install maven` | build tool |
| Node LTS | `fnm install --lts` | actual Node runtime |

Go is the exception — it lives in `Brewfile` (`brew "go"`), not behind a version manager. Per-project versions are handled by Go 1.21+'s built-in **GOTOOLCHAIN**: the `go` line in a project's `go.mod` drives an automatic download/switch, so one brew-managed `go` is enough.

## Install

### Option A: Automated One-Line Bootstrap (Recommended)

```bash
git clone git@github.com:wwts17/dotfiles.git ~/dotfiles && cd ~/dotfiles
bash scripts/install.sh
bash scripts/doctor.sh   # Run diagnosis to verify environment health
```

### Option B: Manual Step-by-Step Installation

Fresh-machine bootstrap. Run top-to-bottom.

**Ordering principle:** each block installs what the next block — or a later shell reload — will source. Swap the order and `.zshrc` runs against missing commands; the `command -v` guards keep it silent, but features (completions, version managers) fail to wire up.

```bash
# 1. Clone
git clone git@github.com:wwts17/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Brew bundle (before stow — .zshrc references antidote/starship/fnm/pnpm/bash)
brew bundle install --file=./Brewfile

# 3. Git identity → ~/.gitconfig.local (not versioned; included by git/.gitconfig).
#    Migrate an existing ~/.gitconfig here first, or write a fresh one,
#    so step 4's stow of git/ doesn't collide.
[ -f ~/.gitconfig ] && ! [ -L ~/.gitconfig ] && mv ~/.gitconfig ~/.gitconfig.local
git config -f ~/.gitconfig.local user.name  "Your Name"
git config -f ~/.gitconfig.local user.email "you@example.com"

# 4. Stow packages → $HOME
stow -t ~ -n -v zsh claude nvim starship ghostty cmux lazygit tig git   # dry-run
stow -t ~    -v zsh claude nvim starship ghostty cmux lazygit tig git

# 5. SDKMAN — curl installer (not in Brewfile).
#    rcupdate=false: zsh/.zshrc already sources sdkman-init.sh.
#    /opt/homebrew/bin/bash: macOS ships Bash 3.2; SDKMAN rejects <4.
curl -s "https://get.sdkman.io?rcupdate=false" | /opt/homebrew/bin/bash

# 6. Install runtimes (before exec zsh — absolute paths since shell init hasn't loaded)
/opt/homebrew/bin/fnm install --lts
/opt/homebrew/bin/fnm default lts-latest
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java 17-tem                        # Temurin 17 (or whatever version you need)
sdk install maven                              # latest 3.x

# 7. Reload shell — every tool now in PATH, completions wire up cleanly
exec zsh
```

First `nvim` launch bootstraps lazy.nvim; Mason then auto-installs LSP/formatter binaries listed in `nvim/.config/nvim/lua/plugins/init.lua` under `ensure_installed`. Wait ~30s, then everything is wired.

## Maintenance

| Task                          | How                                                                                                |
| ----------------------------- | -------------------------------------------------------------------------------------------------- |
| Edit config                   | Edit files inside the repo; symlinks make changes take effect immediately                         |
| See changes                   | `git status` inside the repo, not `$HOME`                                                          |
| Add a stow package            | `mkdir -p <pkg>/<target-rel-path>` → move files → `stow -t ~ -n -v <pkg>` → `stow -t ~ <pkg>`     |
| Remove a stow package         | `stow -t ~ -D <pkg>` → `rm -rf <pkg>`                                                              |
| Add a brew formula            | Edit `Brewfile` → `brew bundle install --file=./Brewfile`                                          |
| Switch Node version           | `cd <proj>` auto-switches if `.nvmrc` present, else `fnm use <ver>`                                |
| Switch JDK / Maven            | `sdk use java <ver>` ; for auto-switch via `.sdkmanrc`, set `sdkman_auto_env=true` in `~/.sdkman/etc/config` |
| Switch Go version             | Set the `go` line in `go.mod` (e.g. `go 1.23.0`) — GOTOOLCHAIN auto-downloads/uses it; no manual install                  |
| New Python project            | `cd <proj>` → `pixi init` → `pixi add python <pkg>...` ; enter env with `pixi shell`, one-off with `pixi run <cmd>` |
| Install a global CLI tool     | `pixi global install <tool>` (lands in `~/.pixi/bin`, already on PATH)                              |
| Upgrade SDKMAN candidates     | `sdk upgrade` lists upgrades → `sdk install <candidate> <ver>`                                     |
| Toggle the local proxy        | `localprox on\|off\|status` — sets the `*_proxy` vars, persists the choice, and restarts the container daemon so it re-snapshots the env |
| Start the container runtime   | `container system start` (or `localprox on`). Not a login service — `brew services start container` respawns endlessly and drops the proxy env |
| Secrets / machine-local       | Put in `~/.zshrc.local` / `~/.zprofile.local` (sourced) or `~/.gitconfig.local` (included) — not versioned |

Always dry-run (`-n -v`) before any real `stow`. **Never use** `stow --adopt` — it overwrites repo contents with whatever is currently in `$HOME`.
