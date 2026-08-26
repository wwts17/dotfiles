# === completion ===
# compinit BEFORE antidote: omz lib calls `compdef` at load time, so compdef must
# already be defined. Plugin completions added to fpath later are picked up via
# zsh's lazy autoload — this matches antidote's official recommended order.
# Full security check once per day; cached load the rest of the time.
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# === plugins & prompt ===
# Each external tool is guarded so partial installs / fresh-machine bootstrap
# don't throw startup errors.

[[ -r /opt/homebrew/opt/antidote/share/antidote/antidote.zsh ]] && {
  source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh
  antidote load
}

command -v starship >/dev/null && eval "$(starship init zsh)"
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
command -v fzf >/dev/null && source <(fzf --zsh)

# === runtimes & PATH ===
# fnm: --use-on-cd auto-switches Node version per directory (.nvmrc / .node-version)
if command -v fnm >/dev/null; then
  eval "$(fnm env --use-on-cd --shell zsh)"
  eval "$(fnm completions --shell zsh)"
fi

# pnpm: PATH needs PNPM_HOME so globally-installed bins (pnpm i -g) are callable
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
command -v pnpm >/dev/null && eval "$(pnpm completion zsh 2>/dev/null)"

# pixi: per-project Python/conda envs. `pixi global install` drops trampolines in
# ~/.pixi/bin regardless of how pixi itself was installed — keep it on PATH so
# globally-installed tools are callable. (No per-dir auto-activation: use `pixi shell`/`pixi run`.)
export PIXI_HOME="$HOME/.pixi"
case ":$PATH:" in
  *":$PIXI_HOME/bin:"*) ;;
  *) export PATH="$PIXI_HOME/bin:$PATH" ;;
esac
# completion: not eval'd — pixi ships a #compdef file (brew installs it to
# $(brew --prefix)/share/zsh/site-functions, already on fpath) that compinit autoloads.

# go: `go install` drops binaries in $(go env GOBIN), default $HOME/go/bin. Put it
# on PATH so those tools are callable. Per-project Go versions are handled by Go
# 1.21+'s built-in GOTOOLCHAIN (reads the `go` line in go.mod, auto-downloads) — no
# version manager needed. Guarded so a fresh-machine bootstrap doesn't break.
if command -v go >/dev/null; then
  case ":$PATH:" in
    *":$HOME/go/bin:"*) ;;
    *) export PATH="$HOME/go/bin:$PATH" ;;
  esac
fi

export PATH="$HOME/.local/bin:$PATH"

# sdkman: JDK / Maven / Gradle version manager. Init last among PATH tools so
# its JAVA_HOME + bin win against earlier prepends (sdkman's official guidance).
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# === aliases ===
alias lz="lazygit"

# === local override ===
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# Added by Antigravity CLI installer
export PATH="/Users/hugo/.local/bin:$PATH"
