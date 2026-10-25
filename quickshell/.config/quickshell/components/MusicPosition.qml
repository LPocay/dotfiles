import Quickshell
import Quickshell.Io
import QtQuick
import "MusicLogic.js" as Logic

Scope {
    id: root

    property var player: null
    property bool active: false
    property real position: 0
    property bool refreshPending: false
    readonly property string trackKey: player
        ? JSON.stringify([player.dbusName, player.uniqueId, player.trackTitle, player.trackArtist, player.trackAlbum])
        : ""

    function refresh() {
        if (!active || !player)
            return;
        if (query.running) {
            refreshPending = true;
            return;
        }
        refreshPending = false;
        query.requestTrack = trackKey;
        query.command = ["playerctl", "--player", player.dbusName.replace(/^org\.mpris\.MediaPlayer2\./, ""), "position"];
        query.running = true;
    }

    onTrackKeyChanged: {
        position = 0;
        refresh();
    }
    onActiveChanged: {
        if (active)
            refresh();
        else
            refreshPending = false;
    }

    Connections {
        target: root.player
        function onPlaybackStateChanged() { root.refresh(); }
    }

    // Read the real position, including seeks and track changes not announced
    // with MPRIS Seeked. Do not extrapolate from Quickshell's cached position.
    Timer {
        interval: 1000
        repeat: true
        running: root.active && root.player !== null
        onTriggered: root.refresh()
    }

    Process {
        id: query
        property string requestTrack: ""
        stdout: StdioCollector { id: output }
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0 && exitStatus === 0 && root.active && requestTrack === root.trackKey) {
                const seconds = Logic.parsePosition(output.text);
                if (seconds !== null)
                    root.position = seconds;
            }
            if (root.refreshPending && root.active)
                Qt.callLater(root.refresh);
        }
    }
}
