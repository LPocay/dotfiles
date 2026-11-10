pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme/"
import "MonitorLogic.js" as MonitorLogic

PanelWindow {
    id: window
    required property var settings
    objectName: "display-settings-modal"
    screen: settings.targetScreen
    visible: settings.expanded
    color: "transparent"
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "display-settings"
    WlrLayershell.keyboardFocus: settings.expanded ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    anchors { top: true; bottom: true; left: true; right: true }
    onVisibleChanged: { if (visible) Qt.callLater(() => keyboard.forceActiveFocus()); }

    Rectangle {
        anchors.fill: parent
        color: Colors.monitors.scrim
        MouseArea { anchors.fill: parent; onClicked: window.settings.close() }
    }
    FocusScope {
        id: keyboard
        objectName: "display-modal-content"
        anchors.fill: parent
        focus: true
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) window.settings.close();
            else if (event.key === Qt.Key_R && (event.modifiers & Qt.ControlModifier)) window.settings.refresh();
            else if ((event.key === Qt.Key_Enter || event.key === Qt.Key_Return) && (event.modifiers & Qt.ControlModifier)) window.settings.apply();
            else return;
            event.accepted = true;
        }
        Rectangle {
            anchors.centerIn: parent
            width: Math.min(820, Math.max(0, parent.width - 32))
            height: Math.min(720, Math.max(0, parent.height - 32))
            radius: 2
            color: Colors.monitors.panel_background
            border.width: 1
            border.color: Colors.monitors.panel_border
            MouseArea { anchors.fill: parent; onClicked: keyboard.forceActiveFocus() }

            Flickable {
                anchors.fill: parent
                anchors.margins: 26
                contentHeight: content.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                ColumnLayout {
                    id: content
                    width: parent.width
                    spacing: 16
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "06  /  DISPLAY LAYOUT"
                            color: Colors.monitors.accent
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 14
                            font.bold: true
                            font.letterSpacing: 1
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: window.settings.monitors.length + " CONNECTED"
                            color: Colors.monitors.text_dim
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                        }
                    }
                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Colors.monitors.divider }
                    Text {
                        Layout.fillWidth: true
                        text: "Drag a display to match your desk. Select it to edit its position."
                        wrapMode: Text.Wrap
                        color: Colors.monitors.text_secondary
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 13
                    }
                    DisplayPreview {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 240
                        settings: window.settings
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        ComboBox {
                            id: output
                            Layout.fillWidth: true
                            model: window.settings.monitors.map(m => m.name)
                            currentIndex: model.indexOf(window.settings.selectedName)
                            onActivated: window.settings.selectedName = currentText
                            enabled: !window.settings.loading && !window.settings.applying
                            palette.button: Colors.monitors.row_background
                            palette.buttonText: Colors.monitors.text_primary
                            palette.text: Colors.monitors.text_primary
                            palette.base: Colors.monitors.panel_background
                            palette.highlight: Colors.monitors.selection_background
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        DisplayButton {
                            text: window.settings.selectedName === window.settings.primary ? "✓ PRIMARY" : "SET PRIMARY"
                            highlighted: window.settings.selectedName === window.settings.primary
                            enabled: !!window.settings.selected && !window.settings.loading && !window.settings.applying
                            onClicked: { window.settings.primary = window.settings.selectedName; window.settings.message = ""; }
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        text: window.settings.selected ? MonitorLogic.mode(window.settings.selected) : "Select a display"
                        elide: Text.ElideRight
                        color: Colors.monitors.text_dim
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        enabled: !!window.settings.selected && !window.settings.loading && !window.settings.applying
                        Repeater {
                            model: ["X", "Y"]
                            RowLayout {
                                id: coordinate
                                required property string modelData
                                Text {
                                    text: coordinate.modelData
                                    color: Colors.monitors.accent
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 13
                                }
                                SpinBox {
                                    Layout.fillWidth: true
                                    from: -32768
                                    to: 32768
                                    editable: true
                                    value: window.settings.selected?.[coordinate.modelData.toLowerCase()] ?? 0
                                    palette.button: Colors.monitors.row_background
                                    palette.buttonText: Colors.monitors.text_primary
                                    palette.text: Colors.monitors.text_primary
                                    palette.base: Colors.monitors.command_background
                                    font.family: "JetBrainsMono Nerd Font"
                                    onValueModified: {
                                        const selected = window.settings.selected;
                                        window.settings.place(selected.name, coordinate.modelData === "X" ? value : selected.x,
                                            coordinate.modelData === "Y" ? value : selected.y, false);
                                    }
                                }
                            }
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        visible: window.settings.monitors.length > 1
                        enabled: !window.settings.loading && !window.settings.applying
                        Text {
                            text: "RELATIVE TO"
                            color: Colors.monitors.text_dim
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                        }
                        ComboBox {
                            id: reference
                            Layout.fillWidth: true
                            model: window.settings.monitors.filter(m => m.name !== window.settings.selectedName).map(m => m.name)
                            palette.button: Colors.monitors.row_background
                            palette.buttonText: Colors.monitors.text_primary
                            palette.text: Colors.monitors.text_primary
                            palette.base: Colors.monitors.panel_background
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        Repeater {
                            model: ["left", "right", "above", "below"]
                            DisplayButton {
                                required property string modelData
                                text: modelData.toUpperCase()
                                onClicked: window.settings.relative(reference.currentText, modelData)
                            }
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        text: "Primary: initial cursor display and X11 preference. Native apps follow focus."
                        wrapMode: Text.Wrap
                        color: Colors.monitors.text_dim
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                    }
                    Text {
                        Layout.fillWidth: true
                        Layout.minimumHeight: 32
                        text: window.settings.error || window.settings.message || (window.settings.applying ? "Applying layout…" : window.settings.dirty ? "Unsaved changes" : "Positions use logical pixels, including scale and rotation.")
                        textFormat: Text.PlainText
                        wrapMode: Text.Wrap
                        color: window.settings.error ? Colors.monitors.error : Colors.monitors.text_secondary
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        DisplayButton { text: "RESET"; enabled: window.settings.dirty && !window.settings.applying && !window.settings.loading; onClicked: window.settings.reset() }
                        Item { Layout.fillWidth: true }
                        DisplayButton { text: "CLOSE"; enabled: !window.settings.applying; onClicked: window.settings.close() }
                        DisplayButton {
                            text: "APPLY LAYOUT"
                            highlighted: true
                            enabled: window.settings.original !== null && window.settings.monitors.length > 0 && !window.settings.applying && !window.settings.loading
                            onClicked: window.settings.apply()
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        text: "CTRL+ENTER apply   ESC close   CTRL+R refresh"
                        color: Colors.monitors.text_dim
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
}
