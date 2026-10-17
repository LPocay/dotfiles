#!/usr/bin/env bash
set -euo pipefail

WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
CURRENT_WALLPAPER="${CURRENT_WALLPAPER:-$HOME/.config/hypr/current_wallpaper}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper-picker"
STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/wallpaper-picker/outputs.json"
FIT_MODE="${FIT_MODE:-cover}"

fail() { printf '%s\n' "$*" >&2; exit 1; }
for tool in jq hyprctl; do
  command -v "$tool" >/dev/null 2>&1 || fail "$tool is not installed"
done

case "${1:-}" in
  scan)
    command -v magick >/dev/null 2>&1 || fail 'ImageMagick (magick) is not installed'
    [[ -d "$WALLPAPER_DIR" ]] || fail "Directory not found: $WALLPAPER_DIR"
    monitors=$(hyprctl monitors -j)
    jq -e 'type == "array" and length > 0' <<< "$monitors" >/dev/null || fail 'No Hyprland monitors detected'
    mkdir -p "$CACHE_DIR"
    catalog=$(mktemp "$CACHE_DIR/catalog.XXXXXX")
    trap 'rm -f "$catalog"' EXIT
    while IFS= read -r -d '' image; do
      signature=$(stat -Lc '%s:%Y' "$image")
      hash=$(printf '%s:%s' "$image" "$signature" | sha256sum)
      thumb="$CACHE_DIR/${hash%% *}.jpg"
      if [[ ! -s "$thumb" ]]; then
        # Write atomically so a failed conversion cannot poison the cache.
        if ! magick "${image}[0]" -auto-orient -thumbnail '480x270^' -gravity center -extent 480x270 -strip -quality 85 "jpg:$thumb.tmp" 2>/dev/null; then
          rm -f "$thumb.tmp"
          continue
        fi
        mv -f "$thumb.tmp" "$thumb"
      fi
      jq -cn --arg path "$image" --arg thumbnail "$thumb" --arg name "$(basename "${image%.*}")" \
        '{path: $path, thumbnail: $thumbnail, name: $name}' >> "$catalog"
    done < <(find -L "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' -o -iname '*.bmp' -o -iname '*.webp' \) -print0 | sort -z)
    current=$(readlink -f -- "$CURRENT_WALLPAPER" || true)
    [[ -f "$current" ]] || current=''
    state='{}'
    if [[ -f "$STATE_FILE" ]]; then
      # A new compositor session starts from hyprpaper.conf's fallback image.
      state=$(jq -e --arg session "${HYPRLAND_INSTANCE_SIGNATURE:-}" \
        'if .session == $session and (.outputs | type == "object") then .outputs else {} end' \
        "$STATE_FILE") || fail "Invalid wallpaper state: $STATE_FILE"
    fi
    # New hyprpaper releases cannot list active wallpapers. Remember our applied
    # outputs, falling back to the configured current_wallpaper on first use.
    # A deleted previous wallpaper must not block setting a replacement.
    while IFS= read -r name; do
      previous=$(jq -r --arg name "$name" '.[$name] // empty' <<< "$state")
      if [[ -n "$previous" && ! -f "$previous" ]]; then
        state=$(jq --arg name "$name" 'del(.[$name])' <<< "$state")
      fi
    done < <(jq -r 'keys[]' <<< "$state")
    jq -n --slurpfile wallpapers "$catalog" --argjson outputs "$monitors" --argjson state "$state" \
      --arg current "$current" --arg monitor "${MONITOR:-}" \
      '{wallpapers: $wallpapers, current: $current, preferredOutput: $monitor,
        outputs: [$outputs[] | {name, width, height, focused,
          wallpaper: ($state[.name] // $current)}]}'
    ;;
  preview|restore|apply)
    payload="${2:?Missing wallpaper request}"
    jq -e 'type == "object" and (.outputs | type == "array") and
      all(.outputs[]; (.name | type == "string" and length > 0) and (.path | type == "string" and length > 0))' <<< "$payload" >/dev/null || fail 'Invalid wallpaper request'
    if [[ "$1" == apply ]]; then
      selected=$(jq -er '.selected | select(type == "string" and length > 0)' <<< "$payload") || fail 'No wallpaper selected'
      [[ -f "$selected" ]] || fail "Wallpaper not found: $selected"
      jq -e '.outputs | length > 0' <<< "$payload" >/dev/null || fail 'No outputs selected'
    fi
    connected=$(hyprctl monitors -j)
    # Validate every output before changing any of them.
    while IFS= read -r output; do
      name=$(jq -r '.name' <<< "$output")
      path=$(jq -r '.path' <<< "$output")
      if ! jq -e --arg name "$name" 'any(.[]; .name == $name)' <<< "$connected" >/dev/null; then
        [[ "$1" == restore ]] && continue
        fail "Output disconnected: $name"
      fi
      [[ -f "$path" ]] || fail "Wallpaper not found: $path"
      [[ "$name" != *,* && "$path" != *,* && "$path" != *$'\n'* ]] || fail 'hyprpaper cannot use commas or newlines in wallpaper paths'
    done < <(jq -c '.outputs[]' <<< "$payload")
    while IFS= read -r output; do
      name=$(jq -r '.name' <<< "$output")
      path=$(jq -r '.path' <<< "$output")
      if [[ "$1" == restore ]] && ! jq -e --arg name "$name" 'any(.[]; .name == $name)' <<< "$connected" >/dev/null; then
        continue
      fi
      result=$(hyprctl hyprpaper wallpaper "$name,$path,$FIT_MODE" 2>&1) || fail "$result"
      [[ "${result,,}" != *error* && "${result,,}" != *'err:'* ]] || fail "$result"
    done < <(jq -c '.outputs[]' <<< "$payload")
    if [[ "$1" == apply ]]; then
      mkdir -p "$(dirname "$CURRENT_WALLPAPER")" "$(dirname "$STATE_FILE")"
      state_tmp=$(mktemp "$(dirname "$STATE_FILE")/outputs.XXXXXX")
      trap 'rm -f "$state_tmp"' EXIT
      jq --arg session "${HYPRLAND_INSTANCE_SIGNATURE:-}" \
        '{session: $session, outputs: ([.outputs[] | {key: .name, value: .path}] | from_entries)}' <<< "$payload" > "$state_tmp"
      ln -nsf -- "$selected" "$CURRENT_WALLPAPER"
      mv -f "$state_tmp" "$STATE_FILE"
    fi
    ;;
  *) fail 'Usage: wallpaper.sh scan|preview|restore|apply [json]' ;;
esac
