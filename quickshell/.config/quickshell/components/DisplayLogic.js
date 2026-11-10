function size(monitor) {
    const rotated = monitor.transform % 2 === 1;
    return { width: Math.round((rotated ? monitor.height : monitor.width) / monitor.scale),
        height: Math.round((rotated ? monitor.width : monitor.height) / monitor.scale) };
}

function bounds(monitors) {
    if (!monitors.length) return { x: 0, y: 0, width: 1, height: 1 };
    const x = Math.min(...monitors.map(m => m.x));
    const y = Math.min(...monitors.map(m => m.y));
    return { x, y, width: Math.max(...monitors.map(m => m.x + size(m).width)) - x,
        height: Math.max(...monitors.map(m => m.y + size(m).height)) - y };
}

function place(monitors, name, x, y, snap) {
    const current = monitors.find(m => m.name === name);
    if (!current) return monitors;
    const s = size(current);
    if (snap) {
        let dx = 25, dy = 25;
        for (const other of monitors.filter(m => m.name !== name)) {
            const o = size(other);
            for (const edge of [other.x, other.x + o.width, other.x - s.width, other.x + o.width - s.width])
                if (Math.abs(edge - x) < Math.abs(dx)) dx = edge - x;
            for (const edge of [other.y, other.y + o.height, other.y - s.height, other.y + o.height - s.height])
                if (Math.abs(edge - y) < Math.abs(dy)) dy = edge - y;
        }
        if (Math.abs(dx) < 25) x += dx;
        if (Math.abs(dy) < 25) y += dy;
    }
    return monitors.map(m => m.name === name ? Object.assign({}, m, { x: Math.round(x), y: Math.round(y) }) : m);
}

function relative(monitors, name, anchor, direction) {
    const current = monitors.find(m => m.name === name);
    const reference = monitors.find(m => m.name === anchor);
    if (!current || !reference || name === anchor) return monitors;
    const s = size(current), r = size(reference);
    let x = reference.x, y = reference.y;
    if (direction === "left") x -= s.width;
    if (direction === "right") x += r.width;
    if (direction === "above") y -= s.height;
    if (direction === "below") y += r.height;
    return place(monitors, name, x, y, false);
}

function payload(monitors, primary) {
    return { primary, monitors: monitors.map(m => ({ name: m.name, x: m.x, y: m.y })) };
}

function changed(monitors, primary, original) {
    return JSON.stringify(payload(monitors, primary)) !== JSON.stringify(original);
}
