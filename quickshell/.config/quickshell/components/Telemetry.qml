import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts
import "../theme/"

RowLayout {
    id: root
    spacing: 6

    // Width available before overlapping the clock; lower-priority items hide first
    property real availableWidth: 1000
    readonly property real statusWidth: Math.max(0, availableWidth - tray.implicitWidth - (SystemTray.items.count > 0 ? 10 : 0))

    SystemTrayView {
        id: tray
    }

    Separator {
        visible: SystemTray.items.count > 0
    }

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
        visible: root.statusWidth >= 120
    }
    StatusReading {
        label: "NET"
        visible: root.statusWidth >= 330
        value: SystemStats.netName ? SystemStats.netName.toUpperCase().substring(0, 10) : "OFF"
        valueColor: SystemStats.netName ? Colors.topbar.accent_blue : Colors.topbar.text_dim
        tooltip: SystemStats.netIp ? `${SystemStats.netName}  ${SystemStats.netIp}` : "sin conexión"
        valueWidthSample: "OFF"
        clickable: true
        onClicked: Quickshell.execDetached(["ghostty", "-e", "impala"])
    }
    StatusReading {
        label: "VOL"
        visible: root.statusWidth >= 400
        value: SystemStats.volumeMuted ? "MUTE" : String(SystemStats.volume)
        valueColor: SystemStats.volumeMuted ? Colors.topbar.text_dim : Colors.topbar.accent_gold
        valueWidthSample: "MUTE"
        clickable: true
        onClicked: Quickshell.execDetached(["pavucontrol"])
    }
    StatusReading {
        label: "MIC"
        visible: root.statusWidth >= 540
        value: SystemStats.micMuted ? "OFF" : "ON"
        valueColor: SystemStats.micMuted ? Colors.topbar.text_dim : Colors.topbar.accent_green
        valueWidthSample: "OFF"
        clickable: true
        onClicked: Quickshell.execDetached(["pavucontrol", "--tab=4"])
    }
    StatusReading {
        label: "BAT"
        visible: SystemStats.hasBattery && root.statusWidth >= 470
        value: String(SystemStats.batteryPercent) + (SystemStats.batteryCharging ? "+" : "")
        valueColor: SystemStats.batteryPercent < 20 && !SystemStats.batteryCharging ? Colors.topbar.accent_warm : Colors.topbar.accent_green
        valueWidthSample: "100+"
    }
    StatusReading {
        label: "CPU"
        visible: root.statusWidth >= 610
        value: String(SystemStats.cpu)
        valueWidthSample: "100"
        clickable: true
        onClicked: Quickshell.execDetached(["ghostty", "-e", "btop"])
    }
    StatusReading {
        label: "RAM"
        visible: root.statusWidth >= 680
        value: String(SystemStats.ram)
        valueWidthSample: "100"
        clickable: true
        onClicked: Quickshell.execDetached(["ghostty", "-e", "btop"])
    }
    StatusReading {
        label: "TMP"
        visible: SystemStats.temp >= 0 && root.statusWidth >= 750
        value: SystemStats.temp + "°"
        valueColor: Colors.topbar.accent_warm
        valueWidthSample: "100°"
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
