import QtQuick
import QtQuick.Layouts
import "../theme/"

RowLayout {
    id: root
    spacing: 6

    // Width available before overlapping the clock; lower-priority items hide first
    property real availableWidth: 1000

    IconButton {
        id: musicButton
        icon: "music"
        active: musicPopup.expanded
        onClicked: {
            powerMenu.expanded = false;
            musicPopup.expanded = !musicPopup.expanded;
        }
    }
    IconButton {
        icon: "bell"
        visible: root.availableWidth >= 120
    }
    StatusReading {
        label: "NET"
        visible: root.availableWidth >= 330
        value: "W3JTS"
        valueColor: Colors.topbar.accent_blue
    }
    StatusReading {
        label: "VOL"
        visible: root.availableWidth >= 400
        value: "100"
        valueColor: Colors.topbar.accent_gold
    }
    StatusReading {
        label: "MIC"
        visible: root.availableWidth >= 540
        value: "ON"
        valueColor: Colors.topbar.accent_green
    }
    StatusReading {
        label: "BAT"
        visible: root.availableWidth >= 470
        value: "100"
        valueColor: Colors.topbar.accent_green
    }
    StatusReading {
        label: "CPU"
        visible: root.availableWidth >= 610
        value: "28"
    }
    StatusReading {
        label: "RAM"
        visible: root.availableWidth >= 680
        value: "42"
    }
    StatusReading {
        label: "TMP"
        visible: root.availableWidth >= 750
        value: "48°"
        valueColor: Colors.topbar.accent_warm
    }
    IconButton {
        id: powerButton
        icon: "power"
        iconSize: 16
        implicitWidth: 30
        implicitHeight: 30
        active: powerMenu.expanded
        onClicked: {
            musicPopup.expanded = false;
            powerMenu.expanded = !powerMenu.expanded;
        }
    }

    MusicPopup {
        id: musicPopup
        anchor.item: musicButton
        anchor.rect.x: musicButton.width - musicPopup.width
        anchor.rect.y: musicButton.height + 10
    }
    PowerMenu {
        id: powerMenu
        anchor.item: powerButton
        anchor.rect.x: powerButton.width - powerMenu.width
        anchor.rect.y: powerButton.height + 10
    }
}
