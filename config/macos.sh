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

  # Bottom left → Desktop
  defaults write com.apple.dock wvous-bl-corner -int 4
  defaults write com.apple.dock wvous-bl-modifier -int 0

  # Top right → Mission Control
  defaults write com.apple.dock wvous-tr-corner -int 2
  defaults write com.apple.dock wvous-tr-modifier -int 0

  # Top left and bottom right → nothing (set explicitly to clear any existing action)
  defaults write com.apple.dock wvous-tl-corner -int 0
  defaults write com.apple.dock wvous-tl-modifier -int 0
  defaults write com.apple.dock wvous-br-corner -int 0
  defaults write com.apple.dock wvous-br-modifier -int 0

  # ── Finder ────────────────────────────────────────────
  # Show all filename extensions
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true

  # Toolbar: Back/Forward, View, space, New Folder, Get Info, Action, space,
  # Search; icons only. Copied from the Mac Studio with:
  #   defaults read com.apple.finder "NSToolbar Configuration Browser"
  # Written as XML so the numbers stay numbers (the old-style format that
  # `defaults read` prints would store them as strings).
  defaults write com.apple.finder "NSToolbar Configuration Browser" '<dict>
    <key>TB Default Item Identifiers</key>
    <array>
      <string>com.apple.finder.BACK</string>
      <string>com.apple.finder.SWCH</string>
      <string>NSToolbarSpaceItem</string>
      <string>com.apple.finder.ARNG</string>
      <string>NSToolbarSpaceItem</string>
      <string>com.apple.finder.SHAR</string>
      <string>com.apple.finder.LABL</string>
      <string>com.apple.finder.ACTN</string>
      <string>NSToolbarSpaceItem</string>
      <string>com.apple.finder.SRCH</string>
      <string>com.apple.finder.SIRI</string>
    </array>
    <key>TB Display Mode</key>
    <integer>2</integer>
    <key>TB Icon Size Mode</key>
    <integer>1</integer>
    <key>TB Is Shown</key>
    <integer>1</integer>
    <key>TB Item Identifiers</key>
    <array>
      <string>com.apple.finder.BACK</string>
      <string>com.apple.finder.SWCH</string>
      <string>NSToolbarSpaceItem</string>
      <string>com.apple.finder.NFLD</string>
      <string>com.apple.finder.INFO</string>
      <string>com.apple.finder.ACTN</string>
      <string>NSToolbarSpaceItem</string>
      <string>com.apple.finder.SRCH</string>
    </array>
    <key>TB Size Mode</key>
    <integer>1</integer>
  </dict>'

  # Sidebar: the Favorites list and the Locations checkboxes live in binary
  # files `defaults` can't edit. Apple removed `sfltool add-item` in macOS
  # 10.13 and the mysides tool is no longer in Homebrew, so these stay manual.
  info "Finder sidebar is set by hand:"
  info "  • Drag ~/Development into Favorites, below Desktop"
  info "  • Finder → Settings → Sidebar: tick your home folder and hard disks"

  # ── Menu bar ───────────────────────────────────────────
  # Which Control Center items show in the menu bar. Copied from the Mac
  # Studio with `defaults -currentHost read com.apple.controlcenter`; items
  # not listed keep the macOS default.
  defaults -currentHost write com.apple.controlcenter Bluetooth -int 2
  defaults -currentHost write com.apple.controlcenter NowPlaying -int 16
  defaults -currentHost write com.apple.controlcenter Siri -int 8
  defaults -currentHost write com.apple.controlcenter Sound -int 16
  defaults -currentHost write com.apple.controlcenter UserSwitcher -int 18

  # ── Safari ───────────────────────────────────────────
  # Safari prefs are sandboxed; writing requires Full Disk Access for the
  # terminal. Without it `defaults write` fails, so try one write first and
  # skip the rest (rather than letting the failure abort the installer).
  local safari_plist=~/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari
  if defaults write "$safari_plist" IncludeDevelopMenu -bool true 2>/dev/null; then
    # Show features for Web Developers
    defaults write "$safari_plist" WebKitDeveloperExtrasEnabledPreferenceKey -bool true
    defaults write "$safari_plist" com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

    # Show full website address in Smart Search field
    defaults write "$safari_plist" ShowFullURLInSmartSearchField -bool true
  else
    warn "Skipped Safari settings — your terminal needs Full Disk Access to change them"
    info "System Settings → Privacy & Security → Full Disk Access, then re-run this step"
  fi

  # ── Scrolling ──────────────────────────────────────────
  # Turn off natural scrolling
  defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
}

# List of processes to restart after applying settings.
MACOS_RESTART_PROCESSES=(
  "Dock"
  "Finder"
  "ControlCenter"
  "Safari"
)
