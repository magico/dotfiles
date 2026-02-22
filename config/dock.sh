#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# config/dock.sh — Dock layout
#
# Edit this file to change Dock order.
# Finder and Trash are always present — no need to list them.
#
# Special entries:
#   --spacer        Regular spacer tile
#   --small-spacer  Small spacer tile
# ─────────────────────────────────────────────────────────────

DOCK_ITEMS=(
  "/Applications/Safari.app"
  "/System/Applications/Mail.app"
  "/System/Applications/Calendar.app"
  "/System/Applications/Reminders.app"
  "/System/Applications/Notes.app"
  "--small-spacer"
  "/System/Applications/Messages.app"
  "/Applications/WhatsApp.app"
  "/System/Applications/Music.app"
  "--small-spacer"
  "/Applications/iTerm.app"
  "/Applications/Claude.app"
  "/Applications/Visual Studio Code.app"
  "/Applications/Sublime Merge.app"
  "/Applications/Google Chrome.app"
)

# Folders added to the right side of Dock (shown as stacks, next to Trash)
DOCK_FOLDERS=(
  "$HOME/Downloads"
)
