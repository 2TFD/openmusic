import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';

void main() {
  test('fallback artist identity is stable across tracks', () {
    final first = _preview('track-1', '  Same   Artist ');
    final second = _preview('track-2', 'same artist');

    expect(
      first.toTrack(null).artists.single.id,
      second.toTrack(null).artists.single.id,
    );
    expect(
      first.toTrack(null).artists.single.id,
      'soundcloud:artist:same artist',
    );
  });

  test('provider artist identity takes precedence', () {
    final preview = _preview(
      'track-1',
      'Artist',
      artistId: 'soundcloud:artist:42',
    );

    expect(preview.toTrack(null).artists.single.id, 'soundcloud:artist:42');
  });
}

TrackPreview _preview(String id, String artist, {String? artistId}) =>
    TrackPreview(
      id: id,
      title: id,
      artist: artist,
      artistId: artistId,
      source: SourceType.soundcloud,
      originalUrl: 'https://example.com/$id',
      urlFile: '',
    );
