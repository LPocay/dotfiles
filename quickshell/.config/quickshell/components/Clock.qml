import Quickshell
import QtQuick
import QtQuick.Layouts

RowLayout {
    spacing: 10
    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
    Text {
        text: "TIME"
        color: "#87A987"
        font.pixelSize: 14
        font.family: "JetBrainsMono Nerd Font"
    }
    Text {
        text: Qt.formatDateTime(clock.date, "HH:mm:ss")
        color: "#C5C9C5"
        font.pixelSize: 20
        font.family: "JetBrainsMono Nerd Font"
        font.bold: true
    }
    Text {
        text: `// ${Qt.formatDateTime(clock.date, "yyyy.MM.dd")}`
        color: "#87A987"
        font.pixelSize: 14
        font.family: "JetBrainsMono Nerd Font"
    }
}
