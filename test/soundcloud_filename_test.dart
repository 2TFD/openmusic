import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/data/datasources/remote/soundcloud_track_source.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';

void main() {
  test('download filename is deterministic and provider-prefixed', () {
    const preview = TrackPreview(
      id: '12345',
      title: 'A / title',
      artist: 'Artist',
      source: SourceType.soundcloud,
      originalUrl: 'https://soundcloud.com/artist/track',
      urlFile: '',
    );

    expect(SoundcloudTrackSource.downloadFilename(preview), 'soundcloud_12345');
    expect(
      SoundcloudTrackSource.downloadFilename(preview),
      SoundcloudTrackSource.downloadFilename(preview),
    );
  });
}
