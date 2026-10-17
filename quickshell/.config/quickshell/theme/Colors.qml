pragma Singleton

import QtQuick

QtObject {
    readonly property TopBarColors topbar: TopBarColors {}
    readonly property WallpaperColors wallpaper: WallpaperColors {}
    readonly property LauncherColors launcher: LauncherColors {}
    readonly property ClipboardColors clipboard: ClipboardColors {}
    readonly property MonitorColors monitors: MonitorColors {}
    readonly property ShortcutColors shortcuts: ShortcutColors {}
    readonly property NotificationColors notifications: NotificationColors {}
}
