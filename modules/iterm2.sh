#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# modules/iterm2.sh — Load iTerm2 settings from dotfiles
# ─────────────────────────────────────────────────────────────

run_module() {
  local iterm_config="$DOTFILES_DIR/config/iterm2"

  if [[ ! -f "$iterm_config/com.googlecode.iterm2.plist" ]]; then
    warn "iTerm2 plist not found in $iterm_config — skipping"
    return
  fi

  task "Configuring iTerm2 to load preferences from dotfiles..."

  # Tell iTerm2 to load settings from our dotfiles folder
  defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$iterm_config"
  defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true

  success "iTerm2 will load preferences from $iterm_config"
  info "Changes you make in iTerm2 Settings will be saved back to this folder"
}
