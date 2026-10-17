pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: window
    required property var manager
    required property var output
    screen: output
    readonly property var entries: manager.popupEntries(output.name)
    objectName: "notification-toasts"
    anchors { top: true; right: true }
    margins { top: 15; right: 26 }
    implicitWidth: Math.min(390, Math.max(0, output.width - 32))
    implicitHeight: Math.min(stack.implicitHeight, Math.max(0, output.height - 110))
    visible: entries.length > 0 && !manager.expanded
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "notification-toasts"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    color: "transparent"

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: stack.implicitHeight
        flickableDirection: Flickable.VerticalFlick
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        Column {
            id: stack
            width: parent.width
            spacing: 12
            Repeater {
                model: window.entries
                delegate: NotificationCard {
                    required property var modelData
                    width: stack.width
                    entry: modelData
                    manager: window.manager
                    popup: true
                }
            }
        }
    }
}
