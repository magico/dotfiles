#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# config/macos.sh — macOS system preferences
#
# Add your `defaults write` commands here.
# These will be applied by modules/macos.sh
#
# Uncomment any you want, or add your own.
# ─────────────────────────────────────────────────────────────

apply_macos_settings() {
  # ── Placeholder ──────────────────────────────────────────
  # The user will provide their preferred settings.
  # Below are common examples you can uncomment and customize.

  : # no-op — remove this line once you add real settings

  # ── Keyboard ───────────────────────────────────────────
  # defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
  # defaults write NSGlobalDomain KeyRepeat -int 2
  # defaults write NSGlobalDomain InitialKeyRepeat -int 15

  # ── Trackpad ───────────────────────────────────────────
  # defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
  # defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

  # ── Finder ─────────────────────────────────────────────
  # defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  # defaults write com.apple.finder AppleShowAllFiles -bool true
  # defaults write com.apple.finder ShowPathbar -bool true
  # defaults write com.apple.finder ShowStatusBar -bool true
  # defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
  # defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

  # ── Dock ───────────────────────────────────────────────
  # defaults write com.apple.dock autohide -bool true
  # defaults write com.apple.dock autohide-delay -float 0
  # defaults write com.apple.dock tilesize -int 48
  # defaults write com.apple.dock show-recents -bool false

  # ── Screenshots ────────────────────────────────────────
  # defaults write com.apple.screencapture location -string "$HOME/Desktop/Screenshots"
  # defaults write com.apple.screencapture type -string "png"
  # defaults write com.apple.screencapture disable-shadow -bool true

  # ── Safari ─────────────────────────────────────────────
  # defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true
  # defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

  # ── Misc ───────────────────────────────────────────────
  # defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
  # defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
}

# List of processes to restart after applying settings.
# Add to this list if your settings affect other apps.
MACOS_RESTART_PROCESSES=(
  # "Finder"
  # "Dock"
  # "SystemUIServer"
)
