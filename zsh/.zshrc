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

# === proxy ===
# 本机代理。用 localprox on|off|status 切换,状态存盘,新终端沿用上次选择。
LOCALPROX_IP="127.0.0.1"
LOCALPROX_PORT="7897"
LOCALPROX_STATE="${XDG_CONFIG_HOME:-$HOME/.config}/localprox/state"
LOCALPROX_NO_PROXY="localhost,127.0.0.1,localaddress,.local,192.168.0.0/16,10.0.0.0/8"
LOCALPROX_CONTAINER_PLIST="$HOME/Library/Application Support/com.apple.container/apiserver/apiserver.plist"

_localprox_env_on() {
  local http="http://${LOCALPROX_IP}:${LOCALPROX_PORT}"
  local socks="socks5://${LOCALPROX_IP}:${LOCALPROX_PORT}"
  export http_proxy="$http" HTTP_PROXY="$http" https_proxy="$http" HTTPS_PROXY="$http"
  export all_proxy="$socks" ALL_PROXY="$socks"
  export no_proxy="$LOCALPROX_NO_PROXY" NO_PROXY="$LOCALPROX_NO_PROXY"
}

_localprox_env_off() {
  unset http_proxy HTTP_PROXY https_proxy HTTPS_PROXY all_proxy ALL_PROXY no_proxy NO_PROXY
}

# apple container 的守护进程只在 container system start 时读一次环境变量,快照进
# service plist,之后不再回看,所以改完代理必须重启它才生效。没在跑就什么都不做——
# 切代理不该顺带拉起一个虚拟机,下次手动 start 时自然会取到当时的环境。
# 同理不能交给 brew services 托管:那个 plist 跑的是一次性命令又配了 KeepAlive,
# 会被 launchd 反复拉起,每次都用不带代理的 launchd 环境覆盖快照。
_localprox_restart_container() {
  command -v container >/dev/null 2>&1 || return 0
  container system status >/dev/null 2>&1 || return 0
  container system stop >/dev/null 2>&1
  container system start >/dev/null
}

_localprox_save() {
  mkdir -p "${LOCALPROX_STATE:h}" && echo "$1" > "$LOCALPROX_STATE"
}

localprox() {
  case "${1:-status}" in
    on)
      _localprox_env_on
      _localprox_save on
      _localprox_restart_container || { echo "container 服务启动失败,代理环境变量已生效" >&2; return 1; }
      echo "代理已开启 ${LOCALPROX_IP}:${LOCALPROX_PORT}"
      ;;
    off)
      _localprox_env_off
      _localprox_save off
      _localprox_restart_container || { echo "container 服务启动失败,代理环境变量已清除" >&2; return 1; }
      echo "代理已关闭"
      ;;
    status)
      echo "存盘状态    $(cat "$LOCALPROX_STATE" 2>/dev/null || echo 'on(默认,无状态文件)')"
      echo "当前 shell  ${http_proxy:-未设置}"
      if [ -f "$LOCALPROX_CONTAINER_PLIST" ]; then
        echo "container   $(plutil -extract EnvironmentVariables.http_proxy raw "$LOCALPROX_CONTAINER_PLIST" 2>/dev/null || echo 未设置)"
      fi
      if nc -z -G 1 "$LOCALPROX_IP" "$LOCALPROX_PORT" 2>/dev/null; then
        echo "端口探测    ${LOCALPROX_IP}:${LOCALPROX_PORT} 可连接"
      else
        echo "端口探测    ${LOCALPROX_IP}:${LOCALPROX_PORT} 连不上"
      fi
      ;;
    *)
      echo "用法: localprox [on|off|status]" >&2
      return 2
      ;;
  esac
}

if [ "$(cat "$LOCALPROX_STATE" 2>/dev/null)" = off ]; then
  _localprox_env_off
else
  _localprox_env_on
fi

# === aliases ===
alias lz="lazygit"
alias actr="container"
# compinit fills _comps only once container's completion is on fpath; without the guard
# a fresh machine reports `compdef: unknown command or service` on every shell start.
(( $+_comps[container] )) && compdef actr=container

# === local override ===
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# Added by Antigravity CLI installer
export PATH="/Users/hugo/.local/bin:$PATH"
