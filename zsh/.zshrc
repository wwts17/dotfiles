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

export PATH="$HOME/.local/bin:$PATH"

# sdkman: JDK / Maven / Gradle version manager. Init last among PATH tools so
# its JAVA_HOME + bin win against earlier prepends (sdkman's official guidance).
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# === functions ===
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
  command rm -f -- "$tmp"
}

# === local override ===
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
