#!/usr/bin/env bash

set -euo pipefail

command -v cliphist >/dev/null 2>&1 || {
  printf 'cliphist not found\n' >&2
  exit 1
}

command -v wofi >/dev/null 2>&1 || {
  printf 'wofi not found\n' >&2
  exit 1
}

command -v wl-copy >/dev/null 2>&1 || {
  printf 'wl-copy not found\n' >&2
  exit 1
}

selection="$({ cliphist list || true; } | wofi --dmenu --insensitive --prompt 'clipboard')"

[[ -n "$selection" ]] || exit 0

printf '%s' "$selection" | cliphist decode | wl-copy
