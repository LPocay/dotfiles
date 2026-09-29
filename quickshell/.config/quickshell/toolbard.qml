import Quickshell // for PanelWindow
import QtQuick // for Text
import Quickshell.Hyprland

PanelWindow {
    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 30

    Text {
        // center the bar in its parent component (the window)
        anchors.centerIn: parent
        text: "hello world"
    }

    Row {
        anchors.left: parent.left
        Repeater {
            model: Hyprland.workspaces
            Rectangle {
                id: workspace
                required property var modelData
                width: 100
                height: 40
                border.width: 1
                color: "red"
                Text {
                    anchors.centerIn: parent
                    text: workspace.modelData.id
                    color: workspace.modelData.active ? "black" : "white"
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        workspace.modelData.activate();
                    }
                }
            }
        }
    }
}
