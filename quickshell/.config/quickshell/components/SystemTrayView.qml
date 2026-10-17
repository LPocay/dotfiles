import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

import "../theme/"

RowLayout {
    id: root

    spacing: 4

    Repeater {
        model: SystemTray.items

        delegate: Item {
            id: trayIcon

            required property var modelData

            Layout.preferredWidth: 26
            Layout.preferredHeight: 30

            Rectangle {
                anchors.centerIn: parent
                width: 26
                height: 26
                radius: 2
                color: mouseArea.containsMouse ? Colors.topbar.workspace_hover_background : "transparent"
                border.width: mouseArea.containsMouse ? 1 : 0
                border.color: Colors.topbar.accent_lime

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

                    onClicked: event => {
                        if (event.button === Qt.LeftButton) {
                            if (trayIcon.modelData.onlyMenu && trayIcon.modelData.hasMenu) {
                                const window = trayIcon.Window.window;
                                const point = trayIcon.mapToItem(window.contentItem, 0, trayIcon.height);
                                trayIcon.modelData.display(window, Math.round(point.x), Math.round(point.y));
                            } else {
                                trayIcon.modelData.activate();
                            }
                        } else if (event.button === Qt.MiddleButton) {
                            trayIcon.modelData.secondaryActivate();
                        } else if (event.button === Qt.RightButton && trayIcon.modelData.hasMenu) {
                            const window = trayIcon.Window.window;
                            const point = trayIcon.mapToItem(window.contentItem, 0, trayIcon.height);
                            trayIcon.modelData.display(window, Math.round(point.x), Math.round(point.y));
                        }
                    }

                    ToolTip.visible: containsMouse && (trayIcon.modelData.tooltipTitle || trayIcon.modelData.title)
                    ToolTip.text: {
                        const title = trayIcon.modelData.tooltipTitle || trayIcon.modelData.title || trayIcon.modelData.id;
                        const description = trayIcon.modelData.tooltipDescription;
                        return description ? `${title}\n${description}` : title;
                    }
                    ToolTip.delay: 500
                }
            }
        }
    }
}
