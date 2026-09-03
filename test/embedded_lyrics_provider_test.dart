import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/data/datasources/lyrics/embedded_lyrics_metadata_reader.dart';
import 'package:openmusic/layers/data/datasources/lyrics/embedded_lyrics_provider.dart';
import 'package:openmusic/layers/domain/repositories/lyrics_provider.dart';

void main() {
  test('returns plain embedded lyrics', () async {
    const provider = EmbeddedLyricsProvider(
      metadataReader: _Reader(
        EmbeddedLyricsMetadata(plainText: 'First\nSecond'),
      ),
    );

    final result = await provider.resolve(_request());

    expect(result, isA<LyricsProviderFound>());
    expect((result as LyricsProviderFound).plainText, 'First\nSecond');
    expect(result.syncedText, isNull);
    expect(result.matchConfidence, 1);
  });

  test('derives plain text from synced embedded lyrics', () async {
    const synced = '[00:01.00]Первая\n[00:02.00]Second';
    const provider = EmbeddedLyricsProvider(
      metadataReader: _Reader(EmbeddedLyricsMetadata(syncedText: synced)),
    );

    final result = await provider.resolve(_request());

    expect(result, isA<LyricsProviderFound>());
    expect((result as LyricsProviderFound).plainText, 'Первая\nSecond');
    expect(result.syncedText, synced);
  });

  test('returns not found for missing embedded tags', () async {
    const provider = EmbeddedLyricsProvider(
      metadataReader: _Reader(EmbeddedLyricsMetadata()),
    );

    expect(await provider.resolve(_request()), isA<LyricsProviderNotFound>());
  });

  test('returns typed failure when metadata reader fails', () async {
    final provider = EmbeddedLyricsProvider(
      metadataReader: _Reader.failure(StateError('ffprobe failed')),
    );

    final result = await provider.resolve(_request());

    expect(result, isA<LyricsProviderPermanentFailure>());
    expect(
      (result as LyricsProviderPermanentFailure).code,
      'embedded_metadata_read_failed',
    );
  });
}

LyricsRequest _request() => LyricsRequest(
  trackId: 'track-1',
  title: 'Song',
  artists: const ['Artist'],
  duration: const Duration(minutes: 3),
  filePath: 'track.mp3',
);

class _Reader implements EmbeddedLyricsMetadataReader {
  const _Reader(this.metadata) : error = null;

  const _Reader.failure(this.error) : metadata = null;

  final EmbeddedLyricsMetadata? metadata;
  final Object? error;

  @override
  Future<EmbeddedLyricsMetadata> read(String filePath) async {
    if (error case final error?) throw error;
    return metadata!;
  }
}
