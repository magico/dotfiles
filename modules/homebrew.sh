#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# modules/homebrew.sh — Install Homebrew
# ─────────────────────────────────────────────────────────────

run_module() {
  if command -v brew &>/dev/null; then
    success "Homebrew already installed"
    task "Updating Homebrew..."
    brew update --quiet
    success "Homebrew updated"
    return 0
  fi

  task "Installing Homebrew..."

  # Install Homebrew (non-interactive)
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add Homebrew to PATH for this session
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  # Persist for future shells
  local shell_profile="$HOME/.zprofile"
  if ! grep -q 'brew shellenv' "$shell_profile" 2>/dev/null; then
    echo '' >> "$shell_profile"
    echo '# Homebrew' >> "$shell_profile"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$shell_profile"
    info "Added Homebrew to $shell_profile"
  fi

  # Turn off analytics
  brew analytics off 2>/dev/null

  success "Homebrew installed"
}
