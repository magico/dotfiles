#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# modules/dock.sh — Configure the macOS Dock
# ─────────────────────────────────────────────────────────────

run_module() {
  source "$DOTFILES_DIR/config/dock.sh"

  # ── Install dockutil if needed ─────────────────────────
  if ! command -v dockutil &>/dev/null; then
    task "Installing dockutil..."
    brew install dockutil
    success "dockutil installed"
  fi

  # ── Clear existing Dock items ──────────────────────────
  task "Removing all current Dock items..."
  dockutil --remove all --no-restart
  success "Dock cleared"

  # ── Add items (apps + spacers) ─────────────────────────
  task "Adding items to Dock..."
  for item in "${DOCK_ITEMS[@]}"; do
    case "$item" in
      --spacer)
        dockutil --add '' --type spacer --section apps --no-restart
        success "Added spacer"
        ;;
      --small-spacer)
        dockutil --add '' --type small-spacer --section apps --no-restart
        success "Added small spacer"
        ;;
      *)
        local app_name
        app_name=$(basename "$item" .app)
        if [[ -d "$item" ]]; then
          dockutil --add "$item" --no-restart
          success "Added: ${app_name}"
        else
          warn "Not found: ${item} — skipping"
        fi
        ;;
    esac
  done

  # ── Apply ──────────────────────────────────────────────
  task "Restarting Dock..."
  killall Dock
  success "Dock configured"
}
