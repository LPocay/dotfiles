pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme/"

PanelWindow {
    id: window

    required property var launcher

    screen: launcher.targetScreen
    visible: launcher.expanded
    color: "transparent"
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "app-launcher"
    WlrLayershell.keyboardFocus: launcher.expanded ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    function focusSearch() {
        search.forceActiveFocus();
    }

    onVisibleChanged: {
        if (visible)
            Qt.callLater(focusSearch);
    }

    Connections {
        target: window.launcher
        function onExpandedChanged() {
            if (window.launcher.expanded)
                Qt.callLater(window.focusSearch);
        }
        function onSelectedIndexChanged() {
            results.positionViewAtIndex(window.launcher.selectedIndex, ListView.Contain);
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Colors.launcher.scrim
        MouseArea {
            anchors.fill: parent
            onClicked: window.launcher.close()
        }
    }

    Rectangle {
        id: panel
        width: Math.min(780, Math.max(0, parent.width - 32))
        height: Math.min(480, Math.max(0, parent.height - 32))
        anchors.horizontalCenter: parent.horizontalCenter
        // Desktop 03 places the palette 109 px below the 62 px top bar.
        y: Math.min(109, Math.max(16, (parent.height - height) / 2))
        radius: 2
        color: Colors.launcher.panel_background
        border.width: 1
        border.color: Colors.launcher.panel_border

        MouseArea {
            anchors.fill: parent
            onClicked: window.focusSearch()
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 26
            spacing: 16

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "03  /  APP LAUNCHER"
                    color: Colors.launcher.accent
                    font.bold: true
                    font.letterSpacing: 1
                    font.pixelSize: 14
                    font.family: "JetBrainsMono Nerd Font"
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: window.launcher.applications.length + " INSTALLED"
                    color: Colors.launcher.text_dim
                    font.pixelSize: 13
                    font.family: "JetBrainsMono Nerd Font"
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Colors.launcher.divider
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                color: Colors.launcher.search_background
                border.width: 1
                border.color: Colors.launcher.search_border

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12
                    Text {
                        text: "❯"
                        color: Colors.launcher.accent
                        font.bold: true
                        font.pixelSize: 21
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    TextField {
                        id: search
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        padding: 0
                        text: window.launcher.query
                        onTextEdited: window.launcher.query = text
                        placeholderText: "apps --find  _"
                        placeholderTextColor: Colors.launcher.text_dim
                        color: Colors.launcher.search_text
                        selectionColor: Colors.launcher.selection_background
                        selectedTextColor: Colors.launcher.accent_selected
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                        background: Item {}
                        selectByMouse: true
                        Keys.priority: Keys.BeforeItem
                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Escape) {
                                window.launcher.close();
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                window.launcher.launch(window.launcher.selectedIndex);
                            } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab) {
                                window.launcher.select(window.launcher.selectedIndex + 1);
                            } else if (event.key === Qt.Key_Up || event.key === Qt.Key_Backtab) {
                                window.launcher.select(window.launcher.selectedIndex - 1);
                            } else if (event.key === Qt.Key_R && event.modifiers & Qt.ControlModifier) {
                                window.launcher.refresh();
                            } else {
                                return;
                            }
                            event.accepted = true;
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: window.launcher.query.trim() ? "RESULTS / " + window.launcher.results.length
                        : window.launcher.recentIds.length ? "RECENT / ALL APPS" : "ALL APPS"
                    color: Colors.launcher.text_dim
                    font.pixelSize: 13
                    font.family: "JetBrainsMono Nerd Font"
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: "↑ ↓ SELECT"
                    color: Colors.launcher.text_dim
                    font.pixelSize: 13
                    font.family: "JetBrainsMono Nerd Font"
                }
            }

            ListView {
                id: results
                Layout.fillWidth: true
                Layout.preferredHeight: 220
                Layout.maximumHeight: 220
                Layout.minimumHeight: 0
                Layout.fillHeight: true
                clip: true
                spacing: 4
                model: window.launcher.results
                boundsBehavior: Flickable.StopAtBounds
                currentIndex: window.launcher.selectedIndex
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                delegate: AppLauncherItem {
                    required property var modelData
                    required property int index
                    width: ListView.view.width
                    entry: modelData
                    number: index + 1
                    selected: index === window.launcher.selectedIndex
                    onHovered: window.launcher.selectedIndex = index
                    onClicked: {
                        window.launcher.selectedIndex = index;
                        window.launcher.launch(index);
                        window.focusSearch();
                    }
                }
                Text {
                    anchors.centerIn: parent
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    visible: !window.launcher.results.length
                    text: window.launcher.applications.length ? "No matching applications." : "No applications found."
                    color: Colors.launcher.text_secondary
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 16
                }
            }

            Text {
                Layout.fillWidth: true
                text: window.launcher.error || (window.launcher.launching ? "Launching…" : "ENTER launch   ESC close   CTRL+R refresh")
                color: window.launcher.error ? Colors.launcher.error : Colors.launcher.text_dim
                elide: Text.ElideRight
                maximumLineCount: 1
                font.pixelSize: 13
                font.family: "JetBrainsMono Nerd Font"
            }

            Item { Layout.fillHeight: true }
        }
    }
}
