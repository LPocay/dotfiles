import QtQuick
import QtQuick.Layouts
import "../theme/"
import "LauncherLogic.js" as Logic

Rectangle {
    id: root

    required property var entry
    required property int number
    property bool selected: false
    signal hovered()
    signal clicked()

    implicitHeight: 52
    radius: 0
    color: selected ? Colors.launcher.selection_background : "transparent"
    border.width: selected ? 1 : 0
    border.color: Colors.launcher.selection_border

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 14

        Icon {
            name: Logic.iconName(root.entry)
            size: 21
            color: root.selected ? Colors.launcher.accent_selected : Colors.launcher.icon
        }

        Text {
            Layout.maximumWidth: parent.width * 0.50
            text: root.entry.name
            elide: Text.ElideRight
            color: Colors.launcher.text_primary
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 16
            font.bold: root.selected
        }

        Text {
            Layout.fillWidth: true
            text: root.entry.genericName || root.entry.comment || ""
            elide: Text.ElideRight
            color: Colors.launcher.text_secondary
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
        }

        Text {
            text: String(root.number).padStart(2, "0")
            color: root.selected ? Colors.launcher.accent_selected : Colors.launcher.text_dim
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        // Moving the pointer selects; a stationary pointer does not override keys.
        onPositionChanged: root.hovered()
        onClicked: root.clicked()
    }
}
