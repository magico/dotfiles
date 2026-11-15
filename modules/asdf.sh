#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# modules/asdf.sh — Install asdf + Node.js, Python, Ruby
# ─────────────────────────────────────────────────────────────

# Newest plain X.Y.Z release of a language. `asdf latest` isn't used because
# it also matches variants such as Python's free-threaded build ("3.15.2t").
asdf_latest_stable() {
  { asdf list all "$1" 2>/dev/null || true; } \
    | awk '$1 ~ /^[0-9]+\.[0-9]+\.[0-9]+$/ { print $1 }' \
    | sort -t. -k1,1n -k2,2n -k3,3n \
    | tail -1
}

run_module() {
  local zshrc="$HOME/.zshrc"
  # shellcheck disable=SC2016  # written to .zshrc unexpanded
  local asdf_path_line='export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"'

  # ── Install asdf ─────────────────────────────────────────
  if ! command -v asdf &>/dev/null; then
    task "Installing asdf via Homebrew..."
    brew install asdf
    success "asdf installed"
  else
    success "asdf already installed"
  fi

  # ── Shell setup ──────────────────────────────────────────
  # asdf 0.16+ is a single binary and no longer ships asdf.sh. All a shell
  # needs is the shims directory on PATH. Replace the old line if an earlier
  # version of this script wrote it.
  if grep -q 'libexec/asdf\.sh' "$zshrc" 2>/dev/null; then
    local tmp
    tmp=$(mktemp)
    awk -v line="$asdf_path_line" '/libexec\/asdf\.sh/ { print line; next } { print }' "$zshrc" > "$tmp"
    cat "$tmp" > "$zshrc"
    rm -f "$tmp"
    info "Replaced outdated asdf.sh line in $zshrc"
  elif ! grep -q 'asdf.*/shims' "$zshrc" 2>/dev/null; then
    {
      echo ''
      echo '# asdf version manager'
      echo "$asdf_path_line"
    } >> "$zshrc"
    info "Added asdf to $zshrc"
  fi
  export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

  # ── Build dependencies ───────────────────────────────────
  # Python and Ruby compile from source. python-build and ruby-build look for
  # openssl@3 (without it python-build compiles its own OpenSSL). xz and zstd
  # provide Python's lzma and zstd modules.
  local deps=(openssl@3 readline libyaml xz zstd)
  task "Installing build dependencies: ${deps[*]}"
  brew install "${deps[@]}" 2>/dev/null
  success "Build dependencies ready"

  # Export flags so ruby-build can find Homebrew libs
  export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@3) --with-libyaml-dir=$(brew --prefix libyaml) --with-readline-dir=$(brew --prefix readline)"

  # ── Languages ────────────────────────────────────────────
  local languages=(nodejs python ruby)
  local lang latest

  for lang in "${languages[@]}"; do
    # Add plugin if missing. (grep without -q so it reads all input: with
    # pipefail, an early exit can fail the pipeline even on a match.)
    if ! asdf plugin list 2>/dev/null | grep -x "$lang" >/dev/null; then
      task "Adding asdf plugin: ${lang}"
      asdf plugin add "$lang"
      success "Plugin added: ${lang}"
    fi

    # Install latest stable version
    task "Installing latest ${lang}..."
    latest=$(asdf_latest_stable "$lang")
    if [[ -z "$latest" ]]; then
      warn "Couldn't determine the latest ${lang} version — skipping"
      continue
    fi
    if asdf list "$lang" 2>/dev/null | tr -d ' *' | grep -xF "$latest" >/dev/null; then
      success "${lang} ${latest} already installed"
    else
      asdf install "$lang" "$latest"
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

  # ── Claude Code ──────────────────────────────────────
  task "Installing Claude Code..."

  # Ensure ~/.local/bin is in PATH (native installer location)
  export PATH="$HOME/.local/bin:$PATH"
  if ! grep -q '\.local/bin' "$zshrc" 2>/dev/null; then
    echo '' >> "$zshrc"
    echo '# Claude Code' >> "$zshrc"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$zshrc"
    info "Added ~/.local/bin to PATH in $zshrc"
  fi

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
