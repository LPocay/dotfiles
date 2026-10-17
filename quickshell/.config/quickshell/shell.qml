//@ pragma UseQApplication
import Quickshell

import "./bars/"
import "./components/"

ShellRoot {
    TopBar {
        onLauncherRequested: launcher.toggle()
    }
    WallpaperPicker { id: wallpaper }
    AppLauncher {
        id: launcher
        blocked: wallpaper.expanded
        onOpenRequested: {
            monitors.close();
            clipboard.close();
            wallpaper.cancel();
        }
    }
    ClipboardManager {
        id: clipboard
        blocked: wallpaper.expanded
        onOpenRequested: {
            monitors.close();
            launcher.close();
            wallpaper.cancel();
        }
    }
    MonitorPicker {
        id: monitors
        blocked: wallpaper.expanded
        onOpenRequested: {
            launcher.close();
            clipboard.close();
            wallpaper.cancel();
        }
    }
}
