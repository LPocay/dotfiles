function entryType(preview) {
    if (/^\[\[ binary data /.test(preview)) {
        return /\b(?:png|jpe?g|gif|webp|bmp|tiff|image\/)\b/i.test(preview) ? "image" : "binary";
    }
    if (/^(?:(?:https?|ftp):\/\/|mailto:|www\.)\S+/i.test(preview)) return "link";
    if (/^#(?:[0-9a-f]{8}|[0-9a-f]{6}|[0-9a-f]{4}|[0-9a-f]{3})(?=$|\s|[·,;])/i.test(preview)) return "color";
    return "text";
}

function parse(text) {
    var seen = new Set();
    var entries = [];
    for (var line of text.split("\n")) {
        var separator = line.indexOf("\t");
        if (separator < 1) continue;
        var id = line.slice(0, separator);
        if (!/^\d+$/.test(id) || seen.has(id)) continue;
        seen.add(id);
        var preview = line.slice(separator + 1);
        var type = entryType(preview);
        entries.push({ id: id, preview: preview, type: type,
            title: type === "image" ? "Image" : type === "binary" ? "Binary content" : preview || "(empty preview)",
            detail: type === "image" || type === "binary"
                ? preview.replace(/^\[\[ binary data\s*/, "").replace(/\s*\]\]$/, "") : "" });
    }
    return entries;
}

function normalized(value) {
    return String(value || "").normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase();
}

function results(entries, query, filter) {
    var terms = normalized(query).trim().split(/\s+/).filter(Boolean);
    return entries.filter(entry => {
        if (filter === "text" && !["text", "color"].includes(entry.type)) return false;
        if (filter === "link" && entry.type !== "link") return false;
        if (filter === "image" && entry.type !== "image") return false;
        var text = normalized(entry.preview);
        return terms.every(term => text.includes(term));
    });
}

function iconName(type) {
    return { text: "file-text", link: "link", color: "palette", image: "image", binary: "file-text" }[type] || "file-text";
}
