-- Migrated from hyprland.conf
-- Refer to the wiki for more information:
-- https://wiki.hypr.land/Configuring/Start/

------------------
---- MONITORS ----
------------------

hl.monitor({
	output = "eDP-1",
	mode = "1920x1200@60",
	position = "0x0",
	scale = 1,
})

hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = 1,
})

---------------------
---- MY PROGRAMS ----
---------------------

local terminal = "uwsm app -- ghostty"
local fileManager = "uwsm app -- thunar"
local menu = "quickshell ipc call launcher toggle"

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
	-- Recover even from a clean exit when the last monitor disappears.
	hl.exec_cmd(
		"uwsm app -t service -u app-quickshell.service"
			.. " -p Restart=always -p RestartSec=5s -p StartLimitIntervalSec=0"
			.. " -p PartOf=graphical-session.target -p After=graphical-session.target"
			.. " -p ExitType=main -- quickshell --no-duplicate"
	)
	-- Quickshell is currently under evaluation and may move to legacy if we switch back.
	-- hl.exec_cmd("uwsm app -- waybar")
	hl.exec_cmd("systemctl --user start hyprpolkitagent")
	hl.exec_cmd("uwsm app -- hypridle")
	hl.exec_cmd("uwsm app -- hyprpaper")
	hl.exec_cmd("uwsm app -- wl-paste --type text --watch cliphist store")
	hl.exec_cmd("uwsm app -- wl-paste --type image --watch cliphist store")
end)


-----------------------
----- PERMISSIONS -----
-----------------------

-- Permission settings from the stock example were left commented in hyprland.conf.

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
	general = {
		gaps_in = 6,
		gaps_out = 10,

		border_size = 1,

		col = {
			active_border = "rgba(87A987ff)",
			inactive_border = "rgba(87A98766)",
		},

		resize_on_border = false,
		allow_tearing = false,
		layout = "dwindle",
	},

	decoration = {
		rounding = 0,
		rounding_power = 2,

		active_opacity = 1.0,
		inactive_opacity = 1.0,

		shadow = {
			enabled = false,
			range = 4,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},

		blur = {
			enabled = true,
			size = 6,
			passes = 2,
			ignore_opacity = false,
			noise = 0.0,
			vibrancy = 0.0,
		},
	},

	animations = {
		enabled = true,
	},
})

-- Curves and animations migrated from the original config.
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1.0 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "slide" })

hl.config({
	dwindle = {
		preserve_split = true,
	},

	master = {
		new_status = "master",
	},

	misc = {
		force_default_wallpaper = -1,
		disable_hyprland_logo = false,
	},
})

---------------
---- INPUT ----
---------------

hl.config({
	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "compose:ralt",
		kb_rules = "",

		follow_mouse = 1,
		sensitivity = 0,

		touchpad = {
			natural_scroll = false,
		},
	},
})

hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

-- The shortcut viewer reads these descriptions from `hyprctl -j binds`.
-- Keep the category and action beside the binding so the catalog stays in sync.
local function bind(category, description, keys, handler, options)
	options = options or {}
	options.description = category .. " | " .. description
	return hl.bind(keys, handler, options)
end

local function dispatch(command)
	return hl.dsp.exec_cmd("hyprctl dispatch " .. command)
end

-- Applications / session
bind("Apps", "Open terminal", mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
bind("Windows", "Close active window", mainMod .. " + Q", hl.dsp.window.close())
bind("Session", "End desktop session", mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("uwsm stop"))
bind("Apps", "Open file manager", mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
bind("Windows", "Toggle floating", mainMod .. " + SHIFT + SPACE", hl.dsp.window.float({ action = "toggle" }))
bind("Apps", "Open clipboard history", mainMod .. " + V", hl.dsp.exec_cmd("quickshell ipc call clipboard toggle"))
bind("Apps", "Open app launcher", mainMod .. " + D", hl.dsp.exec_cmd(menu))
bind("Apps", "Open app launcher", mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))
bind("Windows", "Toggle pseudotile", mainMod .. " + P", hl.dsp.window.pseudo())
bind("Windows", "Toggle maximized fullscreen", mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
bind("Groups", "Toggle window group", mainMod .. " + W", hl.dsp.group.toggle())

-- Shortcut reference
bind("Apps", "Open shortcut reference", mainMod .. " + F1", hl.dsp.exec_cmd("quickshell ipc call shortcuts toggle"))
bind("Apps", "Open notification center", mainMod .. " + N", hl.dsp.exec_cmd("quickshell ipc call notifications toggle"))

-- Move focus with mainMod + home row or arrow keys
bind("Windows", "Focus left", mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
bind("Windows", "Focus right", mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
bind("Windows", "Focus up", mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
bind("Windows", "Focus down", mainMod .. " + j", hl.dsp.focus({ direction = "down" }))
bind("Windows", "Focus left", mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
bind("Windows", "Focus right", mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
bind("Windows", "Focus up", mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
bind("Windows", "Focus down", mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Move windows with mainMod + Shift + home row or arrow keys
bind("Windows", "Swap window left", mainMod .. " + SHIFT + h", hl.dsp.window.swap({ direction = "left" }))
bind("Windows", "Swap window right", mainMod .. " + SHIFT + l", hl.dsp.window.swap({ direction = "right" }))
bind("Windows", "Swap window up", mainMod .. " + SHIFT + k", hl.dsp.window.swap({ direction = "up" }))
bind("Windows", "Swap window down", mainMod .. " + SHIFT + j", hl.dsp.window.swap({ direction = "down" }))
bind("Windows", "Swap window left", mainMod .. " + SHIFT + left", hl.dsp.window.swap({ direction = "left" }))
bind("Windows", "Swap window right", mainMod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "right" }))
bind("Windows", "Swap window up", mainMod .. " + SHIFT + up", hl.dsp.window.swap({ direction = "up" }))
bind("Windows", "Swap window down", mainMod .. " + SHIFT + down", hl.dsp.window.swap({ direction = "down" }))

-- Move window into group with mainMod + Ctrl + home row or arrow keys
bind("Groups", "Move window into group left", mainMod .. " + CTRL + h", dispatch("moveintogroup l"))
bind("Groups", "Move window into group right", mainMod .. " + CTRL + l", dispatch("moveintogroup r"))
bind("Groups", "Move window into group up", mainMod .. " + CTRL + k", dispatch("moveintogroup u"))
bind("Groups", "Move window into group down", mainMod .. " + CTRL + j", dispatch("moveintogroup d"))
bind("Groups", "Move window into group left", mainMod .. " + CTRL + left", dispatch("moveintogroup l"))
bind("Groups", "Move window into group right", mainMod .. " + CTRL + right", dispatch("moveintogroup r"))
bind("Groups", "Move window into group up", mainMod .. " + CTRL + up", dispatch("moveintogroup u"))
bind("Groups", "Move window into group down", mainMod .. " + CTRL + down", dispatch("moveintogroup d"))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	bind("Workspaces", "Switch to workspace " .. i, mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	bind("Workspaces", "Move window to workspace " .. i, mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
bind("Workspaces", "Toggle scratchpad", mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
bind("Workspaces", "Move window to scratchpad", mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Move the current workspace to another connected monitor
bind("Monitors", "Move workspace to another monitor", mainMod .. " + SHIFT + o", hl.dsp.exec_cmd("quickshell ipc call monitors toggle"))

-- Wallpaper picker
bind("Apps", "Open wallpaper picker", mainMod .. " + SHIFT + W", hl.dsp.exec_cmd([[bash "$HOME/dotfiles/scripts/wallpaper_menu.sh"]]))

-- Spotify controls popup
bind("Media", "Open Spotify controls", mainMod .. " + M", hl.dsp.exec_cmd([[bash "$HOME/dotfiles/scripts/spotify_controls.sh"]]))

-- Screenshot selection
bind("Apps", "Capture screen region", mainMod .. " + CTRL + 4", hl.dsp.exec_cmd([[grim -g "$(slurp)"]]), { locked = true, repeating = true })

-- Cycle through existing workspaces with mainMod + brackets or scroll
bind("Workspaces", "Previous workspace", mainMod .. " + bracketleft", hl.dsp.focus({ workspace = "e-1" }))
bind("Workspaces", "Next workspace", mainMod .. " + bracketright", hl.dsp.focus({ workspace = "e+1" }))
bind("Workspaces", "Next workspace", mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
bind("Workspaces", "Previous workspace", mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
bind("Mouse", "Drag window", mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
bind("Mouse", "Resize window", mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
bind("Media", "Raise volume", "XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
bind("Media", "Lower volume", "XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
bind("Media", "Mute audio output", "XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
bind("Media", "Mute microphone", "XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
bind("Media", "Raise brightness", "XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
bind("Media", "Lower brightness", "XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Requires playerctl
bind("Media", "Next track", "XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
bind("Media", "Play or pause", "XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
bind("Media", "Play or pause", "XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
bind("Media", "Previous track", "XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize",
})

hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },

	move = "20 monitor_h-120",
	float = true,
})
