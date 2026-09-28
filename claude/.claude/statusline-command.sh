#!/usr/bin/env bash
# Claude Code status line. Requires `jq` (declared in Brewfile).
set -u

input=$(cat)

# Use a non-whitespace separator to preserve empty fields; keep Bash 3.2 compatibility.
IFS=$'\x1f' read -r five_pct five_resets week_pct week_resets sub_pct ctx_pct <<<"$(
  jq -j '
    [
      .rate_limits.five_hour.used_percentage    // "",
      .rate_limits.five_hour.resets_at          // "",
      .rate_limits.seven_day.used_percentage    // "",
      .rate_limits.seven_day.resets_at          // "",
      .rate_limits.subscription.used_percentage // "",
      .context_window.used_percentage           // ""
    ] | join("")
  ' <<<"$input" 2>/dev/null
)"

fmt_remaining() {
  local resets_at="$1"
  [[ -z "$resets_at" ]] && return
  local diff=$(( resets_at - $(date +%s) ))
  (( diff <= 0 )) && { printf 'now'; return; }
  local d=$(( diff / 86400 ))
  local h=$(( (diff % 86400) / 3600 ))
  local m=$(( (diff % 3600) / 60 ))
  if   (( d > 0 )); then printf '%dd%dh%dm' "$d" "$h" "$m"
  elif (( h > 0 )); then printf '%dh%dm' "$h" "$m"
  else                   printf '%dm' "$m"
  fi
}

model=$(jq -r '.model.display_name // .model.id // empty' <<<"$input" 2>/dev/null)
effort=$(jq -r '.effort.level // empty' <<<"$input" 2>/dev/null)

# Claude palette (24-bit color)
rgb() { printf '\e[38;2;%d;%d;%dm' "$1" "$2" "$3"; }
RST=$'\e[0m'; BOLD=$'\e[1m'
ORANGE=$(rgb 217 119 87)    # #D97757 Claude orange
CREAM=$(rgb 232 230 220)    # #E8E6DC
DIM=$(rgb 135 134 127)      # #87867F warm gray
BLUE=$(rgb 106 155 204)     # #6A9BCC
GREEN=$(rgb 120 140 93)     # #788C5D sage
YELLOW=$(rgb 212 162 127)   # #D4A27F kraft
RED=$(rgb 191 77 67)        # #BF4D43
SEP=" ${DIM}·${RST} "

pct_color() {
  local p; p=$(printf '%.0f' "$1")
  if   (( p >= 80 )); then printf '%s' "$RED"
  elif (( p >= 50 )); then printf '%s' "$YELLOW"
  else                     printf '%s' "$GREEN"
  fi
}

# label, pct, [resets_at]
seg() {
  local out="${DIM}$1${RST} $(pct_color "$2")$(printf '%.0f' "$2")%${RST}"
  [[ -n "${3:-}" ]] && out+=" ${DIM}↻$(fmt_remaining "$3")${RST}"
  printf '%s' "$out"
}

parts=()
parts+=("${CREAM}$(basename "$PWD")${RST}")
if git rev-parse --git-dir &>/dev/null; then
  branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
  if [[ -n "$branch" ]]; then
    if git diff --quiet 2>/dev/null && git diff --cached --quiet 2>/dev/null; then
      parts+=("${BLUE}${branch}${RST} ${GREEN}✓${RST}")
    else
      changed=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
      parts+=("${BLUE}${branch}${RST} ${YELLOW}~${changed}${RST}")
    fi
  fi
fi

[[ -n "$five_pct" ]] && parts+=("$(seg 5h "$five_pct" "$five_resets")")
[[ -n "$week_pct" ]] && parts+=("$(seg 7d "$week_pct" "$week_resets")")
[[ -n "$sub_pct"  ]] && parts+=("$(seg sub "$sub_pct")")
[[ -n "$ctx_pct"  ]] && parts+=("$(seg ctx "$ctx_pct")")

if [[ -n "$model" ]]; then
  model_seg="${BOLD}${ORANGE}${model}${RST}"
  [[ -n "$effort" ]] && model_seg+=" ${DIM}${effort}${RST}"
  parts+=("$model_seg")
fi

line=""
for p in "${parts[@]}"; do
  [[ -n "$line" ]] && line+="$SEP"
  line+="$p"
done
printf '%s' "$line"
