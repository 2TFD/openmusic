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
  final LoopMode loopMode;
  final List<int>? shuffleIndices;
  final String? error;

  const PlayerState({
    this.currentTrack,
    this.queue = const [],
    this.currentIndex = 0,
    this.isPlaying = false,
    this.isLoading = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isShuffleEnabled = false,
    this.loopMode = LoopMode.off,
    this.shuffleIndices,
    this.error,
  });

  bool get hasNext => currentIndex < queue.length - 1;
  bool get hasPrev => currentIndex > 0;

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
    LoopMode? loopMode,
    Object? shuffleIndices = _unset,
    Object? error = _unset,
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
    );
  }
}

const _unset = Object();
