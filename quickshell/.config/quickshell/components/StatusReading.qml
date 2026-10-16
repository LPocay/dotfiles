import Quickshell
import QtQuick
import QtQuick.Layouts
import "../theme/"

Item {
    id: root
    property string label
    property string value
    property color valueColor: Colors.topbar.text_primary
    property string tooltip: ""
    property bool clickable: false
    property string valueWidthSample: "888"
    signal clicked

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }

    PopupWindow {
        anchor.item: root
        anchor.rect.x: 0
        anchor.rect.y: root.height + 10
        implicitWidth: tipText.implicitWidth + 20
        implicitHeight: tipText.implicitHeight + 14
        visible: mouseArea.containsMouse && root.tooltip !== ""
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: Colors.topbar.panel_background
            border.color: Colors.topbar.power_menu_terminal_prompt
            radius: 2
            Text {
                id: tipText
                anchors.centerIn: parent
                text: root.tooltip
                color: Colors.topbar.text_primary
                font.pixelSize: 13
                font.family: "JetBrainsMono Nerd Font"
            }
        }
    }

    RowLayout {
        id: row
        spacing: 4
        Text {
            text: `${root.label}=`
            color: Colors.topbar.text_dim
            font.pixelSize: 15
            font.family: "JetBrainsMono Nerd Font"
        }
        Text {
            text: root.value
            color: root.valueColor
            font.pixelSize: 15
            font.bold: true
            font.family: "JetBrainsMono Nerd Font"
            width: metrics.advanceWidth
        }
    }

    TextMetrics {
        id: metrics
        font.pixelSize: 15
        font.bold: true
        font.family: "JetBrainsMono Nerd Font"
        text: root.valueWidthSample
    }
}
