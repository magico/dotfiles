#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# config/dock.sh — Dock layout
#
# Edit this file to change Dock order.
# Finder and Trash are always present — no need to list them.
# ─────────────────────────────────────────────────────────────

DOCK_APPS=(
  "/Applications/Safari.app"
  "/System/Applications/Mail.app"
  "/System/Applications/Calendar.app"
  "/System/Applications/Messages.app"
  "/System/Applications/Reminders.app"
  "/System/Applications/Notes.app"
  "/Applications/Claude.app"
  "/System/Applications/Music.app"
  "/Applications/iTerm.app"
  "/Applications/Visual Studio Code.app"
  "/Applications/Sublime Merge.app"
)

# Folders to add after a spacer (shown as stacks on the right side of Dock)
DOCK_FOLDERS=(
  "$HOME/Downloads"
)
