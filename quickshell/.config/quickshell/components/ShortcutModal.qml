pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme/"

PanelWindow {
    id: window
    objectName: "shortcut-modal"
    required property var viewer

    screen: viewer.targetScreen
    visible: viewer.expanded
    color: "transparent"
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "shortcut-viewer"
    WlrLayershell.keyboardFocus: viewer.expanded ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    anchors { top: true; bottom: true; left: true; right: true }

    function focusSearch() { search.forceActiveFocus(); }
    onVisibleChanged: {
        if (visible)
            Qt.callLater(focusSearch);
    }
    Connections {
        target: window.viewer
        function onExpandedChanged() {
            if (window.viewer.expanded)
                Qt.callLater(window.focusSearch);
        }
        function onSelectedIndexChanged() {
            results.positionViewAtIndex(window.viewer.selectedIndex, ListView.Contain);
        }
        function onResultsChanged() {
            Qt.callLater(() => results.positionViewAtIndex(window.viewer.selectedIndex, ListView.Contain));
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Colors.shortcuts.scrim
        MouseArea {
            anchors.fill: parent
            onClicked: window.viewer.close()
        }
    }

    Rectangle {
        width: Math.min(900, Math.max(0, parent.width - 32))
        height: Math.min(680, Math.max(0, parent.height - 32))
        anchors.horizontalCenter: parent.horizontalCenter
        y: Math.min(92, Math.max(16, (parent.height - height) / 2))
        radius: 2
        color: Colors.shortcuts.panel_background
        border.width: 1
        border.color: Colors.shortcuts.panel_border
        clip: true

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
                    text: "HYPRLAND  /  SHORTCUTS"
                    color: Colors.shortcuts.accent
                    font.family: "JetBrainsMono Nerd Font"
                    font.bold: true
                    font.pixelSize: 14
                    font.letterSpacing: 1
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: window.viewer.entries.length + " ACTIONS"
                    color: Colors.shortcuts.text_dim
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 13
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Colors.shortcuts.divider
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                color: Colors.shortcuts.search_background
                border.width: 1
                border.color: Colors.shortcuts.panel_border
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12
                    Text {
                        text: "❯"
                        color: Colors.shortcuts.accent
                        font.family: "JetBrainsMono Nerd Font"
                        font.bold: true
                        font.pixelSize: 21
                    }
                    TextField {
                        id: search
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        padding: 0
                        text: window.viewer.query
                        onTextEdited: window.viewer.query = text
                        placeholderText: "shortcuts --find  _"
                        placeholderTextColor: Colors.shortcuts.text_dim
                        color: Colors.shortcuts.text_primary
                        selectionColor: Colors.shortcuts.selection_background
                        selectedTextColor: Colors.shortcuts.accent
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                        background: Item {}
                        selectByMouse: true
                        Accessible.name: "Search Hyprland shortcuts"
                        Keys.priority: Keys.BeforeItem
                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Escape) {
                                window.viewer.close();
                            } else if (event.key === Qt.Key_Down) {
                                window.viewer.select(window.viewer.selectedIndex + 1);
                            } else if (event.key === Qt.Key_Up) {
                                window.viewer.select(window.viewer.selectedIndex - 1);
                            } else if (event.key === Qt.Key_Tab) {
                                window.viewer.cycleCategory(1);
                            } else if (event.key === Qt.Key_Backtab) {
                                window.viewer.cycleCategory(-1);
                            } else if (event.key === Qt.Key_R && event.modifiers & Qt.ControlModifier) {
                                window.viewer.refresh();
                            } else {
                                return;
                            }
                            event.accepted = true;
                        }
                    }
                }
            }

            Flow {
                Layout.fillWidth: true
                Layout.preferredHeight: implicitHeight
                spacing: 6
                Repeater {
                    model: window.viewer.categories
                    delegate: Rectangle {
                        id: chip
                        required property string modelData
                        readonly property bool selected: window.viewer.category === modelData
                        width: categoryText.implicitWidth + 20
                        height: 28
                        radius: 2
                        color: selected ? Colors.shortcuts.selection_background : Colors.shortcuts.row_background
                        border.width: 1
                        border.color: selected ? Colors.shortcuts.selection_border : Colors.shortcuts.row_border
                        Accessible.role: Accessible.Button
                        Accessible.name: modelData + " shortcuts"
                        Accessible.onPressAction: {
                            window.viewer.category = chip.modelData;
                            window.focusSearch();
                        }
                        Text {
                            id: categoryText
                            anchors.centerIn: parent
                            text: chip.modelData
                            color: chip.selected ? Colors.shortcuts.accent : Colors.shortcuts.text_secondary
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                window.viewer.category = chip.modelData;
                                window.focusSearch();
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "RESULTS / " + window.viewer.results.length
                    color: Colors.shortcuts.text_dim
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: "↑ ↓ BROWSE"
                    color: Colors.shortcuts.text_dim
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                }
            }

            ListView {
                id: results
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 0
                clip: true
                spacing: 6
                model: window.viewer.results
                currentIndex: window.viewer.selectedIndex
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                delegate: ShortcutItem {
                    required property var modelData
                    required property int index
                    width: ListView.view.width
                    entry: modelData
                    selected: index === window.viewer.selectedIndex
                    onHovered: window.viewer.selectedIndex = index
                    onClicked: {
                        window.viewer.selectedIndex = index;
                        window.focusSearch();
                    }
                }
                Text {
                    anchors.centerIn: parent
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    visible: !window.viewer.results.length
                    text: window.viewer.loading ? "Loading Hyprland shortcuts…"
                        : window.viewer.error ? "Shortcuts unavailable."
                        : window.viewer.entries.length ? "No matching shortcuts." : "No shortcuts registered."
                    color: Colors.shortcuts.text_secondary
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 16
                }
            }

            Text {
                Layout.fillWidth: true
                visible: !!window.viewer.error || window.viewer.loading
                text: window.viewer.error || "Refreshing shortcuts…"
                textFormat: Text.PlainText
                wrapMode: Text.Wrap
                color: window.viewer.error ? Colors.shortcuts.error : Colors.shortcuts.text_secondary
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
            }

            Text {
                Layout.fillWidth: true
                text: "TAB category   ESC close   CTRL+R refresh"
                wrapMode: Text.Wrap
                color: Colors.shortcuts.text_dim
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
            }
        }
    }
}
