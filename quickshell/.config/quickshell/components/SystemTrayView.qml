import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts

import "../theme/"

RowLayout {
    id: root

    property var panelWindow
    spacing: 4

    Repeater {
        model: SystemTray.items

        delegate: Item {
            id: trayIcon

            required property var modelData
            readonly property string tooltipText: {
                const item = modelData;
                const title = item.tooltipTitle || item.title || item.id || "";
                const description = item.tooltipDescription || "";
                return description ? `${title}\n${description}` : title;
            }

            Layout.preferredWidth: 26
            Layout.preferredHeight: 30

            Rectangle {
                anchors.centerIn: parent
                width: 26
                height: 26
                radius: 2
                color: "transparent"
                border.width: 0

                Image {
                    id: iconImage
                    anchors.centerIn: parent
                    source: trayIcon.modelData.icon
                    sourceSize.width: 18
                    sourceSize.height: 18
                    width: 18
                    height: 18
                    fillMode: Image.PreserveAspectFit
                    visible: status === Image.Ready

                    onStatusChanged: {
                        if (status === Image.Error)
                            console.warn(`System tray icon failed to load: ${trayIcon.modelData.id}`);
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: (trayIcon.modelData.title || trayIcon.modelData.id || "?").charAt(0).toUpperCase()
                    color: Colors.topbar.text_muted
                    font.pixelSize: 12
                    visible: iconImage.status === Image.Error
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                    cursorShape: Qt.PointingHandCursor

                    function openMenu() {
                        const item = trayIcon.modelData;
                        if (!item.hasMenu || !root.panelWindow)
                            return;

                        const point = trayIcon.mapToItem(null, 0, trayIcon.height + 4);
                        item.display(root.panelWindow, Math.round(point.x), Math.round(point.y));
                    }

                    onClicked: event => {
                        const item = trayIcon.modelData;
                        if (event.button === Qt.LeftButton) {
                            if (item.onlyMenu) {
                                openMenu();
                            } else {
                                item.activate();
                            }
                        } else if (event.button === Qt.MiddleButton) {
                            item.secondaryActivate();
                        } else if (event.button === Qt.RightButton && trayIcon.modelData.hasMenu) {
                            openMenu();
                        }
                    }

                }
            }

            PopupWindow {
                anchor.item: trayIcon
                anchor.rect.x: 0
                anchor.rect.y: trayIcon.height + 10
                implicitWidth: tipText.width + 20
                implicitHeight: tipText.implicitHeight + 14
                visible: mouseArea.containsMouse && trayIcon.tooltipText !== ""
                color: "transparent"

                Rectangle {
                    anchors.fill: parent
                    color: Colors.topbar.panel_background
                    border.color: Colors.topbar.power_menu_terminal_prompt
                    radius: 2

                    Text {
                        id: tipText
                        anchors.centerIn: parent
                        width: Math.min(implicitWidth, 360)
                        text: trayIcon.tooltipText
                        wrapMode: Text.Wrap
                        color: Colors.topbar.text_primary
                        font.pixelSize: 13
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }
            }
        }
    }
}
