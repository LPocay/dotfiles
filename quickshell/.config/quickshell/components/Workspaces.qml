import QtQuick
import Quickshell.Hyprland
import QtQuick.Layouts
import "../theme/"

RowLayout {
    spacing: 8
    Layout.leftMargin: 16
    Layout.alignment: Qt.AlignLeft
    Repeater {
        model: Hyprland.workspaces
        Rectangle {
            id: workspace
            required property var modelData
            implicitWidth: 38
            implicitHeight: 32
            radius: 2
            border.width: 1
            border.color: workspace.modelData.active ? Colors.topbar.accent_green : mouseArea.containsMouse ? Colors.topbar.workspace_active_background : Colors.topbar.workspace_idle_background
            color: workspace.modelData.active ? Colors.topbar.workspace_hover_background : mouseArea.containsMouse ? Colors.topbar.workspace_hover_border : "transparent"
            Behavior on color {
                ColorAnimation {
                    duration: 100
                }
            }
            Behavior on border.color {
                ColorAnimation {
                    duration: 100
                }
            }
            Text {
                anchors.centerIn: parent
                text: `0${workspace.modelData.id}`
                color: workspace.modelData.active ? Colors.topbar.text_selected : mouseArea.containsMouse ? Colors.topbar.text_selected : Colors.topbar.text_muted
                font.pixelSize: 12
                font.bold: true
                font.family: "JetBrainsMono Nerd Font"
                Behavior on color {
                    ColorAnimation {
                        duration: 100
                    }
                }
            }
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    workspace.modelData.activate();
                }
            }
        }
    }
}
