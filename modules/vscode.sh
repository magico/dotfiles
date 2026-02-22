#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# modules/vscode.sh — Restore VS Code settings and extensions
# ─────────────────────────────────────────────────────────────

run_module() {
  local vscode_config="$DOTFILES_DIR/config/vscode"
  local vscode_user_dir="$HOME/Library/Application Support/Code/User"

  if ! command -v code &>/dev/null; then
    warn "VS Code CLI (code) not found — install VS Code first"
    return
  fi

  # ── Settings ─────────────────────────────────────────────
  if [[ -f "$vscode_config/settings.json" ]]; then
    task "Restoring VS Code settings..."
    mkdir -p "$vscode_user_dir"
    cp "$vscode_config/settings.json" "$vscode_user_dir/settings.json"
    success "VS Code settings restored"
  fi

  # ── Keybindings ──────────────────────────────────────────
  if [[ -f "$vscode_config/keybindings.json" ]]; then
    task "Restoring VS Code keybindings..."
    cp "$vscode_config/keybindings.json" "$vscode_user_dir/keybindings.json"
    success "VS Code keybindings restored"
  fi

  # ── Extensions ───────────────────────────────────────────
  if [[ -f "$vscode_config/extensions.txt" ]]; then
    task "Installing VS Code extensions..."
    while IFS= read -r ext; do
      [[ -z "$ext" ]] && continue
      if code --list-extensions 2>/dev/null | grep -qi "^${ext}$"; then
        success "${ext} already installed"
      else
        task "Installing ${ext}..."
        if code --install-extension "$ext" --force; then
          success "${ext} installed"
        else
          warn "Failed to install ${ext} — skipping"
        fi
      fi
    done < "$vscode_config/extensions.txt"
  fi
}
