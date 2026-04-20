#!/usr/bin/env bash

set -euo pipefail

if ! command -v yay >/dev/null 2>&1; then
    printf 'Error: yay is required but was not found in PATH.\n' >&2
    printf 'Install yay first, then run this script again.\n' >&2
    exit 1
fi

core_packages=(
    git
    neovim
    ghostty
    tmux
    zellij
)

shell_packages=(
    fzf
    ripgrep
    fd
    bat
    jq
    glow
    eza
    lazygit
    lazydocker
    tre-command
    zoxide
    tokei
    yazi
    fastfetch
    impala
    bluetui
    xclip
    wl-clipboard
    cliphist
    ttf-jetbrains-mono-nerd
)

hyprland_packages=(
    hyprland
    hypridle
    hyprlock
    hyprpaper
    hyprpolkitagent
    xdg-desktop-portal-hyprland
    waybar
    wofi
    dunst
    thunar
    grim
    slurp
    brightnessctl
    playerctl
)

audio_and_services_packages=(
    pipewire
    wireplumber
    pipewire-pulse
    pavucontrol
    mpd
    power-profiles-daemon
    polkit-gnome
)

packages=(
    "${core_packages[@]}"
    "${shell_packages[@]}"
    "${hyprland_packages[@]}"
    "${audio_and_services_packages[@]}"
)

printf 'Installing main Hyprland setup dependencies with yay...\n'
yay -S --needed "${packages[@]}"

printf '\nInstallation finished.\n'
printf 'You may still want to enable or start user/system services like:\n'
printf '  - pipewire / wireplumber\n'
printf '  - power-profiles-daemon\n'
printf '  - mpd\n'
