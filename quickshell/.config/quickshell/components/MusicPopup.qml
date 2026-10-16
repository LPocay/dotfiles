import Quickshell
import QtQuick
import QtQuick.Layouts
import "../theme/"

PopupWindow {
    id: musicPopup
    implicitWidth: 350
    implicitHeight: content.implicitHeight + 40

    property bool expanded: false
    property string title: "AFTERGLOW"
    property string artist: "Northbound"
    property int elapsed: 102
    property int duration: 238

    function formatTime(seconds) {
        const m = Math.floor(seconds / 60);
        const s = seconds % 60;
        return `${String(m).padStart(2, "0")}:${String(s).padStart(2, "0")}`;
    }

    visible: expanded
    color: "transparent"

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
                    text: "● PLAYING"
                    color: Colors.topbar.accent_lime
                }
            }
            Divider {}
            RowLayout {
                Layout.fillWidth: true
                spacing: 14
                Rectangle {
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
                    Icon {
                        anchors.centerIn: parent
                        name: "disc-3"
                        size: 34
                        color: "#D1DED2"
                    }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    Label {
                        text: musicPopup.title
                        color: Colors.topbar.track_title
                        font.pixelSize: 19
                        font.bold: true
                    }
                    Label {
                        text: musicPopup.artist
                        color: Colors.topbar.terminal_concept_description
                        font.pixelSize: 15
                    }
                    Label {
                        text: "MPRIS  /  PLAYER 01"
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
                        width: parent.width * musicPopup.elapsed / musicPopup.duration
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
                    iconSize: 17
                    implicitWidth: 32
                    implicitHeight: 32
                }
                IconButton {
                    flat: true
                    icon: "skip-back"
                    iconSize: 17
                    implicitWidth: 32
                    implicitHeight: 32
                }
                IconButton {
                    active: true
                    icon: "pause"
                    iconSize: 20
                    implicitWidth: 46
                    implicitHeight: 40
                }
                IconButton {
                    flat: true
                    icon: "skip-forward"
                    iconSize: 17
                    implicitWidth: 32
                    implicitHeight: 32
                }
                IconButton {
                    flat: true
                    icon: "repeat-2"
                    iconSize: 17
                    implicitWidth: 32
                    implicitHeight: 32
                }
            }
            Label {
                text: "SPACE pause   ← / → seek   M mute"
                color: Colors.topbar.text_dim
            }
            Divider {}
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                Icon {
                    name: "list-music"
                    size: 17
                    color: Colors.topbar.queue_icon
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3
                    Label {
                        text: "UP NEXT"
                        color: Colors.topbar.text_dim
                        font.pixelSize: 11
                        font.bold: true
                    }
                    Label {
                        text: "Warm Signal  ·  Northbound"
                        color: Colors.topbar.queue_song
                        font.pixelSize: 13
                    }
                }
                Label {
                    text: "02 / 12"
                    color: Colors.topbar.text_dim
                    font.pixelSize: 11
                }
            }
        }
    }
}
