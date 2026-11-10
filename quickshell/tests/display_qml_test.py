"""Run real workspace delegates and display controls with isolated models."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

COMPONENTS = Path(__file__).resolve().parents[1] / '.config/quickshell/components'


class DisplayQmlTest(unittest.TestCase):
    def run_qml(self, source, wayland=False, services=None):
        with tempfile.TemporaryDirectory(prefix='display-qml-test-') as directory:
            base = Path(directory)
            runtime = base / 'runtime'
            runtime.mkdir(mode=0o700)
            if services:
                (base / 'services').mkdir()
                (base / 'services/display-layout.py').write_text(services)
            shell = base / 'shell.qml'
            shell.write_text(source.replace('COMPONENTS_URI', COMPONENTS.as_uri()))
            env = dict(os.environ, QT_QPA_PLATFORM='wayland' if wayland else 'offscreen',
                       XDG_RUNTIME_DIR=str(runtime), HYPRLAND_INSTANCE_SIGNATURE='')
            if wayland:
                env['WAYLAND_DISPLAY'] = os.environ['QUICKSHELL_TEST_WAYLAND']
            try:
                result = subprocess.run(['quickshell', '-p', str(shell)], env=env,
                                        capture_output=True, text=True, timeout=12)
            except subprocess.TimeoutExpired as error:
                self.fail((error.stdout or b'').decode() + (error.stderr or b'').decode())
            output = result.stdout + result.stderr
            self.assertEqual(result.returncode, 0, output)
            self.assertIn('DISPLAY_QML_PASS', output)
            for error in ('DISPLAY_QML_FAIL', 'TypeError', 'ReferenceError', 'Binding loop', 'Failed to load configuration'):
                self.assertNotIn(error, output)

    def test_workspaces_follow_each_screen_after_moves_and_removal(self):
        self.run_qml('''import Quickshell
import QtQuick
import "COMPONENTS_URI" as C
ShellRoot {
    id: root
    property int step: 0
    property bool failed: false
    QtObject {
        id: catalog
        property var values: [
            {id: 10, name: "10", monitor: {name: "DP-1"}, active: false, urgent: false},
            {id: 2, name: "2", monitor: {name: "DP-3"}, active: true, urgent: false},
            {id: 1, name: "1", monitor: {name: "DP-1"}, active: true, urgent: false},
            {id: -99, name: "special:magic", monitor: {name: "DP-1"}, active: false, urgent: false}
        ]
    }
    FloatingWindow {
        implicitWidth: 500; implicitHeight: 120
        C.Workspaces { id: left; screen: ({name: "DP-1"}); workspaceModel: catalog }
        C.Workspaces { id: right; y: 50; screen: ({name: "DP-3"}); workspaceModel: catalog }
    }
    function ids(row) {
        return row.children.filter(c => c.objectName.startsWith("workspace-")).map(c => c.modelData.id);
    }
    function check(condition, message) {
        if (!condition) { failed = true; console.log("DISPLAY_QML_FAIL", message); }
    }
    Timer {
        interval: 120; running: true; repeat: true
        onTriggered: {
            if (root.step === 0) {
                root.check(JSON.stringify(root.ids(left)) === "[1,10]", "left bar leaked another monitor or special workspace");
                root.check(JSON.stringify(root.ids(right)) === "[2]", "right bar leaked another monitor");
                const ten = left.children.find(c => c.objectName === "workspace-10");
                root.check(ten.children.some(c => c.text === "10"), "workspace 10 received an extra zero");
                catalog.values = catalog.values.map(w => Object.assign({}, w, w.id === 10 ? {monitor: {name: "DP-3"}} : {}));
            } else if (root.step === 1) {
                root.check(JSON.stringify(root.ids(left)) === "[1]", "moved workspace stayed on old bar");
                root.check(JSON.stringify(root.ids(right)) === "[2,10]", "moved workspace did not appear on destination");
                right.screen = null;
            } else if (root.step === 2) {
                root.check(root.ids(right).length === 0, "removed screen retained workspaces");
                right.screen = ({name: "DP-3"});
            } else {
                root.check(JSON.stringify(root.ids(right)) === "[2,10]", "reconnected screen lost workspaces");
                if (!root.failed) console.log("DISPLAY_QML_PASS");
                Qt.quit();
            }
            root.step++;
        }
    }
}
''')

    @unittest.skipUnless(os.environ.get('QUICKSHELL_TEST_WAYLAND'), 'set QUICKSHELL_TEST_WAYLAND to an isolated compositor socket')
    def test_modal_drag_primary_reset_apply_and_keyboard(self):
        services = '''import json, sys, time
if sys.argv[1] == 'scan':
    print(json.dumps({'monitors': [
        dict(name='DP-1',width=2560,height=1440,scale=1,transform=0,x=0,y=0,refreshRate=164.96),
        dict(name='DP-3',width=2560,height=1440,scale=1,transform=0,x=2560,y=0,refreshRate=59.95)
    ],'primary':'DP-1'}))
else:
    payload = json.loads(sys.argv[2])
    assert payload['primary'] == 'DP-3'
    assert payload['monitors'][1]['x'] == -2560
    time.sleep(0.05)
    print(json.dumps({'warning': ''}))
'''
        self.run_qml('''import Quickshell
import QtQuick
import QtTest
import "COMPONENTS_URI" as C
ShellRoot {
    id: root
    property int step: 0
    property bool failed: false
    TestCase { id: input; when: false; parent: settings.window.contentItem }
    C.DisplaySettings { id: settings }
    function check(condition, message) {
        if (!condition) { failed = true; console.log("DISPLAY_QML_FAIL", message); }
    }
    function button(text) {
        function find(item) {
            if (item.text === text && typeof item.clicked === "function") return item;
            for (const child of item.children ?? []) { const found = find(child); if (found) return found; }
            return null;
        }
        return find(settings.window.contentItem);
    }
    Timer { interval: 50; running: true; onTriggered: settings.toggle(Quickshell.screens[0]) }
    Timer {
        interval: 250; running: true; repeat: true
        onTriggered: {
            if (settings.loading || settings.applying) return;
            if (root.step === 0) {
                root.check(settings.expanded && settings.monitors.length === 2 && !settings.dirty, "initial scan failed");
                const tile = input.findChild(settings.window.contentItem, "display-preview-DP-3");
                input.mousePress(tile, tile.width / 2, tile.height / 2);
                input.mouseMove(tile, tile.width / 2, tile.height / 2 + 60, 20);
                input.mouseRelease(tile, tile.width / 2, tile.height / 2 + 60);
                root.check(settings.selectedName === "DP-3" && settings.dirty && settings.selected.y > 0, "drag did not update selected output");
                root.button("RESET").clicked();
                root.check(!settings.dirty && settings.selected.y === 0, "reset did not restore positions");
                root.button("LEFT").clicked();
                root.check(settings.selected.x === -2560, "relative placement used the wrong output");
                root.button("SET PRIMARY").clicked();
                root.check(settings.primary === "DP-3", "primary control failed");
                root.button("APPLY LAYOUT").clicked();
            } else if (root.step === 1) {
                root.check(!settings.dirty && settings.message === "Monitor layout saved." && !settings.error, "apply did not finish cleanly");
                const content = input.findChild(settings.window.contentItem, "display-modal-content");
                content.forceActiveFocus();
                input.keyClick(Qt.Key_Escape);
                root.check(!settings.expanded, "Escape did not close the modal");
                settings.toggle(Quickshell.screens[0]);
            } else if (root.step === 2) {
                root.check(settings.expanded && !settings.dirty, "reopening did not refresh");
                settings.close();
                if (!root.failed) console.log("DISPLAY_QML_PASS");
                Qt.quit();
            }
            root.step++;
        }
    }
}
''', wayland=True, services=services)


if __name__ == '__main__':
    unittest.main()
