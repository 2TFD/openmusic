import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/domain/repositories/lyrics_provider.dart';
import 'package:openmusic/layers/domain/services/lyrics_track_matcher.dart';

void main() {
  const matcher = LyricsTrackMatcher();

  test('accepts exact title, artist, and duration', () {
    final result = matcher.match(_request(), [_candidate()]);

    expect(result.disposition, LyricsMatchDisposition.accepted);
    expect(result.confidence, greaterThanOrEqualTo(0.99));
  });

  test('extracts Artist - Title and removes Official Audio cleanup', () {
    final request = _request(
      title: 'Artist - Song Name (Official Audio)',
      artists: const ['Uploader account'],
    );

    expect(
      matcher.buildSearchCandidate(request),
      const LyricsSearchCandidate(title: 'Song Name', artist: 'Artist'),
    );
    expect(
      matcher.match(request, [_candidate()]).disposition,
      LyricsMatchDisposition.accepted,
    );
  });

  test('retains slowed and reverb version markers', () {
    final request = _request(title: 'Song Name (Slowed + Reverb)');

    expect(
      matcher.buildSearchCandidate(request).title,
      'Song Name (Slowed + Reverb)',
    );
    expect(
      matcher.match(request, [_candidate()]).disposition,
      isNot(LyricsMatchDisposition.accepted),
    );
  });

  test('retains remix markers', () {
    final request = _request(title: 'Song Name (Club Remix)');

    expect(matcher.buildSearchCandidate(request).title, contains('Remix'));
    expect(
      matcher.match(request, [_candidate()]).disposition,
      isNot(LyricsMatchDisposition.accepted),
    );
  });

  test('does not auto-accept a large duration mismatch', () {
    final result = matcher.match(_request(), [
      _candidate(duration: const Duration(minutes: 4, seconds: 20)),
    ]);

    expect(result.disposition, isNot(LyricsMatchDisposition.accepted));
  });

  test('marks close competing high-confidence results as ambiguous', () {
    final result = matcher.match(_request(), [
      _candidate(sourceId: 'one', duration: const Duration(seconds: 201)),
      _candidate(sourceId: 'two', duration: const Duration(seconds: 202)),
    ]);

    expect(result.disposition, LyricsMatchDisposition.ambiguous);
    expect(result.candidate, isNotNull);
  });
}

LyricsRequest _request({
  String title = 'Song Name',
  List<String> artists = const ['Artist'],
}) => LyricsRequest(
  trackId: 'track-1',
  title: title,
  artists: artists,
  duration: const Duration(seconds: 200),
);

LyricsTrackCandidate _candidate({
  String sourceId = 'remote-1',
  Duration duration = const Duration(seconds: 200),
}) => LyricsTrackCandidate(
  sourceId: sourceId,
  title: 'Song Name',
  artist: 'Artist',
  duration: duration,
);
