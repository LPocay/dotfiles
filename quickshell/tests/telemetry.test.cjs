const { test } = require('node:test');
const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { join } = require('node:path');
const logic = new Function(readFileSync(join(__dirname, '../.config/quickshell/components/TelemetryLogic.js'), 'utf8')
    + '\nreturn { gpuSnapshot, gib, systemWarning };')();

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

test('SYS warns about hidden memory and temperature pressure at the thresholds', () => {
    assert.equal(logic.systemWarning(89, 84, 94, 100), false);
    assert.equal(logic.systemWarning(90, 40, 0, 100), true);
    assert.equal(logic.systemWarning(20, 85, 0, 100), true);
    assert.equal(logic.systemWarning(20, 40, 95, 100), true);
});

test('missing temperature and VRAM counters do not produce false alerts', () => {
    assert.equal(logic.systemWarning(20, -1, 0, 0), false);
    assert.equal(logic.systemWarning(90, -1, 0, 0), true);
    assert.equal(logic.systemWarning(20, -1, 0, 100), false);
});
