import Quickshell
import QtQuick
import QtQuick.Layouts
import "../theme/"

Rectangle {
    id: root
    property string command
    property string number
    property bool danger: false
    signal triggered

    function runCommand() {
        if (root.command === "lock") {
            Quickshell.execDetached(["hyprlock"]);
            return;
        }
        if (root.command === "suspend") {
            Quickshell.execDetached(["sh", "-c", "loginctl lock-session && systemctl suspend"]);
            return;
        }
        if (root.command === "reboot") {
            Quickshell.execDetached(["systemctl", "reboot"]);
            return;
        }
        if (root.command === "shutdown") {
            Quickshell.execDetached(["systemctl", "poweroff"]);
        }
    }

    Layout.fillWidth: true
    implicitHeight: 39
    radius: 2
    color: danger ? Colors.topbar.shutdown_command : mouseArea.containsMouse ? Colors.topbar.workspace_active_background : Colors.topbar.panel_background

    Behavior on color {
        ColorAnimation {
            duration: 100
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 7
        anchors.rightMargin: 7
        spacing: 7
        Text {
            text: ">"
            color: root.danger ? Colors.topbar.accent_danger : Colors.topbar.accent_green
            font.pixelSize: 16
            font.bold: true
            font.family: "JetBrainsMono Nerd Font"
        }
        Text {
            Layout.fillWidth: true
            text: root.command
            color: root.danger ? Colors.topbar.accent_danger : Colors.topbar.text_primary
            font.pixelSize: 14
            font.family: "JetBrainsMono Nerd Font"
        }
        Text {
            text: root.number
            color: Colors.topbar.lock_command_index
            font.pixelSize: 12
            font.family: "JetBrainsMono Nerd Font"
        }
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.triggered();
            root.runCommand();
        }
    }
}
