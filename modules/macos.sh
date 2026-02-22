#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# modules/macos.sh — Apply macOS system settings
# ─────────────────────────────────────────────────────────────

run_module() {
  source "$DOTFILES_DIR/config/macos.sh"

  # ── Computer name ──────────────────────────────────────
  task "Setting computer name..."

  local current_name
  current_name=$(scutil --get ComputerName 2>/dev/null || true)

  if [[ -n "$current_name" ]]; then
    echo -ne "  ${BOLD_CYAN}?${RESET} Computer name ${DIM}[${current_name}]${RESET}: "
  else
    echo -ne "  ${BOLD_CYAN}?${RESET} Computer name: "
  fi
  read -r computer_name
  computer_name="${computer_name:-$current_name}"

  if [[ -n "$computer_name" ]]; then
    sudo scutil --set ComputerName "$computer_name"
    sudo scutil --set HostName "$computer_name"
    sudo scutil --set LocalHostName "$computer_name"
    sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$computer_name"
    success "Computer name set to: $computer_name"
  else
    skip "Computer name (no value provided)"
  fi

  # ── System defaults ────────────────────────────────────
  task "Applying macOS settings..."

  # Run the settings function from config/macos.sh
  apply_macos_settings

  # Restart affected processes
  if [[ ${#MACOS_RESTART_PROCESSES[@]} -gt 0 ]]; then
    task "Restarting affected processes..."
    for process in "${MACOS_RESTART_PROCESSES[@]}"; do
      if killall "$process" 2>/dev/null; then
        success "Restarted: ${process}"
      fi
    done
  fi

  info "macOS settings applied"
}
