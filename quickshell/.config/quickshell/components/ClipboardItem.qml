import QtQuick
import QtQuick.Layouts
import "../theme/"
import "ClipboardLogic.js" as Logic

Rectangle {
    id: root
    required property var entry
    required property int number
    property bool selected: false
    signal hovered()
    signal clicked()

    implicitHeight: 72
    color: selected ? Colors.clipboard.selection_background : "transparent"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 13
        anchors.rightMargin: 13
        spacing: 16

        Text {
            text: String(root.number).padStart(2, "0")
            color: Colors.clipboard.text_dim
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
        }

        Icon {
            name: Logic.iconName(root.entry.type)
            size: 22
            color: root.entry.type === "link" ? Colors.clipboard.icon_link
                : root.entry.type === "color" ? Colors.clipboard.icon_color
                : root.entry.type === "image" ? Colors.clipboard.icon_image : Colors.clipboard.accent_selected
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5
            Text {
                Layout.fillWidth: true
                text: root.entry.title
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: Colors.clipboard.text_primary
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 16
            }
            Text {
                Layout.fillWidth: true
                text: root.entry.type.toUpperCase() + (root.entry.detail ? "  •  " + root.entry.detail : "")
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: Colors.clipboard.text_meta
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
            }
        }

        Icon {
            name: "corner-down-left"
            size: 18
            color: root.selected ? Colors.clipboard.accent_selected : Colors.clipboard.icon_inactive
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        visible: !root.selected
        color: Colors.clipboard.entry_divider
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPositionChanged: root.hovered()
        onClicked: root.clicked()
    }
}
