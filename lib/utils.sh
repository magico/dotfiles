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

# Interactive checkbox selector for module selection.
# Usage: select_modules "label1" "label2" ...
# Sets SELECTED_MODULES array (0-indexed, matching input order) to 1 or 0.
select_modules() {
  local labels=("$@")
  local count=${#labels[@]}
  local cursor=0
  local selected=()
  SELECTED_MODULES=()

  # All items start checked
  for ((i = 0; i < count; i++)); do
    selected[$i]=1
  done

  # ── Draw the interactive menu ──────────────────────────────
  # Layout: header, blank, N items, blank, submit, blank, hint = N+6 lines
  local total_lines=$((count + 6))
  _sm_draw() {
    if [[ "${1:-}" == "redraw" ]]; then
      printf '\033[%dA' "$total_lines"
    fi
    printf '\033[K'
    echo -e "  ${BOLD}Select which steps to run:${RESET}"
    printf '\033[K\n'
    local idx mark
    for ((idx = 0; idx < count; idx++)); do
      if [[ "${selected[$idx]}" == "1" ]]; then
        mark="[✓]"
      else
        mark="[ ]"
      fi
      printf '\033[K'
      if [[ $idx -eq $cursor ]]; then
        echo -e "  ${BOLD_CYAN}› ${mark} ${labels[$idx]}${RESET}"
      elif [[ "${selected[$idx]}" == "1" ]]; then
        echo -e "    ${mark} ${labels[$idx]}"
      else
        echo -e "    ${DIM}${mark} ${labels[$idx]}${RESET}"
      fi
    done
    printf '\033[K\n'
    printf '\033[K'
    if [[ $cursor -eq $count ]]; then
      echo -e "  ${BOLD_CYAN}› ⏎ Submit${RESET}"
    else
      echo -e "    ${DIM}⏎ Submit${RESET}"
    fi
    printf '\033[K\n'
    printf '\033[K'
    echo -e "  ${DIM}↑/↓ navigate  ⏎ select  a all  n none${RESET}"
  }

  # ── Terminal state ─────────────────────────────────────────
  local old_stty
  old_stty=$(stty -g </dev/tty)

  _sm_cleanup() {
    stty "$old_stty" </dev/tty 2>/dev/null
    printf '\033[?25h'
  }
  trap '_sm_cleanup; exit 1' INT TERM

  printf '\033[?25l'  # hide cursor
  _sm_draw

  # ── Input loop ─────────────────────────────────────────────
  while true; do
    local key="" seq1="" seq2=""
    IFS= read -rsn1 key </dev/tty

    # Arrow keys send escape sequences: \033[A (up), \033[B (down)
    if [[ "$key" == $'\033' ]]; then
      IFS= read -rsn1 -t 1 seq1 </dev/tty 2>/dev/null || true
      IFS= read -rsn1 -t 1 seq2 </dev/tty 2>/dev/null || true
      key+="${seq1}${seq2}"
    fi

    local total=$((count + 1))  # items + submit
    case "$key" in
      $'\033[A' | k)  cursor=$(( (cursor - 1 + total) % total )) ;;
      $'\033[B' | j)  cursor=$(( (cursor + 1) % total )) ;;
      '')  # Enter — toggle item or confirm on Submit
        if [[ $cursor -eq $count ]]; then
          break
        else
          if [[ "${selected[$cursor]}" == "1" ]]; then
            selected[$cursor]=0
          else
            selected[$cursor]=1
          fi
        fi
        ;;
      a)
        for ((i = 0; i < count; i++)); do selected[$i]=1; done
        ;;
      n)
        for ((i = 0; i < count; i++)); do selected[$i]=0; done
        ;;
    esac

    _sm_draw redraw
  done

  # ── Restore terminal & remove traps ───────────────────────
  _sm_cleanup
  trap - INT TERM

  # ── Replace interactive menu with static summary ──────────
  printf '\033[%dA' "$total_lines"
  printf '\033[K'
  echo -e "  ${BOLD}Select which steps to run:${RESET}"
  printf '\033[K\n'
  for ((i = 0; i < count; i++)); do
    printf '\033[K'
    if [[ "${selected[$i]}" == "1" ]]; then
      echo -e "    ${BOLD_GREEN}✓${RESET} ${labels[$i]}"
    else
      echo -e "    ${DIM}○ ${labels[$i]}${RESET}"
    fi
  done
  printf '\033[K\n'
  printf '\033[K\n'
  printf '\033[K\n'
  printf '\033[K\n'

  # ── Populate result array ─────────────────────────────────
  for ((i = 0; i < count; i++)); do
    SELECTED_MODULES[$i]=${selected[$i]}
  done

  unset -f _sm_draw _sm_cleanup
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
