function order(monitors) {
    return monitors.slice().sort((a, b) => (a.x ?? 0) - (b.x ?? 0)
        || (a.y ?? 0) - (b.y ?? 0) || a.name.localeCompare(b.name));
}

function selection(monitors, current, preferred) {
    var index = monitors.findIndex(monitor => monitor.name === preferred && monitor.name !== current);
    return index >= 0 ? index : monitors.findIndex(monitor => monitor.name !== current);
}

function next(monitors, current, index, direction) {
    if (index < 0) index = direction > 0 ? -1 : 0;
    for (var offset = 1; offset <= monitors.length; offset++) {
        var candidate = (index + offset * direction + monitors.length * 2) % monitors.length;
        if (monitors[candidate].name !== current) return candidate;
    }
    return -1;
}

function mode(monitor) {
    var rotated = monitor.transform % 2 === 1;
    var width = rotated ? monitor.height : monitor.width;
    var height = rotated ? monitor.width : monitor.height;
    return width + "×" + height + "  ·  " + Math.round(monitor.refreshRate) + " Hz  ·  scale " + monitor.scale;
}

function workspaceLabel(workspace) {
    return workspace.name && workspace.name !== String(workspace.id)
        ? workspace.name : String(workspace.id).padStart(2, "0");
}
