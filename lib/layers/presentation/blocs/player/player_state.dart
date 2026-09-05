part of 'player_bloc.dart';

class PlayerState extends Equatable {
  final Track? currentTrack;
  final List<Track> queue;
  final List<QueueEntryProvenance> queueProvenance;
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
  final WaveSession? waveSession;
  final bool isWaveGenerating;

  PlayerState({
    this.currentTrack,
    List<Track> queue = const [],
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
    this.waveSession,
    this.isWaveGenerating = false,
    List<QueueEntryProvenance>? queueProvenance,
  }) : queue = List.unmodifiable(queue),
       queueProvenance = List.unmodifiable(
         queueProvenance ??
             List.filled(queue.length, const QueueEntryProvenance.manual()),
       ) {
    if (this.queueProvenance.length != this.queue.length) {
      throw ArgumentError(
        'queueProvenance length must match queue length '
        '(${this.queueProvenance.length} != ${this.queue.length})',
      );
    }
  }

  bool get isWaveActive => waveSession != null;

  @Deprecated('Use waveSession')
  MoodWaveSession? get moodWaveSession => waveSession;

  @Deprecated('Use isWaveActive')
  bool get isMoodWaveActive => waveSession?.source is MoodWaveSource;

  @Deprecated('Use isWaveGenerating')
  bool get isMoodWaveGenerating => isWaveGenerating;

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

  int get remainingQueueCount {
    if (queue.isEmpty) return 0;
    final remaining = queue.length - _effectivePosition - 1;
    return remaining < 0 ? 0 : remaining;
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
    queueProvenance,
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
    waveSession,
    isWaveGenerating,
  ];

  PlayerState copyWith({
    Object? currentTrack = _unset,
    List<Track>? queue,
    List<QueueEntryProvenance>? queueProvenance,
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
    Object? waveSession = _unset,
    bool? isWaveGenerating,
  }) {
    final nextQueue = queue ?? this.queue;
    final nextProvenance =
        queueProvenance ??
        (queue == null
            ? this.queueProvenance
            : List.filled(
                nextQueue.length,
                const QueueEntryProvenance.manual(),
              ));
    return PlayerState(
      currentTrack: identical(currentTrack, _unset)
          ? this.currentTrack
          : currentTrack as Track?,
      queue: nextQueue,
      queueProvenance: nextProvenance,
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
      waveSession: identical(waveSession, _unset)
          ? this.waveSession
          : waveSession as WaveSession?,
      isWaveGenerating: isWaveGenerating ?? this.isWaveGenerating,
    );
  }
}

const _unset = Object();
