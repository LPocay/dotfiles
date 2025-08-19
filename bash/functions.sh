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
