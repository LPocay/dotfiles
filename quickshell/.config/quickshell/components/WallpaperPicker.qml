import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

Scope {
    id: root

    property bool expanded: false
    property bool loading: false
    property bool finishing: false
    property bool touched: false
    property string error: ""
    property var wallpapers: []
    property var outputs: []
    property var selectedOutputs: []
    property int selectedIndex: -1
    property var targetScreen: null
    property var pendingRequest: null
    readonly property var selected: wallpapers[selectedIndex] ?? null
    readonly property bool canApply: !loading && !finishing && selected !== null && selectedOutputs.length > 0
    readonly property string backend: Quickshell.shellPath("services/wallpaper.sh")

    function toggle() {
        if (finishing)
            return;
        if (expanded) {
            cancel();
            return;
        }
        const name = Hyprland.focusedMonitor?.name;
        targetScreen = Quickshell.screens.find(s => s.name === name) ?? Quickshell.screens[0];
        error = "";
        wallpapers = [];
        outputs = [];
        selectedOutputs = [];
        selectedIndex = -1;
        touched = false;
        loading = true;
        expanded = true;
        scan.running = true;
    }

    function select(index) {
        if (loading || finishing || !wallpapers.length)
            return;
        selectedIndex = (index + wallpapers.length) % wallpapers.length;
        preview();
    }

    function toggleOutput(name) {
        if (loading || finishing)
            return;
        selectedOutputs = selectedOutputs.includes(name) ? selectedOutputs.filter(n => n !== name) : [...selectedOutputs, name];
        preview();
    }

    function cycleOutput() {
        if (!outputs.length || finishing)
            return;
        const index = outputs.findIndex(o => o.name === selectedOutputs[0]);
        selectedOutputs = [outputs[(index + 1) % outputs.length].name];
        preview();
    }

    function preview() {
        if (!selected || loading || finishing)
            return;
        // Never preview an output whose previous image cannot be restored.
        if (outputs.some(o => selectedOutputs.includes(o.name) && !o.wallpaper)) {
            error = "No previous wallpaper. Apply to set it; live preview is unavailable.";
            return;
        }
        touched = true;
        enqueue("preview");
    }

    function enqueue(action) {
        pendingRequest = {
            action: action,
            payload: JSON.stringify({
                selected: selected?.path ?? "",
                outputs: outputs.filter(o => o.wallpaper || (action !== "restore" && selectedOutputs.includes(o.name))).map(o => ({
                    name: o.name,
                    path: action !== "restore" && selectedOutputs.includes(o.name) ? selected.path : o.wallpaper
                }))
            })
        };
        runNext();
    }

    function runNext() {
        if (worker.running || !pendingRequest)
            return;
        const request = pendingRequest;
        pendingRequest = null;
        worker.action = request.action;
        worker.command = ["bash", backend, request.action, request.payload];
        worker.running = true;
    }

    function apply() {
        if (!canApply)
            return;
        finishing = true;
        enqueue("apply");
    }

    function cancel() {
        if (finishing)
            return;
        if (!touched) {
            expanded = false;
            return;
        }
        finishing = true;
        enqueue("restore");
    }

    IpcHandler {
        target: "wallpaper"
        function toggle(): void { root.toggle(); }
    }

    Process {
        id: scan
        command: ["bash", root.backend, "scan"]
        stdout: StdioCollector { id: catalog }
        stderr: StdioCollector { id: scanError }
        onExited: (exitCode, exitStatus) => {
            root.loading = false;
            if (!root.expanded)
                return;
            if (exitCode !== 0 || exitStatus !== 0) {
                root.error = scanError.text.trim() || "Could not load wallpapers.";
                return;
            }
            try {
                const data = JSON.parse(catalog.text);
                root.wallpapers = data.wallpapers;
                root.outputs = data.outputs;
                const output = data.outputs.find(o => o.name === data.preferredOutput)
                    ?? data.outputs.find(o => o.focused) ?? data.outputs[0];
                root.selectedOutputs = output ? [output.name] : [];
                const index = data.wallpapers.findIndex(w => w.path === (output?.wallpaper || data.current));
                root.selectedIndex = data.wallpapers.length ? Math.max(0, index) : -1;
            } catch (e) {
                root.error = "Could not read wallpaper catalog: " + e;
            }
        }
    }

    // One worker serializes changes; rapid navigation replaces only the queued
    // preview. Apply/cancel always runs after any preview already in flight.
    Process {
        id: worker
        property string action: ""
        stdout: StdioCollector { id: workerOutput }
        stderr: StdioCollector { id: workerError }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0 || exitStatus !== 0) {
                root.error = workerError.text.trim() || workerOutput.text.trim() || "Could not update wallpaper.";
                if (action !== "preview")
                    root.finishing = false;
            } else {
                root.error = "";
                if (action === "apply" || action === "restore") {
                    root.expanded = false;
                    root.finishing = false;
                    root.touched = false;
                }
            }
            Qt.callLater(root.runNext);
        }
    }

    WallpaperDrawer {
        picker: root
    }
}
