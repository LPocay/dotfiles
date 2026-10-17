const { test } = require('node:test');
const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { join } = require('node:path');
const source = readFileSync(join(__dirname, '../.config/quickshell/components/ShortcutLogic.js'), 'utf8');
const logic = new Function(source + '\nreturn { parse, results, combination, availableCategories };')();
const parse = binds => logic.parse(JSON.stringify(binds));
const catalog = parse([
    { key: 'RETURN', modmask: 64, description: 'Apps | Open terminal', dispatcher: '__lua', arg: '10' },
    { key: '0', modmask: 65, description: 'Workspaces | Move window to workspace 10', dispatcher: '__lua', arg: '12' },
    { key: 'mouse:273', modmask: 64, description: 'Mouse | Resize window' },
    { key: 'XF86AudioRaiseVolume', modmask: 0, description: 'Media | Raise volume', repeat: true, locked: true }
]);

test('reads the live JSON shape and searches descriptions without Lua callback ID noise', () => {
    assert.equal(catalog.length, 4);
    assert.equal(logic.results(catalog, 'terminal', 'All')[0].keys, 'Super + Enter');
    assert.deepEqual(logic.results(catalog, '10', 'All').map(entry => entry.action), ['Move window to workspace 10']);
    assert.equal(logic.results(catalog, 'return', 'All')[0].action, 'Open terminal');
});

test('searches combinations, native media names and modifier aliases with a category filter', () => {
    for (const query of ['SUPER+SHIFT+0', 'win shift 0', 'Mod4 + Shift + 0']) {
        assert.equal(logic.results(catalog, query, 'Workspaces').length, 1);
    }
    assert.equal(logic.results(catalog, 'Super + RMB', 'Mouse').length, 1);
    assert.equal(logic.results(catalog, 'XF86AudioRaiseVolume', 'Media').length, 1);
    assert.equal(logic.results(catalog, 'terminal', 'Windows').length, 0);
    assert.deepEqual(logic.availableCategories(catalog), ['All', 'Apps', 'Workspaces', 'Media', 'Mouse']);
    assert.deepEqual(logic.availableCategories([]), ['All']);
});

test('formats uncommon modifiers, arrows, mouse, media, keycodes and catch-all bindings', () => {
    assert.equal(logic.combination({ key: 'left', modmask: 77 }), 'Super + Ctrl + Alt + Shift + ←');
    assert.equal(logic.combination({ key: 'x', modmask: 178 }), 'Caps + Mod2 + Mod3 + Mod5 + X');
    assert.equal(logic.combination({ key: 'mouse_down', modmask: 64 }), 'Super + Wheel ↓');
    assert.equal(logic.combination({ key: 'XF86MonBrightnessDown' }), 'Brightness ↓');
    assert.equal(logic.combination({ keycode: 49, modmask: 4 }), 'Ctrl + Code 49');
    assert.equal(logic.combination({ catch_all: true }), 'Any key');
});

test('retains undocumented and unfamiliar bindings with a technical fallback', () => {
    const entries = parse([
        { key: 'x', dispatcher: '__lua', arg: '42' },
        { key: 'y', description: 'Custom | My action' },
        { key: 'z', description: 'Other | Custom action' },
        { key: 'a' }
    ]);
    assert.equal(entries.length, 4);
    assert.ok(entries.every(entry => entry.category === 'Other'));
    assert.ok(entries.some(entry => entry.action === '__lua 42'));
    assert.ok(entries.some(entry => entry.action === 'Custom | My action'));
    assert.ok(entries.some(entry => entry.action === 'Custom action'));
    assert.ok(entries.some(entry => entry.action === 'Unnamed binding'));
    assert.equal(logic.results(entries, '__lua 42', 'All').length, 1);
});

test('keeps identical combinations in different submaps and on release', () => {
    const entries = parse([
        { key: 'r', modmask: 4, description: 'Windows | Resize' },
        { key: 'r', modmask: 4, submap: 'resize', release: true, description: 'Windows | Reset size' }
    ]);
    assert.equal(entries.length, 2);
    assert.notEqual(entries[0].id, entries[1].id);
    const submap = logic.results(entries, 'resize release control+r', 'All');
    assert.equal(submap.length, 1);
    assert.match(submap[0].detail, /submap: resize/);
    assert.match(submap[0].detail, /on release/);
});

test('groups equivalent Lua actions and searches either combination independently', () => {
    const entries = parse([
        { key: 'h', modmask: 64, description: 'Windows | Focus left', dispatcher: '__lua', arg: '1' },
        { key: 'left', modmask: 64, description: 'Windows | Focus left', dispatcher: '__lua', arg: '2' },
        { key: 'left', modmask: 4, description: 'Windows | Focus left', dispatcher: '__lua', arg: '3' }
    ]);
    assert.equal(entries.length, 1);
    assert.equal(entries[0].keys, 'Super + H / Super + ← / Ctrl + ←');
    assert.equal(entries[0].bindingCount, 3);
    assert.equal(logic.results(entries, 'super+h', 'Windows').length, 1);
    assert.equal(logic.results(entries, 'ctrl+left', 'Windows').length, 1);
    assert.equal(logic.results(entries, 'ctrl+h', 'Windows').length, 0);
});

test('keeps similarly named actions separate when context or native commands differ', () => {
    const base = { key: 'h', modmask: 64, description: 'Windows | Focus left', dispatcher: '__lua', arg: '1' };
    const entries = parse([
        base, { ...base, key: 'left', submap: 'resize' },
        { ...base, key: 'left', release: true }, { ...base, key: 'left', repeat: true },
        { ...base, key: 'left', locked: true }, { ...base, key: 'left', devices: ['keyboard-1'] },
        { ...base, key: 'left', description: 'Other | Focus left' }
    ]);
    assert.equal(entries.length, 7);
    assert.equal(parse([
        { key: 'a', description: 'Apps | Terminal', dispatcher: 'exec', arg: 'ghostty' },
        { key: 'b', description: 'Apps | Terminal', dispatcher: 'exec', arg: 'kitty' }
    ]).length, 2);
    assert.equal(parse([
        { key: 'a', dispatcher: '__lua', arg: '1' },
        { key: 'b', dispatcher: '__lua', arg: '2' }
    ]).length, 2);
});

test('deduplicates displayed alternatives and keeps group identity across callback renumbering', () => {
    const base = { key: 'd', modmask: 64, description: 'Apps | Open launcher', dispatcher: '__lua', arg: '1' };
    const entries = parse([base, { ...base, key: 'SPACE', arg: '2' }, { ...base, arg: '3' }]);
    assert.equal(entries.length, 1);
    assert.equal(entries[0].keys, 'Super + D / Super + Space');
    assert.equal(entries[0].bindingCount, 3);
    assert.equal(entries[0].id, parse([{ ...base, arg: '99' }])[0].id);
});

test('handles accented descriptions, empty catalogs and repeat/locked flags', () => {
    const entries = parse([{ key: 'e', description: 'Apps | Abrir configuración' }]);
    assert.equal(logic.results(entries, 'CONFIGURACION', 'All').length, 1);
    assert.match(logic.results(catalog, 'volume', 'All')[0].detail, /repeat, while locked/);
    assert.deepEqual(logic.results([], '', 'All'), []);
    assert.deepEqual(parse([]), []);
});

test('rejects invalid responses so the controller can display an error', () => {
    assert.throws(() => logic.parse('not json'));
    assert.throws(() => logic.parse('{"error":"unavailable"}'));
    assert.deepEqual(parse([null, 42, 'invalid', []]), []);
});
