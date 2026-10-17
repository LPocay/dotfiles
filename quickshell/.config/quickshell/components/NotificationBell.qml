import QtQuick
import "../theme/"

IconButton {
    id: root
    required property var manager
    icon: "bell"
    active: manager.expanded
    Accessible.role: Accessible.Button
    Accessible.name: "Notifications, " + manager.unreadCount + " unread" + (manager.dnd ? ", do not disturb on" : "")
    Accessible.onPressAction: root.clicked()
    Rectangle {
        x: 18
        y: 0
        width: 6
        height: 6
        radius: 3
        visible: root.manager.unreadCount > 0
        color: Colors.notifications.unread
    }
    Rectangle {
        anchors.centerIn: parent
        width: 16
        height: 1
        rotation: -45
        color: Colors.notifications.unread
        visible: root.manager.dnd
    }
}
