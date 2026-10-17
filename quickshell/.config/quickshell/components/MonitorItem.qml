import QtQuick
import QtQuick.Layouts
import "../theme/"
import "MonitorLogic.js" as Logic

Rectangle {
    id: root
    required property var monitor
    required property int number
    property bool current: false
    property bool selected: false
    signal hovered()
    signal clicked()

    implicitHeight: 112
    radius: 2
    color: selected ? Colors.monitors.selection_background : current ? Colors.monitors.current_background : Colors.monitors.row_background
    border.width: 1
    border.color: selected ? Colors.monitors.selection_border : Colors.monitors.row_border

    RowLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 16

        Icon {
            name: "monitor"
            size: 26
            color: root.selected ? Colors.monitors.accent_selected : Colors.monitors.accent
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: root.monitor.name
                    textFormat: Text.PlainText
                    elide: Text.ElideRight
                    color: Colors.monitors.text_primary
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 16
                    font.bold: true
                }
                Text {
                    text: root.current ? "CURRENT" : String(root.number).padStart(2, "0")
                    color: root.current ? Colors.monitors.accent : root.selected ? Colors.monitors.accent_selected : Colors.monitors.text_dim
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 13
                }
            }

            Text {
                Layout.fillWidth: true
                text: root.monitor.description || root.monitor.name
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: Colors.monitors.text_secondary
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13
            }

            Text {
                Layout.fillWidth: true
                text: Logic.mode(root.monitor)
                elide: Text.ElideRight
                color: Colors.monitors.text_dim
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13
            }

            Text {
                Layout.fillWidth: true
                text: "WORKSPACES  " + (root.monitor.workspaces.length
                    ? root.monitor.workspaces.map(workspace => Logic.workspaceLabel(workspace)).join("  ") : "—")
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: root.selected ? Colors.monitors.accent_selected : Colors.monitors.text_secondary
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.current ? Qt.ArrowCursor : Qt.PointingHandCursor
        onPositionChanged: {
            if (!root.current)
                root.hovered();
        }
        onClicked: {
            if (!root.current)
                root.clicked();
        }
    }
}
