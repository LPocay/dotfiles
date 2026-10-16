import Quickshell
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
        value: SystemStats.netName ? SystemStats.netName.toUpperCase().substring(0, 10) : "OFF"
        valueColor: SystemStats.netName ? Colors.topbar.accent_blue : Colors.topbar.text_dim
        tooltip: SystemStats.netIp ? `${SystemStats.netName}  ${SystemStats.netIp}` : "sin conexión"
    }
    StatusReading {
        label: "VOL"
        visible: root.availableWidth >= 400
        value: SystemStats.volumeMuted ? "MUTE" : String(SystemStats.volume)
        valueColor: SystemStats.volumeMuted ? Colors.topbar.text_dim : Colors.topbar.accent_gold
        clickable: true
        onClicked: Quickshell.execDetached(["pavucontrol"])
    }
    StatusReading {
        label: "MIC"
        visible: root.availableWidth >= 540
        value: SystemStats.micMuted ? "OFF" : "ON"
        valueColor: SystemStats.micMuted ? Colors.topbar.text_dim : Colors.topbar.accent_green
        clickable: true
        onClicked: Quickshell.execDetached(["pavucontrol", "--tab=4"])
    }
    StatusReading {
        label: "BAT"
        visible: SystemStats.hasBattery && root.availableWidth >= 470
        value: String(SystemStats.batteryPercent) + (SystemStats.batteryCharging ? "+" : "")
        valueColor: SystemStats.batteryPercent < 20 && !SystemStats.batteryCharging ? Colors.topbar.accent_warm : Colors.topbar.accent_green
    }
    StatusReading {
        label: "CPU"
        visible: root.availableWidth >= 610
        value: String(SystemStats.cpu)
        clickable: true
        onClicked: Quickshell.execDetached(["ghostty", "-e", "btop"])
    }
    StatusReading {
        label: "RAM"
        visible: root.availableWidth >= 680
        value: String(SystemStats.ram)
        clickable: true
        onClicked: Quickshell.execDetached(["ghostty", "-e", "btop"])
    }
    StatusReading {
        label: "TMP"
        visible: SystemStats.temp >= 0 && root.availableWidth >= 750
        value: SystemStats.temp + "°"
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
