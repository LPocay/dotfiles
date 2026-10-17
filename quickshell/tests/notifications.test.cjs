const { test } = require('node:test');
const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { join } = require('node:path');
const source = readFileSync(join(__dirname, '../.config/quickshell/components/NotificationLogic.js'), 'utf8');
const logic = new Function(source + '\nreturn { plainText, duration, archive, snapshot, upsert, serialize, restore };')();
const notice = { id: 1, appName: 'Build', summary: 'Finished', body: 'Ready', urgency: 1,
    image: '', appIcon: '', actions: [{ identifier: 'default', text: 'Open log' }], expireTimeout: -1 };
const snapshot = (n = notice, uid = 'one', timestamp = 1000) => logic.snapshot(n, uid, timestamp, null, false);

test('renders bodies as plain text while retaining readable line breaks and entities', () => {
    assert.equal(logic.plainText('<b>Build</b><br/>A &amp; B &lt;ready&gt;'), 'Build\nA & B <ready>');
    assert.equal(logic.plainText('<img src="file:///private">hello'), 'hello');
});

test('all popups expire within six seconds, including critical and zero-timeout notifications', () => {
    assert.equal(logic.duration(notice), 6000);
    assert.equal(logic.duration({ ...notice, expireTimeout: 1500 }), 1500);
    assert.equal(logic.duration({ ...notice, expireTimeout: 0 }), 6000);
    assert.equal(logic.duration({ ...notice, urgency: 2 }), 6000);
    assert.equal(logic.duration({ ...notice, expireTimeout: 60000 }), 6000);
});

test('application closure archives content and unread state while removing stale callbacks', () => {
    const original = snapshot({ ...notice, image: 'file:///tmp/preview.png', hasInlineReply: true });
    const archived = logic.archive(original);
    assert.equal(archived.body, original.body);
    assert.equal(archived.image, original.image);
    assert.equal(archived.unread, true);
    assert.equal(archived.active, false);
    assert.deepEqual(archived.actions, []);
    assert.equal(archived.inlineReply, false);
    assert.equal(original.active, true);
    assert.equal(logic.archive(snapshot({ ...notice, transient: true })), null);
    assert.equal(logic.restore(logic.serialize([archived], false)).entries.length, 1);
});

test('snapshots retain display data and action identifiers without retaining live QObject references', () => {
    const entry = snapshot();
    assert.equal(entry.uid, 'one');
    assert.equal(entry.unread, true);
    assert.deepEqual(entry.actions, [{ id: 'default', text: 'Open log' }]);
    assert.equal(entry.active, true);
    assert.equal(logic.snapshot(notice, 'two', 1001, null, true).unread, false);
    assert.equal(logic.snapshot({ ...notice, lastGeneration: true }, 'one', 1000, { unread: false }, false).unread, false);
});

test('replacements update a single row and sort newest first without mutating the old catalog', () => {
    const old = [snapshot(), snapshot(notice, 'two', 2000)];
    const entries = logic.upsert(old, snapshot({ ...notice, summary: 'Updated' }, 'one', 3000));
    assert.equal(entries.length, 2);
    assert.equal(entries[0].summary, 'Updated');
    assert.equal(old[0].summary, 'Finished');
});

test('history is bounded to the newest 100 entries', () => {
    let entries = [];
    for (let i = 0; i < 125; i++) entries = logic.upsert(entries, snapshot(notice, String(i), i));
    assert.equal(entries.length, 100);
    assert.equal(entries[0].uid, '124');
    assert.equal(entries[99].uid, '25');
});

test('persists unread and DND, excludes transient notices and removes stale actions after restart', () => {
    const saved = logic.serialize([snapshot(), snapshot({ ...notice, transient: true }, 'transient')], true);
    const restored = logic.restore(saved);
    assert.equal(restored.dnd, true);
    assert.equal(restored.entries.length, 1);
    assert.equal(restored.entries[0].unread, true);
    assert.equal(restored.entries[0].active, false);
    assert.deepEqual(restored.entries[0].actions, []);
});

test('keeps file images but does not persist notification image-provider URLs', () => {
    const entries = [snapshot({ ...notice, image: 'image://notification/7' }, 'provider'),
        snapshot({ ...notice, image: 'file:///tmp/image.png' }, 'file'),
        snapshot({ ...notice, image: 'image://icon//tmp/image.png' }, 'file-provider')];
    const restored = logic.restore(logic.serialize(entries, false)).entries;
    assert.equal(restored.find(entry => entry.uid === 'provider').image, '');
    assert.equal(restored.find(entry => entry.uid === 'file').image, 'file:///tmp/image.png');
    assert.equal(restored.find(entry => entry.uid === 'file-provider').image, 'image://icon//tmp/image.png');
});

test('corrupt, unsupported, duplicated and oversized state cannot break the history', () => {
    assert.deepEqual(logic.restore('not json'), { dnd: false, entries: [] });
    assert.deepEqual(logic.restore('{"version":9,"entries":[]}'), { dnd: false, entries: [] });
    const entry = { ...snapshot(), summary: 'x'.repeat(5000) };
    const restored = logic.restore(JSON.stringify({ version: 1, entries: [null, {}, entry, entry] }));
    assert.equal(restored.entries.length, 1);
    assert.equal(restored.entries[0].summary.length, 4096);
});
