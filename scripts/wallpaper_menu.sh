#!/usr/bin/env bash
set -euo pipefail

command -v quickshell >/dev/null 2>&1 || {
  notify-send "Wallpaper Menu" "quickshell is not installed"
  exit 1
}

# Address the integrated shell instead of starting a second picker instance.
exec quickshell ipc call wallpaper toggle
