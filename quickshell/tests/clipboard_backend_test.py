"""Exercise the real cliphist binary with an isolated database and fake wl-copy."""
import base64
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

BACKEND = Path(__file__).resolve().parents[1] / '.config/quickshell/services/clipboard.sh'


class ClipboardBackendTest(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix='clipboard-test-')
        self.addCleanup(self.directory.cleanup)
        self.base = Path(self.directory.name)
        self.env = dict(os.environ, XDG_CACHE_HOME=str(self.base / 'cache'),
                        XDG_CONFIG_HOME=str(self.base / 'config'),
                        XDG_RUNTIME_DIR=str(self.base),
                        CLIPHIST_DB_PATH=str(self.base / 'cache/cliphist/db'),
                        CLIPHIST_CONFIG_PATH=str(self.base / 'config/cliphist/config'))
        self.capture = self.base / 'copied'
        binary = self.base / 'wl-copy'
        binary.write_text('#!/usr/bin/env bash\ncat > "$XDG_RUNTIME_DIR/copied"\n')
        binary.chmod(0o755)
        self.env['PATH'] = str(self.base) + os.pathsep + self.env['PATH']

    def run_backend(self, *args, check=True):
        return subprocess.run(['bash', str(BACKEND), *args], env=self.env,
                              capture_output=True, check=check)

    def store(self, content):
        subprocess.run(['cliphist', 'store'], input=content, env=self.env,
                       capture_output=True, check=True)
        return self.run_backend('list').stdout.split(b'\t', 1)[0].decode()

    def test_empty_history(self):
        self.assertEqual(self.run_backend('list').stdout, b'')

    def test_text_round_trip_preserves_every_byte(self):
        content = b'  leading\t"quotes" $(do-not-run)\nsecond line\n\n'
        entry_id = self.store(content)
        self.run_backend('copy', entry_id)
        self.assertEqual(self.capture.read_bytes(), content)
        self.assertEqual(list(self.base.glob('quickshell-clipboard.*')), [])

    def test_image_round_trip_preserves_binary_data(self):
        image = base64.b64decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+j3ioAAAAASUVORK5CYII=')
        entry_id = self.store(image)
        self.run_backend('copy', entry_id)
        self.assertEqual(self.capture.read_bytes(), image)

    def test_delete_affects_only_the_selected_entry(self):
        first = self.store(b'first item')
        second = self.store(b'second item')
        self.run_backend('delete', first)
        catalog = self.run_backend('list').stdout
        self.assertNotIn(b'first item', catalog)
        self.assertIn(second.encode() + b'\tsecond item', catalog)

    def test_clear_empties_the_database(self):
        self.store(b'one')
        self.store(b'two')
        self.run_backend('clear')
        self.assertEqual(self.run_backend('list').stdout, b'')

    def test_missing_id_or_bad_input_does_not_change_the_clipboard(self):
        self.store(b'existing')
        self.capture.write_bytes(b'keep existing clipboard')
        for entry_id in ['999999', '1; echo injected', '-1', '']:
            result = self.run_backend('copy', entry_id, check=False)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(self.capture.read_bytes(), b'keep existing clipboard')
        self.assertEqual(list(self.base.glob('quickshell-clipboard.*')), [])


if __name__ == '__main__':
    unittest.main()
