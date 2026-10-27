"""Load the real telemetry QML offscreen and exercise laptop-sized budgets."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


COMPONENTS = Path(__file__).resolve().parents[1] / '.config/quickshell/components'


class TelemetryLayoutTest(unittest.TestCase):
    def test_essential_readings_fit_and_hover_panels_close(self):
        with tempfile.TemporaryDirectory(prefix='telemetry-layout-test-') as directory:
            base = Path(directory)
            runtime = base / 'runtime'
            runtime.mkdir(mode=0o700)
            (base / 'services').symlink_to(COMPONENTS.parent / 'services')
            shell = base / 'shell.qml'
            shell.write_text('''import Quickshell
import QtQuick
import QtTest
import "COMPONENTS_URI" as Components

ShellRoot {
    id: root
    property bool failed: false
    property int step: 0
    property var widths: [1920, 1366, 1280, 1024]
    TestCase { id: input; when: false }
    function check(condition, message) {
        if (!condition) {
            failed = true;
            console.log("TELEMETRY_LAYOUT_TEST_FAIL", message);
        }
    }
    QtObject {
        id: notifications
        property bool expanded: false
        property int unreadCount: 0
        property bool dnd: false
        function toggle(screen) { expanded = !expanded; }
    }
    FloatingWindow {
        id: panel
        implicitWidth: 1000
        implicitHeight: 100
        Components.Clock { id: clock; visible: false }
        Components.Telemetry {
            id: telemetry
            notifications: notifications
            panelWindow: panel
        }
    }
    function groups() {
        return telemetry.children.filter(child => child.title !== undefined);
    }
    function setBudget(width) {
        telemetry.availableWidth = width / 2 - 25 - clock.implicitWidth / 2 - 24;
    }
    Timer {
        interval: 300
        running: true
        onTriggered: {
            Components.SystemStats.hasBattery = true;
            Components.SystemStats.batteryPercent = 100;
            Components.SystemStats.batteryCharging = true;
            setBudget(widths[0]);
            steps.start();
        }
    }
    Timer {
        id: steps
        interval: 120
        repeat: true
        onTriggered: {
            const readings = telemetry.children.filter(child => child.label !== undefined);
            root.check(readings.length === 4, "missing a grouped reading");
            const controls = telemetry.children.filter(child => child.icon !== undefined || child.label !== undefined);
            root.check(controls[0].icon === "music" && controls[1].icon === "bell"
                && controls[2].title === "red" && controls[3].label === "SYS",
                "network icon must sit beside music and notifications, before stats");
            root.check(controls[2].iconButtonStyle
                && controls[2].implicitWidth === controls[0].implicitWidth
                && controls[2].implicitHeight === controls[0].implicitHeight,
                "network must use the same button style and size as music");
            for (const reading of readings)
                root.check(reading.visible, "essential reading hidden: " + reading.label);
            root.check(telemetry.implicitWidth <= telemetry.availableWidth + 1,
                "overflow at " + root.widths[root.step] + ": " + telemetry.implicitWidth + " > " + telemetry.availableWidth);
            root.check(telemetry.essentialWidth <= telemetry.availableWidth + 1, "essential budget overflow");
            root.step++;
            if (root.step < root.widths.length) {
                root.setBudget(root.widths[root.step]);
            } else {
                stop();
                root.check(telemetry.compactMode, "narrow output did not compact labels");
                root.check(root.groups().length === 3, "expected three hover panels");
                // Opening another status panel must close its siblings.
                const panels = root.groups();
                panels[0].expanded = true;
                root.check(panels[0].active, "network button did not highlight its open panel");
                panels[1].expanded = true;
                root.check(!panels[0].expanded && panels[1].expanded, "panels overlap");
                // Leaving both surfaces starts the grace-period close timer.
                panels[1].updateHover();
                closing.start();
            }
        }
    }
    Timer {
        id: closing
        interval: 400
        onTriggered: {
            const panels = root.groups();
            root.check(!panels[1].expanded, "panel did not close after leaving");
            panels[0].expanded = true;
            notifications.expanded = true;
            root.check(!panels[0].expanded, "notification center did not dismiss hover panels");
            notifications.expanded = false;
            panels[0].expanded = true;
            panels[0].visible = false;
            root.check(!panels[0].expanded, "hidden anchor left its panel open");
            Components.SystemStats.hasBattery = false;
            root.check(telemetry.groupCount === 3, "desktop kept a battery slot");
            // Real pointer events verify the delay and handoff between windows.
            const group = panels[0];
            group.visible = true;
            input.wait(50);
            input.mouseMove(group, 5, 5, 0);
            root.check(group.hovered, "anchor did not receive hover");
            input.wait(100);
            root.check(!group.expanded, "panel opened without its hover delay");
            input.wait(180);
            root.check(group.expanded, "panel did not open after hovering: hovered=" + group.hovered + " blocked=" + group.blocked);
            if (!group.expanded) { Qt.quit(); return; }
            const popup = group.data.find(child => child.implicitWidth === 300 && child.contentItem !== undefined);
            root.check(popup !== undefined, "missing status popup window");
            if (popup) {
                input.mouseMove(panel.contentItem, 950, 90, 0);
                input.mouseMove(popup.contentItem, 20, 20, 0);
                input.wait(380);
                root.check(group.expanded && group.panelHovered, "panel closed while using its controls");
                input.mouseMove(popup.contentItem, -10, -10, 0);
                input.wait(380);
                root.check(!group.expanded, "panel stayed open after leaving both windows");
            }
            if (!root.failed)
                console.log("TELEMETRY_LAYOUT_TEST_PASS");
            Qt.quit();
        }
    }
}
'''.replace('COMPONENTS_URI', COMPONENTS.as_uri()))
            env = dict(os.environ, QT_QPA_PLATFORM='offscreen', XDG_RUNTIME_DIR=str(runtime))
            try:
                result = subprocess.run(['quickshell', '-p', str(shell)], env=env,
                                        text=True, capture_output=True, timeout=10)
            except subprocess.TimeoutExpired as error:
                self.fail(f'Quickshell timed out: {error.stdout!r} {error.stderr!r}')
            output = result.stdout + result.stderr
            self.assertEqual(result.returncode, 0, output)
            self.assertIn('TELEMETRY_LAYOUT_TEST_PASS', output)
            self.assertNotIn('TELEMETRY_LAYOUT_TEST_FAIL', output)
            for error in ('ReferenceError', 'TypeError', 'Binding loop', 'Failed to load configuration', 'Cannot open:'):
                self.assertNotIn(error, output)


if __name__ == '__main__':
    unittest.main()
