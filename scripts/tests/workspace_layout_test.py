"""Run the workspace layout against simulated live and stale Hyprland sessions."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / 'workspace_layout.sh'


class WorkspaceLayoutTest(unittest.TestCase):
    def setUp(self):
        directory = tempfile.TemporaryDirectory(prefix='workspace-layout-test-')
        self.addCleanup(directory.cleanup)
        self.base = Path(directory.name)
        flatpak = self.base / 'flatpak'
        flatpak.write_text('#!/usr/bin/env bash\nexit 0\n')
        flatpak.chmod(0o755)
        self.state = {
            'working': ['active'],
            'instances': [{'instance': 'active', 'wl_socket': 'wayland-1'}],
            'clients': [
                {'address': '0x1', 'class': 'firefox', 'workspace': {'id': 2}},
                {'address': '0x2', 'class': 'discord', 'workspace': {'id': 3}},
                {'address': '0x3', 'class': 'dev.aunetx.deezer', 'workspace': {'id': 4}},
                {'address': '0x4', 'class': 'zennotes', 'workspace': {'id': 5}},
            ],
        }
        stub = self.base / 'hyprctl'
        stub.write_text('''#!/usr/bin/env python3
import json, os, pathlib, sys
base = pathlib.Path(os.environ['LAYOUT_TEST_DIR'])
state = json.loads((base / 'state.json').read_text())
signature = os.environ.get('HYPRLAND_INSTANCE_SIGNATURE', '')
command = sys.argv[1]
with (base / 'calls.jsonl').open('a') as log:
    log.write(json.dumps({'signature': signature, 'command': command, 'args': sys.argv[2:]}) + '\\n')
if command == 'instances':
    print(state.get('instancesOutput', json.dumps(state['instances'])))
elif command == 'clients':
    state['reads'] = state.get('reads', 0) + 1
    (base / 'state.json').write_text(json.dumps(state))
    if signature not in state['working'] or state['reads'] > state.get('failAfter', 999):
        # Reproduce hyprctl's non-JSON stdout, even with a successful exit code.
        print("Couldn't connect to the Hyprland socket. (4)")
    else:
        print(json.dumps(state['clients']))
elif command == 'dispatch':
    if 'uwsm app -- flatpak run dev.aunetx.deezer' in sys.argv[2]:
        state['clients'].append({'address': '0x5', 'class': 'dev.aunetx.deezer', 'workspace': {'id': 4}})
        (base / 'state.json').write_text(json.dumps(state))
    print('ok')
else:
    sys.exit(1)
''')
        stub.chmod(0o755)
        self.env = dict(os.environ, LAYOUT_TEST_DIR=str(self.base),
                        HYPRLAND_INSTANCE_SIGNATURE='stale', WAYLAND_DISPLAY='wayland-1',
                        XDG_DATA_HOME=str(self.base / 'data'), SETTLE_TIMEOUT='0',
                        PATH=str(self.base) + os.pathsep + os.environ['PATH'])

    def run_layout(self):
        (self.base / 'state.json').write_text(json.dumps(self.state))
        return subprocess.run(['bash', str(SCRIPT)], env=self.env, capture_output=True,
                              text=True, timeout=5)

    def calls(self):
        return [json.loads(line) for line in (self.base / 'calls.jsonl').read_text().splitlines()]

    def assert_completed(self, result, signature='active'):
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('Layout done', result.stdout)
        dispatches = [call for call in self.calls() if call['command'] == 'dispatch']
        self.assertEqual(len(dispatches), 1)  # Existing windows are not relaunched.
        self.assertEqual(dispatches[0]['signature'], signature)
        self.assertIn('hl.dsp.focus', dispatches[0]['args'][0])
        self.assertNotIn('parse error', result.stderr)

    def assert_stopped(self, result):
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('parse error', result.stderr)
        self.assertNotIn('Layout done', result.stdout)
        self.assertFalse(any(call['command'] == 'dispatch' for call in self.calls()))

    def test_stale_signature_recovers_the_only_running_session(self):
        result = self.run_layout()
        self.assert_completed(result)
        self.assertIn('reconnected', result.stdout)

    def test_unset_signature_discovers_the_running_session(self):
        self.env.pop('HYPRLAND_INSTANCE_SIGNATURE')
        self.assert_completed(self.run_layout())

    def test_healthy_session_is_kept_without_discovery(self):
        self.env['HYPRLAND_INSTANCE_SIGNATURE'] = 'active'
        self.state['instances'].append({'instance': 'other', 'wl_socket': 'wayland-2'})
        self.assert_completed(self.run_layout())
        self.assertFalse(any(call['command'] == 'instances' for call in self.calls()))

    def test_multiple_sessions_select_the_matching_wayland_display(self):
        self.state['instances'].insert(0, {'instance': 'other', 'wl_socket': 'wayland-2'})
        self.state['working'].append('other')
        self.assert_completed(self.run_layout())

    def test_ambiguous_sessions_abort_without_dispatching(self):
        self.env.pop('WAYLAND_DISPLAY')
        self.state['instances'].append({'instance': 'other', 'wl_socket': 'wayland-2'})
        result = self.run_layout()
        self.assert_stopped(result)
        self.assertIn('cannot identify an active Hyprland session', result.stderr)

    def test_invalid_instance_response_reports_a_connection_error(self):
        self.state['instancesOutput'] = "Couldn't set socket timeout (2)"
        result = self.run_layout()
        self.assert_stopped(result)
        self.assertIn('cannot identify an active Hyprland session', result.stderr)

    def test_unreachable_selected_session_aborts_without_dispatching(self):
        self.state['working'] = []
        result = self.run_layout()
        self.assert_stopped(result)
        self.assertIn('cannot read Hyprland windows', result.stderr)

    def test_connection_lost_after_startup_does_not_launch_duplicate_apps(self):
        self.env['HYPRLAND_INSTANCE_SIGNATURE'] = 'active'
        self.state['failAfter'] = 1
        result = self.run_layout()
        self.assert_stopped(result)
        self.assertIn('cannot read Hyprland windows', result.stderr)

    def test_missing_deezer_launches_flatpak_even_if_a_browser_web_app_exists(self):
        self.state['clients'][2]['class'] = 'firefox.webapp-old-deezer'
        result = self.run_layout()
        self.assertEqual(result.returncode, 0, result.stderr)
        dispatches = [call['args'][0] for call in self.calls() if call['command'] == 'dispatch']
        launches = [command for command in dispatches if 'hl.dsp.exec_cmd' in command]
        self.assertEqual(launches, ['hl.dsp.exec_cmd("uwsm app -- flatpak run dev.aunetx.deezer")'])
        self.assertIn('workspace 4: flatpak run dev.aunetx.deezer launched', result.stdout)


if __name__ == '__main__':
    unittest.main()
