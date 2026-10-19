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
ln -s "$repo/fastfetch/.config/fastfetch" "$HOME/.config/fastfetch"
ln -s "$repo/quickshell/.config/quickshell" "$HOME/.config/quickshell"
ln -s "$repo/waybar/.config/waybar" "$HOME/.config/waybar"
ln -s "$repo/dunst/.config/dunst" "$HOME/.config/dunst"
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

## Updates

Run `update_all` after sourcing `bash/functions.sh`. It runs `yay -Syu` in the
foreground first and stops if that fails. Installed tools then update in
parallel; missing tools are skipped and individual failures do not stop other
groups. Pi updates itself before its extensions. Herdr updates its installed,
outdated integrations one at a time after all tool updates finish, provided its
own update succeeded.

The terminal shows compact progress, durations, a summary, and the last log lines
for failed groups. Each run keeps separate logs under
`${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/update/`. Colors are enabled only
in a terminal and respect `NO_COLOR`. The command returns a nonzero status if an
update fails; skipped tools do not count as failures. Requires Bash 5.1 or newer.

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
Hyprland setup. Wofi is also legacy: its configuration and the previous
`scripts/clipboard_history.sh` and `scripts/workspace_monitor_menu.sh` pickers
are retained, while the active Hyprland shortcuts use Quickshell. Wofi is no
longer installed by the main dependency script; see [its legacy setup](wofi/README.md)
for Sway or older sessions. Link or run legacy components only when using those sessions.

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
- [btop](https://github.com/aristocratos/btop): terminal CPU and RAM monitor opened from telemetry actions.
- [amdgpu_top](https://github.com/Umio-Yasuno/amdgpu_top): AMD GPU monitor opened from the GPU and VRAM telemetry readings.
- [Python](https://www.python.org/): lightweight GPU sysfs reader used by Quickshell telemetry.
- [bluetui](https://github.com/pythops/bluetui): terminal UI for Bluetooth management.
- [xclip](https://github.com/astrand/xclip): clipboard integration used by tmux copy bindings.

## Main Setup: Wayland And Hyprland

- [Hyprland](https://hypr.land/): main Wayland compositor and current daily-driver setup.
- [UWSM](https://github.com/Vladimir-csp/uwsm): Wayland session manager used to run Hyprland as a systemd-managed graphical session.
- [hypridle](https://github.com/hyprwm/hypridle): idle management daemon for screen dimming, locking, and DPMS.
- [hyprlock](https://github.com/hyprwm/hyprlock): lock screen used by the Hyprland idle flow.
- [hyprpaper](https://github.com/hyprwm/hyprpaper): wallpaper daemon for Hyprland.
- [Waybar](https://github.com/Alexays/Waybar): status bar used in the main Wayland setup.
- [Quickshell](https://quickshell.org/): top bar, application launcher, clipboard manager, wallpaper picker, workspace monitor picker, shortcut reference, and notification server/center in Hyprland.
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

Ghostty uses the local `Terminal Prompt` theme from `hyprland-rice.pen`, with an
`#101711` background at 80% opacity with blur, green/gold ANSI accents, an underline cursor,
the original 17.5 pt font size, and approximately 23 px of padding. Window decorations are
disabled. Bash shows the current directory followed by a green `❯` when `TERM_PROGRAM=ghostty`, via
`bash/.bash_aliases`. Open a new Ghostty window to apply all changes; run
`source ~/.bash_aliases` to refresh the prompt in an existing Ghostty shell.

Fastfetch uses a compact `Terminal Prompt` configuration with a green Arch logo,
system/kernel/desktop, CPU/GPU, memory usage, and uptime. Values are detected at
runtime; memory uses the theme's gold accent. Bash already runs `fastfetch` on
startup. Link its config directory as shown above, or preview it directly with
`fastfetch --config "$HOME/dotfiles/fastfetch/.config/fastfetch/config.jsonc"`.
Edit the `modules` list to choose or reorder the information displayed.

Hyprlock implements `Lock screen / Terminal Prompt` (`aMbJ6`) from
`quickshell/.config/quickshell/hyprland-rice.pen`: a green gradient, large local
clock, and a password panel on every output. Open the power menu and choose
`lock`, or run `loginctl lock-session` with Hypridle running; `hyprlock` also
starts it directly. The existing idle and suspend hooks use the same config.
Type your account password and press `Enter`; `Esc` or `Ctrl+U` clears input.
The border turns amber for Caps Lock and red after failed authentication.
The footer polls Quickshell's unread notification count every five seconds and
shows `--` when the shell is unavailable. JetBrains Mono is provided by the
existing Nerd Font dependency. The background PNG is shipped alongside its
editable SVG; regenerate it after editing with:

```bash
magick -background none hypr/.config/hypr/assets/lock-background.svg hypr/.config/hypr/assets/lock-background.png
```

Press `Super+Shift+o` to open the Quickshell workspace monitor picker. It captures
the active workspace when opened, shows each connected monitor's mode and
workspaces, and marks its current monitor. Use the arrows or `Tab`/`Shift+Tab`
to select a different monitor, then `Enter` or a click to move the workspace.
`Esc` or a click outside closes the panel; `Ctrl+r` refreshes it. Monitor changes
also refresh automatically, and the destination is revalidated before each move.
With one monitor connected, the panel explains that another output is needed.
No monitor names or positions are hardcoded. Scripts can toggle the same panel
with `quickshell ipc call monitors toggle`.

The top bar shows AMD GPU utilization as `GPU=…%` and occupied VRAM as
`VRAM=…G` (GiB), refreshed every two seconds from the driver's sysfs counters.
Hover VRAM to see used/total GiB and percentage. With multiple AMD GPUs, the
reader prefers one with a connected output, then the boot GPU, then the one
with the most VRAM. Card numbers and PCI addresses are discovered each poll;
unavailable counters hide their reading instead of showing stale values.
Click GPU or VRAM to open `amdgpu_top --dark --single --pci <address>` in Ghostty
through UWSM, targeting the same GPU. The monitor is launched only on demand.
If it is installed in `~/.local/bin`, the launcher can find it there even when
Quickshell started with a different PATH. `amdgpu_top` and Python are included in
the setup package list. Telemetry measures each reading's width and hides
lower-priority metrics when space is limited to avoid overlapping the clock.

GPU/telemetry regression checks: `node quickshell/tests/telemetry.test.cjs` and
`python quickshell/tests/gpu_backend_test.py`.

Monitor regression checks: `node quickshell/tests/monitor.test.cjs` and
`python quickshell/tests/monitor_backend_test.py`.

Press `Super+d` or `Super+Space`, or click the top-bar prompt, to toggle the
Quickshell application launcher on the focused monitor. Type to search app names,
descriptions, or keywords; `Up`/`Down` (or `Tab`/`Shift+Tab`) selects a result,
`Enter` launches it, and `Esc` or a click outside closes the palette. The list
scrolls beyond its four visible rows. `Ctrl+r` rebuilds the results from
Quickshell's automatically updated desktop-entry catalog.

Applications launch through `uwsm app -t service -- <entry.desktop>`, including
entries that require a terminal. Recent apps launched from this palette appear
first when the search is empty. History is stored in
`$XDG_STATE_HOME/quickshell/by-shell/<shell-id>/launcher-recent.json`
(`~/.local/state` when `XDG_STATE_HOME` is unset). To toggle it from a script, use
`quickshell ipc call launcher toggle`. Opening the launcher waits for an active
wallpaper preview to be cancelled and restored.

Launcher search and history regression checks can be run with
`node quickshell/tests/launcher.test.cjs`; Node.js is only needed for these checks.

Press `Super+v` to toggle Quickshell's clipboard manager. It uses the existing
`cliphist` history and the text/image watchers started with Hyprland. Search the
entry previews, click a type filter or use `Tab`/`Shift+Tab` to cycle through
all entries, text (including colors), links, and images. `Up`/`Down` selects an
entry; `Enter` or a click restores its original text or image to the clipboard
and closes the panel. Paste it into your app with `Ctrl+v`.

`Delete` removes the selected history entry. `Ctrl+l` requests clearing the
entire history, `Enter` confirms, and `Esc` cancels. Clearing history does not
clear the current clipboard. `Ctrl+r` refreshes manually; history also refreshes
while the panel is open. The installed cliphist 0.7 interface does not expose
timestamps, so the panel shows content types and available image details.
`quickshell ipc call clipboard toggle` opens the same integrated panel from a
script. Clipboard, launcher, monitor, and wallpaper panels coordinate keyboard focus.
The previous `scripts/clipboard_history.sh` Wofi picker remains available as legacy.

Clipboard regression checks use isolated histories and a simulated clipboard:
`node quickshell/tests/clipboard.test.cjs` and
`python quickshell/tests/clipboard_backend_test.py`.

Press `Super+F1` to toggle the Quickshell Hyprland shortcut reference on the
focused monitor. Search actions or combinations (`super+shift+0`, `terminal`,
`XF86AudioRaiseVolume`); click a category or use `Tab`/`Shift+Tab` to filter.
`Up`/`Down` browses the scrollable list. `Esc` or a click outside closes the
panel, and `Ctrl+r` refreshes it. Scripts can use
`quickshell ipc call shortcuts toggle` or `quickshell ipc call shortcuts close`.
The reference displays bindings for consultation; selecting a row does not
execute its action.

The catalog comes from `hyprctl -j binds` each time it opens, and refreshes when
Hyprland reports a configuration reload. The `bind(category, description, ... )`
helper in `hyprland.lua` keeps descriptions beside their actual bindings using
the format `Category | Action`. Existing flags and dispatchers are preserved.
Bindings without descriptions or with unfamiliar categories still appear under
`Other`, with a technical fallback when needed. Mouse, media and workspace
bindings are included. Equivalent actions share one row, with alternative
combinations separated by ` / `; search matches either combination. Bindings
with different submaps or input behavior remain separate. The modal
coordinates focus with the launcher, clipboard, monitor and wallpaper panels.

Shortcut regression checks: `node quickshell/tests/shortcuts.test.cjs` and
`lua quickshell/tests/shortcut_bindings_test.lua` (run from the repository root).

Press `Super+n` or click the bell to open the notification center. It follows
Desktop 06 in `hyprland-rice.pen`: a 430 px right drawer, a full-height scrim,
the latest notification expanded, and older entries in a scrollable history.
Click an older entry or use `Up`/`Down` to expand it. `Enter` invokes its default
action when available. `Delete` or **DELETE** removes it from history, and
`Ctrl+l` or **CLEAR ALL** clears history. `Esc`, `N` or a click outside closes
the drawer. `D` or the
**DO NOT DISTURB** control toggles quiet mode. Opening the drawer marks its
notifications read; the gold bell dot indicates unread entries while closed.

Notification toasts follow Desktop 07/09: 390 px cards at the top right of the
focused monitor, with application icons, timestamps, action buttons and image
previews. Up to three appear at once. Every popup hides after at most six seconds,
including critical alerts and notifications requesting a zero or longer timeout.
Shorter application timeout hints are honored. Hover pauses the timer. Clicking
**×** or **DISMISS** hides the popup and marks it read without removing its
history entry. DND keeps ordinary notifications in history and suppresses
their popups; critical alerts
still appear. Supported inline replies are available in the center.

Quickshell owns `org.freedesktop.Notifications`; the main shell stops
`dunst.service` after its notification server is ready to acquire that name.
Dunst's config remains as a legacy fallback and Dunst is no longer installed by
the main dependency script. Avoid launching another notification daemon while
this shell is running. Existing application notifications and `notify-send`
work without changing their callers. A replacement ID updates the existing
entry. A client close request or a non-resident action closes the live
notification as required by the protocol while retaining an inactive history
entry without obsolete action callbacks.

Ordinary notifications remain in the center after their popup hides or is
dismissed, and stay actionable while the sending application keeps them live.
Only **DELETE**, **CLEAR ALL** or eviction from the bounded 100-entry history
removes them. Image-data previews are retained in memory for archived entries
until their history entry is deleted or Quickshell reloads.
Transient notifications skip history and expire when their toast times out.
History, unread flags and DND are saved in Quickshell's state directory as
`notifications.json`. Reloads retain live actions and images without repeating
the popup. After a full process restart, saved entries are display-only;
application-owned image providers and old action callbacks are not restored.
File-backed images remain usable while their source exists. Notification text
is rendered as plain text. This panel coordinates keyboard focus with the other
desktop panels and recreates popup windows when monitors reconnect.

Scripts can call `quickshell ipc call notifications toggle`, `close`, `clear`
or `dnd`. Logic and persistence regression checks:
`node quickshell/tests/notifications.test.cjs`.

## Shared Services And Media

- [dunst](https://github.com/dunst-project/dunst): legacy notification daemon configuration; the active Hyprland shell uses Quickshell notifications.
- [mpd](https://www.musicpd.org/): music daemon used by the Waybar `mpd` module.
- [power-profiles-daemon](https://gitlab.freedesktop.org/hadess/power-profiles-daemon): exposes power profile status in Waybar.

## Legacy: Sway

- [wofi](https://github.com/SimplyCEO/wofi): launcher for Sway and the old Hyprland pickers; see [legacy configuration](wofi/README.md).
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
