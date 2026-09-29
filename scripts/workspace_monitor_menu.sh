#!/usr/bin/env bash
set -euo pipefail

fail() {
  printf 'Workspace Monitor: %s\n' "$1" >&2
  if command -v notify-send >/dev/null 2>&1; then
    notify-send 'Workspace Monitor' "$1"
  fi
  exit 1
}

for dependency in hyprctl jq wofi; do
  command -v "$dependency" >/dev/null 2>&1 || fail "$dependency is not installed"
done

active_workspace="$(hyprctl activeworkspace -j)" || fail 'Could not read the active workspace'
monitors="$(hyprctl monitors -j)" || fail 'Could not read connected monitors'

workspace_id="$(jq -er '.id | select(type == "number" and . > 0)' <<<"$active_workspace")" || fail 'No regular workspace is active'
current_monitor="$(jq -er '.monitor | select(type == "string" and length > 0)' <<<"$active_workspace")" || fail 'Could not identify the current monitor'
jq -e 'type == "array"' <<<"$monitors" >/dev/null || fail 'Invalid monitor data from Hyprland'

options="$(
  jq -r --arg current "$current_monitor" \
    '.[] | select(.name != $current) | .name + "  " + (.description // "")' \
    <<<"$monitors"
)" || fail 'Could not list other monitors'

if [[ -z "$options" ]]; then
  if command -v notify-send >/dev/null 2>&1; then
    notify-send 'Workspace Monitor' 'No other monitor is connected'
  fi
  exit 0
fi

selection="$(printf '%s\n' "$options" | wofi --dmenu --insensitive --prompt 'move workspace to monitor')" || exit 0
[[ -n "$selection" ]] || exit 0

target_monitor="${selection%%  *}"
[[ "$target_monitor" =~ ^[A-Za-z0-9_.:-]+$ ]] || fail 'Invalid monitor selection'
jq -e --arg target "$target_monitor" 'any(.[]; .name == $target)' <<<"$monitors" >/dev/null || fail 'Selected monitor is unavailable'
[[ "$target_monitor" != "$current_monitor" ]] || exit 0

hyprctl dispatch "hl.dsp.workspace.move({ workspace = $workspace_id, monitor = \"$target_monitor\" })" >/dev/null || fail 'Could not move the workspace'
