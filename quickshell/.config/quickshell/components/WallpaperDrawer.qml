import "../theme/"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: window

    required property var picker
    property real reveal: 0
    readonly property int drawerWidth: Math.min(530, width)

    screen: picker.targetScreen
    visible: picker.expanded || reveal > 0
    color: "transparent"
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "wallpaper-drawer"
    WlrLayershell.keyboardFocus: picker.expanded ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    onVisibleChanged: {
        if (visible) {
            keyboard.forceActiveFocus();
        }
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    // Respect the top bar's exclusive zone without reserving desktop space.

    Connections {
        function onExpandedChanged() {
            window.reveal = window.picker.expanded ? 1 : 0;
            if (window.picker.expanded)
                keyboard.forceActiveFocus();

        }

        target: window.picker
    }

    Rectangle {
        anchors.fill: parent
        color: Colors.wallpaper.wallpaper_scrim
        opacity: window.reveal

        MouseArea {
            anchors.fill: parent
            onClicked: window.picker.cancel()
        }

    }

    FocusScope {
        id: keyboard

        anchors.fill: parent
        focus: true
        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Escape) {
                window.picker.cancel();
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                window.picker.apply();
            } else if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
                window.picker.cycleOutput();
            } else if (event.key === Qt.Key_Right) {
                window.picker.select(window.picker.selectedIndex + 1);
            } else if (event.key === Qt.Key_Left) {
                window.picker.select(window.picker.selectedIndex - 1);
            } else if (event.key === Qt.Key_Down) {
                window.picker.select(Math.min(window.picker.wallpapers.length - 1, window.picker.selectedIndex + 3));
            } else if (event.key === Qt.Key_Up) {
                window.picker.select(Math.max(0, window.picker.selectedIndex - 3));
            } else if (event.key === Qt.Key_W && window.picker.wallpapers.length > 1) {
                const offset = 1 + Math.floor(Math.random() * (window.picker.wallpapers.length - 1));
                window.picker.select(window.picker.selectedIndex + offset);
            } else {
                return ;
            }
            event.accepted = true;
        }

        Rectangle {
            id: drawer

            width: window.drawerWidth
            height: parent.height
            x: parent.width - width * window.reveal
            color: Colors.wallpaper.panel_background
            border.color: Colors.wallpaper.toolbar_accent

            // Consume clicks in the panel, including gaps between controls.
            MouseArea {
                anchors.fill: parent
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 0

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true

                        Label {
                            Layout.fillWidth: true
                            text: "02  /  WALLPAPER"
                            color: Colors.wallpaper.accent_green
                            font.pixelSize: 11
                            font.bold: true
                            font.letterSpacing: 1
                        }

                        Label {
                            text: `${String(window.picker.selectedIndex + 1).padStart(2, "0")} / ${String(window.picker.wallpapers.length).padStart(2, "0")}`
                        }

                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Colors.wallpaper.subtle_divider
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 138
                        clip: true
                        color: Colors.wallpaper.output_background

                        Image {
                            anchors.fill: parent
                            source: window.picker.selected ? "file://" + encodeURI(window.picker.selected.thumbnail).replace(/#/g, "%23").replace(/\?/g, "%3F") : ""
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.bottom: parent.bottom
                            anchors.margins: 12
                            width: Math.min(parent.width - 24, previewLabel.implicitWidth + 16)
                            height: 23
                            radius: 2
                            color: Colors.wallpaper.current_wallpaper_label

                            Label {
                                id: previewLabel

                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                verticalAlignment: Text.AlignVCenter
                                text: window.picker.selected ? window.picker.selected.name.toUpperCase() + "  /  PREVIEW" : window.picker.loading ? "LOADING WALLPAPERS…" : "NO WALLPAPERS"
                                font.bold: true
                                color: Colors.wallpaper.current_wallpaper_name
                            }

                        }

                    }

                    Label {
                        text: "OUTPUTS / APPLY TO"
                        font.pixelSize: 11
                        font.bold: true
                        color: Colors.wallpaper.accent_green
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 13

                        Repeater {
                            model: window.picker.outputs

                            Rectangle {
                                id: output

                                required property var modelData
                                readonly property bool selected: window.picker.selectedOutputs.includes(modelData.name)

                                Layout.fillWidth: true
                                Layout.preferredHeight: 43
                                color: selected ? Colors.wallpaper.output_selected_background : Colors.wallpaper.output_background
                                border.color: selected ? Colors.wallpaper.output_selected_border : Colors.wallpaper.output_border

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12

                                    Label {
                                        Layout.fillWidth: true
                                        text: `${output.modelData.name}  ·  ${output.modelData.name.startsWith("eDP") || output.modelData.name.startsWith("LVDS") ? "internal" : "external"} ${output.modelData.width}×${output.modelData.height}`
                                        color: output.selected ? Colors.wallpaper.output_selected_text : Colors.wallpaper.output_text
                                        font.pixelSize: 11
                                    }

                                    Label {
                                        text: output.selected ? "● SELECTED" : "○"
                                        color: output.selected ? Colors.wallpaper.accent_lime : Colors.wallpaper.output_state
                                    }

                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: window.picker.toggleOutput(output.modelData.name)
                                }

                            }

                        }

                    }

                    Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        elide: Text.ElideNone
                        font.pixelSize: 12
                        color: Colors.wallpaper.live_preview_note
                        text: "Preview updates the desktop immediately. Esc returns to the current wallpaper until you apply."
                    }

                    Label {
                        Layout.fillWidth: true
                        text: "ENTER apply   TAB output   W shuffle"
                    }

                    Label {
                        Layout.fillWidth: true
                        visible: text !== ""
                        wrapMode: Text.WrapAnywhere
                        elide: Text.ElideNone
                        color: Colors.wallpaper.error
                        text: window.picker.error
                    }

                }

                GridView {
                    id: thumbnails

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.topMargin: 12
                    cellWidth: (width - 12) / 3
                    cellHeight: 87
                    flickableDirection: Flickable.VerticalFlick
                    clip: true
                    model: window.picker.wallpapers
                    currentIndex: window.picker.selectedIndex
                    highlightMoveDuration: 150
                    highlightRangeMode: GridView.ApplyRange
                    boundsBehavior: Flickable.StopAtBounds
                    onCurrentIndexChanged: positionViewAtIndex(currentIndex, GridView.Contain)

                    delegate: Rectangle {
                        id: thumbnail

                        required property var modelData
                        required property int index

                        width: thumbnails.cellWidth - 9
                        height: 78
                        radius: 2
                        color: Colors.wallpaper.output_background
                        border.width: index === window.picker.selectedIndex ? 2 : 1
                        border.color: index === window.picker.selectedIndex || hover.containsMouse ? Colors.wallpaper.accent_lime : Colors.wallpaper.thumbnail_border

                        Image {
                            anchors.fill: parent
                            anchors.margins: thumbnail.border.width
                            source: "file://" + encodeURI(thumbnail.modelData.thumbnail).replace(/#/g, "%23").replace(/\?/g, "%3F")
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            sourceSize.width: 240
                            sourceSize.height: 135
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.margins: 2
                            height: 23
                            color: Colors.wallpaper.current_wallpaper_label

                            Label {
                                anchors.fill: parent
                                anchors.leftMargin: 5
                                anchors.rightMargin: 5
                                verticalAlignment: Text.AlignVCenter
                                text: `${String(thumbnail.index + 1).padStart(2, "0")} ${thumbnail.modelData.name.toUpperCase()}`
                                color: Colors.wallpaper.thumbnail_label
                            }

                        }

                        MouseArea {
                            id: hover

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: window.picker.select(thumbnail.index)
                        }

                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }

                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 20
                    Layout.bottomMargin: 39
                    spacing: 10

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 43
                        opacity: window.picker.canApply ? 1 : 0.4
                        color: Colors.wallpaper.apply_background
                        border.color: Colors.wallpaper.accent_green

                        Label {
                            anchors.centerIn: parent
                            text: window.picker.finishing ? "WORKING…" : "ENTER  /  APPLY WALLPAPER"
                            color: Colors.wallpaper.apply_label
                            font.pixelSize: 11
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: window.picker.canApply
                            cursorShape: Qt.PointingHandCursor
                            onClicked: window.picker.apply()
                        }

                    }

                    Rectangle {
                        Layout.preferredWidth: 130
                        Layout.preferredHeight: 43
                        color: Colors.wallpaper.cancel_background
                        border.color: Colors.wallpaper.cancel_border

                        Label {
                            anchors.centerIn: parent
                            text: "ESC  /  BACK"
                            color: Colors.wallpaper.cancel_label
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: !window.picker.finishing
                            cursorShape: Qt.PointingHandCursor
                            onClicked: window.picker.cancel()
                        }

                    }

                }

            }

        }

    }

    Behavior on reveal {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }

    }

    component Label: Text {
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 10
        color: Colors.wallpaper.text_dim
        elide: Text.ElideRight
    }

}
