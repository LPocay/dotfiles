const { test } = require('node:test');
const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { join } = require('node:path');
const logic = new Function(readFileSync(join(__dirname, '../.config/quickshell/components/TelemetryLogic.js'), 'utf8')
    + '\nreturn { gpuSnapshot, gib, fit };')();

test('keeps zero GPU usage and large VRAM counters intact', () => {
    const bytes = 12 * 1073741824;
    const data = logic.gpuSnapshot(JSON.stringify({ available: true, busy: 0, vramUsed: bytes / 2, vramTotal: bytes, pci: '0000:03:00.0' }));
    assert.equal(data.busy, 0);
    assert.equal(data.vramUsed, bytes / 2);
    assert.equal(data.vramTotal, bytes);
    assert.equal(logic.gib(data.vramUsed), '6.0');
});

test('resets unavailable or malformed samples so stale GPU data is not displayed', () => {
    for (const value of ['not json', 'null', '{}', '{"available":false}']) {
        assert.deepEqual(logic.gpuSnapshot(value), { busy: -1, vramUsed: 0, vramTotal: 0, pci: '' });
    }
    assert.equal(logic.gpuSnapshot('{"available":true,"busy":null}').busy, -1);
    assert.equal(logic.gpuSnapshot('{"available":true,"busy":999}').busy, -1);
    assert.equal(logic.gpuSnapshot('{"available":true,"vramUsed":42,"vramTotal":0}').vramTotal, 0);
});

test('fits metrics by priority and reserves gaps without overlapping fixed controls', () => {
    const metrics = [
        { key: 'cpu', width: 60, available: true }, { key: 'gpu', width: 70, available: true },
        { key: 'vram', width: 100, available: true }, { key: 'bat', width: 60, available: false },
        { key: 'tmp', width: 60, available: true }
    ];
    assert.deepEqual(logic.fit(metrics, 320, 6), ['cpu', 'gpu', 'vram', 'tmp']);
    assert.deepEqual(logic.fit(metrics, 248, 6), ['cpu', 'gpu', 'vram']);
    assert.deepEqual(logic.fit(metrics, 142, 6), ['cpu', 'gpu']);
    assert.deepEqual(logic.fit(metrics, 0, 6), []);
    assert.equal(metrics.length, 5);
});
