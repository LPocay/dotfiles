# Shortcut Cheat Sheet

This cheat sheet reflects the current shortcut state after the standard-keyboard remap pass.

## Hyprland

File: `hypr/.config/hypr/hyprland.conf`

### Core

- `Super+Return`: open terminal (`ghostty`)
- `Super+q`: close active window
- `Super+Shift+m`: exit Hyprland session
- `Super+e`: open file manager (`thunar`)
- `Super+Shift+Space`: toggle floating
- `Super+v`: open clipboard history picker
- `Super+d`: app launcher (`wofi --show drun`)
- `Super+p`: toggle pseudotile
- `Super+t`: toggle split
- `Super+f`: fullscreen
- `Super+w`: toggle group
- `Super+Ctrl+4`: screenshot region with `grim` + `slurp`

### Focus windows

- `Super+h`: focus left
- `Super+j`: focus down
- `Super+k`: focus up
- `Super+l`: focus right
- `Super+Left`: focus left
- `Super+Down`: focus down
- `Super+Up`: focus up
- `Super+Right`: focus right

### Move windows

- `Super+Shift+h`: move window left
- `Super+Shift+j`: move window down
- `Super+Shift+k`: move window up
- `Super+Shift+l`: move window right
- `Super+Shift+Left`: move window left
- `Super+Shift+Down`: move window down
- `Super+Shift+Up`: move window up
- `Super+Shift+Right`: move window right

### Move into group

- `Super+Ctrl+h`: move window into group left
- `Super+Ctrl+j`: move window into group down
- `Super+Ctrl+k`: move window into group up
- `Super+Ctrl+l`: move window into group right
- `Super+Ctrl+Left`: move window into group left
- `Super+Ctrl+Down`: move window into group down
- `Super+Ctrl+Up`: move window into group up
- `Super+Ctrl+Right`: move window into group right

### Workspaces

- `Super+1..9`: switch to workspace `1..9`
- `Super+0`: switch to workspace `10`
- `Super+Shift+1..9`: move active window to workspace `1..9`
- `Super+Shift+0`: move active window to workspace `10`
- `Super+s`: toggle special workspace `magic`
- `Super+Shift+s`: move active window to special workspace `magic`
- `Super+MouseWheelDown`: next workspace
- `Super+MouseWheelUp`: previous workspace

### Mouse and media

- `Super+LeftMouse`: drag window
- `Super+RightMouse`: resize window
- `XF86AudioRaiseVolume`: volume up
- `XF86AudioLowerVolume`: volume down
- `XF86AudioMute`: mute output
- `XF86AudioMicMute`: mute mic
- `XF86MonBrightnessUp`: brightness up
- `XF86MonBrightnessDown`: brightness down
- `XF86AudioNext`: next track
- `XF86AudioPause`: play/pause
- `XF86AudioPlay`: play/pause
- `XF86AudioPrev`: previous track
- `Super+M`: Spotify controls popup (play/pause, next, previous, now playing info)

## tmux

File: `tmux/.tmux.conf`

### Prefix

- `Ctrl+a`: tmux prefix
- `Ctrl+a Ctrl+a`: send literal prefix

### Panes and windows

- `Prefix+-`: horizontal split
- `Prefix+|`: vertical split
- `Prefix+"`: split using legacy tmux key
- `Prefix+%`: split using legacy tmux key
- `Prefix+h`: focus left pane
- `Prefix+j`: focus down pane
- `Prefix+k`: focus up pane
- `Prefix+l`: focus right pane
- `Prefix+H`: resize pane left
- `Prefix+J`: resize pane down
- `Prefix+K`: resize pane up
- `Prefix+L`: resize pane right
- `Prefix+c`: new window in current path
- `Prefix+x`: kill current pane
- `Prefix+z`: zoom/unzoom pane
- `Prefix+,`: rename window

### Copy mode

- `Prefix+[` or enter copy mode by your usual tmux command if configured elsewhere
- In copy-mode vi:
- `v`: begin selection
- `y`: copy selection to system clipboard with `xclip`

## Neovim

Files:

- `nvim/.config/nvim/init.lua`
- `nvim/.config/nvim/lua/lpocay/plugins/oil.lua`
- `nvim/.config/nvim/lua/lpocay/plugins/conform.lua`
- `nvim/.config/nvim/lua/lpocay/plugins/telescope.lua`
- `nvim/.config/nvim/lua/lpocay/plugins/gisigns.lua`
- `nvim/.config/nvim/lua/lpocay/plugins/mini.lua`
- `nvim/.config/nvim/lua/lpocay/plugins/cmp.lua`

### Leader and core

- `Leader`: `Space`
- `LocalLeader`: `Space`
- `<Esc>`: clear search highlight
- `<leader>e`: Oil explorer in floating window
- `<leader>pv`: Oil explorer alias / project view
- `<leader>f`: format buffer
- `<leader>q`: open diagnostic location list
- `<leader>u`: update Vim packages with `vim.pack.update()`
- Terminal `Esc Esc`: exit terminal mode

### Window navigation

- `<C-h>`: focus left window
- `<C-j>`: focus lower window
- `<C-k>`: focus upper window
- `<C-l>`: focus right window

### Editing and clipboard

- Visual `J`: move selected lines down
- Visual `K`: move selected lines up
- Visual `<leader>p`: paste without overwriting unnamed register
- `<leader>p`: paste from system clipboard
- `<leader>y`: yank to system clipboard
- `<leader>Y`: yank line to system clipboard
- `<leader>d`: delete without overwriting unnamed register
- `<leader>s`: substitute word under cursor

### Buffers

- `<leader><leader>`: Telescope buffer picker

### LSP and code

- `grr`: go to references
- `gri`: go to implementation
- `grd`: go to definition
- `grt`: go to type definition
- `gO`: document symbols
- `gW`: workspace symbols

### Search and pickers (Telescope)

- `<leader>/`: fuzzy search current buffer
- `<leader>sh`: search help
- `<leader>sk`: search keymaps
- `<leader>sf`: search files
- `<leader>ss`: Telescope builtin selector
- `<leader>sw`: grep current word / visual selection
- `<leader>sg`: live grep
- `<leader>sd`: search diagnostics
- `<leader>sr`: resume picker
- `<leader>s.`: recent files
- `<leader>sc`: search commands
- `<leader>s/`: live grep open files
- `<leader>sn`: search Neovim config files

### Git and hunks (Gitsigns)

- `]c`: next git change
- `[c`: previous git change
- `<leader>hs`: stage hunk
- `<leader>hr`: reset hunk
- `<leader>hS`: stage buffer
- `<leader>hR`: reset buffer
- `<leader>hp`: preview hunk
- `<leader>hi`: preview hunk inline
- `<leader>hb`: blame line
- `<leader>hd`: diff against index
- `<leader>hD`: diff against last commit
- `<leader>hQ`: repo-wide hunks quickfix
- `<leader>hq`: current-file hunks quickfix
- `<leader>tb`: toggle current-line blame
- `<leader>tw`: toggle intra-line word diff
- `ih` (operator/visual): select hunk

### Mini.nvim

- `aa`: around next text object (mini.ai)
- `ii`: inside next text object (mini.ai)
- `sa`: add surrounding (mini.surround)
- `sd`: delete surrounding (mini.surround)
- `sr`: replace surrounding (mini.surround)
- `sf` / `sF`: find surrounding (mini.surround)
- `sh`: highlight surrounding (mini.surround)

### Completion (blink.cmp)

- `<C-space>`: show / hide completion
- `<C-e>`: hide completion
- `<CR>`: accept selected item
- `<Tab>` / `<S-Tab>`: select next / previous item
- `<C-n>` / `<C-p>`: select next / previous item
- `<C-g>`: show completion documentation

## kitty

File: `kitty/.config/kitty/kitty.conf`

- `Ctrl+Shift+t`: new tab
- `Ctrl+Shift+]`: next tab
- `Ctrl+Shift+[` : previous tab
- `Ctrl+Shift+,`: rename tab

## WezTerm

File: `wezterm/.wezterm.lua`

- `Ctrl+Shift+t`: new tab
- `Ctrl+Shift+[`: previous tab
- `Ctrl+Shift+]`: next tab
- `Ctrl+Shift+;`: rename tab
- `Ctrl+Shift+w`: close current tab

## Ghostty

No active custom shortcuts in repo.

## Alacritty

No active custom shortcuts in repo.

## Sway (legacy)

File: `sway/.config/sway/config`

### Core

- `$mod+Return`: terminal
- `$mod+Shift+q`: kill focused window
- `$mod+d`: launcher
- `$mod+Shift+c`: reload config
- `$mod+Shift+e`: exit sway with confirmation
- `$mod+Shift+s`: screenshot region
- `$mod+x`: move workspace to next output

### Focus

- `$mod+$left/$down/$up/$right`: focus left/down/up/right
- `$mod+Left/Down/Up/Right`: focus left/down/up/right

### Move windows

- `$mod+Shift+$left/$down/$up/$right`: move left/down/up/right
- `$mod+Shift+Left/Down/Up/Right`: move left/down/up/right

### Workspaces

- `$mod+1..9`: switch workspace `1..9`
- `$mod+0`: switch workspace `10`
- `$mod+Shift+1..9`: move container to workspace `1..9`
- `$mod+Shift+0`: move container to workspace `10`

### Layout and scratchpad

- `$mod+b`: horizontal split
- `$mod+v`: vertical split
- `$mod+s`: stacking layout
- `$mod+w`: tabbed layout
- `$mod+e`: toggle split layout
- `$mod+f`: fullscreen
- `$mod+Shift+space`: toggle floating
- `$mod+space`: focus mode toggle
- `$mod+a`: focus parent
- `$mod+Shift+minus`: move to scratchpad
- `$mod+minus`: show scratchpad
- `$mod+r`: enter resize mode

### Resize mode

- `$left/$down/$up/$right`: resize using home-row variables
- `Left/Down/Up/Right`: resize using arrow keys
- `Return` or `Escape`: leave resize mode

## i3 (legacy)

File: `i3/.config/i3/config`

### Core

- `$mod+Return`: terminal
- `$mod+d`: rofi launcher
- `$mod+Shift+c`: reload config
- `$mod+Shift+r`: restart i3
- `$mod+Shift+e`: exit i3 with confirmation
- `$mod+x`: move workspace to next output

### Focus

- `$mod+j`: focus left
- `$mod+k`: focus down
- `$mod+l`: focus up
- `$mod+ntilde`: focus right
- `$mod+Left/Down/Up/Right`: focus left/down/up/right

### Move windows

- `$mod+Shift+j`: move left
- `$mod+Shift+k`: move down
- `$mod+Shift+l`: move up
- `$mod+Shift+ntilde`: move right
- `$mod+Shift+Left/Down/Up/Right`: move left/down/up/right

### Layout and workspaces

- `$mod+h`: horizontal split
- `$mod+v`: vertical split
- `$mod+f`: fullscreen
- `$mod+s`: stacking layout
- `$mod+w`: tabbed layout
- `$mod+e`: toggle split layout
- `$mod+Shift+space`: toggle floating
- `$mod+space`: focus mode toggle
- `$mod+a`: focus parent
- `$mod+1..9`: switch workspace `1..9`
- `$mod+0`: switch workspace `10`
- `$mod+Shift+1..9`: move container to workspace `1..9`
- `$mod+Shift+0`: move container to workspace `10`
- `$mod+Shift+minus`: move to scratchpad
- `$mod+minus`: show scratchpad
- `$mod+r`: enter resize mode

### Resize mode

- `j`: resize shrink width
- `k`: resize grow height
- `l`: resize shrink height
- `ntilde`: resize grow width
- `Left/Down/Up/Right`: resize with arrows
- `Return`, `Escape`, or `$mod+r`: leave resize mode
