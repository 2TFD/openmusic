part of 'player_bloc.dart';

class PlayerState extends Equatable {
  final Track? currentTrack;
  final List<Track> queue;
  final int currentIndex;
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final Duration duration;
  final bool isShuffleEnabled;
  final PlaybackLoopMode loopMode;
  final List<int>? shuffleIndices;
  final String? error;
  final bool isRestoring;

  const PlayerState({
    this.currentTrack,
    this.queue = const [],
    this.currentIndex = 0,
    this.isPlaying = false,
    this.isLoading = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isShuffleEnabled = false,
    this.loopMode = PlaybackLoopMode.off,
    this.shuffleIndices,
    this.error,
    this.isRestoring = false,
  });

  bool get hasNext {
    if (queue.length < 2) return false;
    if (loopMode == PlaybackLoopMode.all) return true;
    return _effectivePosition < queue.length - 1;
  }

  bool get hasPrev {
    if (queue.length < 2) return false;
    if (loopMode == PlaybackLoopMode.all) return true;
    return _effectivePosition > 0;
  }

  int get _effectivePosition {
    final indices = shuffleIndices;
    if (!isShuffleEnabled ||
        indices == null ||
        indices.length != queue.length) {
      return currentIndex;
    }
    final position = indices.indexOf(currentIndex);
    return position < 0 ? currentIndex : position;
  }

  double get progress => duration.inMilliseconds == 0
      ? 0
      : position.inMilliseconds / duration.inMilliseconds;

  @override
  List<Object?> get props => [
    currentTrack,
    queue,
    currentIndex,
    isPlaying,
    isLoading,
    position,
    duration,
    isShuffleEnabled,
    loopMode,
    shuffleIndices,
    error,
    isRestoring,
  ];

  PlayerState copyWith({
    Object? currentTrack = _unset,
    List<Track>? queue,
    int? currentIndex,
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    Duration? duration,
    bool? isShuffleEnabled,
    PlaybackLoopMode? loopMode,
    Object? shuffleIndices = _unset,
    Object? error = _unset,
    bool? isRestoring,
  }) {
    return PlayerState(
      currentTrack: identical(currentTrack, _unset)
          ? this.currentTrack
          : currentTrack as Track?,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      loopMode: loopMode ?? this.loopMode,
      shuffleIndices: identical(shuffleIndices, _unset)
          ? this.shuffleIndices
          : shuffleIndices as List<int>?,
      error: identical(error, _unset) ? this.error : error as String?,
      isRestoring: isRestoring ?? this.isRestoring,
    );
  }
}

const _unset = Object();
