import QtQuick
import QtQuick.Effects

// Los SVG usan trazo blanco; MultiEffect los tiñe con `color`.
Item {
    id: root
    property string name
    property int size: 16
    property color color: "white"

    implicitWidth: size
    implicitHeight: size

    Image {
        id: image
        anchors.fill: parent
        visible: false
        source: Qt.resolvedUrl(`../assets/icons/${root.name}.svg`)
        sourceSize: Qt.size(root.size * 2, root.size * 2)
    }
    MultiEffect {
        anchors.fill: image
        source: image
        colorization: 1.0
        colorizationColor: root.color
    }
}
