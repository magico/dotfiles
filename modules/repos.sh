#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# modules/repos.sh — Clone GitHub repos into ~/Development
# ─────────────────────────────────────────────────────────────

run_module() {
  source "$DOTFILES_DIR/config/repos.sh"

  # setup.sh sets SELECTED_REPOS from the repo checklist (and REPOS_PICKED).
  # Without it (module run on its own), clone everything in config/repos.sh.
  # Indexed loops: "${arr[@]}" on an empty array fails under set -u in
  # macOS bash 3.2, and the list is empty when nothing is ticked.
  local repos=() j
  if [[ "${REPOS_PICKED:-}" == "1" ]]; then
    for ((j = 0; j < ${#SELECTED_REPOS[@]}; j++)); do repos+=("${SELECTED_REPOS[$j]}"); done
  else
    for ((j = 0; j < ${#REPOS[@]}; j++)); do repos+=("${REPOS[$j]}"); done
  fi

  if [[ ${#repos[@]} -eq 0 ]]; then
    skip "No repos selected"
    return 0
  fi

  local dev_dir="$HOME/Development"
  mkdir -p "$dev_dir"

  task "Cloning repos into ${dev_dir}..."
  for ((j = 0; j < ${#repos[@]}; j++)); do
    local repo="${repos[$j]}"
    local dest="$dev_dir/${repo##*/}"

    if [[ -d "$dest/.git" ]]; then
      success "${repo} already cloned"
    elif [[ -e "$dest" ]]; then
      warn "${dest} exists but isn't a git repo — skipping ${repo}"
    else
      task "Cloning ${repo}..."
      # The Git step rewrites https://github.com/ to SSH, so private repos
      # use your key. accept-new saves GitHub's host key on first contact
      # (instead of stopping at "continue connecting?") but still refuses a
      # changed key. GIT_TERMINAL_PROMPT=0 makes an HTTPS clone fail rather
      # than wait for a password if the Git step was skipped.
      if GIT_TERMINAL_PROMPT=0 \
         GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new" \
         git clone "https://github.com/${repo}.git" "$dest"; then
        success "${repo} cloned to ${dest}"
      else
        warn "Failed to clone ${repo} — check you have access (the Git + SSH step sets that up)"
      fi
    fi
  done
}
