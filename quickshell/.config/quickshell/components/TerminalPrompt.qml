import QtQuick
import QtQuick.Layouts
import "../theme/"

Item {
    id: root
    signal clicked()
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    RowLayout {
        id: content
        anchors.fill: parent
        spacing: 16

        Text {
            text: "❯_"
            color: Colors.topbar.accent_green
            font.pixelSize: 21
            font.bold: true
            font.family: "JetBrainsMono Nerd Font"
        }

        Text {
            text: "~/hypr"
            color: Colors.topbar.accent_blue
            font.pixelSize: 13
            font.family: "JetBrainsMono Nerd Font"
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
