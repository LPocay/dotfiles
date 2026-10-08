import Quickshell
import QtQuick
import QtQuick.Layouts

import "../theme"
import "../components/"

PanelWindow {
    anchors {
        top: true
        left: true
        right: true
    }
    color: Colors.topbar.toolbar_background
    implicitHeight: 62
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 25
        anchors.rightMargin: 25

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 0
            RowLayout {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                TerminalPrompt {}
                Separator {}
                Workspaces {}
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 0
            RowLayout {
                anchors.centerIn: parent
                Clock {}
            }
        }
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 0
            RowLayout {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    text: "Derecha"
                    color: "white"
                }
            }
        }
    }
}
