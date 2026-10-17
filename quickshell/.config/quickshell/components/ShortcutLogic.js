// Descriptions live beside the bindings: "Category | Human-readable action".
var categories = ["All", "Apps", "Session", "Windows", "Groups", "Workspaces", "Monitors", "Media", "Mouse", "Other"];

function normalized(value) {
    return String(value ?? "").normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase();
}

function keyLabel(bind) {
    var key = String(bind.key || "");
    var names = {
        RETURN: "Enter", SPACE: "Space", LEFT: "←", RIGHT: "→", UP: "↑", DOWN: "↓",
        mouse_down: "Wheel ↓", mouse_up: "Wheel ↑", "mouse:272": "LMB", "mouse:273": "RMB",
        "mouse:274": "MMB", XF86AudioRaiseVolume: "Volume ↑", XF86AudioLowerVolume: "Volume ↓",
        XF86AudioMute: "Mute", XF86AudioMicMute: "Mic mute", XF86MonBrightnessUp: "Brightness ↑",
        XF86MonBrightnessDown: "Brightness ↓", XF86AudioNext: "Next track", XF86AudioPrev: "Previous track",
        XF86AudioPause: "Pause", XF86AudioPlay: "Play"
    };
    return names[key] || names[key.toUpperCase()] || (key.length === 1 ? key.toUpperCase() : key)
        || (bind.keycode ? "Code " + bind.keycode : "Any key");
}

function combination(bind) {
    var mask = Number(bind.modmask) || 0;
    var parts = [];
    // Hyprland uses the XKB modifier mask, including less common modifiers.
    [[64, "Super"], [4, "Ctrl"], [8, "Alt"], [1, "Shift"], [2, "Caps"],
        [16, "Mod2"], [32, "Mod3"], [128, "Mod5"]].forEach(mod => {
        if (mask & mod[0]) parts.push(mod[1]);
    });
    parts.push(keyLabel(bind));
    return parts.join(" + ");
}

function parse(text) {
    var data = JSON.parse(text);
    if (!Array.isArray(data)) throw new Error("Expected a list of bindings");
    var groups = new Map();
    data.filter(bind => bind && typeof bind === "object" && !Array.isArray(bind)).forEach(bind => {
        var description = String(bind.description || "").trim();
        var separator = description.indexOf(" | ");
        var prefix = separator >= 0 ? description.slice(0, separator) : "";
        var categorized = categories.slice(1).includes(prefix);
        var category = categorized ? prefix : "Other";
        var action = categorized ? description.slice(separator + 3).trim() : description;
        var technical = [bind.dispatcher || bind.handler, bind.arg].filter(value => value !== undefined && value !== "").join(" ");
        var flags = [];
        if (bind.release) flags.push("on release");
        if (bind.repeat || bind.repeating) flags.push("repeat");
        if (bind.longPress || bind.long_press) flags.push("long press");
        if (bind.locked) flags.push("while locked");
        if (bind.mouse || bind.drag) flags.push("drag");
        if (bind.non_consuming) flags.push("pass through");
        var submap = String(bind.submap || "");
        var keys = combination(bind);
        // Lua callback IDs differ even for equivalent actions. Descriptions are
        // their semantic identity; unnamed callbacks stay separate. Native
        // dispatchers must also match their command and arguments.
        var dispatcher = bind.dispatcher || bind.handler || "";
        var context = [submap, !!bind.release, !!(bind.repeat || bind.repeating),
            !!(bind.longPress || bind.long_press), !!bind.locked, !!(bind.mouse || bind.drag),
            !!bind.non_consuming, !!bind.ignore_mods, !!bind.transparent, !!bind.dont_inhibit,
            bind.submap_universal === true || bind.submap_universal === "true",
            !!bind.catch_all, !!bind.auto_consuming, !!bind.allow_input_capture,
            bind.devices ?? null, bind.device_inclusive ?? null];
        var id = action ? JSON.stringify([category, action, dispatcher,
            dispatcher === "__lua" ? "" : bind.arg ?? "", context]) : JSON.stringify(bind);
        var group = groups.get(id);
        if (!group) {
            group = {
                id: id, category: category, action: action || technical || "Unnamed binding",
                combinations: [], searches: [], bindingCount: 0,
                detail: [category, submap ? "submap: " + submap : "", flags.join(", ")].filter(Boolean).join("  ·  ")
            };
            groups.set(id, group);
        }
        if (!group.combinations.includes(keys)) group.combinations.push(keys);
        group.searches.push(normalized([action || technical, category, keys, bind.key,
            bind.keycode || "", submap, flags.join(" ")].join(" ")));
        group.bindingCount++;
        group.keys = group.combinations.join(" / ");
    });
    return Array.from(groups.values()).sort((a, b) => categories.indexOf(a.category) - categories.indexOf(b.category)
        || a.action.localeCompare(b.action) || a.keys.localeCompare(b.keys));
}

function results(entries, query, category) {
    var terms = normalized(query).replace(/\b(?:win|mod4)\b/g, "super").replace(/\bcontrol\b/g, "ctrl").split(/[\s+]+/).filter(Boolean);
    return entries.filter(entry => (category === "All" || category === entry.category)
        && entry.searches.some(search => terms.every(term => search.includes(term))));
}

function availableCategories(entries) {
    return categories.filter(category => category === "All" || entries.some(entry => entry.category === category));
}
