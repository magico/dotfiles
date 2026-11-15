#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# config/apps.sh — App lists
#
# Edit these arrays to change which apps are offered. setup.sh shows
# them as a checklist (all ticked) so you can pick what to install.
# Entries are "Name:id" — the name is what the checklist shows.
# ─────────────────────────────────────────────────────────────

# Homebrew Cask apps (GUI apps) — "Name:cask-token"
# Find tokens with: brew search "app name"
CASK_APPS=(
  "SteerMouse:steermouse"
  "iTerm2:iterm2"
  "ChatGPT:chatgpt"
  "Claude:claude"
  "Visual Studio Code:visual-studio-code"
  "Sublime Merge:sublime-merge"
  "CleanShot X:cleanshot"
  "WhatsApp:whatsapp"
  "Google Chrome:google-chrome"
  "Spark:readdle-spark"
)

# Mac App Store apps — "Name:App Store ID"
# Find IDs with: mas search "app name"
# Keynote/Pages/Numbers: since April 2026 the Mac App Store only offers the
# Creator Studio versions, which share the iPhone/iPad app IDs. The old Mac
# IDs (409183694, 409201541, 409203825) no longer resolve.
MAS_APPS=(
  "Keynote:361285480"
  "Pages:361309726"
  "Numbers:361304891"
  "Reeder Classic.:1529448980"
)
