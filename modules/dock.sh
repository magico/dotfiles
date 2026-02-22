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

  # ── Add folders ────────────────────────────────────────
  if [[ ${#DOCK_FOLDERS[@]} -gt 0 ]]; then
    for folder_path in "${DOCK_FOLDERS[@]}"; do
      local folder_name
      folder_name=$(basename "$folder_path")
      if [[ -d "$folder_path" ]]; then
        dockutil --add "$folder_path" --view fan --display folder --sort name --no-restart
        success "Added folder: ${folder_name}"
      else
        warn "Folder not found: ${folder_path} — skipping"
      fi
    done
  fi

  # ── Apply ──────────────────────────────────────────────
  task "Restarting Dock..."
  killall Dock
  success "Dock configured"
}
