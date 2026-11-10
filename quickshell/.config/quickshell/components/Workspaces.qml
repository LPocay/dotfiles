import QtQuick
import Quickshell.Hyprland
import QtQuick.Layouts
import "../theme/"

RowLayout {
    id: root
    required property var screen
    property var workspaceModel: Hyprland.workspaces
    spacing: 8
    Repeater {
        model: root.workspaceModel.values.filter(workspace => root.screen
            && workspace.monitor?.name === root.screen.name
            && !workspace.name.startsWith("special:")).sort((a, b) => a.id - b.id)
        Rectangle {
            id: workspace
            required property var modelData
            objectName: "workspace-" + modelData.id
            implicitWidth: 38
            implicitHeight: 32
            radius: 2
            border.width: 1
            border.color: workspace.modelData.urgent ? Colors.topbar.accent_danger : workspace.modelData.active ? Colors.topbar.accent_green : mouseArea.containsMouse ? Colors.topbar.workspace_active_background : Colors.topbar.workspace_idle_background
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
                text: workspace.modelData.name === String(workspace.modelData.id)
                    ? String(workspace.modelData.id).padStart(2, "0") : workspace.modelData.name
                color: workspace.modelData.urgent ? Colors.topbar.accent_danger : workspace.modelData.active ? Colors.topbar.text_selected : mouseArea.containsMouse ? Colors.topbar.text_selected : Colors.topbar.text_muted
                font.pixelSize: 12
                font.bold: true
                font.family: "JetBrainsMono Nerd Font"
                Behavior on color {
                    ColorAnimation {
                        duration: 100
                    }
                }
            }
            Rectangle {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 4
                width: 4
                height: 4
                radius: 2
                color: Colors.topbar.accent_danger
                visible: workspace.modelData.urgent
            }
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Hyprland.dispatch("hl.dsp.focus({ workspace = " + workspace.modelData.id + " })");
                }
            }
        }
    }
}
