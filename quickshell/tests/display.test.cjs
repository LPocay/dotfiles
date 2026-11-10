const { test } = require('node:test');
const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { join } = require('node:path');
const logic = new Function(readFileSync(join(__dirname, '../.config/quickshell/components/DisplayLogic.js'), 'utf8')
    + '\nreturn { size, bounds, place, relative, payload, changed };')();
const monitors = [
    { name: 'DP-1', width: 2560, height: 1440, scale: 1, transform: 0, x: 0, y: 0 },
    { name: 'DP-3', width: 1920, height: 1080, scale: 1.5, transform: 1, x: 2560, y: 0 }
];

test('preview uses logical dimensions for scaled and rotated outputs', () => {
    assert.deepEqual(logic.size(monitors[1]), { width: 720, height: 1280 });
    assert.deepEqual(logic.bounds(monitors), { x: 0, y: 0, width: 3280, height: 1440 });
    assert.deepEqual(logic.bounds([]), { x: 0, y: 0, width: 1, height: 1 });
});

test('relative placement supports every side and negative coordinates', () => {
    for (const [direction, x, y] of [['left', -720, 0], ['right', 2560, 0], ['above', 0, -1280], ['below', 0, 1440]]) {
        const result = logic.relative(monitors, 'DP-3', 'DP-1', direction)[1];
        assert.deepEqual([result.x, result.y], [x, y]);
    }
    assert.equal(monitors[1].x, 2560);
});

test('dragging snaps to neighboring edges and rounds logical positions', () => {
    const snapped = logic.place(monitors, 'DP-3', 2550, 10, true)[1];
    assert.deepEqual([snapped.x, snapped.y], [2560, 0]);
    const exact = logic.place(monitors, 'DP-3', -100.4, 50.7, false)[1];
    assert.deepEqual([exact.x, exact.y], [-100, 51]);
});

test('dirty state tracks placement and primary independently of mode metadata', () => {
    const original = logic.payload(monitors, 'DP-1');
    assert.equal(logic.changed(monitors, 'DP-1', original), false);
    assert.equal(logic.changed(monitors, 'DP-3', original), true);
    assert.equal(logic.changed(logic.place(monitors, 'DP-3', 0, -1280, false), 'DP-1', original), true);
    assert.equal(logic.changed(monitors.map(m => ({ ...m, refreshRate: 60 })), 'DP-1', original), false);
});
