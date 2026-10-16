import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts
import "../theme/"

PopupWindow {
    id: musicPopup
    implicitWidth: 350
    implicitHeight: content.implicitHeight + 40

    property bool expanded: false

    // Prefer a playing player, otherwise fall back to the first available one
    readonly property var player: {
        const list = Mpris.players.values;
        return list.find(p => p.isPlaying) ?? list[0] ?? null;
    }
    readonly property bool hasPlayer: player !== null
    readonly property bool playing: hasPlayer && player.isPlaying
    readonly property string title: hasPlayer && player.trackTitle ? player.trackTitle : "NO MEDIA"
    readonly property string artist: hasPlayer && player.trackArtist ? player.trackArtist : "—"
    readonly property int elapsed: hasPlayer ? Math.floor(player.position) : 0
    readonly property int duration: hasPlayer && player.lengthSupported ? Math.floor(player.length) : 0

    function formatTime(seconds) {
        const m = Math.floor(seconds / 60);
        const s = Math.floor(seconds % 60);
        return `${String(m).padStart(2, "0")}:${String(s).padStart(2, "0")}`;
    }

    // MPRIS position is not pushed over D-Bus, so poll it while visible and playing
    Timer {
        interval: 1000
        repeat: true
        running: musicPopup.expanded && musicPopup.playing
        triggeredOnStart: true
        onTriggered: musicPopup.player.positionChanged()
    }

    visible: expanded
    color: "transparent"

    onActiveChanged: if (expanded && !active)
        expanded = false

    component Divider: Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        color: Colors.topbar.panel_divider
    }
    component Label: Text {
        font.pixelSize: 12
        font.family: "JetBrainsMono Nerd Font"
    }

    Rectangle {
        anchors.fill: parent
        border.color: Colors.topbar.toolbar_accent
        color: Colors.topbar.panel_background
        radius: 2
        ColumnLayout {
            id: content
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 20
            spacing: 15

            RowLayout {
                Layout.fillWidth: true
                Label {
                    Layout.fillWidth: true
                    text: "01  /  MEDIA"
                    color: Colors.topbar.accent_green
                    font.pixelSize: 13
                    font.bold: true
                    font.letterSpacing: 1
                }
                Label {
                    text: !musicPopup.hasPlayer ? "○ IDLE" : musicPopup.playing ? "● PLAYING" : "❚❚ PAUSED"
                    color: musicPopup.playing ? Colors.topbar.accent_lime : Colors.topbar.text_dim
                }
            }
            Divider {}
            RowLayout {
                Layout.fillWidth: true
                spacing: 14
                Rectangle {
                    clip: true
                    Layout.preferredWidth: 82
                    Layout.preferredHeight: 82
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop {
                            position: 0
                            color: "#243A34"
                        }
                        GradientStop {
                            position: 0.55
                            color: "#6F8A77"
                        }
                        GradientStop {
                            position: 1
                            color: "#171F22"
                        }
                    }
                    Image {
                        anchors.fill: parent
                        source: musicPopup.hasPlayer ? musicPopup.player.trackArtUrl : ""
                        fillMode: Image.PreserveAspectCrop
                        clip: true
                        visible: status === Image.Ready
                    }
                    Icon {
                        anchors.centerIn: parent
                        name: "disc-3"
                        size: 34
                        color: "#D1DED2"
                        visible: !musicPopup.hasPlayer || !musicPopup.player.trackArtUrl
                    }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    Marquee {
                        Layout.fillWidth: true
                        text: musicPopup.title
                        color: Colors.topbar.track_title
                        pixelSize: 19
                        bold: true
                        enabled: musicPopup.expanded
                    }
                    Marquee {
                        Layout.fillWidth: true
                        text: musicPopup.artist
                        color: Colors.topbar.terminal_concept_description
                        pixelSize: 15
                        enabled: musicPopup.expanded
                    }
                    Label {
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        text: `MPRIS  /  ${musicPopup.hasPlayer ? musicPopup.player.identity.toUpperCase() : "NO PLAYER"}`
                        color: Colors.topbar.text_dim
                    }
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 7
                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        Layout.fillWidth: true
                        text: musicPopup.formatTime(musicPopup.elapsed)
                        color: Colors.topbar.time_label
                    }
                    Label {
                        text: musicPopup.formatTime(musicPopup.duration)
                        color: Colors.topbar.time_label
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 4
                    color: Colors.topbar.panel_divider
                    Rectangle {
                        width: musicPopup.duration > 0 ? parent.width * Math.min(1, musicPopup.elapsed / musicPopup.duration) : 0
                        height: parent.height
                        color: Colors.topbar.accent_green
                    }
                }
            }
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 18
                IconButton {
                    flat: true
                    icon: "shuffle"
                    active: musicPopup.hasPlayer && musicPopup.player.shuffleSupported && musicPopup.player.shuffle
                    onClicked: if (musicPopup.hasPlayer && musicPopup.player.shuffleSupported)
                        musicPopup.player.shuffle = !musicPopup.player.shuffle
                    iconSize: 17
                    implicitWidth: 32
                    implicitHeight: 32
                }
                IconButton {
                    flat: true
                    icon: "skip-back"
                    onClicked: if (musicPopup.hasPlayer && musicPopup.player.canGoPrevious)
                        musicPopup.player.previous()
                    iconSize: 17
                    implicitWidth: 32
                    implicitHeight: 32
                }
                IconButton {
                    active: true
                    icon: musicPopup.playing ? "pause" : "play"
                    onClicked: if (musicPopup.hasPlayer && musicPopup.player.canTogglePlaying)
                        musicPopup.player.togglePlaying()
                    iconSize: 20
                    implicitWidth: 46
                    implicitHeight: 40
                }
                IconButton {
                    flat: true
                    icon: "skip-forward"
                    onClicked: if (musicPopup.hasPlayer && musicPopup.player.canGoNext)
                        musicPopup.player.next()
                    iconSize: 17
                    implicitWidth: 32
                    implicitHeight: 32
                }
                IconButton {
                    flat: true
                    icon: "repeat-2"
                    active: musicPopup.hasPlayer && musicPopup.player.loopSupported && musicPopup.player.loopState !== MprisLoopState.None
                    onClicked: {
                        if (!musicPopup.hasPlayer || !musicPopup.player.loopSupported)
                            return;
                        musicPopup.player.loopState = musicPopup.player.loopState === MprisLoopState.None ? MprisLoopState.Playlist : MprisLoopState.None;
                    }
                    iconSize: 17
                    implicitWidth: 32
                    implicitHeight: 32
                }
            }
        }
    }
}
