import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts
import "../theme/"
import "TelemetryLogic.js" as Logic

RowLayout {
    id: root
    required property var notifications
    spacing: 6

    // Width available before overlapping the clock; lower-priority items hide first
    property real availableWidth: 1000
    property var panelWindow
    readonly property real separatorFootprint: traySeparator.Layout.leftMargin + traySeparator.implicitWidth + traySeparator.Layout.rightMargin
    readonly property real fixedControlsWidth: musicButton.implicitWidth + notificationBell.implicitWidth + powerButton.implicitWidth + spacing * 2
    readonly property real trayDecorationWidth: SystemTray.items.values.length > 0 ? separatorFootprint + spacing * 2 : 0
    // Keep reading visibility based on the unbounded tray width.
    readonly property real trayFootprint: tray.naturalWidth + trayDecorationWidth
    readonly property real statusWidth: Math.max(0, availableWidth - trayFootprint)
    readonly property var visibleMetrics: Logic.fit([
        { key: "vol", width: volumeReading.implicitWidth, available: true },
        { key: "net", width: netReading.implicitWidth, available: true },
        { key: "bat", width: batteryReading.implicitWidth, available: SystemStats.hasBattery },
        { key: "cpu", width: cpuReading.implicitWidth, available: true },
        { key: "ram", width: ramReading.implicitWidth, available: true },
        { key: "gpu", width: gpuReading.implicitWidth, available: SystemStats.gpu >= 0 },
        { key: "vram", width: vramReading.implicitWidth, available: SystemStats.vramTotal > 0 },
        { key: "mic", width: micReading.implicitWidth, available: true },
        { key: "tmp", width: tempReading.implicitWidth, available: SystemStats.temp >= 0 }
    ], Math.max(0, statusWidth - fixedControlsWidth), spacing)

    IconButton {
        id: musicButton
        icon: "music"
        active: musicPopup.expanded
        onClicked: {
            powerMenu.expanded = false;
            musicPopup.expanded = !musicPopup.expanded;
        }
    }
    NotificationBell {
        id: notificationBell
        manager: root.notifications
        onClicked: root.notifications.toggle(root.panelWindow.screen)
    }
    StatusReading {
        id: netReading
        label: "NET"
        visible: root.visibleMetrics.includes("net")
        value: SystemStats.netName ? SystemStats.netName.toUpperCase().substring(0, 10) : "OFF"
        valueColor: SystemStats.netName ? Colors.topbar.accent_blue : Colors.topbar.text_dim
        tooltip: SystemStats.netIp ? `${SystemStats.netName}  ${SystemStats.netIp}` : "sin conexión"
        valueWidthSample: "OFF"
        clickable: true
        onClicked: Quickshell.execDetached(["ghostty", "-e", "impala"])
    }
    StatusReading {
        id: volumeReading
        label: "VOL"
        visible: root.visibleMetrics.includes("vol")
        value: SystemStats.volumeMuted ? "MUTE" : String(SystemStats.volume)
        valueColor: SystemStats.volumeMuted ? Colors.topbar.text_dim : Colors.topbar.accent_gold
        valueWidthSample: "MUTE"
        clickable: true
        onClicked: Quickshell.execDetached(["pavucontrol"])
    }
    StatusReading {
        id: micReading
        label: "MIC"
        visible: root.visibleMetrics.includes("mic")
        value: SystemStats.micMuted ? "OFF" : "ON"
        valueColor: SystemStats.micMuted ? Colors.topbar.text_dim : Colors.topbar.accent_green
        valueWidthSample: "OFF"
        clickable: true
        onClicked: Quickshell.execDetached(["pavucontrol", "--tab=4"])
    }
    StatusReading {
        id: batteryReading
        label: "BAT"
        visible: root.visibleMetrics.includes("bat")
        value: String(SystemStats.batteryPercent) + (SystemStats.batteryCharging ? "+" : "")
        valueColor: SystemStats.batteryPercent < 20 && !SystemStats.batteryCharging ? Colors.topbar.accent_warm : Colors.topbar.accent_green
        valueWidthSample: "100+"
    }
    StatusReading {
        id: cpuReading
        label: "CPU"
        visible: root.visibleMetrics.includes("cpu")
        value: String(SystemStats.cpu)
        valueWidthSample: "100"
        clickable: true
        onClicked: Quickshell.execDetached(["ghostty", "-e", "btop"])
    }
    StatusReading {
        id: ramReading
        label: "RAM"
        visible: root.visibleMetrics.includes("ram")
        value: String(SystemStats.ram)
        valueWidthSample: "100"
        clickable: true
        onClicked: Quickshell.execDetached(["ghostty", "-e", "btop"])
    }
    StatusReading {
        id: gpuReading
        label: "GPU"
        visible: root.visibleMetrics.includes("gpu")
        value: SystemStats.gpu + "%"
        valueWidthSample: "100%"
        valueColor: Colors.topbar.accent_blue
        tooltip: "AMD GPU · " + SystemStats.gpuPci + "\nUso: " + SystemStats.gpu + "% · clic para abrir amdgpu_top"
        clickable: true
        onClicked: SystemStats.openGpuMonitor()
    }
    StatusReading {
        id: vramReading
        label: "VRAM"
        visible: root.visibleMetrics.includes("vram")
        value: SystemStats.vramLabel
        valueWidthSample: "99.9G"
        valueColor: Colors.topbar.accent_gold
        tooltip: SystemStats.vramTooltip + "\nClic para abrir amdgpu_top"
        clickable: true
        onClicked: SystemStats.openGpuMonitor()
    }
    StatusReading {
        id: tempReading
        label: "TMP"
        visible: root.visibleMetrics.includes("tmp")
        value: SystemStats.temp + "°"
        valueColor: Colors.topbar.accent_warm
        valueWidthSample: "100°"
    }
    Separator {
        id: traySeparator
        Layout.leftMargin: 4
        Layout.rightMargin: 4
        visible: SystemTray.items.values.length > 0
    }
    SystemTrayView {
        id: tray
        panelWindow: root.panelWindow
        maximumWidth: Math.max(0, root.availableWidth - root.fixedControlsWidth - root.trayDecorationWidth)
        Layout.maximumWidth: maximumWidth
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
    Connections {
        target: root.notifications
        function onExpandedChanged() {
            if (root.notifications.expanded) {
                musicPopup.expanded = false;
                powerMenu.expanded = false;
            }
        }
    }
    PowerMenu {
        id: powerMenu
        anchor.item: powerButton
        anchor.rect.x: powerButton.width - powerMenu.width
        anchor.rect.y: powerButton.height + 10
    }
}
