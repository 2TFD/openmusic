import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:openmusic/core/services/audio_player/audio_player_service.dart';
import 'package:openmusic/core/utils/app_logger.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/usecases/save_statistic_use_case.dart';

part 'player_event.dart';
part 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final AudioPlayerService _service;
  final SaveRecordPlayUseCase _recordPlay;
  final String _appDir;

  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _playingSub;
  StreamSubscription? _indexSub;
  StreamSubscription? _processingSub;

  PlayerBloc({
    required AudioPlayerService service,
    required String appDir,
    required SaveRecordPlayUseCase recordPlay,
  }) : _service = service,
       _appDir = appDir,
       _recordPlay = recordPlay,
       super(const PlayerState()) {
    on<PlayerQueueSet>(_onQueueSet);
    on<PlayerPlayPauseToggled>(_onPlayPause);
    on<PlayerSeeked>(_onSeeked);
    on<PlayerIndexSeeked>(_onIndexSeeked);
    on<PlayerSkippedNext>(_onSkipNext);
    on<PlayerSkippedPrevious>(_onSkipPrev);
    on<PlayerShuffleToggled>(_onShuffleToggle);
    on<PlayerRepeatCycled>(_onRepeatCycle);
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
    );
    _durationSub = _service.durationStream
        .where((d) => d != null && d > Duration.zero)
        .listen((dur) => add(_PlayerDurationUpdated(dur!)));

    _playingSub = _service.playingStream.listen(
      (playing) => add(_PlayerPlayingUpdated(playing)),
    );
    _indexSub = _service.indexStream.listen((index) {
      if (index != null) add(_PlayerIndexUpdated(index));
    });
    _processingSub = _service.processingStream.listen(
      (ps) => add(_PlayerProcessingUpdated(ps)),
    );
  }

  Future<void> _onQueueSet(PlayerQueueSet e, Emitter<PlayerState> emit) async {
    try {
      final tracks = e.tracks.where((e) => e.isReadyToPlay).toList();
      if (tracks.isEmpty) {
        emit(state.copyWith(queue: const [], currentTrack: null));
        return;
      }
      final index = e.startIndex.clamp(0, tracks.length - 1);
      await _service.setQueue(tracks, _appDir, index: index);
      emit(
        state.copyWith(
          queue: tracks,
          currentIndex: e.startIndex,
          currentTrack: tracks[index],
        ),
      );
    } catch (e, st) {
      AppLogger.log('[PlayerBloc._onQueueSet] Error: $e, stackTrace: $st');
      emit(state.copyWith(error: 'Failed to set queue: ${e.toString()}'));
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
      emit(
        state.copyWith(error: 'Failed to toggle play/pause: ${e.toString()}'),
      );
    }
  }

  Future<void> _onSeeked(PlayerSeeked e, Emitter<PlayerState> emit) async {
    try {
      await _service.seek(e.position);
    } catch (e, st) {
      AppLogger.log('[PlayerBloc._onSeeked] Error: $e, stackTrace: $st');
      emit(state.copyWith(error: 'Failed to seek: ${e.toString()}'));
    }
  }

  Future<void> _onIndexSeeked(
    PlayerIndexSeeked e,
    Emitter<PlayerState> emit,
  ) async {
    try {
      if (e.tracks != null && !listEquals(e.tracks, state.queue)) {
        await _service.setQueue(e.tracks!, _appDir, index: e.index);
        await _service.seekToIndex(e.index);
        await _service.play();
        emit(
          state.copyWith(
            queue: e.tracks,
            currentIndex: e.index,
            currentTrack: e.tracks != null && e.index < e.tracks!.length
                ? e.tracks![e.index]
                : null,
          ),
        );

        return;
      }
      await _service.seekToIndex(e.index);
      await _service.play();
    } catch (e, st) {
      AppLogger.log('[PlayerBloc._onIndexSeeked] Error: $e, stackTrace: $st');
      emit(state.copyWith(error: 'Failed to seek to index: ${e.toString()}'));
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
      emit(state.copyWith(error: 'Failed to skip to next: ${e.toString()}'));
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
      emit(
        state.copyWith(error: 'Failed to skip to previous: ${e.toString()}'),
      );
    }
  }

  Future<void> _onShuffleToggle(
    PlayerShuffleToggled e,
    Emitter<PlayerState> emit,
  ) async {
    try {
      final next = !state.shuffleEnabled;
      await _service.setShuffleModeEnabled(next);
      emit(
        state.copyWith(
          shuffleEnabled: next,
          shuffleIndices: next ? _service.shuffleIndices : null,
        ),
      );
    } catch (e, st) {
      AppLogger.log('[PlayerBloc._onShuffleToggle] Error: $e, stackTrace: $st');
    }
  }

  Future<void> _onRepeatCycle(
    PlayerRepeatCycled e,
    Emitter<PlayerState> emit,
  ) async {
    try {
      final next = state.loopMode == LoopMode.off
          ? LoopMode.all
          : state.loopMode == LoopMode.all
          ? LoopMode.one
          : LoopMode.off;
      await _service.setLoopMode(next);
      emit(state.copyWith(loopMode: next));
    } catch (e, st) {
      AppLogger.log('[PlayerBloc._onRepeatCycle] Error: $e, stackTrace: $st');
    }
  }

  void _onPosition(_PlayerPositionUpdated e, Emitter<PlayerState> emit) =>
      emit(state.copyWith(position: e.position));

  void _onDuration(_PlayerDurationUpdated e, Emitter<PlayerState> emit) =>
      emit(state.copyWith(duration: e.duration));

  void _onPlaying(_PlayerPlayingUpdated e, Emitter<PlayerState> emit) =>
      emit(state.copyWith(isPlaying: e.playing));

  void _onIndex(_PlayerIndexUpdated e, Emitter<PlayerState> emit) {
    if (e.index < state.queue.length) {
      if (state.position.inSeconds > 30 && state.currentTrack != null) {
        _recordPlay(state.currentTrack!, state.position).catchError((
          error,
          stackTrace,
        ) {
          AppLogger.log(
            '[PlayerBloc._onIndex] Error recording play: $error, stackTrace: $stackTrace',
          );
        });
      }
      emit(
        state.copyWith(
          currentIndex: e.index,
          currentTrack: state.queue[e.index],
        ),
      );
    }
  }

  void _onProcessing(_PlayerProcessingUpdated e, Emitter<PlayerState> emit) {
    final loading =
        e.state == ProcessingState.loading ||
        e.state == ProcessingState.buffering;
    emit(state.copyWith(isLoading: loading));
  }

  @override
  Future<void> close() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playingSub?.cancel();
    _indexSub?.cancel();
    _processingSub?.cancel();
    return super.close();
  }
}
