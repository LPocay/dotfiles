import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import "LauncherLogic.js" as Logic

Scope {
    id: root

    property bool expanded: false
    property bool blocked: false
    property bool pendingOpen: false
    property string query: ""
    property string error: ""
    property int selectedIndex: -1
    property var targetScreen: null
    property var recentIds: []
    property var applications: []
    property var results: []
    readonly property bool launching: launchProcess.running
    readonly property var selected: results[selectedIndex] ?? null
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
        pendingOpen = false;
        const name = Hyprland.focusedMonitor?.name;
        targetScreen = Quickshell.screens.find(screen => screen.name === name) ?? Quickshell.screens[0];
        query = "";
        error = "";
        refresh();
        expanded = true;
    }

    function close() {
        pendingOpen = false;
        expanded = false;
    }

    function refresh() {
        // DesktopEntries watches the XDG application directories itself.
        applications = DesktopEntries.applications.values.filter(entry => !entry.noDisplay);
        updateResults();
    }

    function updateResults() {
        results = Logic.results(applications, query, recentIds);
        selectedIndex = results.length ? 0 : -1;
    }

    function select(index) {
        if (!results.length) {
            selectedIndex = -1;
            return;
        }
        selectedIndex = (index + results.length) % results.length;
    }

    function launch(index) {
        const entry = results[index];
        if (!entry || launching)
            return;
        error = "";
        launchProcess.entryId = entry.id;
        launchProcess.command = ["uwsm", "app", "-t", "service", "--", Logic.desktopId(entry.id)];
        launchProcess.running = true;
    }

    onQueryChanged: updateResults()
    onBlockedChanged: {
        if (blocked) {
            close();
        } else if (pendingOpen) {
            show();
        }
    }

    Component.onCompleted: refresh()

    Connections {
        target: DesktopEntries
        function onApplicationsChanged() { root.refresh(); }
    }

    IpcHandler {
        target: "launcher"
        function toggle(): void { root.toggle(); }
        function close(): void { root.close(); }
    }

    FileView {
        id: history
        path: Quickshell.statePath("launcher-recent.json")
        printErrors: false
        onLoaded: {
            root.recentIds = Logic.readRecent(text());
            root.updateResults();
        }
        onSaveFailed: console.warn("App launcher: could not save recent applications.")
    }

    Process {
        id: launchProcess
        property string entryId: ""
        stderr: StdioCollector { id: launchError }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0 || exitStatus !== 0) {
                root.error = launchError.text.trim() || "Could not launch this application.";
                return;
            }
            root.recentIds = Logic.recordRecent(root.recentIds, entryId);
            history.setText(JSON.stringify(root.recentIds));
            root.updateResults();
            root.close();
        }
    }

    AppLauncherModal {
        launcher: root
    }
}
