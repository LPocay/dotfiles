import Quickshell
import QtQuick
import QtQuick.Layouts
import "../theme/"

// Shared delayed hover panel. A grace period bridges the gap between windows,
// and the panel stays open while the pointer is over any of its controls.
StatusReading {
    id: root

    property string title: ""
    property var readings: []
    property var actions: []
    property bool blocked: false
    property bool expanded: false
    readonly property bool panelHovered: panelHover.hovered
    signal opened()
    signal actionTriggered(string action)

    function close() {
        openTimer.stop();
        closeTimer.stop();
        expanded = false;
    }

    function updateHover() {
        if (blocked || !visible) {
            close();
        } else if (hovered || panelHovered) {
            closeTimer.stop();
            if (!expanded && !openTimer.running)
                openTimer.start();
        } else {
            openTimer.stop();
            if (expanded)
                closeTimer.restart();
        }
    }

    onHoveredChanged: updateHover()
    onPanelHoveredChanged: updateHover()
    onBlockedChanged: { if (blocked) close(); }
    onVisibleChanged: { if (!visible) close(); }
    onExpandedChanged: { if (expanded) opened(); }

    Timer {
        id: openTimer
        interval: 220
        onTriggered: {
            if (!root.blocked && root.visible && (root.hovered || root.panelHovered))
                root.expanded = true;
        }
    }
    Timer {
        id: closeTimer
        interval: 300
        onTriggered: {
            if (!root.hovered && !root.panelHovered)
                root.expanded = false;
        }
    }

    PopupWindow {
        id: popup
        anchor.item: root
        anchor.rect.x: root.width - width
        anchor.rect.y: root.height + 8
        implicitWidth: 300
        implicitHeight: content.implicitHeight + 28
        visible: root.expanded && root.visible && !root.blocked
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: Colors.topbar.panel_background
            border.color: Colors.topbar.power_menu_terminal_prompt
            radius: 2

            HoverHandler { id: panelHover }

            ColumnLayout {
                id: content
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 14
                spacing: 10

                Text {
                    text: "~/status / " + root.title
                    color: Colors.topbar.accent_green
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 13
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Colors.topbar.panel_divider
                }
                Repeater {
                    model: root.readings
                    RowLayout {
                        id: reading
                        required property var modelData
                        Layout.fillWidth: true
                        visible: modelData.available !== false
                        spacing: 12

                        Text {
                            text: reading.modelData.label
                            color: Colors.topbar.text_dim
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 13
                            Layout.alignment: Qt.AlignTop
                        }
                        Text {
                            text: reading.modelData.value
                            textFormat: Text.PlainText
                            color: reading.modelData.color || Colors.topbar.text_primary
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 13
                            horizontalAlignment: Text.AlignRight
                            wrapMode: Text.WrapAnywhere
                            Layout.fillWidth: true
                        }
                    }
                }
                Rectangle {
                    visible: root.actions.length > 0
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Colors.topbar.panel_divider
                }
                Repeater {
                    model: root.actions
                    Rectangle {
                        id: actionButton
                        required property var modelData
                        Layout.fillWidth: true
                        implicitHeight: 30
                        visible: modelData.available !== false
                        color: actionMouse.containsMouse ? Colors.topbar.workspace_hover_background : "transparent"
                        radius: 2

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 6
                            anchors.verticalCenter: parent.verticalCenter
                            text: "> " + actionButton.modelData.label
                            color: Colors.topbar.accent_green
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 13
                        }
                        MouseArea {
                            id: actionMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.close();
                                root.actionTriggered(actionButton.modelData.key);
                            }
                        }
                    }
                }
            }
        }
    }
}
