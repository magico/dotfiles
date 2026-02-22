#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# modules/xcode.sh — Install Xcode Command Line Tools
# ─────────────────────────────────────────────────────────────

run_module() {
  if xcode-select -p &>/dev/null; then
    success "Xcode Command Line Tools already installed"
    return 0
  fi

  task "Installing Xcode Command Line Tools..."
  info "A system dialog may appear — click \"Install\" when prompted."

  # Trigger the install prompt
  xcode-select --install 2>/dev/null || true

  # Wait for the installation to complete
  info "Waiting for installation to finish..."
  until xcode-select -p &>/dev/null; do
    sleep 5
  done

  success "Xcode Command Line Tools installed"
}
