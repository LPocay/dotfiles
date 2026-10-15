import Quickshell
import QtQuick
import QtQuick.Layouts
import "../theme/"

PopupWindow {
    id: calendarPopup
    implicitWidth: 300
    implicitHeight: 240

    property bool expanded: true
    visible: expanded
    color: "transparent"
    Rectangle {
        anchors.fill: parent
        border.color: Colors.topbar.power_menu_terminal_prompt
        color: Colors.topbar.panel_background
        radius: 2
        Item {
            anchors.fill: parent
            anchors.margins: 16
            ColumnLayout {
                anchors.fill: parent
                spacing: 12
                RowLayout {
                    Text {
                        font.bold: true
                        font.pixelSize: 13
                        color: Colors.topbar.accent_lime
                        text: "cal 2026-10"
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    Text {
                        text: "‹"
                        color: "#87A987"
                        font.pixelSize: 18
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    Text {
                        text: "›"
                        color: "#87A987"
                        font.pixelSize: 18
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Repeater {
                        model: ["SU", "MO", "TU", "WE", "TH", "FR", "SA"]

                        Text {
                            required property string modelData

                            text: modelData
                            color: Colors.topbar.text_dim
                            font.family: "JetBrainsMono Nerd Font"

                            Layout.fillWidth: true
                            Layout.preferredWidth: 0
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
                RowLayout {}
            }
        }
    }
}
