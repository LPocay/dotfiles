"""Exercise the real toast window while its output disappears and returns."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


COMPONENTS = Path(__file__).resolve().parents[1] / '.config/quickshell/components'


class NotificationScreenTest(unittest.TestCase):
    @unittest.skipUnless(os.environ.get('WAYLAND_DISPLAY'), 'requires a Wayland session')
    def test_removed_screen_does_not_break_toast_bindings(self):
        with tempfile.TemporaryDirectory(prefix='notification-screen-test-') as directory:
            base = Path(directory)
            runtime = base / 'runtime'
            runtime.mkdir(mode=0o700)
            shell = base / 'shell.qml'
            shell.write_text('''import Quickshell
import QtQuick
import "COMPONENTS_URI" as Components

ShellRoot {
    id: root
    property int step: 0
    property var savedScreen: Quickshell.screens[0]
    QtObject {
        id: manager
        property bool expanded: false
        function popupEntries(name) { return []; }
    }
    Components.NotificationToasts {
        id: toast
        manager: manager
        output: root.savedScreen
    }
    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            if (root.step === 0) {
                toast.output = null;
            } else if (root.step === 1) {
                if (toast.entries.length !== 0 || toast.visible
                    || toast.implicitWidth !== 0 || toast.implicitHeight !== 0) {
                    console.log("SCREEN_TEST_FAIL: removed output left an active toast");
                    Qt.quit();
                    return;
                }
                toast.output = root.savedScreen;
            } else {
                if (toast.implicitWidth > 0)
                    console.log("SCREEN_TEST_PASS");
                Qt.quit();
            }
            root.step++;
        }
    }
}
'''.replace('COMPONENTS_URI', COMPONENTS.as_uri()))
            # Keep the real display connection while isolating Quickshell IPC.
            display = Path(os.environ['WAYLAND_DISPLAY'])
            if not display.is_absolute():
                display = Path(os.environ['XDG_RUNTIME_DIR']) / display
            env = dict(os.environ, QT_QPA_PLATFORM='wayland',
                       WAYLAND_DISPLAY=str(display), XDG_RUNTIME_DIR=str(runtime))
            result = subprocess.run(['quickshell', '-p', str(shell)], env=env,
                                    capture_output=True, text=True, timeout=10)
            output = result.stdout + result.stderr
            self.assertEqual(result.returncode, 0, output)
            self.assertIn('SCREEN_TEST_PASS', output)
            for error in ('SCREEN_TEST_FAIL', 'TypeError', 'ReferenceError',
                          'Binding loop', 'Failed to load configuration'):
                self.assertNotIn(error, output)


if __name__ == '__main__':
    unittest.main()
