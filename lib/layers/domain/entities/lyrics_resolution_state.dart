import 'package:equatable/equatable.dart';

import 'track_lyrics.dart';

enum LyricsResolutionStatus {
  unknown,
  searching,
  found,
  notFound,
  ambiguous,
  instrumental,
  failed,
}

class LyricsResolutionState extends Equatable {
  const LyricsResolutionState({
    required this.trackId,
    required this.status,
    this.source,
    this.metadataRevision = 0,
    this.attemptCount = 0,
    this.lastAttemptAt,
    this.retryAt,
    this.failureCode,
    this.failureMessage,
    required this.updatedAt,
  });

  final String trackId;
  final LyricsResolutionStatus status;
  final LyricsSource? source;
  final int metadataRevision;
  final int attemptCount;
  final DateTime? lastAttemptAt;
  final DateTime? retryAt;
  final String? failureCode;
  final String? failureMessage;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
    trackId,
    status,
    source,
    metadataRevision,
    attemptCount,
    lastAttemptAt,
    retryAt,
    failureCode,
    failureMessage,
    updatedAt,
  ];
}
