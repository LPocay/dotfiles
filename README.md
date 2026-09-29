# Setup

Clone this repository to `$HOME/dotfiles`. This is the path used by the Hyprland
keybindings and the Zellij shortcut. Link the configurations you use; check for
existing files or directories at the destination before creating a link.

For the current Hyprland setup:

```bash
repo="$HOME/dotfiles"
ln -s "$repo/hypr/.config/hypr" "$HOME/.config/hypr"
ln -s "$repo/uwsm/.config/uwsm" "$HOME/.config/uwsm"
ln -s "$repo/nvim/.config/nvim" "$HOME/.config/nvim"
ln -s "$repo/ghostty/.config/ghostty" "$HOME/.config/ghostty"
ln -s "$repo/quickshell/.config/quickshell" "$HOME/.config/quickshell"
ln -s "$repo/waybar/.config/waybar" "$HOME/.config/waybar"
ln -s "$repo/dunst/.config/dunst" "$HOME/.config/dunst"
ln -s "$repo/wofi/.config/wofi" "$HOME/.config/wofi"
ln -s "$repo/zellij/.config/zellij" "$HOME/.config/zellij"
ln -s "$repo/tmux/.tmux.conf" "$HOME/.tmux.conf"
ln -s "$repo/bash/.bash_aliases" "$HOME/.bash_aliases"
ln -s "$repo/bash/functions.sh" "$HOME/functions.sh"
```

Add these lines to your existing interactive `~/.bashrc` if they are not there:

```bash
source "$HOME/.bash_aliases"
source "$HOME/functions.sh"
```

`~/.bashrc` itself is personal and is not managed by this repo. The alternative
terminal configurations (`alacritty`, `kitty`, `wezterm`) can be linked as needed.
`zed` stores individual files under `~/.config/zed` and should be linked file by
file if that directory already contains local state.

## Dependencies

This setup uses `yay` as the Pacman frontend.

To install the main Hyprland setup dependencies with `yay`, run:

```bash
./scripts/install_hyprland.sh
```

Install [Herdr](https://herdr.dev/docs/install/) separately using its official
instructions. It is required for `hproj` but not for the Hyprland package setup.
The package script installs `fd` and `fzf` for project selection and ImageMagick
(`magick`) for `scripts/wallpaper_menu.sh`. That wallpaper script also needs
`quickshell`, `hyprctl`, `jq`, and `notify-send`. The workspace layout script
needs a running Hyprland session, `hyprctl`, `jq`, `uwsm`, and `notify-send`.
`tmproj` and `tsessions` need tmux; `hproj` needs Herdr.

## Projects and sessions

After sourcing `bash/functions.sh`, run `tmproj` to select an immediate
subdirectory of `$HOME/Projects` and create or attach to a tmux session with
that directory's name. Run `hproj` to open a named Herdr session for the same
project. `tsessions` selects an existing tmux session. The project commands
change the current shell's directory, so they must be sourced as functions.
Set `PROJECTS_DIR` to use a different project root. Project directory names
must be unique directly under that root because they become session names.

## Neovim plugin lock

`nvim/.config/nvim/nvim-pack-lock.json` belongs in Git. On the machine where
you update plugins, use `<leader>u` in Neovim, review the lockfile diff, verify
that Neovim starts and the plugins work, then commit the lockfile. On another
machine, pull the change and restart Neovim; `vim.pack` installs the revisions
recorded in the lock. Use `:packupdate ++lockfile` to sync installed plugins
back to those revisions, and `:checkhealth vim.pack` to diagnose problems.
Do not edit the lockfile by hand. Mason-managed language servers and tools are
installed separately; the `vim.pack` lock does not pin their versions.

## Active and legacy configurations

The current desktop setup is Hyprland with UWSM, plus Quickshell, Waybar, and
the scripts under `scripts/`. The `hyprland-old.conf` file is a previous
Hyprland configuration. `sway` and `swaylock` are kept as a Wayland fallback.
`i3`, `picom`, `polybar`, `rofi`, and `monitors/configure-monitors.sh` belong to
the older X11 setup; that monitor script uses `xrandr` and is not part of the
Hyprland setup. Link or run legacy components only when using those sessions.

## Commits

Commit messages follow the `<area>: <subject>` convention, with an imperative subject:

```text
zed: reorganize keymap and add js/ts formatters
bash: split project helpers for tmux and herdr
chore: bump nvim lockfile
```

Areas used across the repo: `bash`, `zed`, `nvim`, `hypr`, `uwsm`, `quickshell`, `waybar`, `scripts`, `docs`, `chore`.

## Hyprland UWSM Migration

The Hyprland setup is being migrated to `uwsm` so that Hyprland starts as a systemd-managed graphical session. This is important for recent `xdg-desktop-portal` versions, which expect `graphical-session.target` to be active before portal activation.

## Core

- [Go](https://golang.org/): language toolchain used for Go development and `gopls`.
- [Rust](https://www.rust-lang.org/): language toolchain used for Rust development and related tooling.
- [Node.js](https://nodejs.org/): JavaScript runtime used by frontend tooling, linters, formatters, and some LSPs.
- [Git](https://git-scm.com/): version control used directly in shell prompts, Neovim, and general workflow.
- [Nerd Fonts](https://www.nerdfonts.com/): patched fonts required for icons in terminal, bars, and editor UI.

## Shared Terminal And Shell

- [NeoVim](https://neovim.io/): main editor configuration in this repo.
- [alacritty](https://alacritty.org/): alternative terminal emulator config kept in the repo.
- [tmux](https://github.com/tmux/tmux/wiki): terminal multiplexer used for session and pane management.
- [ghostty](https://ghostty.org/): primary terminal emulator used by the Hyprland and Sway configs.
- [kitty](https://sw.kovidgoyal.net/kitty/): alternative terminal emulator config kept in the repo.
- [wezterm](https://wezfurlong.org/wezterm/): alternative terminal emulator config kept in the repo.
- [zellij](https://zellij.dev/): terminal workspace manager used by the shell helper script.
- [herdr](https://herdr.dev/): terminal multiplexer used to open per-project sessions from `hproj`.
- [fzf](https://github.com/junegunn/fzf): fuzzy finder used in shell integration and session selection.
- [ripgrep](https://github.com/BurntSushi/ripgrep): fast text search tool used by shell and editor workflows.
- [fd](https://github.com/sharkdp/fd): modern file finder used by terminal and editor tooling.
- [tree-sitter-cli](https://tree-sitter.github.io/tree-sitter/creating-parsers/1-getting-started.html): parser tooling used by editor integrations and grammar development.
- [bat](https://github.com/sharkdp/bat): `cat` replacement with syntax highlighting.
- [jq](https://jqlang.org/): command-line JSON processor.
- [wl-clipboard](https://github.com/bugaevc/wl-clipboard): Wayland clipboard tools used for clipboard integration and history capture.
- [cliphist](https://github.com/sentriz/cliphist): clipboard history backend used by the Hyprland clipboard picker.
- [glow](https://github.com/charmbracelet/glow): terminal markdown reader.
- [eza](https://github.com/eza-community/eza): modern `ls` replacement used by shell aliases.
- [lazygit](https://github.com/jesseduffield/lazygit): terminal UI for Git.
- [lazydocker](https://github.com/jesseduffield/lazydocker): terminal UI for Docker.
- [tre](https://github.com/dduan/tre): tree-style file explorer for the terminal.
- [zoxide](https://github.com/ajeetdsouza/zoxide): smarter `cd` replacement used in shell init.
- [tokei](https://github.com/XAMPPRocky/tokei): code statistics tool.
- [yazi](https://github.com/sxyazi/yazi): terminal file manager.
- [fastfetch](https://github.com/fastfetch-cli/fastfetch): system info tool launched from shell startup.
- [impala](https://github.com/pythops/impala): terminal UI for Wi-Fi management.
- [bluetui](https://github.com/pythops/bluetui): terminal UI for Bluetooth management.
- [xclip](https://github.com/astrand/xclip): clipboard integration used by tmux copy bindings.

## Main Setup: Wayland And Hyprland

- [Hyprland](https://hypr.land/): main Wayland compositor and current daily-driver setup.
- [UWSM](https://github.com/Vladimir-csp/uwsm): Wayland session manager used to run Hyprland as a systemd-managed graphical session.
- [hypridle](https://github.com/hyprwm/hypridle): idle management daemon for screen dimming, locking, and DPMS.
- [hyprlock](https://github.com/hyprwm/hyprlock): lock screen used by the Hyprland idle flow.
- [hyprpaper](https://github.com/hyprwm/hyprpaper): wallpaper daemon for Hyprland.
- [Waybar](https://github.com/Alexays/Waybar): status bar used in the main Wayland setup.
- [wofi](https://github.com/SimplyCEO/wofi): application launcher used in Hyprland and Sway.
- [thunar](https://docs.xfce.org/xfce/thunar/start): file manager launched from Hyprland keybindings.
- [grim](https://gitlab.freedesktop.org/emersion/grim): screenshot tool used by keybindings.
- [slurp](https://github.com/emersion/slurp): region selector used together with `grim`.
- [brightnessctl](https://github.com/Hummer12007/brightnessctl): backlight control used by Hyprland keybindings and idle hooks.
- [playerctl](https://github.com/altdesktop/playerctl): media player control used by keybindings.
- [pavucontrol](https://freedesktop.org/software/pulseaudio/pavucontrol/): GUI audio mixer opened from Waybar.
- [PipeWire](https://pipewire.org/): audio server stack used for modern Wayland audio handling and Wayland screen sharing.
- [WirePlumber](https://pipewire.pages.freedesktop.org/wireplumber/): session manager that provides tools like `wpctl`.
- [xdg-desktop-portal](https://github.com/flatpak/xdg-desktop-portal): desktop portal service used by sandboxed apps and screen sharing.
- [xdg-desktop-portal-hyprland](https://github.com/hyprwm/xdg-desktop-portal-hyprland): Hyprland portal backend for screen sharing and related integrations.
- [xdg-desktop-portal-gtk](https://github.com/flatpak/xdg-desktop-portal-gtk): GTK portal backend used for file picker fallback with XDPH.

## Shared Services And Media

- [dunst](https://github.com/dunst-project/dunst): notification daemon configuration kept in the repo.
- [mpd](https://www.musicpd.org/): music daemon used by the Waybar `mpd` module.
- [power-profiles-daemon](https://gitlab.freedesktop.org/hadess/power-profiles-daemon): exposes power profile status in Waybar.

## Legacy: Sway

- [sway](https://swaywm.org/): legacy Wayland compositor configuration kept for fallback/reference.
- [swayidle](https://github.com/swaywm/swayidle): idle management used by the legacy Sway setup.
- [swaylock](https://github.com/swaywm/swaylock): lock screen used by the legacy Sway setup.
- [swaynag](https://github.com/swaywm/swaynag): warning/confirmation dialog used by Sway exit bindings.

## Legacy: i3 And X11

- [i3](https://i3wm.org/): legacy X11 window manager configuration kept for fallback/reference.
- [polybar](https://github.com/polybar/polybar): status bar used by the i3 setup.
- [picom](https://github.com/yshui/picom): compositor for transparency and visual effects on X11.
- [rofi](https://github.com/davatorium/rofi): launcher used by the i3 setup.
- [dex](https://github.com/jceb/dex): starts XDG autostart desktop entries in the i3 session.
- [xss-lock](https://bitbucket.org/raymonad/xss-lock): hooks screen locking into suspend/idle handling on X11.
- [i3lock](https://i3wm.org/i3lock/): lock screen used by the i3 setup.
- [nm-applet](https://wiki.gnome.org/Projects/NetworkManager): system tray applet for network management.
- [feh](https://feh.finalrewind.org/): wallpaper setter used by the i3 startup script.
- [xrandr](https://www.x.org/releases/current/doc/man/man1/xrandr.1.xhtml): monitor configuration tool used by the X11 monitor script.

## Polkit Agents

- [polkit-gnome](https://wiki.gnome.org/Projects/PolicyKit): authentication agent used by the Wayland setup.
- [lxsession](https://wiki.lxde.org/en/LXSession): provides `lxpolkit` for the legacy i3 setup.
