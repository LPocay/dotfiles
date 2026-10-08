import QtQuick
import QtQuick.Layouts
import "../theme/"

RowLayout {
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
