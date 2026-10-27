function gpuSnapshot(text) {
    var empty = { busy: -1, vramUsed: 0, vramTotal: 0, pci: "" };
    try {
        var data = JSON.parse(text);
        if (!data || data.available !== true) return empty;
        var validVram = typeof data.vramUsed === "number" && Number.isFinite(data.vramUsed) && data.vramUsed >= 0
            && typeof data.vramTotal === "number" && Number.isFinite(data.vramTotal) && data.vramTotal > 0;
        return {
            busy: typeof data.busy === "number" && Number.isFinite(data.busy) && data.busy >= 0 && data.busy <= 100 ? Math.round(data.busy) : -1,
            vramUsed: validVram ? Math.min(data.vramUsed, data.vramTotal) : 0,
            vramTotal: validVram ? data.vramTotal : 0,
            pci: String(data.pci || "")
        };
    } catch (_) {
        return empty;
    }
}

function gib(bytes) {
    return (bytes / 1073741824).toFixed(1);
}

// Keep hidden details actionable through the SYS reading even with its panel closed.
function systemWarning(ram, temp, vramUsed, vramTotal) {
    return ram >= 90 || temp >= 85 || (vramTotal > 0 && vramUsed / vramTotal >= 0.95);
}
