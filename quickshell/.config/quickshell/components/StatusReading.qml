import QtQuick
import QtQuick.Layouts
import "../theme/"

RowLayout {
    property string label
    property string value
    property color valueColor: Colors.topbar.text_primary

    spacing: 4

    Text {
        text: `${parent.label}=`
        color: Colors.topbar.text_dim
        font.pixelSize: 15
        font.family: "JetBrainsMono Nerd Font"
    }
    Text {
        text: parent.value
        color: parent.valueColor
        font.pixelSize: 15
        font.bold: true
        font.family: "JetBrainsMono Nerd Font"
    }
}
