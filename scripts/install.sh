#!/usr/bin/env bash
# ==============================================================================
# Dotfiles Idempotent Bootstrap Installer
# Repository: https://github.com/wwts17/dotfiles
# ==============================================================================

set -euo pipefail

# ANSI Color Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

log_info()  { printf "%b[INFO]%b %s\n" "${BLUE}" "${NC}" "$*"; }
log_succ()  { printf "%b[SUCCESS]%b %s\n" "${GREEN}" "${NC}" "$*"; }
log_warn()  { printf "%b[WARN]%b %s\n" "${YELLOW}" "${NC}" "$*"; }
log_err()   { printf "%b[ERROR]%b %s\n" "${RED}" "${NC}" "$*"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

log_info "Starting dotfiles installation from: ${BOLD}${DOTFILES_DIR}${NC}"

# 1. OS Verification
if [[ "$(uname -s)" != "Darwin" ]]; then
  log_err "This dotfiles repository is optimized for macOS (Darwin). Current OS: $(uname -s)"
  exit 1
fi

# 2. Check & Install Homebrew
if ! command -v brew >/dev/null 2>&1; then
  log_info "Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 3. Brew Bundle
log_info "Installing packages from Brewfile..."
brew bundle install --file="$DOTFILES_DIR/Brewfile"

# 4. Git Local Identity Migration
if [[ -f "$HOME/.gitconfig" && ! -L "$HOME/.gitconfig" ]]; then
  log_warn "Moving existing ~/.gitconfig to ~/.gitconfig.local to avoid stow collision..."
  mv "$HOME/.gitconfig" "$HOME/.gitconfig.local"
fi

if [[ ! -f "$HOME/.gitconfig.local" ]]; then
  log_info "Creating default ~/.gitconfig.local..."
  git config -f "$HOME/.gitconfig.local" user.name "Hugo"
  git config -f "$HOME/.gitconfig.local" user.email "hugo@example.com"
  log_warn "Please update your name and email in ~/.gitconfig.local"
fi

# 5. Stow Symlinks
log_info "Stowing dotfile packages into $HOME..."
STOW_PKGS=(zsh claude nvim starship ghostty cmux lazygit tig git)
cd "$DOTFILES_DIR"
for pkg in "${STOW_PKGS[@]}"; do
  if [[ -d "$pkg" ]]; then
    log_info "Stowing package: $pkg"
    stow -t "$HOME" -v "$pkg" 2>&1 | grep -v "BUG in find_stowed_path" || true
  fi
done

# 6. SDKMAN Installation
if [[ ! -d "$HOME/.sdkman" ]]; then
  log_info "Installing SDKMAN! via curl..."
  curl -s "https://get.sdkman.io?rcupdate=false" | /opt/homebrew/bin/bash || log_warn "SDKMAN installation returned non-zero code."
else
  log_info "SDKMAN! is already installed at ~/.sdkman"
fi

# 7. Node LTS via fnm
if command -v fnm >/dev/null 2>&1; then
  log_info "Setting up Node.js LTS via fnm..."
  fnm install --lts || true
  fnm default lts-latest || true
fi

log_succ "Dotfiles bootstrap completed successfully!"
log_info "Run ${BOLD}bash scripts/doctor.sh${NC} to verify your environment setup."
