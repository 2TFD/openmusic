import '../../../domain/entities/track_lyrics.dart';
import '../../../domain/repositories/lyrics_provider.dart';
import '../../../domain/services/lrc_parser.dart';
import 'embedded_lyrics_metadata_reader.dart';

class EmbeddedLyricsProvider implements LyricsProvider {
  const EmbeddedLyricsProvider({
    required EmbeddedLyricsMetadataReader metadataReader,
    LrcParser parser = const LrcParser(),
  }) : _metadataReader = metadataReader,
       _parser = parser;

  final EmbeddedLyricsMetadataReader _metadataReader;
  final LrcParser _parser;

  @override
  LyricsSource get source => LyricsSource.embedded;

  @override
  Future<LyricsProviderResult> resolve(LyricsRequest request) async {
    final filePath =
        _usable(request.filePath) ?? _usable(request.originalFilePath);
    if (filePath == null) {
      return const LyricsProviderNotFound(details: 'Audio file is unavailable');
    }

    try {
      final metadata = await _metadataReader.read(filePath);
      if (metadata.isEmpty) {
        return const LyricsProviderNotFound(
          details: 'No supported embedded lyrics tags',
        );
      }

      final syncedText = _usable(metadata.syncedText);
      if (syncedText != null) {
        final parsed = _parser.parse(syncedText);
        if (parsed case LrcParseSuccess(:final plainText, :final syncedText)) {
          return _found(request, plainText, syncedText);
        }
        final plainText = _usable(metadata.plainText);
        if (plainText != null) return _found(request, plainText, null);
        return LyricsProviderPermanentFailure(
          code: 'embedded_synced_lyrics_invalid',
          details: (parsed as LrcParseFailure).reason,
        );
      }

      final plainText = _usable(metadata.plainText);
      if (plainText == null) {
        return const LyricsProviderPermanentFailure(
          code: 'embedded_lyrics_empty',
          details: 'Embedded lyrics tag is empty',
        );
      }
      return _found(request, plainText, null);
    } catch (error) {
      return LyricsProviderPermanentFailure(
        code: 'embedded_metadata_read_failed',
        details: error.runtimeType.toString(),
      );
    }
  }

  static LyricsProviderFound _found(
    LyricsRequest request,
    String plainText,
    String? syncedText,
  ) {
    return LyricsProviderFound(
      plainText: plainText.trim(),
      syncedText: syncedText,
      matchConfidence: 1,
      matchedTitle: request.title,
      matchedArtist: request.artists.join(', '),
      matchedDurationMs: request.duration?.inMilliseconds,
    );
  }

  static String? _usable(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return value;
  }
}
