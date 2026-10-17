"""Verify monitor moves against a simulated Hyprland IPC endpoint."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

BACKEND = Path(__file__).resolve().parents[1] / '.config/quickshell/services/workspace-monitor.sh'


class MonitorBackendTest(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix='monitor-picker-test-')
        self.addCleanup(self.directory.cleanup)
        self.base = Path(self.directory.name)
        self.state = {
            'activeworkspace': {'id': 1, 'name': '1', 'monitor': 'eDP-1'},
            'workspaces': [
                {'id': 1, 'name': '1', 'monitor': 'eDP-1', 'windows': 3},
                {'id': 2, 'name': 'DEV', 'monitor': 'DP-1', 'windows': 2}
            ],
            'monitors': [
                {'name': 'eDP-1', 'description': 'Laptop', 'width': 1920, 'height': 1200, 'scale': 1, 'x': 0, 'y': 0},
                {'name': 'DP-1', 'description': 'External', 'width': 2560, 'height': 1440, 'scale': 1, 'x': 1920, 'y': 0},
                {'name': 'DP-2', 'disabled': True},
                {'name': 'DP-3', 'mirrorOf': 'DP-1'}
            ]
        }
        self.save()
        stub = self.base / 'hyprctl'
        stub.write_text('''#!/usr/bin/env python3
import json, os, pathlib, re, sys
base = pathlib.Path(os.environ['MONITOR_TEST_DIR'])
state = json.loads((base / 'state.json').read_text())
if sys.argv[1] == 'dispatch':
    (base / 'dispatch.txt').write_text(sys.argv[2])
    if state.get('dispatchError'):
        print('simulated dispatch failure', file=sys.stderr)
        sys.exit(1)
    match = re.fullmatch(r'hl\\.dsp\\.workspace\\.move\\(\\{ workspace = ([0-9]+), monitor = "([A-Za-z0-9_.:-]+)" \\}\\)', sys.argv[2])
    if not match: sys.exit(1)
    if not state.get('ignoreMove'):
        for workspace in state['workspaces']:
            if workspace['id'] == int(match[1]): workspace['monitor'] = match[2]
        (base / 'state.json').write_text(json.dumps(state))
    print('ok')
else:
    print(json.dumps(state[sys.argv[1]]))
''')
        stub.chmod(0o755)
        self.env = dict(os.environ, MONITOR_TEST_DIR=str(self.base),
                        PATH=str(self.base) + os.pathsep + os.environ['PATH'])

    def save(self):
        (self.base / 'state.json').write_text(json.dumps(self.state))

    def run_backend(self, *args, check=True):
        return subprocess.run(['bash', str(BACKEND), *args], env=self.env,
                              capture_output=True, check=check)

    def test_scan_excludes_disabled_and_mirrored_outputs(self):
        data = json.loads(self.run_backend('scan').stdout)
        self.assertEqual(data['workspace']['id'], 1)
        self.assertEqual([monitor['name'] for monitor in data['monitors']], ['eDP-1', 'DP-1'])
        self.assertEqual(data['monitors'][1]['workspaces'][0]['name'], 'DEV')

    def test_refresh_keeps_the_original_workspace_after_focus_changes(self):
        self.state['activeworkspace']['id'] = 2
        self.save()
        self.assertEqual(json.loads(self.run_backend('scan', '1').stdout)['workspace']['id'], 1)

    def test_move_uses_the_captured_workspace_and_verifies_the_result(self):
        self.state['activeworkspace']['id'] = 2
        self.save()
        data = json.loads(self.run_backend('move', '1', 'DP-1').stdout)
        self.assertEqual(data, {'workspaceId': 1, 'monitor': 'DP-1'})
        self.assertIn('workspace = 1', (self.base / 'dispatch.txt').read_text())

    def test_same_monitor_does_not_dispatch(self):
        self.run_backend('move', '1', 'eDP-1')
        self.assertFalse((self.base / 'dispatch.txt').exists())

    def test_disconnected_disabled_and_mirrored_targets_do_not_dispatch(self):
        for target in ['missing', 'DP-2', 'DP-3']:
            with self.subTest(target=target):
                self.assertNotEqual(self.run_backend('move', '1', target, check=False).returncode, 0)
        self.assertFalse((self.base / 'dispatch.txt').exists())

    def test_removed_workspace_does_not_dispatch(self):
        self.assertNotEqual(self.run_backend('move', '99', 'DP-1', check=False).returncode, 0)
        self.assertFalse((self.base / 'dispatch.txt').exists())

    def test_invalid_ids_and_monitor_names_are_rejected(self):
        for workspace in ['-1', '0', '1; os.exit()', '2147483648', '']:
            self.assertNotEqual(self.run_backend('move', workspace, 'DP-1', check=False).returncode, 0)
        self.assertNotEqual(self.run_backend('move', '1', 'DP-1"; os.exit()', check=False).returncode, 0)
        self.assertFalse((self.base / 'dispatch.txt').exists())

    def test_special_workspace_is_rejected(self):
        self.state['activeworkspace']['id'] = -99
        self.save()
        self.assertNotEqual(self.run_backend('scan', check=False).returncode, 0)

    def test_dispatch_error_and_unapplied_move_are_reported(self):
        self.state['dispatchError'] = True
        self.save()
        self.assertNotEqual(self.run_backend('move', '1', 'DP-1', check=False).returncode, 0)
        self.state['dispatchError'] = False
        self.state['ignoreMove'] = True
        self.save()
        result = self.run_backend('move', '1', 'DP-1', check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn(b'did not reach', result.stderr)

    def test_malformed_ipc_data_is_reported(self):
        self.state['monitors'] = {'wrong': 'format'}
        self.save()
        self.assertNotEqual(self.run_backend('scan', check=False).returncode, 0)


if __name__ == '__main__':
    unittest.main()
