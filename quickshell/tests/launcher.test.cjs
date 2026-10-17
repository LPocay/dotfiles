const { test } = require('node:test');
const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { join } = require('node:path');

const source = readFileSync(join(__dirname, '../.config/quickshell/components/LauncherLogic.js'), 'utf8');
const logic = new Function(source + '\nreturn { results, readRecent, recordRecent, desktopId, iconName };')();
const apps = [
    { id: 'org.ghostty', name: 'Ghostty', genericName: 'Terminal', categories: ['TerminalEmulator'] },
    { id: 'firefox', name: 'Firefox', genericName: 'Web Browser', keywords: ['Internet'] },
    { id: 'files', name: 'Archivos', comment: 'Gestión de archivos' },
    { id: 'other-terminal', name: 'Another Terminal', genericName: 'Terminal' }
];
const ids = results => results.map(entry => entry.id);

test('matches metadata, multiple words, accents and fuzzy names', () => {
    assert.deepEqual(ids(logic.results(apps, 'web internet', [])), ['firefox']);
    assert.deepEqual(ids(logic.results(apps, 'gestion archivos', [])), ['files']);
    assert.deepEqual(ids(logic.results(apps, 'ghst', [])), ['org.ghostty']);
    assert.deepEqual(logic.results(apps, 'nonexistent', []), []);
});

test('ranks name matches ahead of history and metadata matches', () => {
    assert.deepEqual(ids(logic.results(apps, 'ghostty', ['firefox'])), ['org.ghostty']);
    assert.deepEqual(ids(logic.results(apps, 'terminal', ['org.ghostty'])), ['other-terminal', 'org.ghostty']);
});

test('shows recents first and all remaining applications alphabetically', () => {
    assert.deepEqual(ids(logic.results(apps, '  ', ['firefox', 'removed-app'])),
        ['firefox', 'other-terminal', 'files', 'org.ghostty']);
});

test('recovers from missing, malformed and incompatible history', () => {
    for (const text of ['', '{broken', '{}', 'null']) assert.deepEqual(logic.readRecent(text), []);
    assert.deepEqual(logic.readRecent('["firefox",null,12,"firefox","","files"]'), ['firefox', 'files']);
});

test('history remains unique, ordered and bounded', () => {
    assert.deepEqual(logic.recordRecent(['firefox', 'files'], 'files'), ['files', 'firefox']);
    const history = Array.from({ length: 70 }, (_, index) => String(index));
    assert.equal(logic.readRecent(JSON.stringify(history)).length, 50);
    assert.equal(logic.recordRecent(history, 'latest').length, 50);
});

test('uses desktop IDs and matches the design icon categories', () => {
    assert.equal(logic.desktopId('org.ghostty'), 'org.ghostty.desktop');
    assert.equal(logic.desktopId('firefox.desktop'), 'firefox.desktop');
    assert.equal(logic.iconName(apps[0]), 'terminal');
    assert.equal(logic.iconName({ categories: ['FileManager'] }), 'folder');
    assert.equal(logic.iconName({ categories: ['Settings'] }), 'settings-2');
    assert.equal(logic.iconName({}), 'app-window');
});
