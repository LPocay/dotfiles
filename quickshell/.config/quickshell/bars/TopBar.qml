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
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 25
        anchors.rightMargin: 25
        anchors.left: parent.left
        Workspaces {}
    }
}
