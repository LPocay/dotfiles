import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import "DisplayLogic.js" as Logic

Scope {
    id: root
    property bool expanded: false
    property bool blocked: false
    property bool pendingOpen: false
    property int session: 0
    property var targetScreen: null
    property var monitors: []
    property var original: null
    property string primary: ""
    property string selectedName: ""
    property string error: ""
    property string message: ""
    readonly property var selected: monitors.find(m => m.name === selectedName) ?? null
    readonly property bool loading: scan.running
    readonly property bool applying: applyProcess.running
    readonly property bool dirty: original !== null && Logic.changed(monitors, primary, original)
    readonly property string backend: Quickshell.shellPath("services/display-layout.py")
    readonly property alias window: modal
    signal openRequested()

    function toggle(output) {
        if (applying) return;
        if (expanded || pendingOpen) { close(); return; }
        targetScreen = output ?? Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0];
        pendingOpen = true;
        openRequested();
        if (pendingOpen && !blocked) show();
    }

    function show() {
        session++;
        pendingOpen = false;
        monitors = [];
        original = null;
        error = "";
        message = "";
        expanded = true;
        refresh();
    }

    function close() {
        session++;
        pendingOpen = false;
        expanded = false;
    }

    function refresh() {
        if (!expanded || applying || loading) return;
        error = "";
        scan.requestSession = session;
        scan.running = true;
    }

    function place(name, x, y, snap) {
        if (loading || applying) return;
        monitors = Logic.place(monitors, name, x, y, snap);
        error = "";
        message = "";
    }

    function relative(anchor, direction) {
        if (loading || applying) return;
        monitors = Logic.relative(monitors, selectedName, anchor, direction);
        error = "";
        message = "";
    }

    function reset() {
        if (!original || loading || applying) return;
        monitors = monitors.map(m => Object.assign({}, m, original.monitors.find(o => o.name === m.name)));
        primary = original.primary;
        error = "";
        message = "";
    }

    function apply() {
        if (!original || !monitors.length || loading || applying) return;
        error = "";
        message = "";
        applyProcess.command = ["python3", backend, "apply", JSON.stringify(Logic.payload(monitors, primary))];
        applyProcess.running = true;
    }

    onBlockedChanged: {
        if (blocked) close();
        else if (pendingOpen) show();
    }

    IpcHandler {
        target: "displays"
        function toggle(): void { root.toggle(null); }
        function close(): void { root.close(); }
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (!root.expanded || root.applying) return;
            if (/^(monitoradded|monitorremoved|configreloaded)/.test(event.name)) {
                if (root.dirty)
                    root.error = "Monitors changed. Refresh to load their current positions.";
                else
                    refreshDelay.restart();
            }
        }
    }
    Timer { id: refreshDelay; interval: 250; onTriggered: root.refresh() }

    Process {
        id: scan
        property int requestSession: 0
        command: ["python3", root.backend, "scan"]
        stdout: StdioCollector { id: scanOutput }
        stderr: StdioCollector { id: scanError }
        onExited: (exitCode, exitStatus) => {
            if (!root.expanded) return;
            if (requestSession !== root.session) {
                Qt.callLater(root.refresh);
                return;
            }
            if (exitCode !== 0 || exitStatus !== 0) {
                root.error = scanError.text.trim() || "Could not read the monitor layout.";
                return;
            }
            try {
                const data = JSON.parse(scanOutput.text);
                root.monitors = data.monitors;
                root.primary = data.primary;
                root.original = Logic.payload(data.monitors, data.primary);
                if (!root.selected) root.selectedName = data.primary;
            } catch (_) {
                root.error = "Could not read the monitor layout.";
            }
        }
    }

    Process {
        id: applyProcess
        stdout: StdioCollector { id: applyOutput }
        stderr: StdioCollector { id: applyError }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0 || exitStatus !== 0) {
                root.error = applyError.text.trim() || "Could not apply the monitor layout.";
            } else {
                try {
                    root.message = JSON.parse(applyOutput.text).warning || "Monitor layout saved.";
                    root.original = Logic.payload(root.monitors, root.primary);
                } catch (_) {
                    root.error = "Could not verify the saved layout. Refresh to check.";
                }
            }
        }
    }

    DisplayModal { id: modal; settings: root }
}
