import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import "ShortcutLogic.js" as Logic

Scope {
    id: root

    property bool expanded: false
    property bool blocked: false
    property bool pendingOpen: false
    property bool refreshQueued: false
    property int session: 0
    property int selectedIndex: -1
    property string query: ""
    property string category: "All"
    property string error: ""
    property var targetScreen: null
    property var entries: []
    property var results: []
    readonly property var categories: Logic.availableCategories(entries)
    readonly property bool loading: scan.running
    signal openRequested()

    function toggle() {
        if (expanded || pendingOpen) {
            close();
            return;
        }
        pendingOpen = true;
        openRequested();
        if (pendingOpen && !blocked)
            show();
    }

    function show() {
        session++;
        pendingOpen = false;
        const name = Hyprland.focusedMonitor?.name;
        targetScreen = Quickshell.screens.find(screen => screen.name === name) ?? Quickshell.screens[0];
        entries = [];
        query = "";
        category = "All";
        error = "";
        updateResults();
        expanded = true;
        refresh();
    }

    function close() {
        session++;
        pendingOpen = false;
        refreshQueued = false;
        expanded = false;
    }

    function updateResults(preferredId) {
        results = Logic.results(entries, query, category);
        const index = preferredId ? results.findIndex(entry => entry.id === preferredId) : -1;
        selectedIndex = results.length ? Math.max(0, index) : -1;
    }

    function select(index) {
        selectedIndex = results.length ? (index + results.length) % results.length : -1;
    }

    function cycleCategory(direction) {
        category = categories[(categories.indexOf(category) + direction + categories.length) % categories.length];
    }

    function refresh() {
        if (!expanded)
            return;
        if (loading) {
            refreshQueued = true;
            return;
        }
        refreshQueued = false;
        error = "";
        scan.requestSession = session;
        scan.running = true;
    }

    onQueryChanged: updateResults()
    onCategoryChanged: updateResults()
    onBlockedChanged: {
        if (blocked)
            close();
        else if (pendingOpen)
            show();
    }

    IpcHandler {
        target: "shortcuts"
        function toggle(): void { root.toggle(); }
        function close(): void { root.close(); }
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (root.expanded && event.name === "configreloaded")
                root.refresh();
        }
    }

    Process {
        id: scan
        property int requestSession: 0
        command: ["hyprctl", "-j", "binds"]
        stdout: StdioCollector { id: output }
        stderr: StdioCollector { id: failure }
        onExited: (exitCode, exitStatus) => {
            if (root.expanded && requestSession === root.session) {
                if (exitCode !== 0 || exitStatus !== 0) {
                    root.error = failure.text.trim() || "Could not load Hyprland shortcuts. Press Ctrl+R to retry.";
                } else {
                    try {
                        const preferredId = root.results[root.selectedIndex]?.id;
                        root.entries = Logic.parse(output.text);
                        if (!root.categories.includes(root.category))
                            root.category = "All";
                        root.updateResults(preferredId);
                    } catch (_) {
                        root.error = "Could not read Hyprland shortcuts. Press Ctrl+R to retry.";
                    }
                }
            }
            if (root.refreshQueued && root.expanded)
                Qt.callLater(root.refresh);
        }
    }

    ShortcutModal { viewer: root }
}
