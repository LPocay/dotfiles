#!/usr/bin/env bash
set -euo pipefail

fail() { printf '%s\n' "$*" >&2; exit 1; }
for tool in hyprctl jq; do
  command -v "$tool" >/dev/null 2>&1 || fail "$tool is not installed"
done

valid_workspace() {
  [[ "$1" =~ ^[1-9][0-9]*$ ]] &&
    jq -en --arg id "$1" '$id | tonumber | . <= 2147483647' >/dev/null
}

read_state() {
  monitors=$(hyprctl monitors -j) || fail 'Could not read connected monitors'
  workspaces=$(hyprctl workspaces -j) || fail 'Could not read workspaces'
  jq -e 'type == "array" and all(.[]; (.name | type == "string"))' <<< "$monitors" >/dev/null || fail 'Invalid monitor data'
  jq -e 'type == "array" and all(.[]; (.id | type == "number") and (.monitor | type == "string"))' <<< "$workspaces" >/dev/null || fail 'Invalid workspace data'
  monitors=$(jq '[.[] | select(.disabled != true and ((.mirrorOf // "none") == "none" or .mirrorOf == ""))]' <<< "$monitors")
}

case "${1:-}" in
  scan)
    workspace_id=${2:-}
    if [[ -z "$workspace_id" ]]; then
      active=$(hyprctl activeworkspace -j) || fail 'Could not read the active workspace'
      workspace_id=$(jq -er '.id | select(type == "number")' <<< "$active") || fail 'No workspace is active'
    fi
    valid_workspace "$workspace_id" || fail 'Select a regular workspace before opening the monitor picker'
    read_state
    workspace=$(jq -ec --argjson id "$workspace_id" 'first(.[] | select(.id == $id))' <<< "$workspaces") || fail 'The original workspace no longer exists'
    jq -n --argjson workspace "$workspace" --argjson monitors "$monitors" --argjson workspaces "$workspaces" \
      '{workspace: ($workspace | {id, name, monitor, windows}),
        monitors: [$monitors[] | . as $monitor | {
          name, description: (.description // .model // .name), width, height,
          scale: (.scale // 1), refreshRate: (.refreshRate // 0), x, y,
          transform: (.transform // 0), activeWorkspace: (.activeWorkspace.id // 0),
          workspaces: ([$workspaces[] | select(.id > 0 and .monitor == $monitor.name) | {id, name, windows}] | sort_by(.id))
        }]}'
    ;;
  move)
    workspace_id=${2:-}
    target=${3:-}
    valid_workspace "$workspace_id" || fail 'Invalid workspace ID'
    [[ "$target" =~ ^[A-Za-z0-9_.:-]+$ ]] || fail 'Invalid monitor name'
    read_state
    jq -e --arg target "$target" 'any(.[]; .name == $target)' <<< "$monitors" >/dev/null || fail 'The selected monitor is no longer available'
    source=$(jq -er --argjson id "$workspace_id" 'first(.[] | select(.id == $id)) | .monitor' <<< "$workspaces") || fail 'The original workspace no longer exists'
    if [[ "$source" != "$target" ]]; then
      # This setup uses Hyprland's Lua dispatcher interface. ID and monitor name
      # are validated above, and membership is checked against a fresh snapshot.
      hyprctl dispatch "hl.dsp.workspace.move({ workspace = $workspace_id, monitor = \"$target\" })" >/dev/null || fail 'Could not move the workspace'
      updated=$(hyprctl workspaces -j) || fail 'Could not verify the workspace destination'
      jq -e --argjson id "$workspace_id" --arg target "$target" \
        'any(.[]; .id == $id and .monitor == $target)' <<< "$updated" >/dev/null || fail 'Workspace did not reach the selected monitor. Refresh and try again.'
    fi
    jq -n --argjson id "$workspace_id" --arg monitor "$target" '{workspaceId: $id, monitor: $monitor}'
    ;;
  *) fail 'Usage: workspace-monitor.sh scan [WORKSPACE_ID] | move WORKSPACE_ID MONITOR' ;;
esac
