#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# setup.sh — Main dotfiles installer
#
# Usage:   ./setup.sh
# ─────────────────────────────────────────────────────────────
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Load helpers ─────────────────────────────────────────────
source "$DOTFILES_DIR/lib/utils.sh"

# ── Module list ──────────────────────────────────────────────
MODULE_NAMES=(
  "Install Xcode Command Line Tools"
  "Install Homebrew"
  "Install asdf + languages (Node.js, Python, Ruby)"
  "Configure Git identity + SSH"
  "Install Mac apps"
  "Apply Dracula theme (iTerm2 + VS Code)"
  "Configure Dock"
  "Apply macOS settings"
)

MODULE_FILES=(
  "xcode.sh"
  "homebrew.sh"
  "asdf.sh"
  "git.sh"
  "apps.sh"
  "themes.sh"
  "dock.sh"
  "macos.sh"
)

# ── Welcome ──────────────────────────────────────────────────
clear
banner

echo -e "  ${BOLD}This script will set up your new Mac.${RESET}"
echo ""

# ── Interactive selection ────────────────────────────────────
select_modules "${MODULE_NAMES[@]}"

if ! ask_yes_no "Ready to begin?"; then
  echo ""
  info "Cancelled. Nothing was changed."
  exit 0
fi

# ── Request sudo upfront ─────────────────────────────────────
echo ""
info "Some steps require administrator access (sudo)."
info "Enter your password now so the script can run unattended."
echo ""
sudo -v

# Keep sudo alive in the background for the duration of the script
while true; do sudo -n true; sleep 60; done 2>/dev/null &
SUDO_KEEPALIVE_PID=$!
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null' EXIT

# ── Count selected steps for progress display ────────────────
selected_count=0
for s in "${SELECTED_MODULES[@]}"; do
  [[ "$s" == "1" ]] && selected_count=$((selected_count + 1))
done
set_total_steps "$selected_count"

# ── Run selected modules ────────────────────────────────────
for i in "${!MODULE_FILES[@]}"; do
  if [[ "${SELECTED_MODULES[$i]}" == "1" ]]; then
    step "${MODULE_NAMES[$i]}"
    source "$DOTFILES_DIR/modules/${MODULE_FILES[$i]}"
    run_module
  fi
done

# ── Done ─────────────────────────────────────────────────────
print_summary
