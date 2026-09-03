import 'package:equatable/equatable.dart';

sealed class LrcParseResult extends Equatable {
  const LrcParseResult();
}

class LrcParseSuccess extends LrcParseResult {
  LrcParseSuccess({
    required this.plainText,
    required this.syncedText,
    required Map<String, String> metadata,
    required this.hasTimestamps,
  }) : metadata = Map.unmodifiable(metadata);

  final String plainText;
  final String? syncedText;
  final Map<String, String> metadata;
  final bool hasTimestamps;

  @override
  List<Object?> get props => [plainText, syncedText, metadata, hasTimestamps];
}

class LrcParseFailure extends LrcParseResult {
  const LrcParseFailure(this.reason);

  final String reason;

  @override
  List<Object> get props => [reason];
}

class LrcParser {
  const LrcParser();

  static final RegExp _metadataLine = RegExp(
    r'^\s*\[([A-Za-z][A-Za-z0-9_-]*):(.*)\]\s*$',
  );
  static final RegExp _timestampedLine = RegExp(
    r'^\s*((?:\[\d{1,3}:\d{2}(?:[\.:]\d{1,3})?\])+)(.*)$',
  );
  static final RegExp _timestamp = RegExp(
    r'\[(\d{1,3}):(\d{2})(?:[\.:](\d{1,3}))?\]',
  );
  static final RegExp _malformedTimestampPrefix = RegExp(
    r'^\s*\[\d{1,3}:[^\]]*\]\s*',
  );
  static final RegExp _enhancedTimestamp = RegExp(
    r'<\d{1,3}:\d{2}(?:[\.:]\d{1,3})?>',
  );

  LrcParseResult parse(String source) {
    final metadata = <String, String>{};
    final lyrics = <String>[];
    var hasTimestamps = false;
    final normalized = source
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceFirst('\ufeff', '');

    for (final rawLine in normalized.split('\n')) {
      final metadataMatch = _metadataLine.firstMatch(rawLine);
      if (metadataMatch != null) {
        metadata[metadataMatch.group(1)!.toLowerCase()] = metadataMatch
            .group(2)!
            .trim();
        continue;
      }

      var lyric = rawLine;
      final timestampedMatch = _timestampedLine.firstMatch(rawLine);
      if (timestampedMatch != null &&
          _allTimestampsValid(timestampedMatch.group(1)!)) {
        hasTimestamps = true;
        lyric = timestampedMatch.group(2)!;
      } else {
        lyric = lyric.replaceFirst(_malformedTimestampPrefix, '');
      }
      lyric = lyric.replaceAll(_enhancedTimestamp, '').trim();
      if (lyric.isNotEmpty) lyrics.add(lyric);
    }

    if (lyrics.isEmpty) {
      return const LrcParseFailure('LRC contains no usable lyric lines');
    }
    return LrcParseSuccess(
      plainText: lyrics.join('\n'),
      syncedText: hasTimestamps ? source : null,
      metadata: metadata,
      hasTimestamps: hasTimestamps,
    );
  }

  static bool _allTimestampsValid(String block) {
    final matches = _timestamp.allMatches(block).toList();
    if (matches.isEmpty ||
        matches.map((match) => match.group(0)).join() != block) {
      return false;
    }
    return matches.every((match) {
      final seconds = int.parse(match.group(2)!);
      return seconds < 60;
    });
  }
}
