"""Exercise layout application and recovery against isolated Hyprland IPC."""
import copy
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

BACKEND = Path(__file__).resolve().parents[1] / '.config/quickshell/services/display-layout.py'


class DisplayBackendTest(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix='display-layout-test-')
        self.addCleanup(self.directory.cleanup)
        self.base = Path(self.directory.name)
        self.state = {'monitors': [
            {'name': 'DP-1', 'width': 2560, 'height': 1440, 'scale': 1, 'refreshRate': 164.95799,
             'transform': 0, 'x': 0, 'y': 0, 'focused': True},
            {'name': 'DP-3', 'width': 2560, 'height': 1440, 'scale': 1, 'refreshRate': 59.951,
             'transform': 0, 'x': 2560, 'y': 0}
        ]}
        self.save()
        stub = self.base / 'hyprctl'
        stub.write_text('''#!/usr/bin/env python3
import json, os, pathlib, re, sys
base = pathlib.Path(os.environ['DISPLAY_TEST_DIR'])
state = json.loads((base / 'state.json').read_text())
action = sys.argv[1]
with (base / 'calls').open('a') as stream: stream.write(json.dumps(sys.argv[1:]) + '\\n')
if action == 'monitors':
    print(json.dumps(state['monitors']))
elif action == 'eval':
    code = sys.argv[2]
    # Match hyprctl's argument parser: leading Lua comments are CLI flags.
    if code.startswith('--'):
        print('usage: hyprctl [flags] <command> [args...|--help]')
        sys.exit(1)
    if state.get('evalError'):
        print('invalid monitor rule')
        sys.exit(0)
    if not state.get('ignoreApply'):
        for name, x, y in re.findall(r'output = "([A-Za-z0-9_.:-]+)".*?position = "(-?\\d+)x(-?\\d+)"', code):
            for m in state['monitors']:
                if m['name'] == name: m.update(x=int(x), y=int(y))
        (base / 'state.json').write_text(json.dumps(state))
    print('ok')
elif action == 'dispatch':
    print('ok')
else:
    sys.exit(1)
''')
        stub.chmod(0o755)
        xrandr = self.base / 'xrandr'
        xrandr.write_text('''#!/usr/bin/env python3
import os, pathlib, sys
base = pathlib.Path(os.environ['DISPLAY_TEST_DIR'])
(base / 'xrandr-call').write_text(' '.join(sys.argv[1:]))
sys.exit(int(os.environ.get('XRANDR_FAIL', '0')))
''')
        xrandr.chmod(0o755)
        self.env = dict(os.environ, DISPLAY_TEST_DIR=str(self.base), DISPLAY=':stub',
                        XDG_STATE_HOME=str(self.base / 'state'),
                        PATH=str(self.base) + os.pathsep + os.environ['PATH'])
        self.request = {'primary': 'DP-3', 'monitors': [
            {'name': 'DP-1', 'x': 0, 'y': 0}, {'name': 'DP-3', 'x': -2560, 'y': 0}]}
        self.saved = self.base / 'state/quickshell/display-layout.json'

    def save(self):
        (self.base / 'state.json').write_text(json.dumps(self.state))

    def run_backend(self, action, payload=None):
        args = ['python3', str(BACKEND), action]
        if payload is not None: args.append(json.dumps(payload))
        return subprocess.run(args, env=self.env, capture_output=True, text=True, timeout=10)

    def test_scan_ignores_disabled_and_mirrored_outputs(self):
        self.state['monitors'] += [{'name': 'DP-4', 'disabled': True}, {'name': 'DP-5', 'mirrorOf': 'DP-1'}]
        self.save()
        result = self.run_backend('scan')
        self.assertEqual(result.returncode, 0, result.stderr)
        data = json.loads(result.stdout)
        self.assertEqual([m['name'] for m in data['monitors']], ['DP-1', 'DP-3'])
        self.assertEqual(data['primary'], 'DP-1')

    def test_applies_verifies_and_persists_positions_and_primary(self):
        result = self.run_backend('apply', self.request)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads(self.saved.read_text())['primary'], 'DP-3')
        lua = self.saved.with_suffix('.lua').read_text()
        self.assertIn('position = "-2560x0"', lua)
        self.assertIn('2560x1440@164.95799', lua)
        self.assertIn('default_monitor = "DP-3"', lua)
        self.assertEqual((self.base / 'xrandr-call').read_text(), '--output DP-3 --primary')
        self.assertIn('hl.dsp.focus({ monitor = \\"DP-3\\" })', (self.base / 'calls').read_text())
        self.assertEqual(json.loads(self.run_backend('scan').stdout)['primary'], 'DP-3')

    def test_generated_lua_comments_are_not_passed_as_cli_flags(self):
        result = self.run_backend('apply', self.request)
        self.assertEqual(result.returncode, 0, result.stderr)
        calls = [json.loads(line) for line in (self.base / 'calls').read_text().splitlines()]
        code = next(c[1] for c in calls if c[0] == 'eval')
        self.assertTrue(code.startswith('do\n-- Generated'))
        self.assertTrue(code.endswith('\nend'))

    def test_rejects_stale_duplicate_or_untrusted_outputs_without_mutating(self):
        for names in [['DP-1', 'removed'], ['DP-1', 'DP-1'], ['DP-1', 'DP-3"; os.exit()']]:
            request = copy.deepcopy(self.request)
            for entry, name in zip(request['monitors'], names): entry['name'] = name
            with self.subTest(names=names):
                self.assertNotEqual(self.run_backend('apply', request).returncode, 0)
        self.assertNotIn('eval', (self.base / 'calls').read_text())
        self.assertFalse(self.saved.exists())

    def test_rejects_invalid_primary_positions_and_overlap(self):
        requests = []
        request = copy.deepcopy(self.request)
        request['primary'] = 'removed'
        requests.append(request)
        for x in [True, 1.5, 32769, 'os.exit()', 0]:
            request = copy.deepcopy(self.request)
            request['monitors'][1]['x'] = x
            requests.append(request)
        for request in requests:
            self.assertNotEqual(self.run_backend('apply', request).returncode, 0)
        self.assertNotIn('eval', (self.base / 'calls').read_text())

    def test_scaled_rotated_display_can_touch_without_overlapping(self):
        self.state['monitors'][1].update(scale=2, transform=1)
        self.save()
        self.request['monitors'][1]['x'] = -720
        self.assertEqual(self.run_backend('apply', self.request).returncode, 0)

    def test_failed_verification_restores_old_layout_and_keeps_saved_files(self):
        self.assertEqual(self.run_backend('apply', self.request).returncode, 0)
        previous = self.saved.read_text()
        self.state['ignoreApply'] = True
        self.save()
        self.request['monitors'][1]['x'] = 0
        self.request['monitors'][1]['y'] = -1440
        result = self.run_backend('apply', self.request)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('could not be applied', result.stderr)
        self.assertEqual(self.saved.read_text(), previous)
        calls = [json.loads(line) for line in (self.base / 'calls').read_text().splitlines()]
        self.assertIn('position = "2560x0"', [c[1] for c in calls if c[0] == 'eval'][-1])

    def test_lua_error_does_not_save(self):
        self.state['evalError'] = True
        self.save()
        result = self.run_backend('apply', self.request)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('invalid monitor rule', result.stderr)
        self.assertFalse(self.saved.exists())

    def test_request_cannot_override_modes_or_inject_lua(self):
        self.request['monitors'][0].update(transform='0 }); os.exit(); --', scale=9, width=1)
        result = self.run_backend('apply', self.request)
        self.assertEqual(result.returncode, 0, result.stderr)
        lua = self.saved.with_suffix('.lua').read_text()
        self.assertNotIn('os.exit', lua)
        self.assertIn('scale = 1, transform = 0', lua)
        self.assertIn('2560x1440@164.95799', lua)

    def test_x11_failure_is_reported_without_losing_a_successful_layout(self):
        self.env['XRANDR_FAIL'] = '1'
        result = self.run_backend('apply', self.request)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('X11', json.loads(result.stdout)['warning'])
        self.assertTrue(self.saved.exists())

    def test_remembers_rules_for_disconnected_monitors(self):
        self.assertEqual(self.run_backend('apply', self.request).returncode, 0)
        self.state['monitors'] = self.state['monitors'][:1]
        self.save()
        request = {'primary': 'DP-1', 'monitors': [{'name': 'DP-1', 'x': 0, 'y': 0}]}
        self.assertEqual(self.run_backend('apply', request).returncode, 0)
        self.assertEqual({m['name'] for m in json.loads(self.saved.read_text())['monitors']}, {'DP-1', 'DP-3'})

    def test_primary_is_restored_for_x11_on_startup(self):
        self.assertEqual(self.run_backend('apply', self.request).returncode, 0)
        (self.base / 'xrandr-call').unlink()
        self.assertEqual(self.run_backend('restore-primary').returncode, 0)
        self.assertTrue((self.base / 'xrandr-call').exists())


if __name__ == '__main__':
    unittest.main()
