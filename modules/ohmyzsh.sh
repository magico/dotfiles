#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# modules/ohmyzsh.sh — Install Oh My Zsh
# ─────────────────────────────────────────────────────────────

run_module() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    success "Oh My Zsh already installed"
    return 0
  fi

  task "Installing Oh My Zsh..."

  # --unattended: don't change shell, don't launch zsh
  # --keep-zshrc: don't overwrite existing .zshrc (if any)
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" \
    --unattended

  success "Oh My Zsh installed"

  # Clear ZSH_THEME so it doesn't conflict with spaceship-prompt
  local zshrc="$HOME/.zshrc"
  if grep -q '^ZSH_THEME=' "$zshrc" 2>/dev/null; then
    sed -i '' 's/^ZSH_THEME=.*/ZSH_THEME=""/' "$zshrc"
    info "Cleared ZSH_THEME in .zshrc (spaceship-prompt will be used instead)"
  fi
}
