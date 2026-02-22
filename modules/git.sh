#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# modules/git.sh — Configure Git identity + SSH key for GitHub
# ─────────────────────────────────────────────────────────────

run_module() {
  # ── Git identity ────────────────────────────────────────
  local current_name current_email

  current_name=$(git config --global user.name 2>/dev/null || true)
  current_email=$(git config --global user.email 2>/dev/null || true)

  task "Configuring Git identity..."

  # Prompt for name (show current value as default)
  if [[ -n "$current_name" ]]; then
    echo -ne "  ${BOLD_CYAN}?${RESET} Git name ${DIM}[${current_name}]${RESET}: "
  else
    echo -ne "  ${BOLD_CYAN}?${RESET} Git name: "
  fi
  read -r git_name
  git_name="${git_name:-$current_name}"

  if [[ -z "$git_name" ]]; then
    error "Git name cannot be empty"
    return 1
  fi

  # Prompt for email
  if [[ -n "$current_email" ]]; then
    echo -ne "  ${BOLD_CYAN}?${RESET} Git email ${DIM}[${current_email}]${RESET}: "
  else
    echo -ne "  ${BOLD_CYAN}?${RESET} Git email: "
  fi
  read -r git_email
  git_email="${git_email:-$current_email}"

  if [[ -z "$git_email" ]]; then
    error "Git email cannot be empty"
    return 1
  fi

  git config --global user.name "$git_name"
  git config --global user.email "$git_email"
  success "Git identity: $git_name <$git_email>"

  # ── SSH key for GitHub ──────────────────────────────────
  task "Setting up SSH key for GitHub..."

  local ssh_key="$HOME/.ssh/id_ed25519"

  if [[ -f "$ssh_key" ]]; then
    success "SSH key already exists: $ssh_key"
  else
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    ssh-keygen -t ed25519 -C "$git_email" -f "$ssh_key" -N ""
    success "SSH key generated: $ssh_key"
  fi

  # Start ssh-agent and add key
  eval "$(ssh-agent -s)" > /dev/null 2>&1

  # Configure SSH to auto-load the key
  local ssh_config="$HOME/.ssh/config"
  if ! grep -q "IdentityFile.*id_ed25519" "$ssh_config" 2>/dev/null; then
    cat >> "$ssh_config" << 'EOF'

Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
EOF
    chmod 600 "$ssh_config"
    info "Added GitHub entry to ~/.ssh/config"
  fi

  ssh-add --apple-use-keychain "$ssh_key" 2>/dev/null || ssh-add "$ssh_key" 2>/dev/null

  # ── Install GitHub CLI ──────────────────────────────────
  if ! command -v gh &>/dev/null; then
    task "Installing GitHub CLI..."
    brew install gh
    success "GitHub CLI installed"
  else
    success "GitHub CLI already installed"
  fi

  # ── Authenticate with GitHub ───────────────────────────
  if ! gh auth status &>/dev/null 2>&1; then
    task "Authenticating with GitHub..."
    info "A browser window will open — sign in to GitHub and authorize the CLI."
    echo ""
    gh auth login --git-protocol ssh --web
    success "GitHub CLI authenticated"
  else
    success "GitHub CLI already authenticated"
  fi

  # ── Upload SSH key to GitHub ───────────────────────────
  task "Adding SSH key to GitHub..."
  local key_title="Mac Setup $(hostname -s) $(date +%Y-%m-%d)"
  if gh ssh-key list 2>/dev/null | grep -q "$(cat "${ssh_key}.pub" | awk '{print $2}')"; then
    success "SSH key already registered on GitHub"
  else
    gh ssh-key add "${ssh_key}.pub" --title "$key_title"
    success "SSH key added to GitHub: $key_title"
  fi

  # ── Configure Git to use SSH for GitHub ─────────────────
  git config --global url."git@github.com:".insteadOf "https://github.com/"
  success "Git configured to use SSH for GitHub repos"
}
