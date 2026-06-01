#!/usr/bin/env bash
set -euo pipefail

WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
CURRENT_WALLPAPER="${CURRENT_WALLPAPER:-$HOME/.config/hypr/current_wallpaper}"
MONITOR="${MONITOR:-DP-3}"
FIT_MODE="${FIT_MODE:-cover}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper-picker"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
QML_FILE="$PROJECT_DIR/quickshell/.config/quickshell/wallpaper-picker.qml"

if [[ ! -d "$WALLPAPER_DIR" ]]; then
  notify-send "Wallpaper Menu" "Directory not found: $WALLPAPER_DIR"
  exit 1
fi

command -v quickshell >/dev/null 2>&1 || {
  notify-send "Wallpaper Menu" "quickshell is not installed"
  exit 1
}

command -v magick >/dev/null 2>&1 || {
  notify-send "Wallpaper Menu" "ImageMagick (magick) is not installed"
  exit 1
}

command -v hyprctl >/dev/null 2>&1 || {
  notify-send "Wallpaper Menu" "hyprctl is not installed"
  exit 1
}

mkdir -p "$CACHE_DIR"
mkdir -p "$(dirname "$CURRENT_WALLPAPER")"

mapfile -d '' -t images < <(
  find -L "$WALLPAPER_DIR" -maxdepth 1 -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' -o -iname '*.bmp' -o -iname '*.webp' \) \
    -print0 | sort -z
)

if [[ ${#images[@]} -eq 0 ]]; then
  notify-send "Wallpaper Menu" "No wallpapers found in $WALLPAPER_DIR"
  exit 1
fi

tsv_file=$(mktemp)
selection_file=$(mktemp)
trap 'rm -f "$tsv_file" "$selection_file"' EXIT

for img in "${images[@]}"; do
  sig=$(stat -Lc '%s:%Y' "$img")
  hash=$(printf '%s:%s' "$img" "$sig" | md5sum | cut -d' ' -f1)
  thumb="$CACHE_DIR/$hash.jpg"

  if [[ ! -f "$thumb" ]]; then
    magick "${img}[0]" -auto-orient -resize '960x540^' -gravity center -extent '960x540' -strip -quality 85 "$thumb" &
  fi

  printf '%s\t%s\n' "$img" "$thumb" >> "$tsv_file"
done

wait

export WALLPAPER_TSV="$tsv_file"
export WALLPAPER_SELECTION_FILE="$selection_file"

if [[ ! -f "$CURRENT_WALLPAPER" ]]; then
  ln -nsf "${images[0]}" "$CURRENT_WALLPAPER"
fi

quickshell -p "$QML_FILE"

if [[ -s "$selection_file" ]]; then
  selected=$(<"$selection_file")
  [[ -z "$selected" ]] && exit 0

  ln -nsf "$selected" "$CURRENT_WALLPAPER"

  hyprctl hyprpaper wallpaper "$MONITOR,$selected"

  notify-send "Wallpaper" "Wallpaper changed"
fi
