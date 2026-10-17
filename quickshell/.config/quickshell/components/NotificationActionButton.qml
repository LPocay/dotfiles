import QtQuick
import "../theme/"

Item {
    id: root
    property string text
    property color color: Colors.notifications.muted
    signal clicked()
    implicitWidth: label.implicitWidth + 8
    implicitHeight: label.implicitHeight + 8
    Accessible.role: Accessible.Button
    Accessible.name: text
    Accessible.onPressAction: root.clicked()
    Text {
        id: label
        anchors.centerIn: parent
        width: Math.max(0, parent.width - 8)
        text: root.text
        textFormat: Text.PlainText
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 10
        color: mouse.containsMouse ? Colors.notifications.title : root.color
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
