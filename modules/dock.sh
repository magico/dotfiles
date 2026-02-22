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

  # ── Add apps ───────────────────────────────────────────
  task "Adding apps to Dock..."
  for app_path in "${DOCK_APPS[@]}"; do
    local app_name
    app_name=$(basename "$app_path" .app)

    if [[ -d "$app_path" ]]; then
      dockutil --add "$app_path" --no-restart
      success "Added: ${app_name}"
    else
      warn "Not found: ${app_path} — skipping"
    fi
  done

  # ── Add spacer ─────────────────────────────────────────
  task "Adding spacer..."
  dockutil --add '' --type spacer --section apps --no-restart
  success "Spacer added"

  # ── Add folders ────────────────────────────────────────
  for folder_path in "${DOCK_FOLDERS[@]}"; do
    local folder_name
    folder_name=$(basename "$folder_path")
    folder_path="${folder_path/#\~/$HOME}"

    if [[ -d "$folder_path" ]]; then
      dockutil --add "$folder_path" --view fan --display folder --sort name --no-restart
      success "Added folder: ${folder_name}"
    else
      warn "Folder not found: ${folder_path} — skipping"
    fi
  done

  # ── Apply ──────────────────────────────────────────────
  task "Restarting Dock..."
  killall Dock
  success "Dock configured"
}
