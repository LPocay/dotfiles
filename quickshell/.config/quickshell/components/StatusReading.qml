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
    property string icon: ""
    property string compactIcon: ""
    property bool compact: false
    property bool iconButtonStyle: false
    property bool active: false
    readonly property bool hovered: iconButtonStyle ? iconButton.hovered : mouseArea.containsMouse
    readonly property real expandedWidth: iconButtonStyle ? iconButton.implicitWidth : (label ? labelMetrics.advanceWidth + (icon || value ? row.spacing : 0) : 0)
        + (icon ? 18 + (value ? row.spacing : 0) : 0) + (value ? metrics.advanceWidth : 0)
    signal clicked

    implicitWidth: iconButtonStyle ? iconButton.implicitWidth : row.implicitWidth
    implicitHeight: iconButtonStyle ? iconButton.implicitHeight : Math.max(30, row.implicitHeight)

    IconButton {
        id: iconButton
        anchors.centerIn: parent
        visible: root.iconButtonStyle
        icon: root.icon
        active: root.active
        onClicked: root.clicked()
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: !root.iconButtonStyle
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
        visible: root.hovered && root.tooltip !== ""
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
        visible: !root.iconButtonStyle
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4
        Icon {
            name: root.compact && root.compactIcon ? root.compactIcon : root.icon
            size: 18
            color: root.valueColor
            visible: name !== ""
        }
        Text {
            visible: root.label !== "" && !root.compact
            text: `${root.label}=`
            color: Colors.topbar.text_dim
            font.pixelSize: 15
            font.family: "JetBrainsMono Nerd Font"
        }
        Item {
            visible: root.value !== ""
            Layout.preferredWidth: metrics.advanceWidth
            implicitWidth: metrics.advanceWidth
            implicitHeight: valueText.implicitHeight
            clip: true
            Text {
                id: valueText
                anchors.left: parent.left
                anchors.top: parent.top
                text: root.value
                color: root.valueColor
                font.pixelSize: 15
                font.bold: true
                font.family: "JetBrainsMono Nerd Font"
            }
        }
    }

    TextMetrics {
        id: labelMetrics
        font.pixelSize: 15
        font.family: "JetBrainsMono Nerd Font"
        text: `${root.label}=`
    }

    TextMetrics {
        id: metrics
        font.pixelSize: 15
        font.bold: true
        font.family: "JetBrainsMono Nerd Font"
        text: root.valueWidthSample
    }
}
