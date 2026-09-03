import 'package:equatable/equatable.dart';

enum LyricsSource { embedded, sidecarLrc, lrclib }

class TrackLyrics extends Equatable {
  factory TrackLyrics({
    required String trackId,
    required LyricsSource source,
    String? sourceId,
    required String plainText,
    String? syncedText,
    String? language,
    required String contentHash,
    bool isInstrumental = false,
    double? matchConfidence,
    String? matchedTitle,
    String? matchedArtist,
    int? matchedDurationMs,
    required DateTime fetchedAt,
    required DateTime updatedAt,
  }) {
    if (trackId.trim().isEmpty) {
      throw ArgumentError.value(trackId, 'trackId');
    }
    if (!isInstrumental && plainText.trim().isEmpty) {
      throw ArgumentError.value(plainText, 'plainText');
    }
    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(contentHash)) {
      throw ArgumentError.value(contentHash, 'contentHash', 'must be SHA-256');
    }
    if (matchConfidence != null &&
        (!matchConfidence.isFinite ||
            matchConfidence < 0 ||
            matchConfidence > 1)) {
      throw ArgumentError.value(matchConfidence, 'matchConfidence');
    }
    if (matchedDurationMs != null && matchedDurationMs < 0) {
      throw ArgumentError.value(matchedDurationMs, 'matchedDurationMs');
    }
    return TrackLyrics._(
      trackId: trackId,
      source: source,
      sourceId: sourceId,
      plainText: plainText,
      syncedText: syncedText,
      language: language,
      contentHash: contentHash,
      isInstrumental: isInstrumental,
      matchConfidence: matchConfidence,
      matchedTitle: matchedTitle,
      matchedArtist: matchedArtist,
      matchedDurationMs: matchedDurationMs,
      fetchedAt: fetchedAt,
      updatedAt: updatedAt,
    );
  }

  const TrackLyrics._({
    required this.trackId,
    required this.source,
    this.sourceId,
    required this.plainText,
    this.syncedText,
    this.language,
    required this.contentHash,
    required this.isInstrumental,
    this.matchConfidence,
    this.matchedTitle,
    this.matchedArtist,
    this.matchedDurationMs,
    required this.fetchedAt,
    required this.updatedAt,
  });

  final String trackId;
  final LyricsSource source;
  final String? sourceId;
  final String plainText;
  final String? syncedText;
  final String? language;
  final String contentHash;
  final bool isInstrumental;
  final double? matchConfidence;
  final String? matchedTitle;
  final String? matchedArtist;
  final int? matchedDurationMs;
  final DateTime fetchedAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
    trackId,
    source,
    sourceId,
    plainText,
    syncedText,
    language,
    contentHash,
    isInstrumental,
    matchConfidence,
    matchedTitle,
    matchedArtist,
    matchedDurationMs,
    fetchedAt,
    updatedAt,
  ];
}
