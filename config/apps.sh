#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# config/apps.sh — App lists
#
# Edit these arrays to change which apps get installed.
# ─────────────────────────────────────────────────────────────

# Homebrew Cask apps (GUI apps)
CASK_APPS=(
  steer-mouse
  iterm2
  claude
  visual-studio-code
  sublime-merge
  cleanshot
)

# Mac App Store apps — "Name:ID" format
# Find IDs with: mas search "app name"
MAS_APPS=(
  "Keynote:409183694"
  "Pages:409201541"
  "Numbers:409203825"
  "Reeder.:1529445840"
  "Reeder 4:1529448980"
)
