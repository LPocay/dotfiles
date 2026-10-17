import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import "MonitorLogic.js" as Logic

Scope {
    id: root

    property bool expanded: false
    property bool blocked: false
    property bool pendingOpen: false
    property bool refreshQueued: false
    property int session: 0
    property int workspaceId: 0
    property int selectedIndex: -1
    property var workspace: null
    property var monitors: []
    property var targetScreen: null
    property string error: ""
    readonly property bool loading: scan.running
    readonly property bool moving: moveProcess.running
    readonly property var selected: monitors[selectedIndex] ?? null
    readonly property bool canMove: !loading && !moving && workspace !== null && selected !== null && selected.name !== workspace.monitor
    readonly property string backend: Quickshell.shellPath("services/workspace-monitor.sh")
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
        workspaceId = 0;
        workspace = null;
        monitors = [];
        selectedIndex = -1;
        error = "";
        const name = Hyprland.focusedMonitor?.name;
        targetScreen = Quickshell.screens.find(screen => screen.name === name) ?? Quickshell.screens[0];
        expanded = true;
        refresh();
    }

    function close() {
        session++;
        pendingOpen = false;
        refreshQueued = false;
        expanded = false;
    }

    function refresh(preserveError) {
        if (!expanded || moving)
            return;
        if (loading) {
            refreshQueued = true;
            return;
        }
        refreshQueued = false;
        if (!preserveError)
            error = "";
        scan.requestSession = session;
        scan.command = ["bash", backend, "scan", workspaceId > 0 ? String(workspaceId) : ""];
        scan.running = true;
    }

    function step(direction) {
        if (!moving && workspace)
            selectedIndex = Logic.next(monitors, workspace.monitor, selectedIndex, direction);
    }

    function select(index) {
        const monitor = monitors[index];
        if (!moving && workspace && monitor && monitor.name !== workspace.monitor)
            selectedIndex = index;
    }

    function move() {
        if (!canMove)
            return;
        error = "";
        moveProcess.requestSession = session;
        moveProcess.command = ["bash", backend, "move", String(workspaceId), selected.name];
        moveProcess.running = true;
    }

    onBlockedChanged: {
        if (blocked)
            close();
        else if (pendingOpen)
            show();
    }

    IpcHandler {
        target: "monitors"
        function toggle(): void { root.toggle(); }
        function close(): void { root.close(); }
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (root.expanded && /^(monitoradded|monitorremoved|moveworkspace|createworkspace|destroyworkspace|renameworkspace|openwindow|closewindow)/.test(event.name))
                refreshDelay.restart();
        }
    }

    Timer {
        id: refreshDelay
        interval: 150
        onTriggered: root.refresh(true)
    }

    Process {
        id: scan
        property int requestSession: 0
        stdout: StdioCollector { id: catalog }
        stderr: StdioCollector { id: scanError }
        onExited: (exitCode, exitStatus) => {
            if (root.expanded && requestSession === root.session) {
                if (exitCode !== 0 || exitStatus !== 0) {
                    root.monitors = [];
                    root.selectedIndex = -1;
                    root.error = scanError.text.trim() || "Could not load connected monitors.";
                } else {
                    try {
                        const data = JSON.parse(catalog.text);
                        const preferred = root.selected?.name;
                        root.workspace = data.workspace;
                        root.workspaceId = data.workspace.id;
                        root.monitors = Logic.order(data.monitors);
                        root.selectedIndex = Logic.selection(root.monitors, data.workspace.monitor, preferred);
                    } catch (_) {
                        root.monitors = [];
                        root.selectedIndex = -1;
                        root.error = "Could not read monitor information.";
                    }
                }
            }
            if (root.refreshQueued && root.expanded)
                Qt.callLater(() => root.refresh(true));
        }
    }

    Process {
        id: moveProcess
        property int requestSession: 0
        stderr: StdioCollector { id: moveError }
        onExited: (exitCode, exitStatus) => {
            if (!root.expanded || requestSession !== root.session)
                return;
            if (exitCode !== 0 || exitStatus !== 0) {
                root.error = moveError.text.trim() || "Could not move the workspace.";
                Qt.callLater(() => root.refresh(true));
            } else {
                root.close();
            }
        }
    }

    MonitorModal { picker: root }
}
