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
  "Install Oh My Zsh"
  "Install asdf + languages (Node.js, Python, Ruby)"
  "Configure Git identity + SSH"
  "Clone GitHub repos into ~/Development"
  "Install Mac apps"
  "Apply Dracula theme (iTerm2 + VS Code)"
  "Load iTerm2 settings"
  "Restore SteerMouse settings"
  "Restore VS Code settings + extensions"
  "Configure Dock"
  "Apply macOS settings"
)

MODULE_FILES=(
  "xcode.sh"
  "homebrew.sh"
  "ohmyzsh.sh"
  "asdf.sh"
  "git.sh"
  "repos.sh"
  "apps.sh"
  "themes.sh"
  "iterm2.sh"
  "steermouse.sh"
  "vscode.sh"
  "dock.sh"
  "macos.sh"
)

# ── Welcome ──────────────────────────────────────────────────
clear
banner

echo -e "  ${BOLD}This script will set up your new Mac.${RESET}"
echo ""

# ── Interactive selection ────────────────────────────────────
select_items "Select which steps to run:" "${MODULE_NAMES[@]}"
SELECTED_MODULES=("${SELECTED_ITEMS[@]}")

# True if the step for the given module file (e.g. "apps.sh") is ticked
step_selected() {
  local i
  for i in "${!MODULE_FILES[@]}"; do
    if [[ "${MODULE_FILES[$i]}" == "$1" ]]; then
      [[ "${SELECTED_MODULES[$i]}" == "1" ]]
      return
    fi
  done
  return 1
}

# Per-step checklists below are asked up front, with the steps, so the run
# itself needs no input. (Indexed loops throughout: "${arr[@]}" on an empty
# array fails under set -u in bash 3.2.)

# ── Repo selection (only if the repos step is selected) ──────
if step_selected repos.sh; then
  source "$DOTFILES_DIR/config/repos.sh"

  # Read by modules/repos.sh
  REPOS_PICKED=1
  SELECTED_REPOS=()

  if [[ ${#REPOS[@]} -gt 0 ]]; then
    select_items "Select which repos to clone into ~/Development:" "${REPOS[@]}"

    for ((j = 0; j < ${#REPOS[@]}; j++)); do
      if [[ "${SELECTED_ITEMS[$j]}" == "1" ]]; then
        SELECTED_REPOS+=("${REPOS[$j]}")
      fi
    done
  fi
fi

# ── App selection (only if the apps step is selected) ────────
if step_selected apps.sh; then
  source "$DOTFILES_DIR/config/apps.sh"
  cask_count=${#CASK_APPS[@]}
  mas_count=${#MAS_APPS[@]}

  # Indexes 0..cask_count-1 are casks, the rest App Store apps.
  app_labels=()
  for ((j = 0; j < cask_count; j++)); do
    app_labels+=("${CASK_APPS[$j]%%:*}")
  done
  for ((j = 0; j < mas_count; j++)); do
    app_labels+=("${MAS_APPS[$j]%%:*} (App Store)")
  done

  # Read by modules/apps.sh
  APPS_PICKED=1
  SELECTED_CASK_APPS=()
  SELECTED_MAS_APPS=()

  if [[ ${#app_labels[@]} -gt 0 ]]; then
    select_items "Select which apps to install:" "${app_labels[@]}"

    for ((j = 0; j < cask_count; j++)); do
      if [[ "${SELECTED_ITEMS[$j]}" == "1" ]]; then
        SELECTED_CASK_APPS+=("${CASK_APPS[$j]}")
      fi
    done
    for ((j = 0; j < mas_count; j++)); do
      if [[ "${SELECTED_ITEMS[$((cask_count + j))]}" == "1" ]]; then
        SELECTED_MAS_APPS+=("${MAS_APPS[$j]}")
      fi
    done
  fi
fi

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
