import Quickshell
import QtQuick
import QtQuick.Layouts
import "../theme/"

PopupWindow {
    id: powerMenu
    implicitWidth: 230
    implicitHeight: content.implicitHeight + 20

    property bool expanded: false
    visible: expanded
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        border.color: Colors.topbar.power_menu_terminal_prompt
        color: Colors.topbar.panel_background
        radius: 2
        ColumnLayout {
            id: content
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 10
            spacing: 3
            Text {
                text: "root@hypr:~$ session"
                color: Colors.topbar.accent_green
                font.pixelSize: 13
                font.family: "JetBrainsMono Nerd Font"
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Colors.topbar.terminal_menu_rule
            }
            Repeater {
                model: [
                    {
                        command: "lock",
                        danger: false
                    },
                    {
                        command: "suspend",
                        danger: false
                    },
                    {
                        command: "reboot",
                        danger: false
                    },
                    {
                        command: "shutdown",
                        danger: true
                    }
                ]
                PowerMenuItem {
                    required property var modelData
                    required property int index
                    command: modelData.command
                    danger: modelData.danger
                    number: String(index + 1).padStart(2, "0")
                }
            }
        }
    }
}
