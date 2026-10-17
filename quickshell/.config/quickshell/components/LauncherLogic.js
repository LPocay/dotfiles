// Pure helpers shared by the controller and its regression checks.
function normalized(value) {
    return String(value || "").normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase();
}

function score(entry, query) {
    var name = normalized(entry.name);
    var details = normalized([entry.genericName, entry.comment, entry.id,
        (entry.keywords || []).join(" ")].join(" "));
    var terms = normalized(query).trim().split(/\s+/).filter(Boolean);
    var total = 0;
    for (var term of terms) {
        if (name === term) total += 100;
        else if (name.startsWith(term)) total += 70;
        else if (name.includes(term)) total += 50;
        else if (details.includes(term)) total += 20;
        else {
            var position = -1;
            for (var character of term) {
                position = name.indexOf(character, position + 1);
                if (position < 0) return -1;
            }
            total += 5;
        }
    }
    return total;
}

function results(entries, query, recentIds) {
    var recent = new Map(recentIds.map((id, index) => [id, index]));
    return entries.map(entry => ({ entry: entry, score: score(entry, query) }))
        .filter(result => result.score >= 0)
        .sort((a, b) => b.score - a.score
            || (recent.get(a.entry.id) ?? 1000) - (recent.get(b.entry.id) ?? 1000)
            || a.entry.name.localeCompare(b.entry.name)
            || a.entry.id.localeCompare(b.entry.id))
        .map(result => result.entry);
}

function readRecent(text) {
    try {
        var data = JSON.parse(text);
        if (!Array.isArray(data)) return [];
        return [...new Set(data.filter(id => typeof id === "string" && id.length > 0))].slice(0, 50);
    } catch (_) {
        return [];
    }
}

function recordRecent(recentIds, id) {
    return [id, ...recentIds.filter(previous => previous !== id)].slice(0, 50);
}

function desktopId(id) {
    return id.endsWith(".desktop") ? id : id + ".desktop";
}

function iconName(entry) {
    var categories = entry.categories || [];
    if (categories.includes("TerminalEmulator")) return "terminal";
    if (categories.includes("WebBrowser") || categories.includes("Network")) return "globe";
    if (categories.includes("FileManager")) return "folder";
    if (categories.includes("Settings")) return "settings-2";
    return "app-window";
}
