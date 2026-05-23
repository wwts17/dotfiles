# dotfiles

Personal macOS config repo. Uses GNU stow for symlink farming, Homebrew for system tools, SDKMAN for JVM toolchain, fnm for Node.

## Structure

| Package    | Lays down                                                                                                          | Notes                                |
| ---------- | ------------------------------------------------------------------------------------------------------------------ | ------------------------------------ |
| `zsh/`     | `~/.zshrc` · `~/.zprofile` · `~/.zsh_plugins.txt`                                                                  | antidote-managed plugins             |
| `claude/`  | `~/.claude/{CLAUDE.md, settings.json, statusline-command.sh, agents/, skills/}`                                    | global prefs + skills                |
| `nvim/`    | `~/.config/nvim/`                                                                                                  | NvChad base, lazy.nvim + Mason       |
| `starship/`| `~/.config/starship.toml`                                                                                          |                                      |
| `ghostty/` | `~/.config/ghostty/`                                                                                               |                                      |
| `yazi/`    | `~/.config/yazi/`                                                                                                  | flavors not vendored — `ya pack -i`  |
| `lazygit/` | `~/.config/lazygit/config.yml`                                                                                     |                                      |
| `tig/`     | `~/.tigrc`                                                                                                         |                                      |
| `Brewfile` | —                                                                                                                  | consumed by `brew bundle`, not stow  |

## Software

Source of truth is `Brewfile` (+ SDKMAN / fnm for runtimes). Table below mirrors it for quick browsing — keep in sync when editing `Brewfile`.

### CLI

| Tool | What |
| --- | --- |
| `bash` | modern bash 5.x (macOS ships 3.2; SDKMAN needs ≥4) |
| `antidote` | zsh plugin manager |
| `starship` | shell prompt |
| `stow` | symlink farm manager (bootstraps this repo) |
| `gh` | GitHub CLI |
| `tig` | git TUI |
| `lazygit` | git TUI (richer than tig) |
| `git-delta` | pretty diff pager (used by lazygit + git) |
| `neovim` | editor |
| `tree-sitter` | incremental parser (neovim syntax/highlight) |
| `jq` | JSON processor (used by claude statusline) |
| `fd` | faster `find` |
| `ripgrep` | faster `grep` |
| `fzf` | fuzzy finder |
| `zoxide` | smart `cd` |

### Node toolchain

| Tool | What |
| --- | --- |
| `fnm` | Node version manager (reads `.nvmrc` / `.node-version`) |
| `pnpm` | Node package manager (content-addressable store) |

### Yazi + preview deps

| Tool | What |
| --- | --- |
| `yazi` | terminal file manager |
| `ffmpeg` | video/audio preview |
| `sevenzip` | archive preview (`7zz`) |
| `poppler` | PDF preview |
| `imagemagick` | image preview |
| `resvg` | SVG preview |
| `chafa` | terminal image fallback (when KGP/Sixel probe fails) |

### GUI (casks)

| App | What |
| --- | --- |
| Ghostty | terminal emulator |
| cmux | Ghostty-based GUI w/ AI-agent vertical tabs (reuses ghostty config) |
| OrbStack | Docker / k8s runtime (lightweight Docker Desktop replacement) |
| Rectangle | window snapping |
| Stats | menu-bar system monitor |
| IINA | video player (yazi opener for `video/*`) |

### Outside Brewfile

| Tool | Installer | What |
| --- | --- | --- |
| SDKMAN | curl script (install step 4) | JDK / Maven / Gradle version manager |
| JDK | `sdk install java <ver>` | currently Temurin 17 by default |
| Maven | `sdk install maven` | build tool |
| Node LTS | `fnm install --lts` | actual Node runtime |

## Install

Fresh-machine bootstrap. Run top-to-bottom.

**Ordering principle:** each block installs what the next block — or a later shell reload — will source. Swap the order and `.zshrc` runs against missing commands; the `command -v` guards keep it silent, but features (completions, version managers) fail to wire up.

```bash
# 1. Clone
git clone git@github.com:wwts17/dotfiles.git ~/Personal/dotfiles
cd ~/Personal/dotfiles

# 2. Brew bundle (before stow — .zshrc references antidote/starship/fnm/pnpm/bash)
brew bundle install --file=./Brewfile

# 3. Stow packages → $HOME
stow -t ~ -n -v zsh claude nvim starship ghostty yazi lazygit tig   # dry-run
stow -t ~    -v zsh claude nvim starship ghostty yazi lazygit tig

# 4. SDKMAN — curl installer (not in Brewfile).
#    rcupdate=false: zsh/.zshrc already sources sdkman-init.sh.
#    /opt/homebrew/bin/bash: macOS ships Bash 3.2; SDKMAN rejects <4.
curl -s "https://get.sdkman.io?rcupdate=false" | /opt/homebrew/bin/bash

# 5. Install runtimes (before exec zsh — absolute paths since shell init hasn't loaded)
/opt/homebrew/bin/fnm install --lts
/opt/homebrew/bin/fnm default lts-latest
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java 17-tem                        # Temurin 17 (or whatever version you need)
sdk install maven                              # latest 3.x

# 6. Reload shell — every tool now in PATH, completions wire up cleanly
exec zsh

# 7. Yazi plugins/themes (not vendored — pulled per yazi/.config/yazi/package.toml)
ya pack -i
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
| Upgrade SDKMAN candidates     | `sdk upgrade` lists upgrades → `sdk install <candidate> <ver>`                                     |
| Update yazi flavors           | `ya pack -u`                                                                                       |
| Secrets / machine-local       | Put in `~/.zshrc.local` / `~/.zprofile.local` — sourced automatically, not versioned               |

Always dry-run (`-n -v`) before any real `stow`. **Never use** `stow --adopt` — it overwrites repo contents with whatever is currently in `$HOME`.
