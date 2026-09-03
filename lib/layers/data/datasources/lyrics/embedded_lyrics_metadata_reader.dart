import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:path/path.dart' as path;

class EmbeddedLyricsMetadata {
  const EmbeddedLyricsMetadata({this.plainText, this.syncedText});

  factory EmbeddedLyricsMetadata.fromTagSets(
    Iterable<Map<dynamic, dynamic>> tagSets,
  ) {
    final tags = tagSets.toList(growable: false);
    return EmbeddedLyricsMetadata(
      plainText: _firstTag(tags, const ['lyrics', 'unsyncedlyrics', 'uslt']),
      syncedText: _firstTag(tags, const ['syncedlyrics', 'sylt']),
    );
  }

  final String? plainText;
  final String? syncedText;

  bool get isEmpty => plainText == null && syncedText == null;

  static String? _firstTag(
    List<Map<dynamic, dynamic>> tagSets,
    List<String> acceptedKeys,
  ) {
    for (final acceptedKey in acceptedKeys) {
      for (final tags in tagSets) {
        for (final entry in tags.entries) {
          if (entry.key.toString().trim().toLowerCase() != acceptedKey) {
            continue;
          }
          final value = entry.value?.toString();
          if (value != null && value.trim().isNotEmpty) return value;
        }
      }
    }
    return null;
  }
}

abstract interface class EmbeddedLyricsMetadataReader {
  Future<EmbeddedLyricsMetadata> read(String filePath);
}

class FfprobeEmbeddedLyricsMetadataReader
    implements EmbeddedLyricsMetadataReader {
  const FfprobeEmbeddedLyricsMetadataReader({this.appDirectory});

  final String? appDirectory;

  @override
  Future<EmbeddedLyricsMetadata> read(String filePath) async {
    final resolvedPath = path.isAbsolute(filePath)
        ? filePath
        : path.join(appDirectory ?? '', filePath);
    final session = await FFprobeKit.getMediaInformation(resolvedPath);
    final information = session.getMediaInformation();
    if (information == null) return const EmbeddedLyricsMetadata();

    final tagSets = <Map<dynamic, dynamic>>[
      ?information.getTags(),
      for (final stream in information.getStreams()) ?stream.getTags(),
    ];

    return EmbeddedLyricsMetadata.fromTagSets(tagSets);
  }
}
