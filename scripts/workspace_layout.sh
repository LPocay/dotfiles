#!/usr/bin/env bash
set -euo pipefail

# Opens the daily working set of apps, each on its own Hyprland workspace.
# Workspace 1 is left untouched on purpose: it holds the terminal this script
# is run from. Re-running is safe, apps that already have a window are skipped.
#
# The config is hyprland.lua, so `hyprctl dispatch` evaluates its argument as
# Lua (hl.dispatch(<arg>)) instead of the classic "dispatcher args" syntax.
# That is why every dispatch below is written as an hl.dsp.* call.

LAUNCH_TIMEOUT="${LAUNCH_TIMEOUT:-20}"
POLL_INTERVAL="${POLL_INTERVAL:-0.2}"
HOME_WORKSPACE="${HOME_WORKSPACE:-1}"
SETTLE_TIMEOUT="${SETTLE_TIMEOUT:-8}"

# workspace | window class regex (case-insensitive) | launch command
APPS=(
  "2|^firefox$|firefox"
  "3|^discord$|discord"
  "4|^spotify$|spotify-launcher"
  "5|^ZenNotes$|zennotes"
)

command -v hyprctl >/dev/null 2>&1 || {
  notify-send "Workspace Layout" "hyprctl is not installed"
  exit 1
}

command -v jq >/dev/null 2>&1 || {
  notify-send "Workspace Layout" "jq is not installed"
  exit 1
}

if [[ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
  notify-send "Workspace Layout" "Hyprland is not running"
  exit 1
fi

# Address of the first window whose class matches the given regex, if any.
find_window() {
  local class_re="$1"
  hyprctl clients -j |
    jq -r --arg re "$class_re" 'first(.[] | select(.class | test($re; "i")) | .address) // empty'
}

# Workspace id the given window address currently lives on.
window_workspace() {
  local addr="$1"
  hyprctl clients -j |
    jq -r --arg addr "$addr" 'first(.[] | select(.address == $addr) | .workspace.id) // empty'
}

# Move a window to its workspace, unless it is already there.
move_to_workspace() {
  local ws="$1" addr="$2"
  if [[ "$(window_workspace "$addr")" != "$ws" ]]; then
    hyprctl dispatch \
      "hl.dsp.window.move({ window = \"address:$addr\", workspace = $ws, silent = true })" >/dev/null
  fi
}

# Launch an app if needed and make sure it ends up on the right workspace.
place_app() {
  local ws="$1" class_re="$2" cmd="$3"
  local addr

  addr="$(find_window "$class_re")"
  if [[ -n "$addr" ]]; then
    move_to_workspace "$ws" "$addr"
    printf 'workspace %s: %s already running\n' "$ws" "$cmd"
    return 0
  fi

  if ! command -v "${cmd%% *}" >/dev/null 2>&1; then
    printf 'workspace %s: %s is not installed, skipping\n' "$ws" "${cmd%% *}" >&2
    return 1
  fi

  hyprctl dispatch "hl.dsp.exec_cmd(\"uwsm app -- $cmd\")" >/dev/null

  local deadline=$(( SECONDS + LAUNCH_TIMEOUT ))
  while :; do
    addr="$(find_window "$class_re")"
    [[ -n "$addr" ]] && break
    (( SECONDS >= deadline )) && break
    sleep "$POLL_INTERVAL"
  done

  if [[ -z "$addr" ]]; then
    notify-send "Workspace Layout" "$cmd did not open a window within ${LAUNCH_TIMEOUT}s"
    printf 'workspace %s: %s timed out\n' "$ws" "$cmd" >&2
    return 1
  fi

  move_to_workspace "$ws" "$addr"
  printf 'workspace %s: %s launched\n' "$ws" "$cmd"
}

# Some apps (Discord for one) map a splash or updater window first and replace
# it with the real one a few seconds later, which lands on whatever workspace is
# active. Re-check for a short while and move anything that drifted.
settle() {
  local deadline=$(( SECONDS + SETTLE_TIMEOUT ))
  local ws class_re cmd addr entry
  while (( SECONDS < deadline )); do
    sleep 1
    for entry in "${APPS[@]}"; do
      IFS='|' read -r ws class_re cmd <<<"$entry"
      addr="$(find_window "$class_re")"
      if [[ -n "$addr" ]]; then
        move_to_workspace "$ws" "$addr"
      fi
    done
  done
}

for entry in "${APPS[@]}"; do
  IFS='|' read -r ws class_re cmd <<<"$entry"
  place_app "$ws" "$class_re" "$cmd" || true
done

# Focus goes home last: apps that raise themselves on startup (Spotify does)
# would otherwise steal it back during the settle window.
settle
hyprctl dispatch "hl.dsp.focus({ workspace = $HOME_WORKSPACE })" >/dev/null
printf 'Layout done, back on workspace %s\n' "$HOME_WORKSPACE"
