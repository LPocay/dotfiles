pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme/"

PanelWindow {
    id: window
    required property var manager
    objectName: "notification-center"
    screen: manager.targetScreen
    visible: manager.expanded
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "notification-center"
    WlrLayershell.keyboardFocus: manager.expanded ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    color: "transparent"

    onVisibleChanged: {
        if (visible) Qt.callLater(() => keyboard.forceActiveFocus());
    }
    Connections {
        target: window.manager
        function onSelectedUidChanged() {
            const index = window.manager.history.findIndex(entry => entry.uid === window.manager.selectedUid);
            if (index >= 0) entries.positionViewAtIndex(index, ListView.Contain);
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Colors.notifications.scrim
        MouseArea { anchors.fill: parent; onClicked: window.manager.close() }
    }
    FocusScope {
        id: keyboard
        anchors.fill: parent
        focus: true
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape || event.key === Qt.Key_N) window.manager.close();
            else if (event.key === Qt.Key_D && !(event.modifiers & Qt.ControlModifier)) window.manager.toggleDnd();
            else if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab) window.manager.step(1);
            else if (event.key === Qt.Key_Up || event.key === Qt.Key_Backtab) window.manager.step(-1);
            else if (event.key === Qt.Key_Delete && window.manager.selectedUid) window.manager.remove(window.manager.selectedUid);
            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) window.manager.invoke(window.manager.selectedUid, "default");
            else if (event.key === Qt.Key_L && event.modifiers & Qt.ControlModifier) window.manager.clear();
            else return;
            event.accepted = true;
        }

        Rectangle {
            width: Math.min(430, parent.width)
            anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
            color: Colors.notifications.panel_background
            border.width: 1
            border.color: Colors.notifications.panel_border
            MouseArea { anchors.fill: parent; onClicked: keyboard.forceActiveFocus() }
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "06  /  NOTIFY"
                        color: Colors.notifications.accent
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                        font.bold: true
                        font.letterSpacing: 1
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: String(window.manager.history.length).padStart(2, "0") + " SAVED"
                        color: Colors.notifications.success
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 10
                    }
                    NotificationActionButton { text: "×"; onClicked: window.manager.close() }
                }
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Colors.notifications.divider }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 3
                    Icon { name: "bell"; size: 14; color: Colors.notifications.accent }
                    NotificationActionButton {
                        text: "DO NOT DISTURB  " + (window.manager.dnd ? "ON" : "OFF")
                        color: window.manager.dnd ? Colors.notifications.unread : Colors.notifications.control
                        onClicked: window.manager.toggleDnd()
                    }
                    Item { Layout.fillWidth: true }
                    NotificationActionButton { text: "CLEAR ALL  ×"; onClicked: window.manager.clear() }
                }

                ListView {
                    id: entries
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 0
                    clip: true
                    spacing: 9
                    model: window.manager.history
                    boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                    delegate: Column {
                        id: historyItem
                        required property var modelData
                        required property int index
                        width: ListView.view.width
                        spacing: 9
                        Text {
                            visible: historyItem.index === 1
                            text: "EARLIER"
                            color: Colors.notifications.text_dim
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 10
                        }
                        NotificationCard {
                            width: parent.width
                            entry: historyItem.modelData
                            manager: window.manager
                            compact: historyItem.index > 0 && !entry.image && window.manager.selectedUid !== entry.uid
                        }
                    }
                    Column {
                        anchors.centerIn: parent
                        width: parent.width
                        spacing: 16
                        visible: !window.manager.history.length
                        Icon { anchors.horizontalCenter: parent.horizontalCenter; name: "bell"; size: 28; color: Colors.notifications.accent }
                        Text {
                            width: parent.width
                            text: "ALL CAUGHT UP"
                            horizontalAlignment: Text.AlignHCenter
                            color: Colors.notifications.title
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 14
                        }
                        Text {
                            width: parent.width
                            text: "New notifications will appear here."
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.Wrap
                            color: Colors.notifications.control
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                        }
                    }
                }
                Text {
                    visible: window.manager.dnd || !!window.manager.storageError
                    Layout.fillWidth: true
                    text: window.manager.storageError || "Quiet mode · critical alerts still appear."
                    textFormat: Text.PlainText
                    wrapMode: Text.Wrap
                    color: window.manager.storageError ? Colors.notifications.critical : Colors.notifications.muted
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 10
                }
                Text {
                    Layout.fillWidth: true
                    text: "D toggle DND   DEL delete   ESC close"
                    wrapMode: Text.Wrap
                    color: Colors.notifications.text_dim
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 10
                }
            }
        }
    }
}
