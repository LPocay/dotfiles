import QtQuick

// Single-line text that scrolls horizontally only when it does not fit
Item {
    id: root
    property string text
    property color color: "white"
    property int pixelSize: 14
    property bool bold: false
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int gap: 40
    property real speed: 40 // pixels per second
    property bool enabled: true

    readonly property bool overflowing: measure.implicitWidth > width

    implicitHeight: measure.implicitHeight
    clip: true

    Text {
        id: measure
        visible: false
        text: root.text
        font.pixelSize: root.pixelSize
        font.bold: root.bold
        font.family: root.fontFamily
    }

    Row {
        id: strip
        spacing: root.gap
        Text {
            text: root.text
            color: root.color
            font: measure.font
        }
        Text {
            visible: root.overflowing
            text: root.text
            color: root.color
            font: measure.font
        }
    }

    SequentialAnimation {
        id: scrollAnimation
        running: root.enabled && root.overflowing && root.visible
        loops: Animation.Infinite
        onRunningChanged: if (!running)
            strip.x = 0
        PauseAnimation {
            duration: 1500
        }
        NumberAnimation {
            target: strip
            property: "x"
            from: 0
            to: -(measure.implicitWidth + root.gap)
            duration: (measure.implicitWidth + root.gap) / root.speed * 1000
        }
    }

    // Restart from the beginning when the text changes
    onTextChanged: Qt.callLater(() => {
        strip.x = 0;
        if (root.overflowing && root.visible)
            scrollAnimation.restart();
    })
    onOverflowingChanged: strip.x = 0
}
