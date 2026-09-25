#!/usr/bin/env bash

set -euo pipefail

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

# OS Verification
if [[ "$(uname -s)" != "Darwin" ]]; then
  log_err "This dotfiles repository is optimized for macOS (Darwin). Current OS: $(uname -s)"
  exit 1
fi

# Check & Install Homebrew
if ! command -v brew >/dev/null 2>&1; then
  log_info "Homebrew not found. Installing Homebrew..."
  curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | /bin/bash
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  else
    log_err "Homebrew installation finished, but brew was not found."
    exit 1
  fi
fi

# Brew Bundle
log_info "Installing packages from Brewfile..."
brew bundle install --file="$DOTFILES_DIR/Brewfile"

# Git Local Identity Migration
if [[ -f "$HOME/.gitconfig" && ! -L "$HOME/.gitconfig" ]]; then
  if [[ -e "$HOME/.gitconfig.local" ]]; then
    log_err "Both ~/.gitconfig and ~/.gitconfig.local exist; merge them before installing."
    exit 1
  fi
  log_warn "Moving existing ~/.gitconfig to ~/.gitconfig.local to avoid stow collision..."
  mv "$HOME/.gitconfig" "$HOME/.gitconfig.local"
fi

if [[ ! -f "$HOME/.gitconfig.local" ]]; then
  log_warn "Create ~/.gitconfig.local with your Git name and email."
fi

# Stow Symlinks
log_info "Stowing dotfile packages into $HOME..."
STOW_PKGS=(zsh claude antigravity nvim starship ghostty cmux lazygit tig git pixi)
cd "$DOTFILES_DIR"
stow -n -t "$HOME" "${STOW_PKGS[@]}"
for pkg in "${STOW_PKGS[@]}"; do
  if [[ -d "$pkg" ]]; then
    log_info "Stowing package: $pkg"
    stow -t "$HOME" -v "$pkg"
  fi
done

ANTIGRAVITY_SETTINGS="$HOME/.gemini/antigravity-cli/settings.json"
if [[ ! -e "$ANTIGRAVITY_SETTINGS" ]]; then
  mkdir -p "$(dirname "$ANTIGRAVITY_SETTINGS")"
  temp_settings=$(mktemp)
  if jq --arg command "$HOME/.gemini/antigravity-cli/statusline.sh" \
    '.statusLine = {type: "command", command: $command, enabled: true}' \
    "$DOTFILES_DIR/antigravity/.gemini/antigravity-cli/settings.example.json" > "$temp_settings"; then
    mv "$temp_settings" "$ANTIGRAVITY_SETTINGS"
  else
    rm -f "$temp_settings"
    log_err "Failed to create Antigravity settings."
    exit 1
  fi
fi

# SDKMAN Installation
if [[ ! -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
  log_info "Installing SDKMAN! via curl..."
  curl -fsSL "https://get.sdkman.io?rcupdate=false" | bash
else
  log_info "SDKMAN! is already installed at ~/.sdkman"
fi

# Node LTS via fnm
log_info "Setting up Node.js LTS via fnm..."
fnm install --lts
fnm default lts-latest

log_succ "Dotfiles bootstrap completed successfully!"
log_info "Run ${BOLD}bash scripts/doctor.sh${NC} to verify your environment setup."
