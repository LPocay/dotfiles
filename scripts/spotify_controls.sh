#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
QML_FILE="$PROJECT_DIR/quickshell/.config/quickshell/spotify-controls.qml"

command -v quickshell >/dev/null 2>&1 || {
  notify-send "Spotify Controls" "quickshell is not installed"
  exit 1
}

command -v playerctl >/dev/null 2>&1 || {
  notify-send "Spotify Controls" "playerctl is not installed"
  exit 1
}

if ! playerctl --list-all 2>/dev/null | grep -qi spotify; then
  notify-send "Spotify Controls" "Spotify is not running"
  exit 1
fi

quickshell -p "$QML_FILE"
