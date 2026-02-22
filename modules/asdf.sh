#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# modules/asdf.sh — Install asdf + Node.js, Python, Ruby
# ─────────────────────────────────────────────────────────────

run_module() {
  # ── Install asdf ─────────────────────────────────────────
  if ! command -v asdf &>/dev/null; then
    task "Installing asdf via Homebrew..."
    brew install asdf

    # Add asdf to current shell
    local asdf_sh
    asdf_sh="$(brew --prefix asdf)/libexec/asdf.sh"
    if [[ -f "$asdf_sh" ]]; then
      source "$asdf_sh"
    fi

    # Persist for future shells
    local zshrc="$HOME/.zshrc"
    if ! grep -q 'asdf.sh' "$zshrc" 2>/dev/null; then
      echo '' >> "$zshrc"
      echo '# asdf version manager' >> "$zshrc"
      echo '. "$(brew --prefix asdf)/libexec/asdf.sh"' >> "$zshrc"
      info "Added asdf to $zshrc"
    fi

    success "asdf installed"
  else
    success "asdf already installed"
  fi

  # ── Languages ────────────────────────────────────────────
  local languages=(nodejs python ruby)

  for lang in "${languages[@]}"; do
    # Add plugin if missing
    if ! asdf plugin list 2>/dev/null | grep -q "^${lang}$"; then
      task "Adding asdf plugin: ${lang}"
      asdf plugin add "$lang"
      success "Plugin added: ${lang}"
    fi

    # Install latest version
    task "Installing latest ${lang}..."
    local latest
    latest=$(asdf latest "$lang")
    if asdf list "$lang" 2>/dev/null | grep -q "$latest"; then
      success "${lang} ${latest} already installed"
    else
      asdf install "$lang" latest
      success "${lang} ${latest} installed"
    fi

    # Set as global default
    asdf global "$lang" "$latest"
    info "${lang} global version set to ${latest}"
  done

  # Add asdf shims to PATH for this session
  export PATH="$HOME/.asdf/shims:$PATH"

  # ── Verify ─────────────────────────────────────────────
  echo ""
  info "Versions now available:"
  info "  Node.js: $(node --version 2>/dev/null || echo 'not found')"
  info "  Python:  $(python3 --version 2>/dev/null || echo 'not found')"
  info "  Ruby:    $(ruby --version 2>/dev/null || echo 'not found')"
}
