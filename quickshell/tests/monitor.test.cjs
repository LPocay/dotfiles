const { test } = require('node:test');
const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { join } = require('node:path');
const source = readFileSync(join(__dirname, '../.config/quickshell/components/MonitorLogic.js'), 'utf8');
const logic = new Function(source + '\nreturn { order, selection, next, mode, workspaceLabel };')();
const monitors = [
    { name: 'DP-1', x: 1920, y: 0 },
    { name: 'HDMI-A-1', x: -1920, y: 0 },
    { name: 'eDP-1', x: 0, y: 0 }
];

test('sorts by physical placement without mutating the catalog', () => {
    assert.deepEqual(logic.order(monitors).map(monitor => monitor.name), ['HDMI-A-1', 'eDP-1', 'DP-1']);
    assert.equal(monitors[0].name, 'DP-1');
});

test('preserves an available destination and recovers after disconnection', () => {
    assert.equal(logic.selection(monitors, 'eDP-1', 'HDMI-A-1'), 1);
    assert.equal(logic.selection(monitors, 'eDP-1', 'removed'), 0);
    assert.equal(logic.selection(monitors, 'eDP-1', 'eDP-1'), 0);
    assert.equal(logic.selection([{ name: 'eDP-1' }], 'eDP-1'), -1);
});

test('navigation wraps and skips the current monitor', () => {
    assert.equal(logic.next(monitors, 'eDP-1', 1, 1), 0);
    assert.equal(logic.next(monitors, 'eDP-1', 0, -1), 1);
    assert.equal(logic.next(monitors, 'eDP-1', -1, 1), 0);
    assert.equal(logic.next(monitors, 'DP-1', -1, -1), 2);
    assert.equal(logic.next([{ name: 'eDP-1' }], 'eDP-1', -1, 1), -1);
    assert.equal(logic.next([], 'eDP-1', -1, 1), -1);
});

test('formats rotated displays, refresh rate and scaling', () => {
    assert.equal(logic.mode({ width: 1920, height: 1080, refreshRate: 59.95, scale: 1.5, transform: 1 }),
        '1080×1920  ·  60 Hz  ·  scale 1.5');
});

test('keeps named workspaces and formats numbered ones', () => {
    assert.equal(logic.workspaceLabel({ id: 2, name: '2' }), '02');
    assert.equal(logic.workspaceLabel({ id: 3, name: 'DEV' }), 'DEV');
    assert.equal(logic.workspaceLabel({ id: 10 }), '10');
});
