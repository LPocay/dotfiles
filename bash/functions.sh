#!/usr/bin/env bash

tproj() {
  #set -euo pipefail

  local base="$HOME/Projects"
  if [[ ! -d "$base" ]]; then
    echo "✗ Base directory not found: $base" >&2
    return 1
  fi

  command -v fzf >/dev/null 2>&1 || { echo "✗ fzf not found" >&2; return 1; }
  command -v tmux >/dev/null 2>&1 || { echo "✗ tmux not found" >&2; return 1; }

  local picked="$base/$(cd $base && fd . -d 1 -t d | fzf)"
  local session_name="$(basename $picked)" 
  "$(cd $picked && tmux new-session -A -s $session_name)" 
  return 0
}

tsessions() {
  local session_name="$(tmux ls | fzf | cut -d":" -f 1)"
  "$(tmux a -t $session_name)" 
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
