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
    success "Computer name set to: $computer_name"

    # Host names only allow letters, digits and hyphens (scutil rejects
    # anything else), so "Magico's Mac Studio" becomes "Magicos-Mac-Studio",
    # the same conversion macOS does itself.
    local host_name
    host_name=$(printf '%s' "$computer_name" | tr -s ' ' '-' | LC_ALL=C tr -cd 'A-Za-z0-9-' | sed 's/^-*//; s/-*$//')
    if [[ -n "$host_name" ]]; then
      sudo scutil --set HostName "$host_name"
      sudo scutil --set LocalHostName "$host_name"
      # NetBIOS names are limited to 15 characters
      sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "${host_name:0:15}"
      success "Host name set to: $host_name"
    else
      warn "Couldn't derive a valid host name from \"$computer_name\" — host name unchanged"
    fi
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
