#!/usr/bin/env bash

# Give each background group its own process group so cancellation also stops
# descendants of the updater commands. Keep this out of the caller's shell.
set -m
set -uo pipefail

declare -A labels=(
  [rust]='Rust' [deno]='Deno' [opencode]='OpenCode' [pi]='Pi'
  [claude]='Claude' [copilot]='Copilot' [codex]='Codex' [herdr]='Herdr'
  [flatpak]='Flatpak' [integrations]='Integraciones de Herdr'
)
declare -A commands=(
  [rust]='rustup' [deno]='deno' [opencode]='opencode' [pi]='pi'
  [claude]='claude' [copilot]='copilot' [codex]='codex' [herdr]='herdr'
  [flatpak]='flatpak'
)
declare -A running=() results=() started=() durations=()
groups=(rust deno opencode pi claude copilot codex herdr flatpak)
red='' green='' yellow='' cyan='' bold='' reset=''
if [[ -t 1 && -z ${NO_COLOR+x} && ${TERM:-dumb} != dumb ]]; then
  red=$'\e[31m' green=$'\e[32m' yellow=$'\e[33m' cyan=$'\e[36m'
  bold=$'\e[1m' reset=$'\e[0m'
fi

status_line() {
  local state=$1 label=$2 detail=${3:-} color=$cyan
  case "$state" in
    OK) color=$green ;;
    FAIL) color=$red ;;
    SKIP) color=$yellow ;;
  esac
  printf '%s[%-4s]%s %-24s %s\n' "$color" "$state" "$reset" "$label" "$detail"
}

cancel() {
  local code=$1 pid
  trap '' INT TERM
  for pid in "${!running[@]}"; do
    kill -TERM -- "-$pid" 2>/dev/null || true
  done
  wait 2>/dev/null || true
  printf '\nActualización cancelada. Logs: %s\n' "$log_dir"
  exit "$code"
}

run_step() {
  local code
  printf '\n>>> '
  printf '%q ' "$@"
  printf '\n'
  "$@"
  code=$?
  printf '\n<<< Código de salida: %s\n' "$code"
  return "$code"
}

run_group() {
  local code
  case "$1" in
    rust) run_step rustup upgrade ;;
    deno) run_step deno upgrade ;;
    opencode) run_step opencode upgrade ;;
    pi)
      run_step pi update
      code=$?
      if (( code != 0 )); then
        printf '\nSKIP: extensiones de Pi porque falló la actualización de Pi.\n'
        return "$code"
      fi
      run_step pi update --extensions
      ;;
    claude) run_step claude update ;;
    copilot) run_step copilot update ;;
    codex) run_step codex update ;;
    herdr) run_step herdr update ;;
    flatpak) run_step flatpak update --noninteractive --assumeyes ;;
    integrations) update_integrations ;;
  esac
}

update_integrations() {
  local output code line agent state count=0 failed=0 seen=0
  local pattern='^([a-z][a-z0-9-]*)([[:space:]]+\(experimental\))?:[[:space:]]+(current|outdated|not installed)([[:space:]]|$)'
  # --outdated-only prints a prose instruction, whereas the full status has
  # one row per integration. Read fresh status after updating the binary.
  output="$(herdr integration status)"
  code=$?
  printf '%s\n' "$output"
  (( code == 0 )) || return "$code"

  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    if [[ ! $line =~ $pattern ]]; then
      printf 'Formato de estado no reconocido: %s\n' "$line"
      failed=1
      continue
    fi
    seen=1
    agent=${BASH_REMATCH[1]}
    state=${BASH_REMATCH[3]}
    [[ $state == outdated ]] || continue
    (( count += 1 ))
    run_step herdr integration install "$agent" || failed=1
  done <<< "$output"

  if (( seen == 0 )); then
    printf 'No se pudo reconocer el estado de las integraciones.\n'
    return 1
  fi
  printf '\nIntegraciones pendientes procesadas: %s\n' "$count"
  return "$failed"
}

start_group() {
  local group=$1 pid
  started[$group]=$SECONDS
  status_line RUN "${labels[$group]}"
  ( run_group "$group" ) </dev/null >"$log_dir/$group.log" 2>&1 &
  pid=$!
  running[$pid]=$group
}

collect_group() {
  local finished='' code group
  wait -n -p finished "${!running[@]}"
  code=$?
  group=${running[$finished]}
  unset 'running[$finished]'
  durations[$group]=$(( SECONDS - started[$group] ))
  if (( code == 0 )); then
    results[$group]=OK
    status_line OK "${labels[$group]}" "${durations[$group]}s"
  else
    results[$group]=FAIL
    status_line FAIL "${labels[$group]}" "${durations[$group]}s · código $code"
    printf '  Log: %s/%s.log\n' "$log_dir" "$group"
    tail -n 12 -- "$log_dir/$group.log"
  fi
}

if ! command -v yay >/dev/null 2>&1; then
  status_line FAIL Sistema 'yay no está instalado; no se ejecutó ninguna actualización.'
  exit 127
fi

log_root="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/update"
mkdir -p -- "$log_root" || exit 1
log_dir="$(mktemp -d "$log_root/$(date +%Y%m%d-%H%M%S)-XXXXXX")" || exit 1
trap 'cancel 130' INT
trap 'cancel 143' TERM

printf '\n%sActualización del entorno%s\nLogs: %s\n\n' "$bold" "$reset" "$log_dir"
status_line RUN Sistema 'yay -Syu · obligatorio'
system_start=$SECONDS
yay -Syu 2>&1 | tee "$log_dir/system.log"
pipeline_status=("${PIPESTATUS[@]}")
if (( pipeline_status[0] != 0 || pipeline_status[1] != 0 )); then
  status_line FAIL Sistema 'Se detuvo el flujo. Consultá system.log.'
  if (( pipeline_status[0] != 0 )); then
    exit "${pipeline_status[0]}"
  fi
  exit "${pipeline_status[1]}"
fi
status_line OK Sistema "$(( SECONDS - system_start ))s"
printf '\n%sHerramientas en paralelo%s\n' "$bold" "$reset"

for group in "${groups[@]}"; do
  if command -v "${commands[$group]}" >/dev/null 2>&1; then
    start_group "$group"
  else
    results[$group]=SKIP
    status_line SKIP "${labels[$group]}" 'No instalado'
  fi
done
while (( ${#running[@]} > 0 )); do
  collect_group
done

printf '\n%sIntegraciones%s\n' "$bold" "$reset"
if [[ ${results[herdr]} == OK ]]; then
  start_group integrations
  collect_group
else
  results[integrations]=SKIP
  status_line SKIP "${labels[integrations]}" 'Herdr no está disponible o falló su actualización'
fi

ok=1 failed=0 skipped=0
for group in "${groups[@]}" integrations; do
  case "${results[$group]}" in
    OK) (( ok += 1 )) ;;
    FAIL) (( failed += 1 )) ;;
    SKIP) (( skipped += 1 )) ;;
  esac
done
printf '\n%sResumen%s · %s%s OK%s · %s%s fallos%s · %s%s omitidos%s · %ss\n' \
  "$bold" "$reset" "$green" "$ok" "$reset" "$red" "$failed" "$reset" \
  "$yellow" "$skipped" "$reset" "$SECONDS"
printf 'Logs: %s\n' "$log_dir"
(( failed == 0 ))
