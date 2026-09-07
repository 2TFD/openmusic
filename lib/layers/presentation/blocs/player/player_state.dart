part of 'player_bloc.dart';

enum WaveContinuationStatus { inactive, ready, generating, waiting }

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
  final WaveContinuationStatus waveContinuationStatus;

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
    WaveContinuationStatus? waveContinuationStatus,
    bool? isWaveGenerating,
    List<QueueEntryProvenance>? queueProvenance,
  }) : waveContinuationStatus =
           waveContinuationStatus ??
           (isWaveGenerating == true
               ? WaveContinuationStatus.generating
               : null) ??
           (waveSession == null
               ? WaveContinuationStatus.inactive
               : WaveContinuationStatus.ready),
       queue = List.unmodifiable(queue),
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

  bool get isWaveGenerating =>
      waveContinuationStatus == WaveContinuationStatus.generating;

  bool get isWaveWaiting =>
      waveContinuationStatus == WaveContinuationStatus.waiting;

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
    return futureQueueIndices.length;
  }

  List<int> get futureQueueIndices {
    if (queue.isEmpty) return const [];
    final playbackOrder =
        isShuffleEnabled &&
            shuffleIndices != null &&
            shuffleIndices!.length == queue.length
        ? shuffleIndices!
        : List<int>.generate(queue.length, (index) => index);
    final position = playbackOrder.indexOf(currentIndex);
    final effectivePosition = position < 0 ? currentIndex : position;
    if (effectivePosition >= playbackOrder.length - 1) return const [];
    return List.unmodifiable(playbackOrder.sublist(effectivePosition + 1));
  }

  Set<String> get futureQueueTrackIds => {
    for (final index in futureQueueIndices)
      if (index >= 0 && index < queue.length) queue[index].id,
  };

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
    waveContinuationStatus,
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
    WaveContinuationStatus? waveContinuationStatus,
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
      waveContinuationStatus:
          waveContinuationStatus ??
          (isWaveGenerating == true
              ? WaveContinuationStatus.generating
              : isWaveGenerating == false
              ? (identical(waveSession, _unset)
                    ? (this.waveSession == null
                          ? WaveContinuationStatus.inactive
                          : WaveContinuationStatus.ready)
                    : waveSession == null
                    ? WaveContinuationStatus.inactive
                    : WaveContinuationStatus.ready)
              : null) ??
          (identical(waveSession, _unset)
              ? this.waveContinuationStatus
              : waveSession == null
              ? WaveContinuationStatus.inactive
              : this.waveSession == null
              ? WaveContinuationStatus.ready
              : this.waveContinuationStatus),
    );
  }
}

const _unset = Object();
