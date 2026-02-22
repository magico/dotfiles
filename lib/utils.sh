#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# utils.sh — Colorful UI toolkit for the dotfiles installer
# ─────────────────────────────────────────────────────────────

# ── Colors ───────────────────────────────────────────────────
BOLD='\033[1m'
DIM='\033[2m'
ITALIC='\033[3m'
RESET='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD_CYAN='\033[1;36m'
BOLD_GREEN='\033[1;32m'
BOLD_RED='\033[1;31m'
BOLD_YELLOW='\033[1;33m'
BOLD_MAGENTA='\033[1;35m'
BOLD_BLUE='\033[1;34m'
BG_CYAN='\033[46m'
BG_MAGENTA='\033[45m'

# ── State ────────────────────────────────────────────────────
STEP_COUNT=0
TOTAL_STEPS=0

set_total_steps() {
  TOTAL_STEPS=$1
}

# ── Output helpers ───────────────────────────────────────────

banner() {
  echo ""
  echo -e "${BOLD_CYAN}  ┌─────────────────────────────────────────────┐${RESET}"
  echo -e "${BOLD_CYAN}  │${RESET}${BOLD}  ✦ Mac Setup                                ${RESET}${BOLD_CYAN}│${RESET}"
  echo -e "${BOLD_CYAN}  │${RESET}${DIM}  Interactive dotfiles installer              ${RESET}${BOLD_CYAN}│${RESET}"
  echo -e "${BOLD_CYAN}  └─────────────────────────────────────────────┘${RESET}"
  echo ""
}

step() {
  STEP_COUNT=$((STEP_COUNT + 1))
  echo ""
  echo -e "${BOLD_MAGENTA}  ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄${RESET}"
  echo -e "${BOLD_MAGENTA}  ► Step ${STEP_COUNT}/${TOTAL_STEPS}: ${1}${RESET}"
  echo -e "${BOLD_MAGENTA}  ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄${RESET}"
  echo ""
}

info() {
  echo -e "  ${BOLD_BLUE}ℹ${RESET} ${1}"
}

success() {
  echo -e "  ${BOLD_GREEN}✓${RESET} ${1}"
}

warn() {
  echo -e "  ${BOLD_YELLOW}⚠${RESET} ${1}"
}

error() {
  echo -e "  ${BOLD_RED}✗${RESET} ${1}"
}

skip() {
  echo -e "  ${DIM}↷ Skipped: ${1}${RESET}"
}

task() {
  echo -e "  ${CYAN}→${RESET} ${1}"
}

# ── Prompts ──────────────────────────────────────────────────

ask_yes_no() {
  local prompt="$1"
  local default="${2:-y}"
  local hint
  if [[ "$default" == "y" ]]; then
    hint="Y/n"
  else
    hint="y/N"
  fi
  echo -ne "  ${BOLD_CYAN}?${RESET} ${prompt} ${DIM}[${hint}]${RESET} "
  read -r answer
  answer="${answer:-$default}"
  [[ "$answer" =~ ^[Yy] ]]
}

# Print a numbered list and let user toggle items on/off.
# Usage: select_modules "label1" "label2" ...
# Sets SELECTED_MODULES array (0-indexed, matching input order) to 1 or 0.
select_modules() {
  local labels=("$@")
  local count=${#labels[@]}
  SELECTED_MODULES=()

  # Default: all selected
  for ((i = 0; i < count; i++)); do
    SELECTED_MODULES[$i]=1
  done

  echo -e "  ${BOLD}Select which steps to run:${RESET}"
  echo ""
  for ((i = 0; i < count; i++)); do
    local num=$((i + 1))
    echo -e "    ${BOLD_CYAN}${num}.${RESET} ${labels[$i]}"
  done
  echo ""
  echo -e "  ${DIM}Enter step numbers to toggle off, separated by spaces.${RESET}"
  echo -e "  ${DIM}Press Enter to run all.${RESET}"
  echo ""
  echo -ne "  ${BOLD_CYAN}?${RESET} Skip steps: "
  read -r skip_input

  if [[ -n "$skip_input" ]]; then
    for num in $skip_input; do
      local idx=$((num - 1))
      if [[ $idx -ge 0 && $idx -lt $count ]]; then
        SELECTED_MODULES[$idx]=0
      fi
    done
  fi

  # Print summary
  echo ""
  for ((i = 0; i < count; i++)); do
    if [[ "${SELECTED_MODULES[$i]}" == "1" ]]; then
      echo -e "    ${BOLD_GREEN}✓${RESET} ${labels[$i]}"
    else
      echo -e "    ${DIM}○ ${labels[$i]}${RESET}"
    fi
  done
  echo ""
}

# ── Progress ─────────────────────────────────────────────────

start_spinner() {
  local msg="$1"
  local spin_chars='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  SPINNER_MSG="$msg"
  (
    while true; do
      for ((i = 0; i < ${#spin_chars}; i++)); do
        echo -ne "\r  ${CYAN}${spin_chars:$i:1}${RESET} ${msg}"
        sleep 0.08
      done
    done
  ) &
  SPINNER_PID=$!
  disown "$SPINNER_PID" 2>/dev/null
}

stop_spinner() {
  local result="$1" # "success" or "error"
  if [[ -n "$SPINNER_PID" ]]; then
    kill "$SPINNER_PID" 2>/dev/null
    wait "$SPINNER_PID" 2>/dev/null
    SPINNER_PID=""
  fi
  echo -ne "\r\033[K" # clear line
  if [[ "$result" == "success" ]]; then
    success "$SPINNER_MSG"
  elif [[ "$result" == "error" ]]; then
    error "$SPINNER_MSG"
  fi
}

# Run a command with a spinner. Captures output to a temp file.
# Usage: run_with_spinner "message" command arg1 arg2 ...
run_with_spinner() {
  local msg="$1"
  shift
  local tmpfile
  tmpfile=$(mktemp)

  start_spinner "$msg"
  if "$@" > "$tmpfile" 2>&1; then
    stop_spinner "success"
    rm -f "$tmpfile"
    return 0
  else
    stop_spinner "error"
    echo -e "  ${DIM}$(cat "$tmpfile")${RESET}" | tail -5
    rm -f "$tmpfile"
    return 1
  fi
}

# ── Summary ──────────────────────────────────────────────────

print_summary() {
  echo ""
  echo -e "${BOLD_CYAN}  ┌─────────────────────────────────────────────┐${RESET}"
  echo -e "${BOLD_CYAN}  │${RESET}${BOLD}  ✦ Setup Complete!                           ${RESET}${BOLD_CYAN}│${RESET}"
  echo -e "${BOLD_CYAN}  └─────────────────────────────────────────────┘${RESET}"
  echo ""
  echo -e "  ${DIM}All tools are available in this shell session.${RESET}"
  echo -e "  ${DIM}Open a new terminal and everything will still work.${RESET}"
  echo ""
}
