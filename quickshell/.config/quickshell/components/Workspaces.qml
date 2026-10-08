import QtQuick
import Quickshell.Hyprland
import QtQuick.Layouts
import "../theme/"

RowLayout {
    spacing: 8
    anchors.leftMargin: 16
    anchors.left: parent.left
    Repeater {
        model: Hyprland.workspaces
        Rectangle {
            id: workspace
            required property var modelData
            implicitWidth: 38
            implicitHeight: 32
            radius: 2
            border.width: 1
            border.color: workspace.modelData.active ? Colors.toolbar.accent_green : mouseArea.containsMouse ? Colors.toolbar.workspace_active_background : Colors.toolbar.workspace_idle_background
            color: workspace.modelData.active ? Colors.toolbar.workspace_hover_background : mouseArea.containsMouse ? Colors.toolbar.workspace_hover_border : "transparent"
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
                color: workspace.modelData.active ? "#B7C7AD" : mouseArea.containsMouse ? "#B7C7AD" : "#848780"
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
