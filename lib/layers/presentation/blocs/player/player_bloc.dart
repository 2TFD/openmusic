import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/core/utils/app_logger.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/repositories/audio_player_port.dart';
import 'package:openmusic/layers/domain/usecases/build_playback_queue_use_case.dart';
import 'package:openmusic/layers/domain/usecases/save_statistic_use_case.dart';

part 'player_event.dart';
part 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final AudioPlayerPort _service;
  final SaveRecordPlayUseCase _recordPlay;
  final BuildPlaybackQueueUseCase _buildQueue;

  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _playingSub;
  StreamSubscription? _indexSub;
  StreamSubscription? _processingSub;
  Duration _listenedDuration = Duration.zero;
  Duration? _lastObservedPosition;
  String? _listeningTrackId;

  PlayerBloc({
    required AudioPlayerPort service,
    required SaveRecordPlayUseCase recordPlay,
    required BuildPlaybackQueueUseCase buildQueue,
  }) : _service = service,
       _recordPlay = recordPlay,
       _buildQueue = buildQueue,
       super(const PlayerState()) {
    on<PlayerQueueSet>(_onQueueSet);
    on<PlayerPlayPauseToggled>(_onPlayPause);
    on<PlayerSeeked>(_onSeeked);
    on<PlayerTrackSelected>(_onTrackSelected);
    on<PlayerSkippedNext>(_onSkipNext);
    on<PlayerSkippedPrevious>(_onSkipPrev);
    on<PlayerShuffleToggled>(_onShuffleToggle);
    on<PlayerRepeatCycled>(_onRepeatCycle);
    on<PlayerErrorShown>((e, emit) => emit(state.copyWith(error: null)));
    on<_PlayerPositionUpdated>(_onPosition);
    on<_PlayerDurationUpdated>(_onDuration);
    on<_PlayerPlayingUpdated>(_onPlaying);
    on<_PlayerIndexUpdated>(_onIndex);
    on<_PlayerProcessingUpdated>(_onProcessing);

    _subscribe();
  }

  void _subscribe() {
    _positionSub = _service.positionStream.listen(
      (pos) => add(_PlayerPositionUpdated(pos)),
      onError: (e, st) => AppLogger.log(
        '[PlayerBloc] positionStream error: $e, stackTrace: $st',
      ),
    );
    _durationSub = _service.durationStream
        .where((d) => d != null && d > Duration.zero)
        .listen(
          (dur) => add(_PlayerDurationUpdated(dur!)),
          onError: (e, st) => AppLogger.log(
            '[PlayerBloc] durationStream error: $e, stackTrace: $st',
          ),
        );

    _playingSub = _service.playingStream.listen(
      (playing) => add(_PlayerPlayingUpdated(playing)),
      onError: (e, st) => AppLogger.log(
        '[PlayerBloc] playingStream error: $e, stackTrace: $st',
      ),
    );
    _indexSub = _service.indexStream.listen(
      (index) {
        if (index != null) add(_PlayerIndexUpdated(index));
      },
      onError: (e, st) =>
          AppLogger.log('[PlayerBloc] indexStream error: $e, stackTrace: $st'),
    );
    _processingSub = _service.processingStream.listen(
      (ps) => add(_PlayerProcessingUpdated(ps)),
      onError: (e, st) => AppLogger.log(
        '[PlayerBloc] processingStream error: $e, stackTrace: $st',
      ),
    );
  }

  Future<void> _onQueueSet(PlayerQueueSet e, Emitter<PlayerState> emit) async {
    try {
      await _recordCurrentPlay();
      final queue = _buildQueue(e.tracks, startTrack: e.startTrack);
      if (queue.isEmpty) {
        _resetListening(null);
        emit(state.copyWith(queue: const [], currentTrack: null));
        return;
      }
      await _service.setQueue(queue.tracks, index: queue.startIndex);
      emit(
        state.copyWith(
          queue: queue.tracks,
          currentIndex: queue.startIndex,
          currentTrack: queue.tracks[queue.startIndex],
        ),
      );
      _resetListening(queue.tracks[queue.startIndex]);
      if (e.autoPlay) await _service.play();
    } catch (e, st) {
      AppLogger.log('[PlayerBloc._onQueueSet] Error: $e, stackTrace: $st');
      emit(state.copyWith(error: failureFromException(e).toLocaleKey()));
    }
  }

  Future<void> _onPlayPause(
    PlayerPlayPauseToggled e,
    Emitter<PlayerState> emit,
  ) async {
    try {
      state.isPlaying ? await _service.pause() : await _service.play();
    } catch (e, st) {
      AppLogger.log('[PlayerBloc._onPlayPause] Error: $e, stackTrace: $st');
      emit(state.copyWith(error: failureFromException(e).toLocaleKey()));
    }
  }

  Future<void> _onSeeked(PlayerSeeked e, Emitter<PlayerState> emit) async {
    try {
      _lastObservedPosition = null;
      await _service.seek(e.position);
    } catch (e, st) {
      AppLogger.log('[PlayerBloc._onSeeked] Error: $e, stackTrace: $st');
      emit(state.copyWith(error: failureFromException(e).toLocaleKey()));
    }
  }

  Future<void> _onTrackSelected(
    PlayerTrackSelected e,
    Emitter<PlayerState> emit,
  ) async {
    try {
      await _service.seekToIndex(e.index);
      await _service.play();
    } catch (e, st) {
      AppLogger.log('[PlayerBloc._onTrackSelected] Error: $e, stackTrace: $st');
      emit(state.copyWith(error: failureFromException(e).toLocaleKey()));
    }
  }

  Future<void> _onSkipNext(
    PlayerSkippedNext e,
    Emitter<PlayerState> emit,
  ) async {
    try {
      if (state.hasNext) await _service.skipToNext();
    } catch (e, st) {
      AppLogger.log('[PlayerBloc._onSkipNext] Error: $e, stackTrace: $st');
      emit(state.copyWith(error: failureFromException(e).toLocaleKey()));
    }
  }

  Future<void> _onSkipPrev(
    PlayerSkippedPrevious e,
    Emitter<PlayerState> emit,
  ) async {
    try {
      if (state.position.inSeconds > 3) {
        await _service.seek(Duration.zero);
      } else if (state.hasPrev) {
        await _service.skipToPrevious();
      }
    } catch (e, st) {
      AppLogger.log('[PlayerBloc._onSkipPrev] Error: $e, stackTrace: $st');
      emit(state.copyWith(error: failureFromException(e).toLocaleKey()));
    }
  }

  Future<void> _onShuffleToggle(
    PlayerShuffleToggled e,
    Emitter<PlayerState> emit,
  ) async {
    try {
      final next = !state.isShuffleEnabled;
      await _service.setShuffleModeEnabled(next);
      emit(
        state.copyWith(
          isShuffleEnabled: next,
          shuffleIndices: next ? _service.shuffleIndices : null,
        ),
      );
    } catch (e, st) {
      AppLogger.log('[PlayerBloc._onShuffleToggle] Error: $e, stackTrace: $st');
      emit(state.copyWith(error: failureFromException(e).toLocaleKey()));
    }
  }

  Future<void> _onRepeatCycle(
    PlayerRepeatCycled e,
    Emitter<PlayerState> emit,
  ) async {
    try {
      final next = state.loopMode == PlaybackLoopMode.off
          ? PlaybackLoopMode.all
          : state.loopMode == PlaybackLoopMode.all
          ? PlaybackLoopMode.one
          : PlaybackLoopMode.off;
      await _service.setLoopMode(next);
      emit(state.copyWith(loopMode: next));
    } catch (e, st) {
      AppLogger.log('[PlayerBloc._onRepeatCycle] Error: $e, stackTrace: $st');
      emit(state.copyWith(error: failureFromException(e).toLocaleKey()));
    }
  }

  void _onPosition(_PlayerPositionUpdated e, Emitter<PlayerState> emit) {
    final track = state.currentTrack;
    if (track == null) {
      _resetListening(null);
    } else {
      if (_listeningTrackId != track.id) _resetListening(track);
      final previous = _lastObservedPosition;
      if (state.isPlaying && previous != null) {
        final delta = e.position - previous;
        if (delta > Duration.zero) {
          _listenedDuration += delta;
        }
      }
      _lastObservedPosition = e.position;
    }
    emit(state.copyWith(position: e.position));
  }

  void _onDuration(_PlayerDurationUpdated e, Emitter<PlayerState> emit) =>
      emit(state.copyWith(duration: e.duration));

  void _onPlaying(_PlayerPlayingUpdated e, Emitter<PlayerState> emit) {
    if (e.playing != state.isPlaying) _lastObservedPosition = null;
    emit(state.copyWith(isPlaying: e.playing));
  }

  Future<void> _onIndex(
    _PlayerIndexUpdated e,
    Emitter<PlayerState> emit,
  ) async {
    if (e.index < state.queue.length) {
      final nextTrack = state.queue[e.index];
      if (state.currentTrack?.id != nextTrack.id) {
        await _recordCurrentPlay();
        _resetListening(nextTrack);
      }
      emit(
        state.copyWith(
          currentIndex: e.index,
          currentTrack: nextTrack,
          position: Duration.zero,
        ),
      );
    }
  }

  Future<void> _onProcessing(
    _PlayerProcessingUpdated e,
    Emitter<PlayerState> emit,
  ) async {
    final loading =
        e.state == PlaybackProcessingState.loading ||
        e.state == PlaybackProcessingState.buffering;
    emit(state.copyWith(isLoading: loading));
    if (e.state == PlaybackProcessingState.completed) {
      await _recordCurrentPlay();
    }
  }

  void _resetListening(Track? track) {
    _listeningTrackId = track?.id;
    _listenedDuration = Duration.zero;
    _lastObservedPosition = null;
  }

  Future<void> _recordCurrentPlay() async {
    final track = state.currentTrack;
    final listened = _listenedDuration;
    _listenedDuration = Duration.zero;
    _lastObservedPosition = null;
    if (track == null || listened == Duration.zero) return;
    try {
      await _recordPlay(track, listened);
    } catch (error, stackTrace) {
      await AppLogger.log(
        '[PlayerBloc] Error recording play: $error, stackTrace: $stackTrace',
      );
    }
  }

  @override
  Future<void> close() async {
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _playingSub?.cancel();
    await _indexSub?.cancel();
    await _processingSub?.cancel();
    await _recordCurrentPlay();
    await super.close();
  }
}
