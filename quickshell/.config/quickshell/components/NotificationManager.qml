pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import QtQuick
import QtQml.Models
import "NotificationLogic.js" as Logic

Scope {
    id: root

    property bool expanded: false
    property bool blocked: false
    property bool pendingOpen: false
    property bool dnd: false
    property bool stateReady: false
    property bool takeOverDunst: false
    property int sequence: 0
    property var targetScreen: null
    property var records: []
    property var live: ({})
    property var retainedImages: ({})
    property var toastStates: ({})
    property string selectedUid: ""
    property string storageError: ""
    readonly property var history: records.filter(entry => !entry.transient)
    readonly property int unreadCount: history.filter(entry => entry.unread).length
    readonly property var toastEntries: records.filter(entry => toastStates[entry.uid] && !toastStates[entry.uid].hidden)
    signal openRequested()

    function screenForFocus() {
        const name = Hyprland.focusedMonitor?.name;
        return Quickshell.screens.find(screen => screen.name === name) ?? Quickshell.screens[0] ?? null;
    }

    function toggle(screen) {
        if (expanded || pendingOpen) {
            close();
            return;
        }
        targetScreen = screen || screenForFocus();
        pendingOpen = true;
        openRequested();
        if (pendingOpen && !blocked)
            show();
    }

    function show() {
        pendingOpen = false;
        if (!Quickshell.screens.includes(targetScreen)) targetScreen = screenForFocus();
        expanded = true;
        records = records.map(entry => Object.assign({}, entry, { unread: false }));
        selectedUid = history[0]?.uid || "";
        hideToasts();
        save();
    }

    function close() {
        pendingOpen = false;
        expanded = false;
    }

    function save() {
        if (stateReady) saveDelay.restart();
    }

    function receive(notification, replacement) {
        notification.tracked = true;
        const previous = records.find(entry => (live[entry.uid] === notification)
            || (notification.lastGeneration && entry.liveId === notification.id));
        const uid = previous?.uid || Date.now() + "-" + (++sequence) + "-" + notification.id;
        const now = notification.lastGeneration && previous && !replacement ? previous.timestamp : Date.now();
        const entry = Logic.snapshot(notification, uid, now, previous, expanded && !notification.transient);
        if (replacement) entry.unread = !expanded;
        live[uid] = notification;
        // Preserve image-data previews even if the application later closes its
        // notification. These locks are released when history entries are deleted.
        if (entry.image.startsWith("image://") && !entry.image.startsWith("image://icon/") && !retainedImages[uid])
            retainedImages[uid] = imageLock.createObject(root, { object: notification });
        const previousRecords = records;
        records = Logic.upsert(records, entry);
        // Bound both the archive and the number of tracked notification objects.
        previousRecords.filter(item => !records.some(record => record.uid === item.uid)).forEach(item => remove(item.uid));
        if ((!notification.lastGeneration || replacement) && !expanded && (!dnd || entry.urgency === 2)) {
            const duration = Logic.duration(notification);
            toastStates[uid] = { screen: screenForFocus()?.name || "", remaining: duration,
                deadline: duration ? Date.now() + duration : 0, paused: false, hidden: false };
            toastStates = Object.assign({}, toastStates);
        } else {
            removeToast(uid);
            if (entry.transient) Qt.callLater(() => root.expireTransient(uid));
        }
        if (expanded && !selectedUid) selectedUid = uid;
        save();
    }

    function update(notification) {
        if (!notification) return;
        const old = records.find(entry => live[entry.uid] === notification);
        if (!old) return;
        // A replace-id update changes the existing row and resets its toast timer.
        receive(notification, true);
    }

    function removeToast(uid) {
        if (!toastStates[uid]) return;
        delete toastStates[uid];
        toastStates = Object.assign({}, toastStates);
    }

    function hideToasts() {
        const transients = records.filter(entry => entry.transient && toastStates[entry.uid]);
        toastStates = ({});
        transients.forEach(entry => expireTransient(entry.uid));
    }

    function expireTransient(uid) {
        const notification = live[uid];
        delete live[uid];
        removeToast(uid);
        records = records.filter(entry => entry.uid !== uid);
        if (notification) notification.expire();
        releaseImage(uid);
        save();
    }

    function tick() {
        const now = Date.now();
        for (const uid of Object.keys(toastStates)) {
            const state = toastStates[uid];
            if (!state.paused && state.deadline && state.deadline <= now) {
                removeToast(uid);
                if (records.find(entry => entry.uid === uid)?.transient) expireTransient(uid);
            }
        }
    }

    function pause(uid, paused) {
        const state = toastStates[uid];
        if (!state || state.paused === paused || !state.deadline) return;
        if (paused) state.remaining = Math.max(0, state.deadline - Date.now());
        else state.deadline = Date.now() + state.remaining;
        state.paused = paused;
    }

    function popupEntries(screenName) {
        return toastEntries.filter(entry => toastStates[entry.uid]?.screen === screenName).slice(0, 3);
    }

    function dismiss(uid) {
        // Dismiss only the presentation. The original notification, including
        // its actions and image, remains available in the center.
        removeToast(uid);
        markRead(uid);
        if (records.find(entry => entry.uid === uid)?.transient) expireTransient(uid);
    }

    function releaseImage(uid) {
        const lock = retainedImages[uid];
        if (!lock) return;
        delete retainedImages[uid];
        lock.locked = false;
        lock.destroy();
    }

    function remove(uid) {
        const notification = live[uid];
        delete live[uid];
        removeToast(uid);
        records = records.filter(entry => entry.uid !== uid);
        if (selectedUid === uid) selectedUid = history[0]?.uid || "";
        if (notification) notification.dismiss();
        releaseImage(uid);
        save();
    }

    function closed(notification) {
        const entry = records.find(item => live[item.uid] === notification);
        if (!entry) return;
        delete live[entry.uid];
        removeToast(entry.uid);
        // Closing the application-side notification invalidates its actions,
        // but its content remains readable in history.
        const archived = Logic.archive(entry);
        records = archived ? records.map(item => item.uid === entry.uid ? archived : item)
            : records.filter(item => item.uid !== entry.uid);
        if (!archived) {
            releaseImage(entry.uid);
            if (selectedUid === entry.uid) selectedUid = history[0]?.uid || "";
        }
        save();
    }

    function clear() {
        records.slice().forEach(entry => remove(entry.uid));
    }

    function invoke(uid, actionId) {
        const notification = live[uid];
        const action = notification?.actions.find(item => item.identifier === actionId);
        if (!action) return;
        markRead(uid);
        // Non-resident notifications are closed by Quickshell after invocation.
        action.invoke();
    }

    function reply(uid, text) {
        const notification = live[uid];
        if (notification?.hasInlineReply && text.trim()) {
            markRead(uid);
            notification.sendInlineReply(text.trim());
        }
    }

    function markRead(uid) {
        records = records.map(entry => entry.uid === uid ? Object.assign({}, entry, { unread: false }) : entry);
        save();
    }

    function step(direction) {
        const index = history.findIndex(entry => entry.uid === selectedUid);
        selectedUid = history.length ? history[(index + direction + history.length) % history.length].uid : "";
    }

    function toggleDnd() { dnd = !dnd; }

    onDndChanged: {
        if (dnd) {
            for (const entry of toastEntries) {
                if (entry.urgency !== 2) {
                    removeToast(entry.uid);
                    if (entry.transient) expireTransient(entry.uid);
                }
            }
        }
        save();
    }
    onBlockedChanged: {
        if (blocked) close();
        else if (pendingOpen) show();
    }

    Component.onCompleted: {
        const saved = Logic.restore(stateFile.text());
        dnd = saved.dnd;
        const current = records;
        records = saved.entries.filter(entry => !current.some(item => item.uid === entry.uid)).concat(current)
            .sort((a, b) => b.timestamp - a.timestamp).slice(0, Logic.historyLimit);
        stateReady = true;
    }

    NotificationServer {
        id: server
        keepOnReload: true
        persistenceSupported: true
        bodySupported: true
        bodyMarkupSupported: false
        actionsSupported: true
        imageSupported: true
        inlineReplySupported: true
        onNotification: notification => root.receive(notification)
    }
    Component { id: imageLock; RetainableLock { locked: true } }

    Instantiator {
        model: server.trackedNotifications
        delegate: NotificationTracker {
            required property var modelData
            notification: modelData
            manager: root
        }
    }

    Connections {
        target: Quickshell
        function onScreensChanged() {
            if (root.expanded && !Quickshell.screens.includes(root.targetScreen)) root.close();
            const names = Quickshell.screens.map(screen => screen.name);
            for (const uid of Object.keys(root.toastStates)) {
                if (!names.includes(root.toastStates[uid].screen)) {
                    root.removeToast(uid);
                    if (root.records.find(entry => entry.uid === uid)?.transient) root.expireTransient(uid);
                }
            }
        }
    }

    Timer { interval: 100; repeat: true; running: root.toastEntries.length > 0; onTriggered: root.tick() }
    Timer {
        id: saveDelay
        interval: 150
        onTriggered: stateFile.setText(Logic.serialize(root.records, root.dnd))
    }
    FileView {
        id: stateFile
        path: Quickshell.statePath("notifications.json")
        blockLoading: true
        printErrors: false
        onSaved: root.storageError = ""
        onSaveFailed: root.storageError = "Could not save notification history."
    }

    IpcHandler {
        target: "notifications"
        function count(): string { return String(root.unreadCount); }
        function toggle(): void { root.toggle(); }
        function close(): void { root.close(); }
        function clear(): void { root.clear(); }
        function dnd(): void { root.toggleDnd(); }
    }

    NotificationCenter { manager: root }
    // The server is already listening for the D-Bus name to become available.
    // Only the main desktop shell enables this; isolated previews leave it off.
    Process {
        command: ["sh", "-c", "if systemctl --user cat dunst.service >/dev/null 2>&1; then systemctl --user stop dunst.service; fi"]
        running: root.takeOverDunst
    }
    Variants {
        model: Quickshell.screens.filter(screen => screen.name && screen.name !== "FALLBACK")
        NotificationToasts {
            required property var modelData
            output: modelData
            manager: root
        }
    }
}
