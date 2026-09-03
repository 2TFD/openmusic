import 'package:equatable/equatable.dart';

import '../entities/source.dart';
import '../entities/track_lyrics.dart';

class LyricsRequest extends Equatable {
  LyricsRequest({
    required this.trackId,
    required this.title,
    required List<String> artists,
    this.album,
    this.duration,
    this.filePath,
    this.originalFilePath,
    this.source,
  }) : artists = List.unmodifiable(artists) {
    if (trackId.trim().isEmpty) throw ArgumentError.value(trackId, 'trackId');
    if (title.trim().isEmpty) throw ArgumentError.value(title, 'title');
    if (duration != null && duration!.isNegative) {
      throw ArgumentError.value(duration, 'duration');
    }
  }

  final String trackId;
  final String title;
  final List<String> artists;
  final String? album;
  final Duration? duration;
  final String? filePath;
  final String? originalFilePath;
  final SourceType? source;

  @override
  List<Object?> get props => [
    trackId,
    title,
    artists,
    album,
    duration,
    filePath,
    originalFilePath,
    source,
  ];
}

abstract interface class LyricsProvider {
  LyricsSource get source;

  Future<LyricsProviderResult> resolve(LyricsRequest request);
}

sealed class LyricsProviderResult extends Equatable {
  const LyricsProviderResult();
}

class LyricsProviderFound extends LyricsProviderResult {
  LyricsProviderFound({
    required this.plainText,
    this.syncedText,
    this.language,
    this.sourceId,
    this.matchConfidence,
    this.matchedTitle,
    this.matchedArtist,
    this.matchedDurationMs,
  }) {
    if (plainText.trim().isEmpty) {
      throw ArgumentError.value(plainText, 'plainText');
    }
    _validateMatch(matchConfidence, matchedDurationMs);
  }

  final String plainText;
  final String? syncedText;
  final String? language;
  final String? sourceId;
  final double? matchConfidence;
  final String? matchedTitle;
  final String? matchedArtist;
  final int? matchedDurationMs;

  @override
  List<Object?> get props => [
    plainText,
    syncedText,
    language,
    sourceId,
    matchConfidence,
    matchedTitle,
    matchedArtist,
    matchedDurationMs,
  ];
}

class LyricsProviderNotFound extends LyricsProviderResult {
  const LyricsProviderNotFound({this.details});

  final String? details;

  @override
  List<Object?> get props => [details];
}

class LyricsProviderAmbiguous extends LyricsProviderResult {
  LyricsProviderAmbiguous({
    this.bestConfidence,
    this.matchedTitle,
    this.matchedArtist,
    this.matchedDurationMs,
    this.details,
  }) {
    _validateMatch(bestConfidence, matchedDurationMs);
  }

  final double? bestConfidence;
  final String? matchedTitle;
  final String? matchedArtist;
  final int? matchedDurationMs;
  final String? details;

  @override
  List<Object?> get props => [
    bestConfidence,
    matchedTitle,
    matchedArtist,
    matchedDurationMs,
    details,
  ];
}

class LyricsProviderInstrumental extends LyricsProviderResult {
  LyricsProviderInstrumental({
    this.sourceId,
    this.matchConfidence,
    this.matchedTitle,
    this.matchedArtist,
    this.matchedDurationMs,
  }) {
    _validateMatch(matchConfidence, matchedDurationMs);
  }

  final String? sourceId;
  final double? matchConfidence;
  final String? matchedTitle;
  final String? matchedArtist;
  final int? matchedDurationMs;

  @override
  List<Object?> get props => [
    sourceId,
    matchConfidence,
    matchedTitle,
    matchedArtist,
    matchedDurationMs,
  ];
}

class LyricsProviderTemporaryFailure extends LyricsProviderResult {
  const LyricsProviderTemporaryFailure({
    required this.code,
    this.details,
    this.retryAfter,
  });

  final String code;
  final String? details;
  final Duration? retryAfter;

  @override
  List<Object?> get props => [code, details, retryAfter];
}

class LyricsProviderPermanentFailure extends LyricsProviderResult {
  const LyricsProviderPermanentFailure({required this.code, this.details});

  final String code;
  final String? details;

  @override
  List<Object?> get props => [code, details];
}

void _validateMatch(double? confidence, int? durationMs) {
  if (confidence != null &&
      (!confidence.isFinite || confidence < 0 || confidence > 1)) {
    throw ArgumentError.value(confidence, 'confidence');
  }
  if (durationMs != null && durationMs < 0) {
    throw ArgumentError.value(durationMs, 'durationMs');
  }
}
