function hasTrack(player) {
    return !!(player.trackTitle || player.trackArtist || player.trackAlbum);
}

function selectPlayer(players, previousName) {
    var playing = players.find(player => player.isPlaying);
    if (playing) return playing;

    var previous = players.find(player => player.dbusName === previousName);
    if (previous && (hasTrack(previous) || previous.canPlay || previous.canPause))
        return previous;

    return players.find(hasTrack)
        ?? players.find(player => player.canPlay || player.canPause)
        ?? previous ?? players[0] ?? null;
}

function parsePosition(text) {
    if (typeof text !== "string" || !text.trim()) return null;
    var seconds = Number(text.trim());
    return Number.isFinite(seconds) && seconds >= 0 ? seconds : null;
}

function playbackTime(position, length) {
    var duration = Number.isFinite(length) && length > 0 ? Math.floor(length) : 0;
    var elapsed = Number.isFinite(position) && position >= 0 ? Math.floor(position) : 0;
    if (duration > 0) elapsed = Math.min(elapsed, duration);
    return { elapsed: elapsed, duration: duration, progress: duration > 0 ? elapsed / duration : 0 };
}
