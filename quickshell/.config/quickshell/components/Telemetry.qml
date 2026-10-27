import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts
import "../theme/"
import "TelemetryLogic.js" as Logic

RowLayout {
    id: root
    required property var notifications
    property real availableWidth: 1000
    property var panelWindow
    spacing: 6

    // Essential readings never compete with tray icons. Scroll the tray first;
    // on narrower outputs replace labels with icons, keeping all values visible.
    readonly property int groupCount: SystemStats.hasBattery ? 4 : 3
    readonly property real controlsWidth: musicButton.implicitWidth + notificationBell.implicitWidth + powerButton.implicitWidth
    readonly property real separatorFootprint: traySeparator.Layout.leftMargin + traySeparator.implicitWidth + traySeparator.Layout.rightMargin
    readonly property real trayDecorationWidth: separatorFootprint + spacing * 2
    readonly property real expandedStatusWidth: systemGroup.expandedWidth + netGroup.expandedWidth + audioGroup.expandedWidth
        + (SystemStats.hasBattery ? batteryReading.expandedWidth : 0)
    readonly property bool compactMode: availableWidth < controlsWidth + expandedStatusWidth + spacing * (groupCount + 2)
        + (SystemTray.items.values.length > 0 ? 26 + trayDecorationWidth : 0)
    readonly property real essentialWidth: controlsWidth + systemGroup.implicitWidth + netGroup.implicitWidth + audioGroup.implicitWidth
        + (SystemStats.hasBattery ? batteryReading.implicitWidth : 0) + spacing * (groupCount + 2)
    readonly property bool systemWarning: Logic.systemWarning(SystemStats.ram, SystemStats.temp, SystemStats.vramUsed, SystemStats.vramTotal)
    readonly property bool hoverBlocked: musicPopup.expanded || powerMenu.expanded || root.notifications.expanded

    function closeStatusPanels(except) {
        for (const group of [systemGroup, netGroup, audioGroup]) {
            if (group !== except)
                group.close();
        }
    }

    IconButton {
        id: musicButton
        icon: "music"
        active: musicPopup.expanded
        onClicked: {
            root.closeStatusPanels(null);
            powerMenu.expanded = false;
            musicPopup.expanded = !musicPopup.expanded;
        }
    }
    NotificationBell {
        id: notificationBell
        manager: root.notifications
        onClicked: {
            root.closeStatusPanels(null);
            root.notifications.toggle(root.panelWindow.screen);
        }
    }
    StatusGroup {
        id: netGroup
        label: ""
        value: ""
        iconButtonStyle: true
        active: expanded
        icon: !SystemStats.netName ? "wifi-off" : SystemStats.netType === "wifi" ? "wifi" : "ethernet"
        title: "red"
        blocked: root.hoverBlocked
        clickable: true
        readings: [
            { label: "Estado", value: SystemStats.netName ? "Conectado" : "Sin conexión" },
            { label: "Red", value: SystemStats.netName, available: SystemStats.netName !== "" },
            { label: "Interfaz", value: SystemStats.netDevice, available: SystemStats.netDevice !== "" },
            { label: "IP", value: SystemStats.netIp, available: SystemStats.netIp !== "" }
        ]
        actions: [{ key: "network", label: "Abrir impala" }]
        onOpened: root.closeStatusPanels(netGroup)
        onClicked: {
            close();
            Quickshell.execDetached(["ghostty", "-e", "impala"]);
        }
        onActionTriggered: Quickshell.execDetached(["ghostty", "-e", "impala"])
    }
    StatusGroup {
        id: systemGroup
        label: "SYS"
        compactIcon: "cpu"
        compact: root.compactMode
        value: SystemStats.cpu + "%"
        valueWidthSample: "100%"
        valueColor: root.systemWarning ? Colors.topbar.accent_danger : Colors.topbar.text_primary
        title: root.systemWarning ? "sistema !" : "sistema"
        blocked: root.hoverBlocked
        clickable: true
        readings: [
            { label: "CPU", value: SystemStats.cpu + "%" },
            { label: "RAM", value: SystemStats.ram + "%", color: SystemStats.ram >= 90 ? Colors.topbar.accent_danger : Colors.topbar.text_primary },
            { label: "GPU", value: SystemStats.gpu + "%", available: SystemStats.gpu >= 0, color: Colors.topbar.accent_blue },
            { label: "VRAM", value: Logic.gib(SystemStats.vramUsed) + " / " + Logic.gib(SystemStats.vramTotal) + " GiB", available: SystemStats.vramTotal > 0, color: Colors.topbar.accent_gold },
            { label: "VRAM %", value: (SystemStats.vramTotal > 0 ? Math.round(SystemStats.vramUsed / SystemStats.vramTotal * 100) : 0) + "%", available: SystemStats.vramTotal > 0, color: Colors.topbar.accent_gold },
            { label: "GPU PCI", value: SystemStats.gpuPci, available: SystemStats.gpuPci !== "" },
            { label: "CPU temp", value: SystemStats.temp + " °C", available: SystemStats.temp >= 0, color: SystemStats.temp >= 85 ? Colors.topbar.accent_danger : Colors.topbar.accent_warm }
        ]
        actions: [
            { key: "btop", label: "Abrir btop" },
            { key: "gpu", label: "Monitor GPU", available: SystemStats.gpuPci !== "" }
        ]
        onOpened: root.closeStatusPanels(systemGroup)
        onClicked: {
            close();
            Quickshell.execDetached(["ghostty", "-e", "btop"]);
        }
        onActionTriggered: action => {
            if (action === "gpu")
                SystemStats.openGpuMonitor();
            else
                Quickshell.execDetached(["ghostty", "-e", "btop"]);
        }
    }
    StatusGroup {
        id: audioGroup
        label: "VOL"
        compactIcon: SystemStats.volumeMuted ? "volume-x" : "volume-2"
        compact: root.compactMode
        value: SystemStats.volumeMuted ? "MUTE" : String(SystemStats.volume)
        valueColor: SystemStats.volumeMuted ? Colors.topbar.text_dim : Colors.topbar.accent_gold
        valueWidthSample: "MUTE"
        title: "audio"
        blocked: root.hoverBlocked
        clickable: true
        readings: [
            { label: "Volumen", value: SystemStats.volumeMuted ? "Silenciado" : SystemStats.volume + "%", color: Colors.topbar.accent_gold },
            { label: "Micrófono", value: SystemStats.micMuted ? "Silenciado" : "Activo", color: SystemStats.micMuted ? Colors.topbar.text_dim : Colors.topbar.accent_green }
        ]
        actions: [
            { key: "volume", label: "Controles de audio" },
            { key: "mic", label: "Configurar micrófono" }
        ]
        onOpened: root.closeStatusPanels(audioGroup)
        onClicked: {
            close();
            Quickshell.execDetached(["pavucontrol"]);
        }
        onActionTriggered: action => Quickshell.execDetached(action === "mic" ? ["pavucontrol", "--tab=4"] : ["pavucontrol"])
    }
    StatusReading {
        id: batteryReading
        label: "BAT"
        compactIcon: SystemStats.batteryCharging ? "battery-charging" : "battery"
        compact: root.compactMode
        visible: SystemStats.hasBattery
        value: SystemStats.batteryPercent + "%" + (SystemStats.batteryCharging ? "+" : "")
        valueColor: SystemStats.batteryPercent < 20 && !SystemStats.batteryCharging ? Colors.topbar.accent_danger : Colors.topbar.accent_green
        valueWidthSample: "100%+"
        tooltip: SystemStats.batteryCharging ? "Cargando / conectada" : "Usando batería"
    }
    Separator {
        id: traySeparator
        Layout.leftMargin: 4
        Layout.rightMargin: 4
        visible: tray.visible
    }
    SystemTrayView {
        id: tray
        panelWindow: root.panelWindow
        maximumWidth: Math.max(0, root.availableWidth - root.essentialWidth - root.trayDecorationWidth)
        Layout.maximumWidth: maximumWidth
        visible: SystemTray.items.values.length > 0 && maximumWidth > 0
    }
    IconButton {
        id: powerButton
        icon: "power"
        iconSize: 16
        implicitWidth: 30
        implicitHeight: 30
        active: powerMenu.expanded
        onClicked: {
            root.closeStatusPanels(null);
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
                root.closeStatusPanels(null);
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
