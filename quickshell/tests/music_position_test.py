"""Exercise the real QML position reader with delayed, isolated playerctl replies."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


COMPONENTS = Path(__file__).resolve().parents[1] / '.config/quickshell/components'


class MusicPositionTest(unittest.TestCase):
    def test_track_changes_pause_and_reopening_use_fresh_samples(self):
        with tempfile.TemporaryDirectory(prefix='music-position-test-') as directory:
            base = Path(directory)
            runtime = base / 'runtime'
            runtime.mkdir(mode=0o700)
            stub = base / 'playerctl'
            stub.write_text('''#!/usr/bin/env python3
import os, pathlib, sys, time
log = pathlib.Path(os.environ['MUSIC_POSITION_TEST_LOG'])
assert sys.argv[1:] == ['--player', 'mock', 'position'], sys.argv
calls = log.read_text().splitlines() if log.exists() else []
with log.open('a') as stream:
    stream.write('position\\n')
value = [205, 3.25, 15.25, 1.25][min(len(calls), 3)]
time.sleep(0.2)
print(value)
''')
            stub.chmod(0o755)
            shell = base / 'shell.qml'
            shell.write_text('''import Quickshell
import QtQuick
import "COMPONENTS_URI" as Components

ShellRoot {
    id: root
    function check(condition, message) {
        if (!condition) {
            console.log("MUSIC_POSITION_TEST_FAIL", message, reader.position);
            Qt.quit();
        }
    }
    QtObject {
        id: mock
        property string dbusName: "org.mpris.MediaPlayer2.mock"
        property int uniqueId: 1
        property string trackTitle: "Old song"
        property string trackArtist: "Artist"
        property string trackAlbum: "Album"
        property int playbackState: 1
    }
    Components.MusicPosition { id: reader; player: mock; active: true }
    Timer {
        interval: 80; running: true
        onTriggered: { mock.uniqueId++; mock.trackTitle = "New song"; }
    }
    Timer {
        interval: 600; running: true
        onTriggered: root.check(reader.position === 3.25, "old-track reply was not discarded")
    }
    Timer {
        interval: 650; running: true
        onTriggered: mock.playbackState = 2
    }
    Timer {
        interval: 950; running: true
        onTriggered: {
            root.check(reader.position === 15.25, "pause did not refresh the actual position");
            reader.active = false;
        }
    }
    Timer { interval: 1000; running: true; onTriggered: reader.active = true }
    Timer {
        interval: 1450; running: true
        onTriggered: {
            root.check(reader.position === 1.25, "reopening did not pick up a backward seek");
            reader.active = false;
        }
    }
    Timer {
        interval: 1900; running: true
        onTriggered: {
            root.check(reader.position === 1.25, "paused position continued advancing");
            console.log("MUSIC_POSITION_TEST_PASS");
            Qt.quit();
        }
    }
}
'''.replace('COMPONENTS_URI', COMPONENTS.as_uri()))
            log = base / 'calls'
            env = dict(os.environ, QT_QPA_PLATFORM='offscreen', XDG_RUNTIME_DIR=str(runtime),
                       MUSIC_POSITION_TEST_LOG=str(log),
                       PATH=str(base) + os.pathsep + os.environ['PATH'])
            result = subprocess.run(['quickshell', '-p', str(shell)], env=env,
                                    text=True, capture_output=True, timeout=10)
            output = result.stdout + result.stderr
            self.assertEqual(result.returncode, 0, output)
            self.assertIn('MUSIC_POSITION_TEST_PASS', output)
            self.assertNotIn('MUSIC_POSITION_TEST_FAIL', output)
            self.assertEqual(len(log.read_text().splitlines()), 4, output)


if __name__ == '__main__':
    unittest.main()
