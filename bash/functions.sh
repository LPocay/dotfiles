#!/usr/bin/env bash

_pick_project() {
  local base="${PROJECTS_DIR:-$HOME/Projects}"
  if [[ ! -d "$base" ]]; then
    printf 'Project directory not found: %s\n' "$base" >&2
    return 2
  fi

  command -v fd >/dev/null 2>&1 || { printf 'fd not found\n' >&2; return 2; }
  command -v fzf >/dev/null 2>&1 || { printf 'fzf not found\n' >&2; return 2; }

  REPLY="$(fd -t d -d 1 . "$base" | fzf --prompt='project> ')" || return 1
  [[ -n "$REPLY" && -d "$REPLY" ]] || return 1
}

tmproj() {
  command -v tmux >/dev/null 2>&1 || { printf 'tmux not found\n' >&2; return 2; }

  local pick_status session_name
  if _pick_project; then
    :
  else
    pick_status=$?
    (( pick_status == 1 )) && return 0
    return "$pick_status"
  fi

  session_name="$(basename "$REPLY")"
  cd -- "$REPLY" || return

  if [[ -n "${TMUX:-}" ]]; then
    tmux has-session -t "=$session_name" 2>/dev/null ||
      tmux new-session -d -s "$session_name" -c "$PWD" || return
    tmux switch-client -t "=$session_name"
  else
    tmux new-session -A -s "$session_name" -c "$PWD"
  fi
}

hproj() {
  command -v herdr >/dev/null 2>&1 || { printf 'herdr not found\n' >&2; return 2; }

  local pick_status session_name
  if _pick_project; then
    :
  else
    pick_status=$?
    (( pick_status == 1 )) && return 0
    return "$pick_status"
  fi

  session_name="$(basename "$REPLY")"
  cd -- "$REPLY" || return
  herdr --session "$session_name"
}

tsessions() {
  command -v tmux >/dev/null 2>&1 || { printf 'tmux not found\n' >&2; return 2; }
  command -v fzf >/dev/null 2>&1 || { printf 'fzf not found\n' >&2; return 2; }

  local sessions session_name
  sessions="$(tmux list-sessions -F '#S' 2>/dev/null)" || {
    printf 'No tmux sessions are running\n' >&2
    return 0
  }
  [[ -n "$sessions" ]] || return 0
  session_name="$(printf '%s\n' "$sessions" | fzf --prompt='tmux> ')" || return 0
  [[ -n "$session_name" ]] || return 0

  if [[ -n "${TMUX:-}" ]]; then
    tmux switch-client -t "=$session_name"
  else
    tmux attach-session -t "=$session_name"
  fi
}

update_all() {
  printf 'Updating system packages...\n'
  yay -Syu || return $?

  printf 'Updating Rust...\n'
  rustup upgrade || return $?

  printf 'Updating Deno...\n'
  deno upgrade || return $?

  printf 'Updating OpenCode...\n'
  opencode upgrade || return $?

  printf 'Updating pi...\n'
  pi update || return $?

  printf 'Updating Herdr...\n'
  herdr update || return $?

  printf 'Updating Codex...\n'
  codex update || return $?
}

tshortcuts() {
  local file="$HOME/dotfiles/SHORTCUT_CHEATSHEET.md"

  if [[ ! -f "$file" ]]; then
    printf 'Shortcut cheat sheet not found: %s\n' "$file" >&2
    return 1
  fi

  command -v fzf >/dev/null 2>&1 || {
    printf 'fzf not found\n' >&2
    return 1
  }

  local selected line
  selected="$(rg -n '^(## |### |- `)' "$file" | \
    fzf \
      --delimiter=':' \
      --with-nth=2.. \
      --prompt='shortcuts> ' \
      --preview-window='right,70%,wrap' \
      --preview '
        line=$(printf "%s" {} | cut -d: -f1)
        start=$(( line > 15 ? line - 15 : 1 ))
        end=$(( line + 15 ))
        if command -v bat >/dev/null 2>&1; then
          bat --style=plain --color=always --line-range "${start}:${end}" "'$file'"
        else
          sed -n "${start},${end}p" "'$file'"
        fi
      ' )"

  [[ -n "$selected" ]] || return 0

  line="${selected%%:*}"
  "${EDITOR:-nvim}" "+${line}" "$file"
}
