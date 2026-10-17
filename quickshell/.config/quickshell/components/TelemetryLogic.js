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

// Each reading adds its own width plus one gap to the fixed bar controls.
// Widths are measured from the actual components, rather than fixed cutoffs.
function fit(metrics, budget, spacing) {
    var visible = [];
    for (var metric of metrics) {
        if (!metric.available) continue;
        var cost = metric.width + spacing;
        if (cost <= budget) {
            visible.push(metric.key);
            budget -= cost;
        }
    }
    return visible;
}
