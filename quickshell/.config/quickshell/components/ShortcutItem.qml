pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../theme/"

Rectangle {
    id: root
    required property var entry
    required property bool selected
    signal hovered()
    signal clicked()

    height: Math.max(66, keyText.implicitHeight + 36)
    radius: 2
    color: selected ? Colors.shortcuts.selection_background : Colors.shortcuts.row_background
    border.width: 1
    border.color: selected ? Colors.shortcuts.selection_border : Colors.shortcuts.row_border
    Accessible.role: Accessible.ListItem
    Accessible.name: entry.action + ", " + entry.keys + ", " + entry.detail

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5
            Text {
                Layout.fillWidth: true
                text: root.entry.action
                textFormat: Text.PlainText
                color: Colors.shortcuts.text_primary
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                text: root.entry.detail
                textFormat: Text.PlainText
                color: Colors.shortcuts.text_secondary
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 11
                elide: Text.ElideRight
            }
        }
        Rectangle {
            Layout.preferredWidth: Math.min(keyText.implicitWidth + 18, root.width * 0.46)
            Layout.preferredHeight: Math.max(30, keyText.implicitHeight + 12)
            color: Colors.shortcuts.search_background
            border.width: 1
            border.color: root.selected ? Colors.shortcuts.selection_border : Colors.shortcuts.row_border
            radius: 2
            Text {
                id: keyText
                anchors.fill: parent
                anchors.leftMargin: 9
                anchors.rightMargin: 9
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: root.entry.keys
                textFormat: Text.PlainText
                color: Colors.shortcuts.accent
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
                wrapMode: Text.Wrap
            }
        }
    }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onPositionChanged: root.hovered()
        onClicked: root.clicked()
    }
}
