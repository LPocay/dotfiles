pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme/"

PanelWindow {
    id: window
    objectName: "clipboard-modal"
    required property var manager

    screen: manager.targetScreen
    visible: manager.expanded
    color: "transparent"
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "clipboard-manager"
    WlrLayershell.keyboardFocus: manager.expanded ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    function focusSearch() { search.forceActiveFocus(); }
    onVisibleChanged: {
        if (visible)
            Qt.callLater(focusSearch);
    }

    Connections {
        target: window.manager
        function onExpandedChanged() {
            if (window.manager.expanded)
                Qt.callLater(window.focusSearch);
        }
        function onSelectedIndexChanged() {
            history.positionViewAtIndex(window.manager.selectedIndex, ListView.Contain);
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Colors.clipboard.scrim
        MouseArea {
            anchors.fill: parent
            onClicked: window.manager.close()
        }
    }

    Rectangle {
        width: Math.min(720, Math.max(0, parent.width - 32))
        height: Math.min(550, Math.max(0, parent.height - 32))
        anchors.horizontalCenter: parent.horizontalCenter
        y: Math.min(92, Math.max(16, (parent.height - height) / 2))
        radius: 2
        color: Colors.clipboard.panel_background
        border.width: 1
        border.color: Colors.clipboard.panel_border

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
                    text: "04  /  CLIPBOARD"
                    color: Colors.clipboard.accent
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                    font.bold: true
                    font.letterSpacing: 1
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: window.manager.entries.length + " ITEMS"
                    color: Colors.clipboard.text_dim
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 13
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Colors.clipboard.divider
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                color: Colors.clipboard.search_background
                border.width: 1
                border.color: Colors.clipboard.search_border
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12
                    Icon {
                        name: "search"
                        size: 21
                        color: Colors.clipboard.accent
                    }
                    TextField {
                        id: search
                        objectName: "clipboard-search"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        padding: 0
                        text: window.manager.query
                        onTextEdited: window.manager.query = text
                        placeholderText: "clip --grep  Search history…"
                        placeholderTextColor: Colors.clipboard.search_placeholder
                        color: Colors.clipboard.search_text
                        selectionColor: Colors.clipboard.selection_background
                        selectedTextColor: Colors.clipboard.accent_selected
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                        selectByMouse: true
                        background: Item {}
                        Keys.priority: Keys.BeforeItem
                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Escape) {
                                if (window.manager.confirmClear)
                                    window.manager.confirmClear = false;
                                else
                                    window.manager.close();
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                if (window.manager.confirmClear)
                                    window.manager.clear();
                                else
                                    window.manager.copy(window.manager.selectedIndex);
                            } else if (event.key === Qt.Key_Delete) {
                                window.manager.remove();
                            } else if (event.key === Qt.Key_L && (event.modifiers & Qt.ControlModifier)) {
                                window.manager.requestClear();
                            } else if (event.key === Qt.Key_R && (event.modifiers & Qt.ControlModifier)) {
                                window.manager.refresh();
                            } else if (event.key === Qt.Key_Tab) {
                                window.manager.cycleFilter(1);
                            } else if (event.key === Qt.Key_Backtab) {
                                window.manager.cycleFilter(-1);
                            } else if (event.key === Qt.Key_Down) {
                                window.manager.select(window.manager.selectedIndex + 1);
                            } else if (event.key === Qt.Key_Up) {
                                window.manager.select(window.manager.selectedIndex - 1);
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
                Layout.preferredHeight: 24
                spacing: 21
                Repeater {
                    model: [
                        { label: "ALL", value: "all" }, { label: "TEXT", value: "text" },
                        { label: "LINKS", value: "link" }, { label: "IMAGES", value: "image" }
                    ]
                    delegate: Item {
                        id: filter
                        required property var modelData
                        objectName: "clipboard-filter-" + modelData.value
                        implicitWidth: label.implicitWidth
                        Layout.fillHeight: true
                        Text {
                            id: label
                            anchors.verticalCenter: parent.verticalCenter
                            text: filter.modelData.label
                            color: window.manager.filter === filter.modelData.value
                                ? Colors.clipboard.accent_selected : Colors.clipboard.text_dim
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 13
                            font.bold: window.manager.filter === filter.modelData.value
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                window.manager.filter = filter.modelData.value;
                                window.focusSearch();
                            }
                        }
                    }
                }
                Item { Layout.fillWidth: true }
                Text {
                    visible: window.manager.query.length > 0 || window.manager.filter !== "all"
                    text: window.manager.results.length + " MATCHES"
                    color: Colors.clipboard.text_dim
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                }
            }

            ListView {
                id: history
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 288
                Layout.maximumHeight: 288
                Layout.minimumHeight: 0
                clip: true
                model: window.manager.results
                currentIndex: window.manager.selectedIndex
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                delegate: ClipboardItem {
                    required property var modelData
                    required property int index
                    width: ListView.view.width
                    entry: modelData
                    number: index + 1
                    selected: index === window.manager.selectedIndex
                    onHovered: {
                        if (!window.manager.confirmClear)
                            window.manager.selectedIndex = index;
                    }
                    onClicked: {
                        window.manager.copy(index);
                        window.focusSearch();
                    }
                }
                Text {
                    anchors.centerIn: parent
                    width: parent.width
                    visible: !window.manager.results.length
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    text: window.manager.loading ? "Loading history…" : window.manager.error ? "Could not load history. CTRL+R retries."
                        : window.manager.entries.length ? "No matching entries." : "Clipboard history is empty."
                    color: Colors.clipboard.text_meta
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 16
                }
            }

            Text {
                Layout.fillWidth: true
                text: window.manager.confirmClear ? "Clear all " + window.manager.entries.length + " items? ENTER confirm  ESC cancel"
                    : window.manager.error || (window.manager.busy && !window.manager.loading ? "Updating clipboard…"
                        : "ENTER copy   DEL remove   CTRL+L clear")
                color: window.manager.error || window.manager.confirmClear ? Colors.clipboard.error : Colors.clipboard.text_dim
                textFormat: Text.PlainText
                elide: Text.ElideRight
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13
            }
        }
    }
}
