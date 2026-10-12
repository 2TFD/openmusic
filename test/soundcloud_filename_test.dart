import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/layers/data/datasources/remote/soundcloud_track_source.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/entities/track_preview.dart';

void main() {
  test('download filename is deterministic and readable, provider-tagged', () {
    const preview = TrackPreview(
      id: '12345',
      title: 'A / title',
      artist: 'Artist',
      source: SourceType.soundcloud,
      originalUrl: 'https://soundcloud.com/artist/track',
      urlFile: '',
    );

    expect(
      SoundcloudTrackSource.downloadFilename(preview),
      'Artist - A _ title - soundcloud - 12345',
    );
    expect(
      SoundcloudTrackSource.downloadFilename(preview),
      SoundcloudTrackSource.downloadFilename(preview),
    );
  });
}
