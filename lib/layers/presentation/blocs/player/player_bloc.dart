import 'dart:async';
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/core/services/recommendation/mood_wave_engine.dart';
import 'package:openmusic/core/services/recommendation/wave_recommendation_engine.dart';
import 'package:openmusic/core/utils/app_logger.dart';
import 'package:openmusic/layers/domain/entities/mood_wave.dart';
import 'package:openmusic/layers/domain/entities/queue_entry_provenance.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/wave_session.dart';
import 'package:openmusic/layers/domain/entities/listening_event.dart';
import 'package:openmusic/layers/domain/entities/playback_session.dart';
import 'package:openmusic/layers/domain/repositories/audio_player_port.dart';
import 'package:openmusic/layers/domain/repositories/listening_checkpoint_repository.dart';
import 'package:openmusic/layers/domain/repositories/playback_command_bus.dart';
import 'package:openmusic/layers/domain/repositories/playback_session_repository.dart';
import 'package:openmusic/layers/domain/usecases/build_playback_queue_use_case.dart';
import 'package:openmusic/layers/domain/usecases/restore_playback_session_use_case.dart';
import 'package:openmusic/layers/domain/usecases/save_listening_summary_use_case.dart';
import 'package:openmusic/layers/domain/usecases/skip_track_use_case.dart';
import 'package:openmusic/layers/domain/services/listening_tracker.dart';

part 'player_event.dart';
part 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final AudioPlayerPort _service;
  final SaveListeningSummaryUseCase _saveListeningSummary;
  final ListeningCheckpointRepository _checkpoints;
  final BuildPlaybackQueueUseCase _buildQueue;
  final RestorePlaybackSessionUseCase _restorePlayback;
  final PlaybackSessionRepository _sessions;
  final SkipTrackUseCase _skipTrack;
  final PlaybackCommandBus _commands;
  final ListeningTracker _listeningTracker;
  final WaveRecommendationEngine? _waveRecommendationEngine;
  final MoodWaveEngine? _moodWaveEngine;

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
  Duration _lastTransitionPosition = Duration.zero;
  Future<void> _checkpointWrites = Future.value();
  Future<void> _sessionWrites = Future.value();
  Duration _lastSessionPosition = Duration.zero;
  bool _waveGenerationInFlight = false;
  bool _waveNextTransitionSkipped = false;
  bool _installingWaveQueue = false;

  PlayerBloc({
    required AudioPlayerPort service,
    required SaveListeningSummaryUseCase saveListeningSummary,
    required ListeningCheckpointRepository checkpoints,
    required BuildPlaybackQueueUseCase buildQueue,
    required RestorePlaybackSessionUseCase restorePlayback,
    required PlaybackSessionRepository sessions,
    required SkipTrackUseCase skipTrack,
    required PlaybackCommandBus commands,
    required ListeningTracker listeningTracker,
    WaveRecommendationEngine? waveRecommendationEngine,
    MoodWaveEngine? moodWaveEngine,
  }) : _service = service,
       _saveListeningSummary = saveListeningSummary,
       _checkpoints = checkpoints,
       _buildQueue = buildQueue,
       _restorePlayback = restorePlayback,
       _sessions = sessions,
       _skipTrack = skipTrack,
       _commands = commands,
       _listeningTracker = listeningTracker,
       _waveRecommendationEngine = waveRecommendationEngine,
       _moodWaveEngine = moodWaveEngine,
       super(PlayerState(isRestoring: true)) {
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
      case PlayerMoodWaveStarted():
        await _onMoodWaveStarted(event, emit);
      case PlayerTrackWaveStarted():
        await _onTrackWaveStarted(event, emit);
      case PlayerArtistWaveStarted():
        await _onArtistWaveStarted(event, emit);
      case PlayerWaveMoodSettingsUpdated():
        _onWaveMoodSettingsUpdated(event, emit);
      case PlayerWaveStopped():
        await _onWaveStopped(emit);
      case PlayerMoodWaveStopped():
        await _onWaveStopped(emit);
      case PlayerTrackRemoved():
        await _onTrackRemoved(event, emit);
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
        await _onPlaying(event, emit);
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
        if (!state.isPlaying)
          await _onPlayPause(PlayerPlayPauseToggled(), emit);
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
        emit(PlayerState(isRestoring: false));
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
          _lastTransitionPosition = position;
          _listeningTracker.synchronize(
            trackId: tracks[startIndex].id,
            position: position,
            listened: Duration.zero,
            duration: tracks[startIndex].duration,
            isPlaying: false,
          );
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
    emit(PlayerState(isRestoring: false));
  }

  void _subscribe() {
    _commandSub = _commands.commands.listen(
      (command) => add(_PlayerSystemCommandReceived(command)),
      onError: (e, st) =>
          AppLogger.log('[PlayerBloc] command bus error: $e, stackTrace: $st'),
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
    if (state.waveSession != null && !_installingWaveQueue) {
      emit(state.copyWith(waveSession: null, isWaveGenerating: false));
    }
    try {
      final previousTrack = state.currentTrack;
      final previousPosition = _lastTransitionPosition;
      final previousListened = _listenedDuration;
      final previousDuration = _effectiveDuration(previousTrack);
      await _recordCurrentPlay();
      final queue = _buildQueue(e.tracks, startTrack: e.startTrack);
      if (queue.isEmpty) {
        _resetListening(null);
        _listeningTracker.synchronize(
          trackId: null,
          position: Duration.zero,
          listened: Duration.zero,
          duration: Duration.zero,
          isPlaying: false,
        );
        emit(state.copyWith(queue: const [], currentTrack: null));
        _scheduleSessionWrite(replaceQueue: true);
        return;
      }
      await _service.setQueue(queue.tracks, index: queue.startIndex);
      final nextTrack = queue.tracks[queue.startIndex];
      if (previousTrack != null && previousTrack.id != nextTrack.id) {
        await _recordListening(
          _listeningTracker.trackChanged(
            previousTrackId: previousTrack.id,
            trackId: nextTrack.id,
            previousPosition: previousPosition,
            previousListened: previousListened,
            previousDuration: previousDuration,
            duration: nextTrack.duration,
            isPlaying: state.isPlaying,
            forcedReason: ListeningTransitionReason.queueSelection,
          ),
        );
      } else if (previousTrack != null) {
        await _recordListening(
          _listeningTracker.replayConfirmed(
            trackId: nextTrack.id,
            listened: previousListened,
            duration: nextTrack.duration,
            reason: ListeningTransitionReason.queueSelection,
          ),
        );
      } else {
        _listeningTracker.synchronize(
          trackId: nextTrack.id,
          position: Duration.zero,
          listened: Duration.zero,
          duration: nextTrack.duration,
          isPlaying: state.isPlaying,
        );
      }
      emit(
        state.copyWith(
          queue: queue.tracks,
          currentIndex: queue.startIndex,
          currentTrack: nextTrack,
        ),
      );
      _resetListening(nextTrack);
      _lastSessionPosition = Duration.zero;
      _scheduleSessionWrite(replaceQueue: true);
      if (e.autoPlay) _startPlayback();
    } catch (e, st) {
      AppLogger.log('[PlayerBloc._onQueueSet] Error: $e, stackTrace: $st');
      emit(state.copyWith(error: failureFromException(e).toLocaleKey()));
    }
  }

  Future<void> _onMoodWaveStarted(
    PlayerMoodWaveStarted event,
    Emitter<PlayerState> emit,
  ) async {
    await _startWave(
      WaveSession.startMood(
        targetValence: event.targetValence,
        targetArousal: event.targetArousal,
        radius: event.radius,
        mode: event.mode,
        seedTrackId: state.currentTrack?.id,
        seedAudioRevision: state.currentTrack?.audioRevision,
      ),
      autoPlay: event.autoPlay,
      emit: emit,
    );
  }

  Future<void> _onTrackWaveStarted(
    PlayerTrackWaveStarted event,
    Emitter<PlayerState> emit,
  ) async {
    await _startWave(
      WaveSession.startTrack(
        trackId: event.track.id,
        trackTitle: event.track.title,
        imageUrl: event.track.imageUrl,
        seedAudioRevision: event.track.audioRevision,
      ),
      autoPlay: event.autoPlay,
      emit: emit,
    );
  }

  Future<void> _onArtistWaveStarted(
    PlayerArtistWaveStarted event,
    Emitter<PlayerState> emit,
  ) async {
    await _startWave(
      WaveSession.startArtist(
        artistId: event.artistId,
        artistName: event.artistName,
        imageUrl: event.imageUrl,
      ),
      autoPlay: event.autoPlay,
      emit: emit,
    );
  }

  void _onWaveMoodSettingsUpdated(
    PlayerWaveMoodSettingsUpdated event,
    Emitter<PlayerState> emit,
  ) {
    final session = state.waveSession;
    if (session == null || session.source is! MoodWaveSource) return;
    final source = session.source as MoodWaveSource;
    final targetChanged =
        event.targetValence != null || event.targetArousal != null;
    final userTarget = targetChanged
        ? MoodPoint(
            valence: event.targetValence ?? source.userTarget.valence,
            arousal: event.targetArousal ?? source.userTarget.arousal,
          )
        : null;
    emit(
      state.copyWith(
        waveSession: session.updateMoodSettings(
          userTarget: userTarget,
          radius: event.radius,
          mode: event.mode,
        ),
      ),
    );
  }

  Future<void> _onWaveStopped(Emitter<PlayerState> emit) async {
    final sessionId = state.waveSession?.id;
    if (sessionId != null) {
      await _removeFutureWaveEntries(sessionId, emit);
    }
    emit(state.copyWith(waveSession: null, isWaveGenerating: false));
  }

  Future<void> _startWave(
    WaveSession initialSession, {
    required bool autoPlay,
    required Emitter<PlayerState> emit,
  }) async {
    if (!_canGenerate(initialSession) || _waveGenerationInFlight) return;
    _waveGenerationInFlight = true;
    try {
      final oldSessionId = state.waveSession?.id;
      if (oldSessionId != null) {
        await _removeFutureWaveEntries(oldSessionId, emit);
      }
      emit(state.copyWith(waveSession: initialSession, isWaveGenerating: true));
      final batch = await _generateWave(
        initialSession,
        currentTrackId: state.currentTrack?.id,
        queuedTrackIds: state.queue.map((track) => track.id).toSet(),
      );
      if (batch == null || batch.isEmpty) {
        emit(state.copyWith(waveSession: null, isWaveGenerating: false));
        return;
      }
      final queuedIds = state.queue.map((track) => track.id).toSet();
      final generated = <Track>[];
      for (final track in batch.tracks) {
        if (queuedIds.add(track.id)) generated.add(track);
      }
      if (generated.isEmpty) {
        emit(state.copyWith(waveSession: null, isWaveGenerating: false));
        return;
      }
      if (state.queue.isEmpty || state.currentTrack == null) {
        _installingWaveQueue = true;
        try {
          await _onQueueSet(
            PlayerQueueSet(generated, autoPlay: autoPlay),
            emit,
          );
        } finally {
          _installingWaveQueue = false;
        }
        if (state.queue.isEmpty) {
          emit(state.copyWith(waveSession: null, isWaveGenerating: false));
          return;
        }
        emit(
          state.copyWith(
            queueProvenance: List.filled(
              state.queue.length,
              QueueEntryProvenance.wave(batch.session.id),
            ),
            waveSession: batch.session,
            isWaveGenerating: false,
          ),
        );
      } else {
        await _appendWaveBatch(generated, batch.session, emit);
        if (autoPlay && !state.isPlaying) _startPlayback();
      }
    } catch (error, stackTrace) {
      await AppLogger.log(
        '[PlayerBloc] Error starting Wave: '
        '$error, stackTrace: $stackTrace',
      );
      emit(
        state.copyWith(
          waveSession: null,
          isWaveGenerating: false,
          error: failureFromException(error).toLocaleKey(),
        ),
      );
    } finally {
      _waveGenerationInFlight = false;
    }
  }

  Future<void> _continueWaveIfNeeded(Emitter<PlayerState> emit) async {
    final session = state.waveSession;
    if (session == null ||
        !_canGenerate(session) ||
        state.remainingQueueCount > _remainingQueueThreshold ||
        _waveGenerationInFlight) {
      return;
    }
    _waveGenerationInFlight = true;
    emit(state.copyWith(isWaveGenerating: true));
    try {
      final batch = await _generateWave(
        session,
        currentTrackId: state.currentTrack?.id,
        queuedTrackIds: state.queue.map((track) => track.id).toSet(),
      );
      if (batch == null || batch.isEmpty) {
        emit(state.copyWith(waveSession: null, isWaveGenerating: false));
        return;
      }
      final queuedIds = state.queue.map((track) => track.id).toSet();
      final appended = <Track>[];
      for (final track in batch.tracks) {
        if (queuedIds.add(track.id)) appended.add(track);
      }
      if (appended.isEmpty) {
        emit(state.copyWith(waveSession: null, isWaveGenerating: false));
        return;
      }
      await _appendWaveBatch(appended, batch.session, emit);
    } catch (error, stackTrace) {
      await AppLogger.log(
        '[PlayerBloc] Error continuing Wave: '
        '$error, stackTrace: $stackTrace',
      );
      emit(
        state.copyWith(
          isWaveGenerating: false,
          error: failureFromException(error).toLocaleKey(),
        ),
      );
    } finally {
      _waveGenerationInFlight = false;
    }
  }

  Future<void> _appendWaveBatch(
    List<Track> tracks,
    WaveSession session,
    Emitter<PlayerState> emit,
  ) async {
    await _service.appendQueue(tracks);
    emit(
      state.copyWith(
        queue: [...state.queue, ...tracks],
        queueProvenance: [
          ...state.queueProvenance,
          ...List.filled(tracks.length, QueueEntryProvenance.wave(session.id)),
        ],
        shuffleIndices: state.isShuffleEnabled ? _service.shuffleIndices : null,
        waveSession: session,
        isWaveGenerating: false,
      ),
    );
    _scheduleSessionWrite(replaceQueue: true);
  }

  Future<void> _removeFutureWaveEntries(
    String sessionId,
    Emitter<PlayerState> emit,
  ) async {
    final indices = <int>[];
    for (
      var index = state.currentIndex + 1;
      index < state.queueProvenance.length;
      index++
    ) {
      if (state.queueProvenance[index].belongsToWave(sessionId)) {
        indices.add(index);
      }
    }
    if (indices.isEmpty) return;
    await _service.removeQueueItemsAt(indices);
    final queue = List<Track>.of(state.queue);
    final provenance = List<QueueEntryProvenance>.of(state.queueProvenance);
    for (final index in indices.reversed) {
      queue.removeAt(index);
      provenance.removeAt(index);
    }
    emit(
      state.copyWith(
        queue: queue,
        queueProvenance: provenance,
        shuffleIndices: state.isShuffleEnabled ? _service.shuffleIndices : null,
      ),
    );
    _scheduleSessionWrite(replaceQueue: true);
  }

  bool _canGenerate(WaveSession session) =>
      _waveRecommendationEngine != null ||
      (_moodWaveEngine != null && session.source is MoodWaveSource);

  int get _remainingQueueThreshold =>
      _waveRecommendationEngine?.continuationConfig.remainingQueueThreshold ??
      _moodWaveEngine?.config.remainingQueueThreshold ??
      3;

  int get _recentContextSize =>
      _waveRecommendationEngine?.continuationConfig.recentContextSize ??
      _moodWaveEngine?.config.recentContextSize ??
      3;

  Future<WaveRecommendationBatch?> _generateWave(
    WaveSession session, {
    required String? currentTrackId,
    Set<String> queuedTrackIds = const {},
  }) async {
    final engine = _waveRecommendationEngine;
    if (engine != null) {
      return engine.generate(
        session: session,
        currentTrackId: currentTrackId,
        queuedTrackIds: queuedTrackIds,
      );
    }
    if (session.source is MoodWaveSource) {
      return _moodWaveEngine?.generate(
        session: session,
        currentTrackId: currentTrackId,
        queuedTrackIds: queuedTrackIds,
      );
    }
    return null;
  }

  Future<void> _onTrackRemoved(
    PlayerTrackRemoved e,
    Emitter<PlayerState> emit,
  ) async {
    try {
      await _removeTrackFromPlayback(e.trackId, emit);
      _completeTrackRemoval(e);
    } catch (error, stackTrace) {
      await AppLogger.log(
        '[PlayerBloc._onTrackRemoved] Error removing ${e.trackId}: '
        '$error, stackTrace: $stackTrace',
      );
      _completeTrackRemoval(e, error: error, stackTrace: stackTrace);
      emit(state.copyWith(error: failureFromException(error).toLocaleKey()));
    }
  }

  Future<void> _removeTrackFromPlayback(
    String trackId,
    Emitter<PlayerState> emit,
  ) async {
    if (!state.queue.any((track) => track.id == trackId)) return;

    final wasPlaying = state.isPlaying;
    final removedCurrent = state.currentTrack?.id == trackId;
    final removedTrack = removedCurrent ? state.currentTrack : null;
    final removedPosition = _lastTransitionPosition;
    final removedListened = _listenedDuration;
    final removedDuration = _effectiveDuration(removedTrack);
    final keptIndices = <int>[
      for (var index = 0; index < state.queue.length; index++)
        if (state.queue[index].id != trackId) index,
    ];
    final nextQueue = [for (final index in keptIndices) state.queue[index]];
    final nextProvenance = [
      for (final index in keptIndices) state.queueProvenance[index],
    ];

    if (removedCurrent) await _recordCurrentPlay();

    if (nextQueue.isEmpty) {
      await _service.clearQueue();
      _resetListening(null);
      _listeningTracker.synchronize(
        trackId: null,
        position: Duration.zero,
        listened: Duration.zero,
        duration: Duration.zero,
        isPlaying: false,
      );
      _lastSessionPosition = Duration.zero;
      emit(
        state.copyWith(
          queue: const [],
          queueProvenance: const [],
          currentIndex: 0,
          currentTrack: null,
          isPlaying: false,
          isLoading: false,
          position: Duration.zero,
          duration: Duration.zero,
          shuffleIndices: null,
        ),
      );
      _scheduleSessionWrite(replaceQueue: true, position: Duration.zero);
      return;
    }

    final currentTrackId = state.currentTrack?.id;
    final nextIndex = removedCurrent
        ? min(state.currentIndex, nextQueue.length - 1)
        : nextQueue.indexWhere((track) => track.id == currentTrackId);
    final normalizedIndex = nextIndex < 0
        ? min(state.currentIndex, nextQueue.length - 1)
        : nextIndex;
    final position = removedCurrent ? Duration.zero : state.position;
    final nextTrack = nextQueue[normalizedIndex];

    await _service.setQueue(
      nextQueue,
      index: normalizedIndex,
      initialPosition: position,
    );
    await _service.setLoopMode(state.loopMode);
    await _service.setShuffleModeEnabled(state.isShuffleEnabled);

    if (removedCurrent) {
      await _recordListening(
        _listeningTracker.trackChanged(
          previousTrackId: removedTrack!.id,
          trackId: nextTrack.id,
          previousPosition: removedPosition,
          previousListened: removedListened,
          previousDuration: removedDuration,
          duration: nextTrack.duration,
          isPlaying: wasPlaying,
          forcedReason: ListeningTransitionReason.unknown,
        ),
      );
      _resetListening(nextTrack);
    } else {
      _lastObservedPosition = null;
    }
    _lastSessionPosition = position;

    emit(
      state.copyWith(
        queue: nextQueue,
        queueProvenance: nextProvenance,
        currentIndex: normalizedIndex,
        currentTrack: nextTrack,
        isLoading: false,
        position: position,
        duration: removedCurrent ? nextTrack.duration : state.duration,
        shuffleIndices: state.isShuffleEnabled ? _service.shuffleIndices : null,
      ),
    );
    _scheduleSessionWrite(replaceQueue: true, position: position);
    if (wasPlaying) _startPlayback();
  }

  void _completeTrackRemoval(
    PlayerTrackRemoved event, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    final completer = event.completer;
    if (completer == null || completer.isCompleted) return;
    if (error == null) {
      completer.complete();
    } else {
      completer.completeError(error, stackTrace);
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
  Future<void> _seekTo(
    Duration position,
    Emitter<PlayerState> emit, {
    bool recordListeningEvent = true,
  }) async {
    final track = state.currentTrack;
    final from = state.position;
    final listened = _listenedDuration;
    _lastObservedPosition = null;
    await _service.seek(position);
    _lastTransitionPosition = position;
    if (recordListeningEvent && track != null) {
      await _recordListening(
        _listeningTracker.seekConfirmed(
          trackId: track.id,
          from: from,
          to: position,
          listened: listened,
          duration: _effectiveDuration(track),
        ),
      );
    }
    _lastSessionPosition = position;
    emit(state.copyWith(position: position));
    _scheduleSessionWrite(position: position);
  }

  Future<void> _onTrackSelected(
    PlayerTrackSelected e,
    Emitter<PlayerState> emit,
  ) async {
    try {
      if (e.index < 0 || e.index >= state.queue.length) return;
      final currentTrack = state.currentTrack;
      final selectedTrack = state.queue[e.index];
      if (currentTrack?.id == selectedTrack.id) {
        final listened = _listenedDuration;
        await _service.seekToIndex(e.index);
        await _recordListening(
          _listeningTracker.replayConfirmed(
            trackId: selectedTrack.id,
            listened: listened,
            duration: _effectiveDuration(selectedTrack),
            reason: ListeningTransitionReason.queueSelection,
          ),
        );
        _lastObservedPosition = null;
        _lastTransitionPosition = Duration.zero;
        emit(state.copyWith(position: Duration.zero));
        _scheduleSessionWrite(position: Duration.zero);
        _startPlayback();
        return;
      }
      _listeningTracker.navigationRequested(
        ListeningNavigationIntent.queueSelection,
      );
      _waveNextTransitionSkipped = true;
      await _service.seekToIndex(e.index);
      _startPlayback();
    } catch (e, st) {
      _waveNextTransitionSkipped = false;
      _listeningTracker.cancelNavigationRequest();
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
          final track = state.currentTrack!;
          final listened = _listenedDuration;
          await _seekTo(Duration.zero, emit, recordListeningEvent: false);
          await _recordListening(
            _listeningTracker.replayConfirmed(
              trackId: track.id,
              listened: listened,
              duration: _effectiveDuration(track),
              reason: ListeningTransitionReason.userPrevious,
            ),
          );
        case AdvanceToNextTrack():
          _listeningTracker.navigationRequested(
            ListeningNavigationIntent.userNext,
          );
          _waveNextTransitionSkipped = true;
          await _service.skipToNext();
        case AdvanceToPreviousTrack():
          _listeningTracker.navigationRequested(
            ListeningNavigationIntent.userPrevious,
          );
          _waveNextTransitionSkipped = true;
          await _service.skipToPrevious();
        case SkipRejected():
          break;
      }
    } catch (e, st) {
      _waveNextTransitionSkipped = false;
      _listeningTracker.cancelNavigationRequest();
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
      if (previous == null || e.position >= previous) {
        _lastTransitionPosition = e.position;
      }
    }
    if (track != null) {
      _listeningTracker.positionUpdated(
        trackId: track.id,
        position: e.position,
        listened: _listenedDuration,
        duration: _effectiveDuration(track),
      );
    }
    emit(state.copyWith(position: e.position));
    if (!state.isRestoring &&
        (e.position - _lastSessionPosition).abs() >=
            const Duration(seconds: 5)) {
      _lastSessionPosition = e.position;
      _scheduleSessionWrite(position: e.position);
    }
  }

  void _onDuration(_PlayerDurationUpdated e, Emitter<PlayerState> emit) {
    final track = state.currentTrack;
    if (track != null) {
      _listeningTracker.positionUpdated(
        trackId: track.id,
        position: state.position,
        listened: _listenedDuration,
        duration: e.duration,
      );
    }
    emit(state.copyWith(duration: e.duration));
  }

  Future<void> _onPlaying(
    _PlayerPlayingUpdated e,
    Emitter<PlayerState> emit,
  ) async {
    if (e.playing != state.isPlaying) _lastObservedPosition = null;
    await _recordListening(
      _listeningTracker.playingChanged(
        trackId: state.currentTrack?.id,
        isPlaying: e.playing,
        position: state.position,
        listened: _listenedDuration,
        duration: _effectiveDuration(state.currentTrack),
      ),
    );
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
      final isTrackTransition = state.currentTrack?.id != nextTrack.id;
      if (isTrackTransition) {
        final previousTrack = state.currentTrack;
        if (previousTrack != null) {
          await _recordListening(
            _listeningTracker.trackChanged(
              previousTrackId: previousTrack.id,
              trackId: nextTrack.id,
              previousPosition: _lastTransitionPosition,
              previousListened: _listenedDuration,
              previousDuration: _effectiveDuration(previousTrack),
              duration: nextTrack.duration,
              isPlaying: state.isPlaying,
            ),
          );
        }
        await _recordCurrentPlay();
        _resetListening(nextTrack);
      }
      var waveSession = state.waveSession;
      if (isTrackTransition && waveSession != null) {
        final previousTrackId = state.currentTrack?.id;
        if (previousTrackId != null) {
          waveSession = waveSession.recordPlayed(
            previousTrackId,
            skipped: _waveNextTransitionSkipped,
            contextSize: _recentContextSize,
          );
        }
      }
      if (isTrackTransition) _waveNextTransitionSkipped = false;
      emit(
        state.copyWith(
          currentIndex: e.index,
          currentTrack: nextTrack,
          position: Duration.zero,
          waveSession: waveSession,
        ),
      );
      _lastSessionPosition = Duration.zero;
      _scheduleSessionWrite(position: Duration.zero);
      if (isTrackTransition) await _continueWaveIfNeeded(emit);
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
      final track = state.currentTrack;
      if (track != null) {
        await _recordListening(
          _listeningTracker.processingCompleted(
            trackId: track.id,
            position: _lastTransitionPosition,
            listened: _listenedDuration,
            duration: _effectiveDuration(track),
          ),
        );
      }
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
    _lastTransitionPosition = Duration.zero;
  }

  Duration _effectiveDuration(Track? track) {
    if (track == null) return Duration.zero;
    if (state.currentTrack?.id == track.id && state.duration > Duration.zero) {
      return state.duration;
    }
    return track.duration;
  }

  Future<void> _recordListening(Future<void> write) async {
    try {
      await write;
    } catch (error, stackTrace) {
      await AppLogger.log(
        '[PlayerBloc] Error saving listening event: '
        '$error, stackTrace: $stackTrace',
      );
    }
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
      await _saveListeningSummary(track, listened, summaryId: checkpoint.id);
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
