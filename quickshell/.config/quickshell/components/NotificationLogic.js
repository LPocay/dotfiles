var historyLimit = 100;

function plainText(value) {
    return String(value || "").replace(/<br\s*\/?\s*>/gi, "\n").replace(/<\/?[^>]+>/g, "")
        .replace(/&lt;/g, "<").replace(/&gt;/g, ">").replace(/&quot;/g, '"')
        .replace(/&#39;|&apos;/g, "'").replace(/&amp;/g, "&");
}

function duration(notification) {
    // Every popup closes within six seconds, even if an application requests
    // an indefinite/long timeout. The notification itself stays in history.
    return notification.expireTimeout > 0 ? Math.min(notification.expireTimeout, 6000) : 6000;
}

function archive(entry) {
    if (entry.transient) return null;
    return Object.assign({}, entry, { active: false, actions: [], inlineReply: false });
}

function snapshot(notification, uid, now, previous, seen) {
    return {
        uid: uid, liveId: notification.id, timestamp: now,
        appName: String(notification.appName || notification.desktopEntry || "Application").slice(0, 256),
        summary: plainText(notification.summary || "Notification").slice(0, 4096),
        body: plainText(notification.body).slice(0, 16384),
        icon: String(notification.appIcon || ""), image: String(notification.image || ""),
        urgency: Number(notification.urgency) || 0, transient: !!notification.transient,
        unread: !seen && (!notification.lastGeneration || (previous?.unread ?? true)),
        active: true,
        actions: Array.from(notification.actions || []).map(action => ({ id: action.identifier, text: action.text })),
        inlineReply: !!notification.hasInlineReply,
        replyPlaceholder: String(notification.inlineReplyPlaceholder || "Write a reply…")
    };
}

function upsert(entries, entry) {
    return [entry].concat(entries.filter(item => item.uid !== entry.uid))
        .sort((a, b) => b.timestamp - a.timestamp).slice(0, historyLimit);
}

function serialize(entries, dnd) {
    return JSON.stringify({ version: 1, dnd: dnd, entries: entries.filter(entry => !entry.transient).map(entry => ({
        uid: entry.uid, liveId: entry.liveId, timestamp: entry.timestamp, appName: entry.appName,
        summary: entry.summary, body: entry.body, icon: entry.icon,
        // Notification image providers belong to the live server generation.
        image: entry.image.startsWith("image://") && !entry.image.startsWith("image://icon/") ? "" : entry.image,
        urgency: entry.urgency, unread: entry.unread
    })) });
}

function restore(text) {
    try {
        var data = JSON.parse(text);
        if (data.version !== 1 || !Array.isArray(data.entries)) return { dnd: false, entries: [] };
        var seen = new Set();
        var entries = data.entries.filter(entry => {
            if (!entry || typeof entry.uid !== "string" || seen.has(entry.uid) || !Number.isFinite(entry.timestamp)) return false;
            seen.add(entry.uid);
            return true;
        }).slice(0, historyLimit).map(entry => ({
            uid: entry.uid, liveId: Number(entry.liveId) || 0, timestamp: entry.timestamp,
            appName: String(entry.appName || "Application").slice(0, 256),
            summary: String(entry.summary || "Notification").slice(0, 4096), body: String(entry.body || "").slice(0, 16384),
            icon: String(entry.icon || ""), image: String(entry.image || ""), urgency: Number(entry.urgency) || 0,
            unread: !!entry.unread, active: false, transient: false, actions: [], inlineReply: false, replyPlaceholder: ""
        })).sort((a, b) => b.timestamp - a.timestamp);
        return { dnd: !!data.dnd, entries: entries };
    } catch (_) {
        return { dnd: false, entries: [] };
    }
}

function clock(timestamp) {
    var date = new Date(timestamp);
    return String(date.getHours()).padStart(2, "0") + ":" + String(date.getMinutes()).padStart(2, "0");
}

function icon(entry) {
    if (entry.image) return "image";
    if (entry.urgency === 2) return "bell";
    return "bell";
}
