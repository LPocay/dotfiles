-- Validate the actual config without starting processes or touching the session.
local function proxy(path)
	return setmetatable({}, {
		__index = function(_, key) return proxy(path .. "." .. key) end,
		__call = function(_, ...) return { dispatcher = path, args = { ... } } end,
	})
end

local bindings = {}
hl = proxy("hl")
hl.bind = function(keys, handler, options)
	assert(type(options.description) == "string" and options.description:match("^%w+ | .+"), keys .. " needs a description")
	assert(not bindings[keys], "Duplicate binding: " .. keys)
	bindings[keys] = { handler = handler, options = options }
end
assert(loadfile("hypr/.config/hypr/hyprland.lua"))()

local shortcuts = assert(bindings["SUPER + F1"])
assert(shortcuts.handler.args[1] == "quickshell ipc call shortcuts toggle")
for i = 1, 10 do
	local key = i % 10
	assert(bindings["SUPER + " .. key].options.description == "Workspaces | Switch to workspace " .. i)
	assert(bindings["SUPER + SHIFT + " .. key].options.description == "Workspaces | Move window to workspace " .. i)
end
assert(bindings["SUPER + mouse:272"].options.mouse)
assert(bindings["SUPER + mouse:273"].options.mouse)
assert(bindings["SUPER + CTRL + 4"].options.locked)
assert(bindings["SUPER + CTRL + 4"].options.repeating)
for _, key in ipairs({ "XF86AudioRaiseVolume", "XF86AudioLowerVolume", "XF86AudioMute", "XF86AudioMicMute", "XF86MonBrightnessUp", "XF86MonBrightnessDown" }) do
	assert(bindings[key].options.locked and bindings[key].options.repeating, key .. " lost its flags")
end
local count = 0
for _ in pairs(bindings) do count = count + 1 end
assert(bindings["SUPER + N"].handler.args[1] == "quickshell ipc call notifications toggle")
assert(bindings["SUPER + bracketleft"].handler.args[1].workspace == "e-1")
assert(bindings["SUPER + bracketright"].handler.args[1].workspace == "e+1")
assert(count == 79, "Expected all 77 existing bindings plus previous/next workspace shortcuts")
print("All 79 bindings have descriptions; workspace targets, IPC and input flags verified.")
