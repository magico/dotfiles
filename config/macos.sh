#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# config/macos.sh — macOS system preferences
#
# These will be applied by modules/macos.sh
# ─────────────────────────────────────────────────────────────

apply_macos_settings() {

  # ── Dock ───────────────────────────────────────────────
  # Auto-hide the Dock
  defaults write com.apple.dock autohide -bool true

  # ── Desktop & Widgets ──────────────────────────────────
  # Disable widgets on desktop (macOS Sonoma+)
  defaults write com.apple.WindowManager StandardHideWidgets -bool true
  defaults write com.apple.WindowManager StageManagerHideWidgets -bool true

  # ── Hot Corners ────────────────────────────────────────
  # Values: 0=none, 2=Mission Control, 3=App Windows,
  #         4=Desktop, 5=Screen Saver On, 6=Screen Saver Off,
  #         10=Display Sleep, 11=Launchpad, 12=Notification Center,
  #         13=Lock Screen, 14=Quick Note

  # Bottom left → Mission Control
  defaults write com.apple.dock wvous-bl-corner -int 2
  defaults write com.apple.dock wvous-bl-modifier -int 0

  # Top right → Desktop
  defaults write com.apple.dock wvous-tr-corner -int 4
  defaults write com.apple.dock wvous-tr-modifier -int 0

  # ── Finder ────────────────────────────────────────────
  # Show all filename extensions
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true

  # ── Safari ───────────────────────────────────────────
  # Show features for Web Developers
  defaults write com.apple.Safari IncludeDevelopMenu -bool true
  defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

  # Show full website address in Smart Search field
  defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

  # ── Scrolling ──────────────────────────────────────────
  # Turn off natural scrolling
  defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
}

# List of processes to restart after applying settings.
MACOS_RESTART_PROCESSES=(
  "Dock"
  "Finder"
  "Safari"
)
