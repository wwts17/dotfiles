#!/usr/bin/env bash
# One-click Antigravity Stow Deployment & Health Check Script

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🚀 Deploying Antigravity Dotfiles from ${DOTFILES_DIR}..."

if ! command -v stow >/dev/null 2>&1; then
    echo "❌ Error: GNU Stow is not installed. Please install it via 'brew install stow'."
    exit 1
fi

cd "${DOTFILES_DIR}"

# Run Stow re-stow
stow -R antigravity

echo "✅ Antigravity Stow package linked successfully!"

# Verify symlinks
echo "🔍 Verifying symlinks in ~/.gemini..."
ls -la ~/.gemini/GEMINI.md ~/.gemini/ANTIGRAVITY.md ~/.gemini/antigravity-cli/settings.json ~/.gemini/antigravity-cli/statusline.sh

# Test statusline execution
echo "🧪 Testing statusline execution..."
if [ -f ~/.gemini/antigravity-cli/statusline.sh ]; then
    echo '{"workspace": "'"${DOTFILES_DIR}"'", "model": {"display_name": "Gemini 3.6 Flash"}}' | ~/.gemini/antigravity-cli/statusline.sh
fi

echo "🎉 All done! Antigravity CLI is ready."
