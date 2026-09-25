if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

export XDG_CONFIG_HOME="$HOME/.config"
typeset -U PATH path
path=("$HOME/.local/bin" $path)

[[ -r ~/.zprofile.local ]] && source ~/.zprofile.local
