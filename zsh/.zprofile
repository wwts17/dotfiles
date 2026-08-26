eval "$(/opt/homebrew/bin/brew shellenv)"

export XDG_CONFIG_HOME="$HOME/.config"

[ -f ~/.zprofile.local ] && source ~/.zprofile.local

# Added by Antigravity CLI installer
export PATH="/Users/hugo/.local/bin:$PATH"
