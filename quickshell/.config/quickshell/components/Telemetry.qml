import QtQuick
import QtQuick.Layouts
import "../theme/"

RowLayout {
    id: root
    spacing: 6

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
    }
    StatusReading {
        label: "NET"
        value: "W3JTS"
        valueColor: Colors.topbar.accent_blue
    }
    StatusReading {
        label: "VOL"
        value: "100"
        valueColor: Colors.topbar.accent_gold
    }
    StatusReading {
        label: "MIC"
        value: "ON"
        valueColor: Colors.topbar.accent_green
    }
    StatusReading {
        label: "BAT"
        value: "100"
        valueColor: Colors.topbar.accent_green
    }
    StatusReading {
        label: "CPU"
        value: "28"
    }
    StatusReading {
        label: "RAM"
        value: "42"
    }
    StatusReading {
        label: "TMP"
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
