import QtQuick
import QtQuick.Controls
import "../theme/"

Button {
    id: root
    implicitHeight: 36
    implicitWidth: contentItem.implicitWidth + 24
    opacity: enabled ? 1 : 0.4
    contentItem: Text {
        text: root.text
        color: root.highlighted ? Colors.monitors.accent_selected : Colors.monitors.text_primary
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 12
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    background: Rectangle {
        radius: 2
        color: root.down || root.hovered ? Colors.monitors.selection_background : Colors.monitors.row_background
        border.width: 1
        border.color: root.highlighted || root.activeFocus || root.hovered ? Colors.monitors.selection_border : Colors.monitors.row_border
    }
}
