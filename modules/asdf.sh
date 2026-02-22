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

  # ── Build dependencies ───────────────────────────────────
  # Ruby compiles from source and needs these libraries
  local deps=(openssl readline libyaml)
  task "Installing build dependencies: ${deps[*]}"
  brew install "${deps[@]}" 2>/dev/null
  success "Build dependencies ready"

  # Export flags so ruby-build can find Homebrew libs
  export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl) --with-libyaml-dir=$(brew --prefix libyaml) --with-readline-dir=$(brew --prefix readline)"

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

    # Set as global default (asdf 0.18+ uses "set", older uses "global")
    if asdf set --help &>/dev/null 2>&1; then
      asdf set --home "$lang" "$latest"
    else
      asdf global "$lang" "$latest"
    fi
    info "${lang} global version set to ${latest}"
  done

  # Add asdf shims to PATH for this session
  export PATH="$HOME/.asdf/shims:$PATH"

  # ── Claude Code ──────────────────────────────────────
  task "Installing Claude Code..."
  if command -v claude &>/dev/null; then
    success "Claude Code already installed"
  else
    curl -fsSL https://claude.ai/install.sh | bash
    success "Claude Code installed"
  fi

  # ── Verify ─────────────────────────────────────────────
  echo ""
  info "Versions now available:"
  info "  Node.js: $(node --version 2>/dev/null || echo 'not found')"
  info "  Python:  $(python3 --version 2>/dev/null || echo 'not found')"
  info "  Ruby:    $(ruby --version 2>/dev/null || echo 'not found')"
  info "  Claude:  $(claude --version 2>/dev/null || echo 'not found')"
}
