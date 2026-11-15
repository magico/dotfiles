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

  # A running iTerm2 (e.g. opened by the theme step) keeps its current settings
  # in memory and, once pointed at the custom folder, offers to copy them over
  # the dotfiles plist when it quits. Quit it first so it loads ours on launch.
  if pgrep -x iTerm2 >/dev/null; then
    if [[ "${TERM_PROGRAM:-}" == "iTerm.app" ]]; then
      warn "iTerm2 is running this installer — restart iTerm2 afterwards to load the dotfiles settings"
      info "If iTerm2 offers to copy its current settings to the dotfiles folder when quitting, decline"
    else
      task "Quitting iTerm2 so it picks up the new settings on next launch..."
      killall iTerm2 2>/dev/null || true
      local i
      for i in 1 2 3 4 5 6 7 8 9 10; do
        pgrep -x iTerm2 >/dev/null || break
        sleep 1
      done
    fi
  fi

  task "Configuring iTerm2 to load preferences from dotfiles..."

  # Tell iTerm2 to load settings from our dotfiles folder
  defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$iterm_config"
  defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true

  success "iTerm2 will load preferences from $iterm_config"
  info "Changes you make in iTerm2 Settings will be saved back to this folder"
}
