#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# modules/steermouse.sh — Restore SteerMouse settings
# ─────────────────────────────────────────────────────────────

run_module() {
  local steermouse_config="$DOTFILES_DIR/config/steermouse"

  if [[ ! -d "$steermouse_config" ]]; then
    warn "SteerMouse config not found in $steermouse_config — skipping"
    return
  fi

  task "Restoring SteerMouse preferences..."

  for plist in "$steermouse_config"/*.plist; do
    local filename
    filename="$(basename "$plist")"
    # Import through cfprefsd: copying the file straight into
    # ~/Library/Preferences can be overwritten by cached preferences.
    defaults import "${filename%.plist}" "$plist"
    success "Restored $filename"
  done

  info "SteerMouse settings restored — restart SteerMouse to apply"
}
