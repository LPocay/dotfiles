pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme/"
import "NotificationLogic.js" as Logic

Rectangle {
    id: root
    required property var entry
    required property var manager
    property bool compact: false
    property bool popup: false
    readonly property color accent: entry.urgency === 2 ? Colors.notifications.critical
        : entry.image ? Colors.notifications.image_accent : Colors.notifications.success
    implicitHeight: compact ? 69 : content.implicitHeight + 26
    height: implicitHeight
    radius: 2
    color: compact ? Colors.notifications.history_background : Colors.notifications.toast_background
    border.width: compact ? 0 : 1
    border.color: entry.urgency === 2 ? Colors.notifications.critical
        : entry.image ? Colors.notifications.image_border : Colors.notifications.toast_border
    Accessible.role: Accessible.ListItem
    Accessible.name: entry.appName + ", " + entry.summary + ", " + entry.body
    HoverHandler {
        onHoveredChanged: {
            if (root.popup) {
                const manager = root.manager;
                const uid = root.entry.uid;
                const paused = hovered;
                Qt.callLater(() => manager.pause(uid, paused));
            }
        }
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: root.compact ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.manager.selectedUid = root.entry.uid
        onDoubleClicked: root.manager.invoke(root.entry.uid, "default")
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 9
        anchors.rightMargin: 9
        spacing: 10
        visible: root.compact
        Icon { name: Logic.icon(root.entry); size: 18; color: root.accent }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4
            Text {
                Layout.fillWidth: true
                text: root.entry.summary
                textFormat: Text.PlainText
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
                font.bold: true
                color: Colors.notifications.history_title
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                text: root.entry.body || root.entry.appName
                textFormat: Text.PlainText
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 11
                color: Colors.notifications.history_body
                elide: Text.ElideRight
            }
        }
        Text {
            text: Logic.clock(root.entry.timestamp)
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 9
            color: Colors.notifications.text_dim
        }
        NotificationActionButton { text: "DELETE"; onClicked: root.manager.remove(root.entry.uid) }
    }

    ColumnLayout {
        id: content
        visible: !root.compact
        x: 13
        y: 13
        width: Math.max(0, parent.width - 26)
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 7
            Item {
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
                Icon {
                    anchors.fill: parent
                    name: Logic.icon(root.entry)
                    size: 16
                    color: root.accent
                    visible: appIcon.status !== Image.Ready
                }
                Image {
                    id: appIcon
                    anchors.fill: parent
                    source: root.entry.icon ? (/^(?:\/|file:|image:)/.test(root.entry.icon)
                        ? root.entry.icon : Quickshell.iconPath(root.entry.icon, true)) : ""
                    sourceSize: Qt.size(32, 32)
                    fillMode: Image.PreserveAspectFit
                    visible: status === Image.Ready
                }
            }
            Text {
                Layout.fillWidth: true
                text: root.entry.appName.toUpperCase()
                textFormat: Text.PlainText
                color: root.accent
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 10
                font.bold: true
                elide: Text.ElideRight
            }
            Text {
                text: Logic.clock(root.entry.timestamp)
                color: Colors.notifications.timestamp
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 10
            }
            NotificationActionButton {
                visible: root.popup
                text: "×"
                color: Colors.notifications.timestamp
                onClicked: root.manager.dismiss(root.entry.uid)
            }
        }

        Text {
            Layout.fillWidth: true
            text: root.entry.summary
            textFormat: Text.PlainText
            color: Colors.notifications.title
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 17
            font.bold: true
            wrapMode: Text.Wrap
            maximumLineCount: root.popup ? 3 : 8
            elide: Text.ElideRight
        }
        Text {
            Layout.fillWidth: true
            visible: !!root.entry.body
            text: root.entry.body
            textFormat: Text.PlainText
            color: Colors.notifications.body
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            wrapMode: Text.Wrap
            maximumLineCount: root.popup ? 4 : 16
            elide: Text.ElideRight
        }

        Image {
            id: preview
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? 100 : 0
            visible: !!root.entry.image && status !== Image.Error
            source: root.entry.image
            sourceSize: Qt.size(728, 400)
            fillMode: Image.PreserveAspectCrop
            clip: true
        }

        Flow {
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
            spacing: 10
            Repeater {
                model: root.entry.active ? root.entry.actions : []
                delegate: NotificationActionButton {
                    required property var modelData
                    text: "[ " + (modelData.text || (modelData.id === "default" ? "OPEN" : modelData.id)).toUpperCase() + " ]"
                    color: root.accent
                    width: Math.min(implicitWidth, content.width)
                    onClicked: root.manager.invoke(root.entry.uid, modelData.id)
                }
            }
            NotificationActionButton {
                text: root.popup ? "DISMISS" : "DELETE"
                onClicked: root.popup ? root.manager.dismiss(root.entry.uid) : root.manager.remove(root.entry.uid)
            }
        }

        RowLayout {
            visible: !root.popup && root.entry.active && root.entry.inlineReply
            Layout.fillWidth: true
            TextField {
                id: reply
                Layout.fillWidth: true
                placeholderText: root.entry.replyPlaceholder
                placeholderTextColor: Colors.notifications.muted
                color: Colors.notifications.title
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
                background: Rectangle { color: Colors.notifications.history_background; border.color: root.accent; border.width: 1 }
                onAccepted: {
                    root.manager.reply(root.entry.uid, text);
                    clear();
                }
            }
            NotificationActionButton {
                text: "SEND"
                color: root.accent
                onClicked: {
                    root.manager.reply(root.entry.uid, reply.text);
                    reply.clear();
                }
            }
        }
    }
}
