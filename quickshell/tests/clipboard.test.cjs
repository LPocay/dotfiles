const { test } = require('node:test');
const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { join } = require('node:path');

const source = readFileSync(join(__dirname, '../.config/quickshell/components/ClipboardLogic.js'), 'utf8');
const logic = new Function(source + '\nreturn { parse, results, entryType };')();
const entries = logic.parse([
    '18446744073709551615\t  café\twith tabs',
    '12\thttps://example.test/path',
    '11\t#87A987 · sage accent',
    '10\t[[ binary data 68 B png 1x1 ]]',
    '9\t[[ binary data 128 B ]]',
    '8\t<b>literal markup</b>',
    '7\t',
    ''
].join('\n'));

test('preserves IDs as strings, whitespace, tabs and literal markup', () => {
    assert.equal(entries[0].id, '18446744073709551615');
    assert.equal(entries[0].preview, '  café\twith tabs');
    assert.equal(entries[5].title, '<b>literal markup</b>');
    assert.equal(entries[6].title, '(empty preview)');
});

test('recognizes text, links, colors, images and other binary data', () => {
    assert.deepEqual(entries.map(entry => entry.type), ['text', 'link', 'color', 'image', 'binary', 'text', 'text']);
    assert.equal(entries[3].title, 'Image');
    assert.equal(entries[3].detail, '68 B png 1x1');
    assert.equal(logic.entryType('#123456789 is not a color'), 'text');
    assert.equal(logic.entryType('text mentioning https://example.test'), 'text');
});

test('filters by type and includes colors in text results', () => {
    assert.deepEqual(logic.results(entries, '', 'text').map(entry => entry.id),
        ['18446744073709551615', '11', '8', '7']);
    assert.deepEqual(logic.results(entries, '', 'link').map(entry => entry.id), ['12']);
    assert.deepEqual(logic.results(entries, '', 'image').map(entry => entry.id), ['10']);
});

test('search is case and accent insensitive, uses all terms and preserves recency', () => {
    assert.deepEqual(logic.results(entries, 'CAFE tabs', 'all').map(entry => entry.id), ['18446744073709551615']);
    assert.deepEqual(logic.results(entries, 'png 1x1', 'image').map(entry => entry.id), ['10']);
    assert.deepEqual(logic.results(entries, 'no match', 'all'), []);
    assert.deepEqual(logic.results(entries, '', 'all'), entries);
});

test('ignores malformed rows and duplicate IDs without interpreting preview contents', () => {
    assert.deepEqual(logic.parse('oops\nnot-a-number\ttext\n1\tfirst\n1\tduplicate\n\tbad'),
        [{ id: '1', preview: 'first', type: 'text', title: 'first', detail: '' }]);
    assert.deepEqual(logic.parse(''), []);
});
