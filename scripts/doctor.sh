#!/usr/bin/env bash
# ==============================================================================
# Dotfiles Environment Health Doctor
# Repository: https://github.com/wwts17/dotfiles
# ==============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

check_pass() { printf "  %b[PASS]%b %s\n" "${GREEN}" "${NC}" "$*"; PASS_COUNT=$((PASS_COUNT + 1)); }
check_warn() { printf "  %b[WARN]%b %s\n" "${YELLOW}" "${NC}" "$*"; WARN_COUNT=$((WARN_COUNT + 1)); }
check_fail() { printf "  %b[FAIL]%b %s\n" "${RED}" "${NC}" "$*"; FAIL_COUNT=$((FAIL_COUNT + 1)); }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

printf "%b=== Dotfiles Environment Health Doctor ===%b\n\n" "${BOLD}" "${NC}"

# 1. OS & Architecture Check
printf "%b▶ Checking Operating System...%b\n" "${BLUE}" "${NC}"
if [[ "$(uname -s)" == "Darwin" ]]; then
  check_pass "macOS ($(uname -m)) detected."
else
  check_fail "Unsupported OS: $(uname -s). Expecting macOS."
fi

# 2. Stow Symlink Verification
printf "\n%b▶ Checking Symlinks (Stow managed)...%b\n" "${BLUE}" "${NC}"
SYMLINKS=(
  "$HOME/.zshrc"
  "$HOME/.zprofile"
  "$HOME/.config/starship.toml"
  "$HOME/.config/ghostty"
  "$HOME/.config/nvim"
  "$HOME/.config/lazygit/config.yml"
  "$HOME/.gitconfig"
  "$HOME/.claude"
  "$HOME/.gemini/GEMINI.md"
  "$HOME/.gemini/ANTIGRAVITY.md"
  "$HOME/.gemini/config/hooks.json"
  "$HOME/.gemini/antigravity-cli/settings.json"
  "$HOME/.gemini/antigravity-cli/hooks"
  "$HOME/.gemini/antigravity-cli/skills"
  "$HOME/.gemini/shared"
  "$HOME/.gemini/config/agents"
  "$HOME/.claude/shared"
  "$HOME/.tigrc"
)

for link in "${SYMLINKS[@]}"; do
  if [[ -L "$link" ]]; then
    check_pass "Symlink active: $link -> $(readlink "$link")"
  elif [[ -e "$link" ]]; then
    check_warn "File exists but is NOT a symlink: $link"
  else
    check_fail "Missing configuration target: $link"
  fi
done

# 3. CLI Binary & Toolchain Availability
printf "\n%b▶ Checking Core CLI Toolchains...%b\n" "${BLUE}" "${NC}"
TOOLS=(brew stow antidote starship fnm pnpm pixi go lazygit tig nvim delta rg fd fzf zoxide jq)
for tool in "${TOOLS[@]}"; do
  if command -v "$tool" >/dev/null 2>&1; then
    check_pass "CLI available: $tool ($(command -v "$tool"))"
  else
    check_warn "CLI missing or not on PATH: $tool"
  fi
done

# 4. Version Managers & Runtime Environments
printf "\n%b▶ Checking Version Managers...%b\n" "${BLUE}" "${NC}"
if [[ -d "$HOME/.sdkman" ]]; then
  check_pass "SDKMAN! directory present at ~/.sdkman"
else
  check_warn "SDKMAN! directory (~/.sdkman) missing."
fi

if [[ -f "$HOME/.gitconfig.local" ]]; then
  check_pass "Local Git identity file ~/.gitconfig.local present."
else
  check_warn "Local Git identity file ~/.gitconfig.local missing."
fi

# 5. Shared Claude/Antigravity Config
# The antigravity package symlinks its rules, skills and shared/ into claude/.
# A file both tools read must describe engineering, not one tool's harness: a slash
# command, a review round or a ~/.claude path is correct for one side and dead text
# for the other. The shared set is derived from the symlinks, so it needs no updating.
printf "\n%b▶ Checking Shared Claude/Antigravity Config...%b\n" "${BLUE}" "${NC}"

HARNESS_TERMS='/quality-review|/code-review|/feature|recheck|~/\.claude|~/\.gemini|commands/|skills-parked'
SHARED_FILES=()

while IFS= read -r link; do
  target="$(cd "$(dirname "$link")" && cd "$(dirname "$(readlink "$link")")" 2>/dev/null && pwd)/$(basename "$(readlink "$link")")" || continue
  case "$target" in
    "$DOTFILES_DIR"/claude/*) ;;
    *) continue ;;
  esac
  if [[ ! -e "$target" ]]; then
    check_fail "Dead shared symlink: ${link#"$DOTFILES_DIR"/} -> $(readlink "$link")"
    continue
  fi
  if [[ -d "$target" ]]; then
    while IFS= read -r f; do SHARED_FILES+=("$f"); done < <(find "$target" -name '*.md' -type f)
  else
    SHARED_FILES+=("$target")
  fi
done < <(find "$DOTFILES_DIR/antigravity" -type l)

if [[ ${#SHARED_FILES[@]} -eq 0 ]]; then
  check_fail "No shared files found — the antigravity package no longer links into claude/."
else
  LEAKS=0
  for f in "${SHARED_FILES[@]}"; do
    if hits="$(grep -nE "$HARNESS_TERMS" "$f")"; then
      LEAKS=$((LEAKS + 1))
      check_fail "Harness-only wording in shared file ${f#"$DOTFILES_DIR"/}:"
      printf "%s\n" "$hits" | sed 's/^/           /'
    fi
  done
  [[ $LEAKS -eq 0 ]] && check_pass "${#SHARED_FILES[@]} shared files carry no harness-only wording."
fi

# 6. Shell Syntax Validation
printf "\n%b▶ Validating Shell Syntax...%b\n" "${BLUE}" "${NC}"
if zsh -n "$DOTFILES_DIR/zsh/.zshrc" 2>/dev/null; then
  check_pass "zsh/.zshrc syntax valid."
else
  check_fail "zsh/.zshrc contains syntax errors."
fi

if zsh -n "$DOTFILES_DIR/zsh/.zprofile" 2>/dev/null; then
  check_pass "zsh/.zprofile syntax valid."
else
  check_fail "zsh/.zprofile contains syntax errors."
fi

if bash -n "$DOTFILES_DIR/scripts/install.sh" 2>/dev/null; then
  check_pass "scripts/install.sh syntax valid."
else
  check_fail "scripts/install.sh contains syntax errors."
fi

# Summary
printf "\n%b=== Doctor Diagnosis Summary ===%b\n" "${BOLD}" "${NC}"
printf "%bPassed:%b %d | %bWarnings:%b %d | %bFailed:%b %d\n" "${GREEN}" "${NC}" "$PASS_COUNT" "${YELLOW}" "${NC}" "$WARN_COUNT" "${RED}" "${NC}" "$FAIL_COUNT"

if [[ $FAIL_COUNT -eq 0 ]]; then
  printf "\n%bYour dotfiles environment is healthy!%b\n" "${GREEN}${BOLD}" "${NC}"
  exit 0
else
  printf "\n%bSome critical checks failed. Please address the issues listed above.%b\n" "${RED}${BOLD}" "${NC}"
  exit 1
fi
