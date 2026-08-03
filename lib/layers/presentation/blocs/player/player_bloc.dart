import 'dart:async';
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/core/utils/app_logger.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/playback_session.dart';
import 'package:openmusic/layers/domain/repositories/audio_player_port.dart';
import 'package:openmusic/layers/domain/repositories/listening_checkpoint_repository.dart';
import 'package:openmusic/layers/domain/repositories/playback_command_bus.dart';
import 'package:openmusic/layers/domain/repositories/playback_session_repository.dart';
import 'package:openmusic/layers/domain/usecases/build_playback_queue_use_case.dart';
import 'package:openmusic/layers/domain/usecases/restore_playback_session_use_case.dart';
import 'package:openmusic/layers/domain/usecases/save_statistic_use_case.dart';
import 'package:openmusic/layers/domain/usecases/skip_track_use_case.dart';

part 'player_event.dart';
part 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final AudioPlayerPort _service;
  final SaveRecordPlayUseCase _recordPlay;
  final ListeningCheckpointRepository _checkpoints;
  final BuildPlaybackQueueUseCase _buildQueue;
  final RestorePlaybackSessionUseCase _restorePlayback;
  final PlaybackSessionRepository _sessions;
  final SkipTrackUseCase _skipTrack;
  final PlaybackCommandBus _commands;

  StreamSubscription? _commandSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _playingSub;
  StreamSubscription? _indexSub;
  StreamSubscription? _processingSub;
  Duration _listenedDuration = Duration.zero;
  Duration? _lastObservedPosition;
  String? _listeningTrackId;
  Duration _lastCheckpointedDuration = Duration.zero;
  Future<void> _checkpointWrites = Future.value();
  Future<void> _sessionWrites = Future.value();
  Duration _lastSessionPosition = Duration.zero;

  PlayerBloc({
    required AudioPlayerPort service,
    required SaveRecordPlayUseCase recordPlay,
    required ListeningCheckpointRepository checkpoints,
    required BuildPlaybackQueueUseCase buildQueue,
    required RestorePlaybackSessionUseCase restorePlayback,
    required PlaybackSessionRepository sessions,
    required SkipTrackUseCase skipTrack,
    required PlaybackCommandBus commands,
  }) : _service = service,
       _recordPlay = recordPlay,
       _checkpoints = checkpoints,
       _buildQueue = buildQueue,
       _restorePlayback = restorePlayback,
       _sessions = sessions,
       _skipTrack = skipTrack,
       _commands = commands,
       super(const PlayerState(isRestoring: true)) {
    on<PlayerEvent>(_onEvent, transformer: _sequential());

    _subscribe();
    add(PlayerRestoreRequested());
  }

  Future<void> _onEvent(PlayerEvent event, Emitter<PlayerState> emit) async {
    switch (event) {
      case PlayerRestoreRequested():
        await _onRestore(emit);
      case PlayerSessionFlushRequested():
        await _flushSession();
      case PlayerQueueSet():
        await _onQueueSet(event, emit);
      case PlayerPlayPauseToggled():
        await _onPlayPause(event, emit);
      case PlayerSeeked():
        await _onSeeked(event, emit);
      case PlayerTrackSelected():
        await _onTrackSelected(event, emit);
      case PlayerSkippedNext():
        await _onSkip(SkipDirection.next, emit);
      case PlayerSkippedPrevious():
        await _onSkip(SkipDirection.previous, emit);
      case PlayerShuffleToggled():
        await _onShuffleToggle(event, emit);
      case PlayerRepeatCycled():
        await _onRepeatCycle(event, emit);
      case PlayerErrorShown():
        emit(state.copyWith(error: null));
      case _PlayerPositionUpdated():
        _onPosition(event, emit);
      case _PlayerDurationUpdated():
        _onDuration(event, emit);
      case _PlayerPlayingUpdated():
        _onPlaying(event, emit);
      case _PlayerIndexUpdated():
        await _onIndex(event, emit);
      case _PlayerProcessingUpdated():
        await _onProcessing(event, emit);
      case _PlayerPlaybackFailed():
        emit(
          state.copyWith(
            error: failureFromException(event.error).toLocaleKey(),
          ),
        );
      case _PlayerSystemCommandReceived():
        await _onSystemCommand(event, emit);
    }
  }

  /// Системные команды переиспользуют те же обработчики, что и UI: политика
  /// переключения, учёт прослушанного и запись сессии не должны зависеть от
  /// того, откуда пришло нажатие.
  Future<void> _onSystemCommand(
    _PlayerSystemCommandReceived e,
    Emitter<PlayerState> emit,
  ) async {
    switch (e.command) {
      case PlayRequested():
        if (!state.isPlaying) await _onPlayPause(PlayerPlayPauseToggled(), emit);
      case PauseRequested():
        if (state.isPlaying) await _onPlayPause(PlayerPlayPauseToggled(), emit);
      case StopRequested():
        if (state.isPlaying) await _onPlayPause(PlayerPlayPauseToggled(), emit);
        await _flushSession();
      case SkipNextRequested():
        await _onSkip(SkipDirection.next, emit);
      case SkipPreviousRequested():
        await _onSkip(SkipDirection.previous, emit);
      case SeekRequested(:final position):
        await _onSeeked(PlayerSeeked(position), emit);
      case QueueItemRequested(:final index):
        await _onTrackSelected(PlayerTrackSelected(index: index), emit);
    }
  }

  Future<void> _onRestore(Emitter<PlayerState> emit) async {
    try {
      final restored = await _restorePlayback();
      if (restored == null) {
        emit(const PlayerState(isRestoring: false));
        return;
      }
      var tracks = List<Track>.from(restored.tracks);
      var startIndex = restored.startIndex;
      var position = restored.position;
      while (tracks.isNotEmpty) {
        try {
          await _service.setQueue(
            tracks,
            index: startIndex,
            initialPosition: position,
          );
          await _service.setLoopMode(restored.loopMode);
          await _service.setShuffleModeEnabled(restored.shuffleEnabled);
          await _service.pause();
          _lastSessionPosition = position;
          _resetListening(tracks[startIndex]);
          emit(
            PlayerState(
              currentTrack: tracks[startIndex],
              queue: tracks,
              currentIndex: startIndex,
              position: position,
              isShuffleEnabled: restored.shuffleEnabled,
              loopMode: restored.loopMode,
              shuffleIndices: restored.shuffleEnabled
                  ? _service.shuffleIndices
                  : null,
              isRestoring: false,
            ),
          );
          return;
        } catch (error, stackTrace) {
          await AppLogger.log(
            '[PlayerBloc] Failed to restore track '
            '${tracks[startIndex].id}: $error, stackTrace: $stackTrace',
          );
          tracks.removeAt(startIndex);
          if (tracks.isEmpty) break;
          startIndex = min(startIndex, tracks.length - 1);
          position = Duration.zero;
          await _sessions.replace(
            PlaybackSession(
              queueTrackIds: tracks.map((track) => track.id).toList(),
              currentTrackId: tracks[startIndex].id,
              currentQueuePosition: startIndex,
              position: Duration.zero,
              shuffleEnabled: restored.shuffleEnabled,
              loopMode: restored.loopMode,
              updatedAt: DateTime.now(),
            ),
          );
        }
      }
      await _sessions.clear();
    } catch (error, stackTrace) {
      await AppLogger.log(
        '[PlayerBloc] Error restoring playback session: '
        '$error, stackTrace: $stackTrace',
      );
    }
    emit(const PlayerState(isRestoring: false));
  }

  void _subscribe() {
    _commandSub = _commands.commands.listen(
      (command) => add(_PlayerSystemCommandReceived(command)),
      onError: (e, st) => AppLogger.log(
        '[PlayerBloc] command bus error: $e, stackTrace: $st',
      ),
    );
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
        _scheduleSessionWrite(replaceQueue: true);
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
      _lastSessionPosition = Duration.zero;
      _scheduleSessionWrite(replaceQueue: true);
      if (e.autoPlay) _startPlayback();
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
      if (state.isPlaying) {
        await _service.pause();
      } else {
        _startPlayback();
      }
    } catch (e, st) {
      AppLogger.log('[PlayerBloc._onPlayPause] Error: $e, stackTrace: $st');
      emit(state.copyWith(error: failureFromException(e).toLocaleKey()));
    }
  }

  Future<void> _onSeeked(PlayerSeeked e, Emitter<PlayerState> emit) async {
    try {
      await _seekTo(e.position, emit);
    } catch (e, st) {
      AppLogger.log('[PlayerBloc._onSeeked] Error: $e, stackTrace: $st');
      emit(state.copyWith(error: failureFromException(e).toLocaleKey()));
    }
  }

  /// Сброс [_lastObservedPosition] обязателен: иначе следующий тик позиции
  /// посчитает перемотку вперёд прослушанным временем и раздует статистику.
  Future<void> _seekTo(Duration position, Emitter<PlayerState> emit) async {
    _lastObservedPosition = null;
    await _service.seek(position);
    _lastSessionPosition = position;
    emit(state.copyWith(position: position));
    _scheduleSessionWrite(position: position);
  }

  Future<void> _onTrackSelected(
    PlayerTrackSelected e,
    Emitter<PlayerState> emit,
  ) async {
    try {
      await _service.seekToIndex(e.index);
      _startPlayback();
    } catch (e, st) {
      AppLogger.log('[PlayerBloc._onTrackSelected] Error: $e, stackTrace: $st');
      emit(state.copyWith(error: failureFromException(e).toLocaleKey()));
    }
  }

  Future<void> _onSkip(
    SkipDirection direction,
    Emitter<PlayerState> emit,
  ) async {
    if (state.currentTrack == null) return;
    try {
      final action = _skipTrack(
        direction,
        position: state.position,
        hasNext: state.hasNext,
        hasPrev: state.hasPrev,
      );
      switch (action) {
        case RestartCurrentTrack():
          await _seekTo(Duration.zero, emit);
        case AdvanceToNextTrack():
          await _service.skipToNext();
        case AdvanceToPreviousTrack():
          await _service.skipToPrevious();
        case SkipRejected():
          break;
      }
    } catch (e, st) {
      AppLogger.log('[PlayerBloc._onSkip] Error: $e, stackTrace: $st');
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
      _scheduleSessionWrite();
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
      _scheduleSessionWrite();
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
          if (_listenedDuration - _lastCheckpointedDuration >=
              const Duration(seconds: 5)) {
            _lastCheckpointedDuration = _listenedDuration;
            _scheduleCheckpoint(track, _listenedDuration);
          }
        }
      }
      _lastObservedPosition = e.position;
    }
    emit(state.copyWith(position: e.position));
    if (!state.isRestoring &&
        (e.position - _lastSessionPosition).abs() >=
            const Duration(seconds: 5)) {
      _lastSessionPosition = e.position;
      _scheduleSessionWrite(position: e.position);
    }
  }

  void _onDuration(_PlayerDurationUpdated e, Emitter<PlayerState> emit) =>
      emit(state.copyWith(duration: e.duration));

  void _onPlaying(_PlayerPlayingUpdated e, Emitter<PlayerState> emit) {
    if (e.playing != state.isPlaying) _lastObservedPosition = null;
    emit(state.copyWith(isPlaying: e.playing));
    if (!e.playing && state.currentTrack != null) {
      _scheduleSessionWrite();
    }
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
      _lastSessionPosition = Duration.zero;
      _scheduleSessionWrite(position: Duration.zero);
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
      _lastSessionPosition = Duration.zero;
      _scheduleSessionWrite(position: Duration.zero);
    }
  }

  void _startPlayback() {
    unawaited(
      _service.play().catchError((Object error, StackTrace stackTrace) {
        unawaited(
          AppLogger.log(
            '[PlayerBloc] Error starting playback: '
            '$error, stackTrace: $stackTrace',
          ),
        );
        if (!isClosed) add(_PlayerPlaybackFailed(error));
      }),
    );
  }

  void _resetListening(Track? track) {
    _listeningTrackId = track?.id;
    _listenedDuration = Duration.zero;
    _lastObservedPosition = null;
    _lastCheckpointedDuration = Duration.zero;
  }

  void _scheduleCheckpoint(Track track, Duration listened) {
    _checkpointWrites = _checkpointWrites
        .then((_) async {
          await _checkpoints.save(track, listened);
        })
        .catchError((Object error, StackTrace stackTrace) async {
          await AppLogger.log(
            '[PlayerBloc] Error saving listening checkpoint: '
            '$error, stackTrace: $stackTrace',
          );
        });
  }

  Future<void> _recordCurrentPlay() async {
    final track = state.currentTrack;
    final listened = _listenedDuration;
    _listenedDuration = Duration.zero;
    _lastObservedPosition = null;
    if (track == null || listened == Duration.zero) return;
    try {
      await _checkpointWrites;
      final checkpoint = await _checkpoints.save(track, listened);
      await _recordPlay(track, listened, recordId: checkpoint.id);
      await _checkpoints.clear(checkpoint.id);
    } catch (error, stackTrace) {
      await AppLogger.log(
        '[PlayerBloc] Error recording play: $error, stackTrace: $stackTrace',
      );
    }
  }

  void _scheduleSessionWrite({bool replaceQueue = false, Duration? position}) {
    final snapshot = _sessionSnapshot(position: position);
    _sessionWrites = _sessionWrites
        .then((_) async {
          if (snapshot.queueTrackIds.isEmpty) {
            await _sessions.clear();
          } else if (replaceQueue) {
            await _sessions.replace(snapshot);
          } else {
            await _sessions.updatePlayback(snapshot);
          }
        })
        .catchError((Object error, StackTrace stackTrace) async {
          await AppLogger.log(
            '[PlayerBloc] Error saving playback session: '
            '$error, stackTrace: $stackTrace',
          );
        });
  }

  PlaybackSession _sessionSnapshot({Duration? position}) {
    return PlaybackSession(
      queueTrackIds: state.queue.map((track) => track.id).toList(),
      currentTrackId: state.currentTrack?.id,
      currentQueuePosition: state.currentIndex,
      position: position ?? state.position,
      shuffleEnabled: state.isShuffleEnabled,
      loopMode: state.loopMode,
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _flushSession() async {
    if (!state.isRestoring) _scheduleSessionWrite();
    await _sessionWrites;
    await _checkpointWrites;
  }

  @override
  Future<void> close() async {
    await _commandSub?.cancel();
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _playingSub?.cancel();
    await _indexSub?.cancel();
    await _processingSub?.cancel();
    await _recordCurrentPlay();
    await _flushSession();
    await super.close();
  }
}

EventTransformer<E> _sequential<E>() =>
    (events, mapper) => events.asyncExpand(mapper);
