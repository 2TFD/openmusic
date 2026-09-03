import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/data/datasources/lyrics/embedded_lyrics_metadata_reader.dart';

void main() {
  test('reads supported format and stream tags case-insensitively', () {
    final metadata = EmbeddedLyricsMetadata.fromTagSets(const [
      {'TITLE': 'Track', 'UNSYNCEDLYRICS': 'Plain lyrics'},
      {'SyLt': '[00:01.00] Synced lyrics'},
    ]);

    expect(metadata.plainText, 'Plain lyrics');
    expect(metadata.syncedText, '[00:01.00] Synced lyrics');
  });

  test('ignores unrelated tags and empty supported values', () {
    final metadata = EmbeddedLyricsMetadata.fromTagSets(const [
      {'comment': 'not lyrics', 'lyrics': '   '},
    ]);

    expect(metadata.isEmpty, isTrue);
  });

  test('uses deterministic supported-key priority', () {
    final metadata = EmbeddedLyricsMetadata.fromTagSets(const [
      {'USLT': 'USLT value', 'Lyrics': 'Lyrics value'},
      {'SYLT': 'SYLT value', 'SYNCEDLYRICS': 'Synced value'},
    ]);

    expect(metadata.plainText, 'Lyrics value');
    expect(metadata.syncedText, 'Synced value');
  });
}
