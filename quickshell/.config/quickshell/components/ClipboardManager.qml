import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import "ClipboardLogic.js" as Logic

Scope {
    id: root

    property bool expanded: false
    property bool blocked: false
    property bool pendingOpen: false
    property bool pendingRefresh: false
    property bool confirmClear: false
    property string query: ""
    property string filter: "all"
    property string error: ""
    property string snapshot: ""
    property int selectedIndex: -1
    property int session: 0
    property var targetScreen: null
    property var entries: []
    property var results: []
    property var pendingAction: null
    readonly property var selected: results[selectedIndex] ?? null
    readonly property bool busy: worker.running
    readonly property bool loading: busy && worker.action === "list"
    readonly property string backend: Quickshell.shellPath("services/clipboard.sh")
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
        query = "";
        filter = "all";
        confirmClear = false;
        error = "";
        updateResults();
        expanded = true;
        refresh();
    }

    function close() {
        session++;
        pendingOpen = false;
        pendingRefresh = false;
        pendingAction = null;
        confirmClear = false;
        expanded = false;
    }

    function updateResults(preferredId, previousIndex) {
        results = Logic.results(entries, query, filter);
        const index = preferredId ? results.findIndex(entry => entry.id === preferredId) : -1;
        selectedIndex = !results.length ? -1 : index >= 0 ? index : Math.min(previousIndex ?? 0, results.length - 1);
    }

    function select(index) {
        if (confirmClear)
            return;
        selectedIndex = results.length ? (index + results.length) % results.length : -1;
    }

    function cycleFilter(offset) {
        const filters = ["all", "text", "link", "image"];
        filter = filters[(filters.indexOf(filter) + offset + filters.length) % filters.length];
    }

    function refresh() {
        if (busy) {
            pendingRefresh = true;
            return;
        }
        pendingRefresh = false;
        run("list");
    }

    function run(action, id) {
        if (busy) {
            // A background catalog refresh must not swallow Enter or Delete.
            if (worker.action === "list" && action !== "list" && !pendingAction)
                pendingAction = { action: action, id: id };
            return;
        }
        error = "";
        worker.action = action;
        worker.entryId = id ?? "";
        worker.requestSession = session;
        worker.command = ["bash", backend, action, worker.entryId];
        worker.running = true;
    }

    function runPending() {
        if (!expanded)
            return;
        if (pendingAction) {
            const request = pendingAction;
            pendingAction = null;
            run(request.action, request.id);
        } else if (pendingRefresh) {
            refresh();
        }
    }

    function copy(index) {
        const entry = results[index];
        if (entry && !confirmClear)
            run("copy", entry.id);
    }

    function remove() {
        if (selected && !confirmClear)
            run("delete", selected.id);
    }

    function requestClear() {
        if (!busy && entries.length)
            confirmClear = true;
    }

    function clear() {
        if (!confirmClear || busy)
            return;
        confirmClear = false;
        run("clear");
    }

    onQueryChanged: { confirmClear = false; updateResults(); }
    onFilterChanged: { confirmClear = false; updateResults(); }
    onBlockedChanged: {
        if (blocked)
            close();
        else if (pendingOpen)
            show();
    }

    IpcHandler {
        target: "clipboard"
        function toggle(): void { root.toggle(); }
        function close(): void { root.close(); }
    }

    Timer {
        interval: 1500
        running: root.expanded && !root.busy && !root.confirmClear && !root.error
        repeat: true
        onTriggered: root.refresh()
    }

    Process {
        id: worker
        property string action: ""
        property string entryId: ""
        property int requestSession: 0
        stdout: StdioCollector { id: output }
        stderr: StdioCollector { id: failure }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0 || exitStatus !== 0) {
                root.error = failure.text.trim() || "Could not update clipboard history.";
                root.pendingRefresh = false;
                root.pendingAction = null;
                return;
            }
            const preferredId = root.selected?.id;
            const previousIndex = Math.max(0, root.selectedIndex);
            if (action === "list") {
                if (root.snapshot !== output.text) {
                    root.snapshot = output.text;
                    root.entries = Logic.parse(output.text);
                    root.updateResults(preferredId, previousIndex);
                }
            } else if (action === "copy") {
                if (requestSession === root.session)
                    root.close();
            } else {
                root.snapshot = "";
                root.entries = action === "clear" ? [] : root.entries.filter(entry => entry.id !== entryId);
                root.updateResults(action === "delete" ? null : preferredId, previousIndex);
                root.pendingRefresh = true;
            }
            Qt.callLater(root.runPending);
        }
    }

    ClipboardModal { manager: root }
}
