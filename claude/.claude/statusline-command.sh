#!/usr/bin/env bash
# Claude Code status line. Requires `jq` (declared in Brewfile).
set -u

input=$(cat)

# One jq pass; join with US (0x1f) so empty fields don't collapse the way they would
# with whitespace IFS chars like tab. (Stay 3.2-compat: script may run via /bin/bash
# when Claude Code launches outside a brew-PATH shell.)
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

rate_part=""
[[ -n "$five_pct" ]] && rate_part+=" 5h:$(printf '%.0f' "$five_pct")%($(fmt_remaining "$five_resets"))"
[[ -n "$week_pct" ]] && rate_part+=" 7d:$(printf '%.0f' "$week_pct")%($(fmt_remaining "$week_resets"))"
[[ -n "$sub_pct"  ]] && rate_part+=" sub:$(printf '%.0f' "$sub_pct")%"

ctx_part=""
[[ -n "$ctx_pct" ]] && ctx_part=" ctx:$(printf '%.0f' "$ctx_pct")%"

git_part=""
if git rev-parse --git-dir &>/dev/null; then
  branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
  if [[ -n "$branch" ]]; then
    if git diff --quiet 2>/dev/null && git diff --cached --quiet 2>/dev/null; then
      status_icon="✓"
    else
      changed=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
      status_icon="~${changed}"
    fi
    git_part=" ${branch}[${status_icon}]"
  fi
fi

printf '%s%s%s%s' "$(basename "$PWD")" "$rate_part" "$ctx_part" "$git_part"
