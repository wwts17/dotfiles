# dotfiles

Personal macOS config repo. GNU stow lays each package down as symlinks in `$HOME`.

## Structure

- `zsh/` — `~/.zshrc`, `~/.zprofile`, `~/.zsh_plugins.txt`
- `claude/` — `~/.claude/settings.json`, `~/.claude/statusline-command.sh`
- `antigravity/` — `~/.gemini/antigravity-cli/`: `settings.json`, `statusline.sh`, `statusline.py`
- `nvim/` — `~/.config/nvim/`
- `starship/` — `~/.config/starship.toml`
- `ghostty/` — `~/.config/ghostty/config`
- `cmux/` — `~/.config/cmux/cmux.json`
- `lazygit/` — `~/.config/lazygit/config.yml`
- `tig/` — `~/.tigrc`
- `git/` — `~/.gitconfig`
- `pixi/` — `~/.pixi/manifests/pixi-global.toml`

Not stow packages:

- `Brewfile` — package list read by `brew bundle`
- `scripts/` — `install.sh` bootstrap, `doctor.sh` health check
- `.github/` — GitHub Actions workflows
