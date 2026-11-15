#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# modules/apps.sh — Install Mac apps via Homebrew Cask + MAS
# ─────────────────────────────────────────────────────────────

run_module() {
  source "$DOTFILES_DIR/config/apps.sh"

  # setup.sh sets SELECTED_*_APPS from the app checklist (and APPS_PICKED).
  # Without it (module run on its own), install everything in config/apps.sh.
  # Indexed loops throughout: "${arr[@]}" on an empty array fails under
  # set -u in macOS bash 3.2, and these lists are empty when nothing is ticked.
  local casks=() mas_apps=() j
  if [[ "${APPS_PICKED:-}" == "1" ]]; then
    for ((j = 0; j < ${#SELECTED_CASK_APPS[@]}; j++)); do casks+=("${SELECTED_CASK_APPS[$j]}"); done
    for ((j = 0; j < ${#SELECTED_MAS_APPS[@]}; j++)); do mas_apps+=("${SELECTED_MAS_APPS[$j]}"); done
  else
    for ((j = 0; j < ${#CASK_APPS[@]}; j++)); do casks+=("${CASK_APPS[$j]}"); done
    for ((j = 0; j < ${#MAS_APPS[@]}; j++)); do mas_apps+=("${MAS_APPS[$j]}"); done
  fi

  if [[ ${#casks[@]} -eq 0 && ${#mas_apps[@]} -eq 0 ]]; then
    skip "No apps selected"
    return 0
  fi

  # ── Homebrew Cask apps ─────────────────────────────────
  if [[ ${#casks[@]} -gt 0 ]]; then
    task "Installing Homebrew Cask apps..."
    for ((j = 0; j < ${#casks[@]}; j++)); do
      local name="${casks[$j]%%:*}"
      local token="${casks[$j]##*:}"

      if brew list --cask "$token" &>/dev/null; then
        success "${name} already installed"
      else
        task "Installing ${name}..."
        if brew install --cask "$token"; then
          success "${name} installed"
        else
          warn "Failed to install ${name} — skipping"
        fi
      fi
    done
  fi

  # ── Mac App Store apps ─────────────────────────────────
  if [[ ${#mas_apps[@]} -gt 0 ]]; then
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
    # List once, quietly: on a fresh Mac Spotlight hasn't indexed /Applications
    # yet and `mas list` prints a long warning on every call.
    local installed_mas
    installed_mas=$(mas list 2>/dev/null || true)

    for ((j = 0; j < ${#mas_apps[@]}; j++)); do
      local name="${mas_apps[$j]%%:*}"
      local id="${mas_apps[$j]##*:}"

      if grep -E "^[[:space:]]*${id}[[:space:]]" <<< "$installed_mas" >/dev/null; then
        success "${name} already installed"
      else
        task "Installing ${name} (ID: ${id})..."
        # `get` also handles free apps this Apple Account hasn't downloaded
        # before; `install` only re-downloads apps already obtained.
        if mas get "$id"; then
          success "${name} installed"
        else
          warn "Failed to install ${name} — check you're signed into the App Store and the ID is current (mas search \"${name}\")"
        fi
      fi
    done
  fi
}
