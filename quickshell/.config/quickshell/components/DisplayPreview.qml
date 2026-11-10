pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../theme/"
import "DisplayLogic.js" as Logic

Rectangle {
    id: root
    required property var settings
    readonly property var bounds: Logic.bounds(settings.monitors)
    readonly property real factor: Math.min((width - 80) / bounds.width, (height - 64) / bounds.height)
    color: Colors.monitors.command_background
    border.width: 1
    border.color: Colors.monitors.row_border
    clip: true

    Repeater {
        model: root.settings.monitors
        Rectangle {
            id: tile
            required property var modelData
            property real offsetX: 0
            property real offsetY: 0
            readonly property bool selected: modelData.name === root.settings.selectedName
            readonly property var dimensions: Logic.size(modelData)
            objectName: "display-preview-" + modelData.name
            x: (root.width - root.bounds.width * root.factor) / 2 + (modelData.x - root.bounds.x) * root.factor + offsetX
            y: (root.height - root.bounds.height * root.factor) / 2 + (modelData.y - root.bounds.y) * root.factor + offsetY
            width: dimensions.width * root.factor
            height: dimensions.height * root.factor
            z: drag.pressed ? 2 : selected ? 1 : 0
            radius: 2
            color: selected ? Colors.monitors.selection_background : Colors.monitors.current_background
            border.width: selected ? 2 : 1
            border.color: selected ? Colors.monitors.selection_border : Colors.monitors.row_border
            ColumnLayout {
                anchors.centerIn: parent
                width: Math.max(0, parent.width - 16)
                spacing: 5
                Text {
                    Layout.fillWidth: true
                    text: tile.modelData.name
                    textFormat: Text.PlainText
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    color: Colors.monitors.text_primary
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                    font.bold: true
                }
                Text {
                    Layout.fillWidth: true
                    text: tile.modelData.name === root.settings.primary ? "PRIMARY" : tile.dimensions.width + " × " + tile.dimensions.height
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    color: Colors.monitors.accent
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                }
            }
            MouseArea {
                id: drag
                anchors.fill: parent
                enabled: !root.settings.loading && !root.settings.applying
                cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                property var start
                onPressed: mouse => {
                    root.settings.selectedName = tile.modelData.name;
                    start = mapToItem(root, mouse.x, mouse.y);
                }
                onPositionChanged: mouse => {
                    if (!pressed) return;
                    const point = mapToItem(root, mouse.x, mouse.y);
                    tile.offsetX = point.x - start.x;
                    tile.offsetY = point.y - start.y;
                }
                onReleased: {
                    const x = tile.modelData.x + tile.offsetX / root.factor;
                    const y = tile.modelData.y + tile.offsetY / root.factor;
                    const name = tile.modelData.name;
                    tile.offsetX = 0;
                    tile.offsetY = 0;
                    root.settings.place(name, x, y, true);
                }
                onCanceled: { tile.offsetX = 0; tile.offsetY = 0; }
            }
        }
    }
    Text {
        anchors.centerIn: parent
        visible: !root.settings.monitors.length
        text: root.settings.loading ? "Loading monitors…" : "No active monitors"
        color: Colors.monitors.text_secondary
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 14
    }
}
