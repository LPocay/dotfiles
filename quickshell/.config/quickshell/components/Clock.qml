import Quickshell
import QtQuick
import QtQuick.Layouts
import "../theme/"
import "./"

Item {
    id: root
    implicitWidth: clockContent.implicitWidth
    implicitHeight: clockContent.implicitHeight
    RowLayout {
        id: clockContent
        spacing: 10
        SystemClock {
            id: clock
            precision: SystemClock.Seconds
        }
        Text {
            text: "TIME"
            color: Colors.topbar.accent_green
            font.pixelSize: 14
            font.family: "JetBrainsMono Nerd Font"
        }
        Text {
            text: Qt.formatTime(clock.date, "HH:mm:ss")
            color: Colors.topbar.text_primary
            font.pixelSize: 20
            font.family: "JetBrainsMono Nerd Font"
            font.bold: true
        }
        Text {
            text: `// ${Qt.formatDate(clock.date, "yyyy.MM.dd")}`
            color: Colors.topbar.accent_green
            font.pixelSize: 14
            font.family: "JetBrainsMono Nerd Font"
        }
    }
    Calendar {
        id: calendarPopup
        anchor.item: root
        anchor.rect.y: root.height + 10
        anchor.rect.x: (root.width - calendarPopup.width) / 2
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: calendarPopup.expanded = !calendarPopup.expanded
    }
}
