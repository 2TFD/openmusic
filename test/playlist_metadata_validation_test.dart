import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/domain/usecases/playlist_metadata_validation.dart';

void main() {
  test('playlist metadata is normalized at the use-case boundary', () {
    final metadata = validatePlaylistMetadata(
      name: '  Playlist  ',
      description: '  Description  ',
      imageUrl: '  https://example.com/cover.jpg  ',
    );

    expect(metadata.name, 'Playlist');
    expect(metadata.description, 'Description');
    expect(metadata.imageUrl, 'https://example.com/cover.jpg');
  });

  test('cover URL requires an HTTP(S) authority and host', () {
    expect(
      () => validatePlaylistMetadata(
        name: 'Playlist',
        imageUrl: 'https:cover.jpg',
      ),
      throwsArgumentError,
    );
    expect(
      () => validatePlaylistMetadata(
        name: 'Playlist',
        imageUrl: 'file:///cover.jpg',
      ),
      throwsArgumentError,
    );
  });
}
