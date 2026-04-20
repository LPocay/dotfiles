# Dependencies

This setup uses `yay` as the Pacman frontend.

To install the main Hyprland setup dependencies with `yay`, run:

```bash
./scripts/install_hyprland.sh
```

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
- [PipeWire](https://pipewire.org/): audio server stack used for modern Wayland audio handling.
- [WirePlumber](https://pipewire.pages.freedesktop.org/wireplumber/): session manager that provides tools like `wpctl`.

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
