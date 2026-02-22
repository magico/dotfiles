#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# modules/apps.sh — Install Mac apps via Homebrew Cask + MAS
# ─────────────────────────────────────────────────────────────

run_module() {
  source "$DOTFILES_DIR/config/apps.sh"

  # ── Homebrew Cask apps ─────────────────────────────────
  task "Installing Homebrew Cask apps..."
  for app in "${CASK_APPS[@]}"; do
    if brew list --cask "$app" &>/dev/null; then
      success "${app} already installed"
    else
      task "Installing ${app}..."
      if brew install --cask "$app"; then
        success "${app} installed"
      else
        warn "Failed to install ${app} — skipping"
      fi
    fi
  done

  # ── Mac App Store apps ─────────────────────────────────
  if [[ ${#MAS_APPS[@]} -gt 0 ]]; then
    # Install mas CLI if needed
    if ! command -v mas &>/dev/null; then
      task "Installing mas (Mac App Store CLI)..."
      brew install mas
      success "mas installed"
    fi

    # Check if signed in
    # On newer macOS, mas account may not work, but installs still do
    # if the user is signed into the App Store app.
    info "Mac App Store apps require you to be signed into the App Store."
    echo ""

    task "Installing Mac App Store apps..."
    for entry in "${MAS_APPS[@]}"; do
      local name="${entry%%:*}"
      local id="${entry##*:}"

      if mas list | grep -q "^${id} "; then
        success "${name} already installed"
      else
        task "Installing ${name} (ID: ${id})..."
        if mas install "$id"; then
          success "${name} installed"
        else
          warn "Failed to install ${name} — make sure you're signed into the App Store"
        fi
      fi
    done
  fi
}
