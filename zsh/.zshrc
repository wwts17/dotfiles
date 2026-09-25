typeset -U PATH path FPATH fpath

[[ -d "$HOME/.orbstack/shell/completions/zsh" ]] &&
  fpath+=("$HOME/.orbstack/shell/completions/zsh")

# Initialize before plugins that call compdef; compinit reuses its dump file.
autoload -Uz compinit
compinit

# Plugins and shell integrations
[[ -r "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/antidote/share/antidote/antidote.zsh" ]] && {
  source "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/antidote/share/antidote/antidote.zsh"
  antidote load
}

(( $+commands[starship] )) && eval "$(starship init zsh)"
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
(( $+commands[fzf] )) && source <(fzf --zsh)

# Node.js
if (( $+commands[fnm] )); then
  eval "$(fnm env --use-on-cd --shell zsh)"
  eval "$(fnm completions --shell zsh)"
fi

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
path=("$PNPM_HOME" $path)
(( $+commands[pnpm] )) && eval "$(pnpm completion zsh 2>/dev/null)"

# Pixi
export PIXI_HOME="$HOME/.pixi"
path=("$PIXI_HOME/bin" $path)

# Go
(( $+commands[go] )) && path=("$HOME/go/bin" $path)

path=("$HOME/.local/bin" $path)

# SDKMAN: initialize after PATH prepends so its binaries take precedence.
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# OrbStack: also available in non-login shells.
[[ -d "$HOME/.orbstack/bin" ]] && path+=("$HOME/.orbstack/bin")

# Aliases
alias lz="lazygit"

# Local overrides
[[ -r ~/.zshrc.local ]] && source ~/.zshrc.local
