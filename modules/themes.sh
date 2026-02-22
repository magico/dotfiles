#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# modules/themes.sh — Download and apply the Dracula theme
# ─────────────────────────────────────────────────────────────

run_module() {
  local themes_dir="$DOTFILES_DIR/.themes"
  mkdir -p "$themes_dir"

  # ── iTerm2 Dracula theme ───────────────────────────────
  task "Downloading Dracula theme for iTerm2..."
  local iterm_theme="$themes_dir/Dracula.itermcolors"

  if [[ -f "$iterm_theme" ]]; then
    success "Dracula.itermcolors already downloaded"
  else
    curl -fsSL \
      "https://raw.githubusercontent.com/dracula/iterm/master/Dracula.itermcolors" \
      -o "$iterm_theme"
    success "Downloaded Dracula.itermcolors"
  fi

  # Import the theme into iTerm2 by opening the .itermcolors file
  # This registers it in iTerm2's color presets
  task "Importing Dracula theme into iTerm2..."
  if [[ -d "/Applications/iTerm.app" ]]; then
    open "$iterm_theme"
    sleep 2
    success "Dracula theme imported into iTerm2"
    info "To activate: iTerm2 → Preferences → Profiles → Colors → Color Presets → Dracula"
  else
    warn "iTerm2 not found — theme downloaded but not imported"
    info "Run this step again after installing iTerm2"
  fi

  # ── VS Code Dracula theme ──────────────────────────────
  task "Installing Dracula theme for VS Code..."

  if command -v code &>/dev/null; then
    if code --list-extensions 2>/dev/null | grep -qi "dracula-theme.theme-dracula"; then
      success "Dracula theme already installed in VS Code"
    else
      code --install-extension dracula-theme.theme-dracula --force
      success "Dracula theme extension installed"
    fi

    # Set Dracula as active theme in VS Code settings
    local vscode_settings_dir="$HOME/Library/Application Support/Code/User"
    local vscode_settings="$vscode_settings_dir/settings.json"
    mkdir -p "$vscode_settings_dir"

    if [[ -f "$vscode_settings" ]]; then
      # Update existing settings — check if workbench.colorTheme is already set
      if grep -q '"workbench.colorTheme"' "$vscode_settings"; then
        # Replace existing theme setting
        sed -i '' 's/"workbench.colorTheme"[[:space:]]*:[[:space:]]*"[^"]*"/"workbench.colorTheme": "Dracula"/' "$vscode_settings"
      else
        # Add theme setting (insert after opening brace)
        sed -i '' 's/^{$/{\n  "workbench.colorTheme": "Dracula",/' "$vscode_settings"
      fi
    else
      # Create new settings file
      cat > "$vscode_settings" << 'EOF'
{
  "workbench.colorTheme": "Dracula"
}
EOF
    fi
    success "Dracula set as active VS Code theme"
  else
    warn "VS Code CLI (code) not found — install VS Code first"
    info "Run this step again after installing VS Code"
  fi
}
