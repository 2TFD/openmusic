import 'package:equatable/equatable.dart';

enum ListeningEventType {
  playStarted,
  pause,
  resume,
  skipNext,
  skipPrevious,
  seekForward,
  seekBackward,
  trackCompleted,
  trackChanged,
  replay,
}

enum ListeningTransitionReason {
  natural,
  userNext,
  userPrevious,
  queueSelection,
  repeat,
  unknown,
}

class ListeningEvent extends Equatable {
  ListeningEvent({
    required this.id,
    this.sessionId,
    required this.trackId,
    required this.type,
    required this.occurredAt,
    this.positionMs,
    this.listenedMs,
    this.durationMs,
    this.previousTrackId,
    this.transitionReason,
  }) {
    if (id.isEmpty) throw ArgumentError.value(id, 'id');
    if (trackId.isEmpty) throw ArgumentError.value(trackId, 'trackId');
    for (final value in [positionMs, listenedMs, durationMs]) {
      if (value != null && value < 0) {
        throw ArgumentError.value(value, 'duration', 'must not be negative');
      }
    }
  }

  final String id;
  final String? sessionId;
  final String trackId;
  final ListeningEventType type;
  final DateTime occurredAt;
  final int? positionMs;
  final int? listenedMs;
  final int? durationMs;
  final String? previousTrackId;
  final ListeningTransitionReason? transitionReason;

  @override
  List<Object?> get props => [
    id,
    sessionId,
    trackId,
    type,
    occurredAt,
    positionMs,
    listenedMs,
    durationMs,
    previousTrackId,
    transitionReason,
  ];
}
