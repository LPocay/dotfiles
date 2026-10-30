//@ pragma UseQApplication
pragma ComponentBehavior: Bound

import Quickshell

import "./bars/"
import "./components/"

ShellRoot {
    // Recreate the bar when an output disappears and returns (DPMS/hotplug).
    Variants {
        model: Quickshell.screens.filter(screen => screen.name && screen.name !== "FALLBACK")
        TopBar {
            required property var modelData
            screen: modelData
            notifications: notificationCenter
            onLauncherRequested: launcher.toggle()
        }
    }
    WallpaperPicker { id: wallpaper }
    AppLauncher {
        id: launcher
        blocked: wallpaper.expanded
        onOpenRequested: {
            notificationCenter.close();
            shortcuts.close();
            monitors.close();
            clipboard.close();
            wallpaper.cancel();
        }
    }
    ClipboardManager {
        id: clipboard
        blocked: wallpaper.expanded
        onOpenRequested: {
            notificationCenter.close();
            shortcuts.close();
            monitors.close();
            launcher.close();
            wallpaper.cancel();
        }
    }
    MonitorPicker {
        id: monitors
        blocked: wallpaper.expanded
        onOpenRequested: {
            notificationCenter.close();
            shortcuts.close();
            launcher.close();
            clipboard.close();
            wallpaper.cancel();
        }
    }
    ShortcutViewer {
        id: shortcuts
        blocked: wallpaper.expanded
        onOpenRequested: {
            notificationCenter.close();
            launcher.close();
            clipboard.close();
            monitors.close();
            wallpaper.cancel();
        }
    }
    NotificationManager {
        id: notificationCenter
        takeOverDunst: true
        blocked: wallpaper.expanded
        onOpenRequested: {
            shortcuts.close();
            launcher.close();
            clipboard.close();
            monitors.close();
            wallpaper.cancel();
        }
    }
}
