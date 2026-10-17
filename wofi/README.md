# Legacy: Wofi

This configuration is retained for the Sway fallback and older Hyprland setup.
The active Hyprland session uses Quickshell for the application launcher,
clipboard manager, and workspace monitor picker. Wofi is no longer a dependency
of `scripts/install_hyprland.sh`.

The previous Wofi pickers are also retained:

- `scripts/clipboard_history.sh`
- `scripts/workspace_monitor_menu.sh`

For a legacy session, install Wofi separately and link this theme after checking
for an existing destination:

```bash
yay -S --needed wofi
ln -s "$HOME/dotfiles/wofi/.config/wofi" "$HOME/.config/wofi"
```
