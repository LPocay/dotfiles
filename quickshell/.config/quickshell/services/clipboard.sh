#!/usr/bin/env bash
set -euo pipefail

fail() { printf '%s\n' "$*" >&2; exit 1; }
command -v cliphist >/dev/null 2>&1 || fail 'cliphist is not installed'

case "${1:-}" in
  list)
    # Older cliphist versions do not have MIME or timestamp metadata. Keep the
    # stable ID/preview interface, with enough preview text to search useful snippets.
    if catalog=$(cliphist -preview-width 500 list 2>&1); then
      printf '%s' "$catalog"
    elif [[ "$catalog" != *'no such file or directory'* && "$catalog" != *'please store something first'* ]]; then
      fail "$catalog"
    fi
    ;;
  copy|delete)
    id=${2:-}
    [[ "$id" =~ ^[0-9]+$ ]] || fail 'Invalid clipboard entry ID'
    if [[ "$1" == delete ]]; then
      printf '%s\n' "$id" | cliphist delete
    else
      command -v wl-copy >/dev/null 2>&1 || fail 'wl-copy is not installed'
      # Decode successfully before changing the clipboard. Never send a failed
      # decode's empty output to wl-copy, or turn binary data into a shell string.
      payload=$(mktemp "${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/quickshell-clipboard.XXXXXX")
      trap 'rm -f -- "$payload"' EXIT
      cliphist decode "$id" > "$payload"
      wl-copy < "$payload"
    fi
    ;;
  clear)
    cliphist wipe
    ;;
  *) fail 'Usage: clipboard.sh list|copy ID|delete ID|clear' ;;
esac
