import QtQuick
import "../theme/"

Rectangle {
    id: root
    property string icon
    property int iconSize: 14
    property bool active: false
    property bool flat: false
    signal clicked

    readonly property bool hovered: mouseArea.containsMouse
    readonly property bool boxLit: active || (mouseArea.containsMouse && !flat)
    readonly property bool iconLit: active || mouseArea.containsMouse

    implicitWidth: 24
    implicitHeight: 24
    radius: 2
    color: boxLit ? Colors.topbar.workspace_hover_background : flat ? "transparent" : Colors.topbar.toolbar_background
    border.width: flat && !boxLit ? 0 : 1
    border.color: boxLit ? Colors.topbar.accent_lime : Colors.topbar.workspace_idle_background

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

    Icon {
        anchors.centerIn: parent
        name: root.icon
        size: root.iconSize
        color: root.iconLit ? Colors.topbar.accent_lime : root.flat ? Colors.topbar.icon_muted : Colors.topbar.text_muted
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
