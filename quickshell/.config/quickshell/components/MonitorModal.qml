pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme/"
import "MonitorLogic.js" as Logic

PanelWindow {
    id: window
    objectName: "monitor-modal"
    required property var picker

    screen: picker.targetScreen
    visible: picker.expanded
    color: "transparent"
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "workspace-monitor-picker"
    WlrLayershell.keyboardFocus: picker.expanded ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    function focusKeyboard() { keyboard.forceActiveFocus(); }
    onVisibleChanged: {
        if (visible)
            Qt.callLater(focusKeyboard);
    }

    Connections {
        target: window.picker
        function onExpandedChanged() {
            if (window.picker.expanded)
                Qt.callLater(window.focusKeyboard);
        }
        function onSelectedIndexChanged() {
            monitors.positionViewAtIndex(window.picker.selectedIndex, ListView.Contain);
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Colors.monitors.scrim
        MouseArea {
            anchors.fill: parent
            onClicked: window.picker.close()
        }
    }

    FocusScope {
        id: keyboard
        anchors.fill: parent
        focus: true
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                window.picker.close();
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                window.picker.move();
            } else if ([Qt.Key_Right, Qt.Key_Down, Qt.Key_Tab].includes(event.key)) {
                window.picker.step(1);
            } else if ([Qt.Key_Left, Qt.Key_Up, Qt.Key_Backtab].includes(event.key)) {
                window.picker.step(-1);
            } else if (event.key === Qt.Key_R && (event.modifiers & Qt.ControlModifier)) {
                window.picker.refresh();
            } else {
                return;
            }
            event.accepted = true;
        }

        Rectangle {
            width: Math.min(720, Math.max(0, parent.width - 32))
            height: Math.min(540, Math.max(0, parent.height - 32))
            anchors.horizontalCenter: parent.horizontalCenter
            y: Math.min(92, Math.max(16, (parent.height - height) / 2))
            radius: 2
            color: Colors.monitors.panel_background
            border.width: 1
            border.color: Colors.monitors.panel_border

            MouseArea {
                anchors.fill: parent
                onClicked: window.focusKeyboard()
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 26
                spacing: 16

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "05  /  MONITORS"
                        color: Colors.monitors.accent
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 14
                        font.bold: true
                        font.letterSpacing: 1
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: window.picker.monitors.length + " CONNECTED"
                        color: Colors.monitors.text_dim
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 13
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Colors.monitors.divider
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56
                    color: Colors.monitors.command_background
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 12
                        Text {
                            text: "❯"
                            color: Colors.monitors.accent
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 21
                        }
                        Text {
                            Layout.fillWidth: true
                            text: window.picker.workspace ? "move workspace " + Logic.workspaceLabel(window.picker.workspace) : "Loading workspace…"
                            textFormat: Text.PlainText
                            elide: Text.ElideRight
                            color: Colors.monitors.text_primary
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 16
                        }
                        Text {
                            Layout.maximumWidth: parent.width * 0.35
                            text: window.picker.workspace?.monitor ?? ""
                            textFormat: Text.PlainText
                            elide: Text.ElideRight
                            color: Colors.monitors.text_secondary
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 13
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "CONNECTED OUTPUTS"
                        color: Colors.monitors.text_dim
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 13
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: "↑ ↓ SELECT"
                        color: Colors.monitors.text_dim
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 13
                    }
                }

                ListView {
                    id: monitors
                    objectName: "monitor-list"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: 232
                    Layout.maximumHeight: 232
                    Layout.minimumHeight: 0
                    clip: true
                    spacing: 8
                    model: window.picker.monitors
                    currentIndex: window.picker.selectedIndex
                    boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                    delegate: MonitorItem {
                        required property var modelData
                        required property int index
                        objectName: "monitor-" + modelData.name
                        width: ListView.view.width
                        monitor: modelData
                        number: index + 1
                        current: modelData.name === window.picker.workspace?.monitor
                        selected: index === window.picker.selectedIndex
                        onHovered: window.picker.select(index)
                        onClicked: {
                            window.picker.select(index);
                            window.picker.move();
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: !window.picker.monitors.length
                        text: window.picker.loading ? "Loading monitors…" : "No monitor information available."
                        color: Colors.monitors.text_secondary
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                    }
                }

                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    text: window.picker.error || (window.picker.moving ? "Moving workspace…"
                        : window.picker.selected ? "Destination: " + window.picker.selected.name
                        : window.picker.loading ? "Refreshing monitors…" : "Connect another monitor to move this workspace.")
                    textFormat: Text.PlainText
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    color: window.picker.error ? Colors.monitors.error : Colors.monitors.text_secondary
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 13
                }

                Text {
                    Layout.fillWidth: true
                    text: "ENTER move   ESC close   CTRL+R refresh"
                    color: Colors.monitors.text_dim
                    elide: Text.ElideRight
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 13
                }
            }
        }
    }
}
