const { test } = require('node:test');
const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { join } = require('node:path');
const logic = new Function(readFileSync(join(__dirname, '../.config/quickshell/components/MusicLogic.js'), 'utf8')
    + '\nreturn { selectPlayer, parsePosition, playbackTime };')();

const idle = { dbusName: 'brave', isPlaying: false, canPlay: false };
const deezer = {
    dbusName: 'org.mpris.MediaPlayer2.deezer',
    isPlaying: true, canPlay: true, canPause: true, trackTitle: 'Song'
};

test('keeps the selected Deezer player and its metadata after pausing', () => {
    const player = { ...deezer };
    const players = [idle, player];
    const selected = logic.selectPlayer(players, '');
    assert.equal(selected, player);
    player.isPlaying = false;
    assert.equal(logic.selectPlayer(players, selected.dbusName), player);
    assert.equal(logic.selectPlayer(players, selected.dbusName).trackTitle, 'Song');
});

test('initially paused music wins over an idle browser', () => {
    const paused = { ...deezer, isPlaying: false };
    assert.equal(logic.selectPlayer([idle, paused], ''), paused);
});

test('another playing player takes over and remains selected when paused', () => {
    const paused = { ...deezer, isPlaying: false };
    const other = { dbusName: 'other', isPlaying: true, trackTitle: 'Other song' };
    assert.equal(logic.selectPlayer([paused, other], paused.dbusName), other);
    other.isPlaying = false;
    assert.equal(logic.selectPlayer([paused, other], other.dbusName), other);
});

test('temporarily missing metadata does not discard a controllable player', () => {
    const player = { ...deezer, isPlaying: false, trackTitle: '' };
    assert.equal(logic.selectPlayer([idle, player], player.dbusName), player);
});

test('removed players and an empty player list are handled', () => {
    assert.equal(logic.selectPlayer([idle], deezer.dbusName), idle);
    assert.equal(logic.selectPlayer([], deezer.dbusName), null);
});

test('position samples are seconds and preserve fractional precision', () => {
    assert.equal(logic.parsePosition('103.732416\n'), 103.732416);
    assert.equal(logic.parsePosition('0.000000\n'), 0);
    for (const value of ['', ' ', 'No players found', '-1', 'NaN', 'Infinity', null])
        assert.equal(logic.parsePosition(value), null);
});

test('a new track or a backward seek uses its actual position', () => {
    assert.equal(logic.playbackTime(205, 420).elapsed, 205);
    assert.equal(logic.playbackTime(0.3, 420).elapsed, 0);
    assert.equal(logic.playbackTime(12.8, 420).elapsed, 12);
});

test('elapsed time and the progress bar never exceed the track duration', () => {
    assert.deepEqual(logic.playbackTime(350, 255), { elapsed: 255, duration: 255, progress: 1 });
    assert.deepEqual(logic.playbackTime(127.9, 255), { elapsed: 127, duration: 255, progress: 127 / 255 });
});

test('missing or invalid times cannot produce negative or invalid progress', () => {
    for (const value of [NaN, Infinity, -10, undefined, null])
        assert.deepEqual(logic.playbackTime(value, value), { elapsed: 0, duration: 0, progress: 0 });
    assert.deepEqual(logic.playbackTime(30, 0), { elapsed: 30, duration: 0, progress: 0 });
});
