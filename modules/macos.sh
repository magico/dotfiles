#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# modules/macos.sh — Apply macOS system settings
# ─────────────────────────────────────────────────────────────

run_module() {
  source "$DOTFILES_DIR/config/macos.sh"

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
  info "Edit config/macos.sh to add your preferred settings"
}
