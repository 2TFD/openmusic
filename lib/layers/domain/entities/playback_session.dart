import 'package:equatable/equatable.dart';
import 'package:openmusic/layers/domain/repositories/audio_player_port.dart';

class PlaybackSession extends Equatable {
  const PlaybackSession({
    required this.queueTrackIds,
    required this.currentQueuePosition,
    required this.position,
    required this.shuffleEnabled,
    required this.loopMode,
    required this.updatedAt,
    this.currentTrackId,
  });

  final List<String> queueTrackIds;
  final String? currentTrackId;
  final int currentQueuePosition;
  final Duration position;
  final bool shuffleEnabled;
  final PlaybackLoopMode loopMode;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
    queueTrackIds,
    currentTrackId,
    currentQueuePosition,
    position,
    shuffleEnabled,
    loopMode,
    updatedAt,
  ];

  PlaybackSession copyWith({
    List<String>? queueTrackIds,
    Object? currentTrackId = _unset,
    int? currentQueuePosition,
    Duration? position,
    bool? shuffleEnabled,
    PlaybackLoopMode? loopMode,
    DateTime? updatedAt,
  }) {
    return PlaybackSession(
      queueTrackIds: queueTrackIds ?? this.queueTrackIds,
      currentTrackId: identical(currentTrackId, _unset)
          ? this.currentTrackId
          : currentTrackId as String?,
      currentQueuePosition:
          currentQueuePosition ?? this.currentQueuePosition,
      position: position ?? this.position,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      loopMode: loopMode ?? this.loopMode,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

const _unset = Object();
