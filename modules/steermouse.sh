#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# modules/steermouse.sh — Restore SteerMouse settings
# ─────────────────────────────────────────────────────────────

run_module() {
  local steermouse_config="$DOTFILES_DIR/config/steermouse"
  local prefs_dir="$HOME/Library/Preferences"

  if [[ ! -d "$steermouse_config" ]]; then
    warn "SteerMouse config not found in $steermouse_config — skipping"
    return
  fi

  task "Restoring SteerMouse preferences..."

  for plist in "$steermouse_config"/*.plist; do
    local filename
    filename="$(basename "$plist")"
    cp "$plist" "$prefs_dir/$filename"
    success "Restored $filename"
  done

  info "SteerMouse settings restored — restart SteerMouse to apply"
}
