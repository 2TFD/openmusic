import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/core/services/audio_player/playback_command_bus_impl.dart';
import 'package:openmusic/core/services/music_analysis/music_analysis_model_registry.dart';
import 'package:openmusic/core/services/recommendation/mood_wave_config.dart';
import 'package:openmusic/core/services/recommendation/mood_wave_engine.dart';
import 'package:openmusic/layers/domain/entities/artist.dart';
import 'package:openmusic/layers/domain/entities/listening_summary.dart';
import 'package:openmusic/layers/domain/entities/mood_map.dart';
import 'package:openmusic/layers/domain/entities/mood_wave.dart';
import 'package:openmusic/layers/domain/entities/music_analysis.dart';
import 'package:openmusic/layers/domain/entities/playback_session.dart';
import 'package:openmusic/layers/domain/entities/queue_entry_provenance.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/track_embedding.dart';
import 'package:openmusic/layers/domain/entities/track_emotion_analysis.dart';
import 'package:openmusic/layers/domain/entities/track_temporal_embedding.dart';
import 'package:openmusic/layers/domain/repositories/audio_player_port.dart';
import 'package:openmusic/layers/domain/repositories/listening_checkpoint_repository.dart';
import 'package:openmusic/layers/domain/repositories/listening_summary_repository.dart';
import 'package:openmusic/layers/domain/repositories/mood_map_repository.dart';
import 'package:openmusic/layers/domain/repositories/music_analysis_client.dart';
import 'package:openmusic/layers/domain/repositories/playback_session_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_embedding_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_temporal_embedding_repository.dart';
import 'package:openmusic/layers/domain/services/listening_tracker.dart';
import 'package:openmusic/layers/domain/usecases/build_playback_queue_use_case.dart';
import 'package:openmusic/layers/domain/usecases/restore_playback_session_use_case.dart';
import 'package:openmusic/layers/domain/usecases/save_listening_summary_use_case.dart';
import 'package:openmusic/layers/domain/usecases/skip_track_use_case.dart';
import 'package:openmusic/layers/presentation/blocs/player/player_bloc.dart';

void main() {
  test(
    'remaining <= 3 appends one unique batch and preserves repeat',
    () async {
      final harness = await _Harness.create(trackCount: 12);
      addTearDown(harness.close);

      harness.bloc.add(PlayerRepeatCycled());
      await _until(() => harness.bloc.state.loopMode == PlaybackLoopMode.all);
      harness.start();
      await _until(() => harness.bloc.state.queue.length == 5);

      final initialIds = harness.bloc.state.queue
          .map((track) => track.id)
          .toSet();
      harness.player.index.add(1);
      await _until(() => harness.player.appendCalls == 1);

      expect(harness.bloc.state.queue, hasLength(10));
      expect(
        harness.bloc.state.queue.map((track) => track.id).toSet(),
        hasLength(10),
      );
      expect(
        harness.player.appended.every(
          (track) => !initialIds.contains(track.id),
        ),
        isTrue,
      );
      expect(harness.bloc.state.loopMode, PlaybackLoopMode.all);
      expect(harness.player.loopMode, PlaybackLoopMode.all);
      expect(harness.bloc.state.moodWaveSession!.recentTrackIds, isNotEmpty);
      expect(
        harness.bloc.state.queueProvenance,
        everyElement(
          isA<QueueEntryProvenance>().having(
            (value) => value.waveSessionId,
            'waveSessionId',
            harness.bloc.state.waveSession!.id,
          ),
        ),
      );
    },
  );

  test('concurrent low-queue events do not duplicate generation', () async {
    final harness = await _Harness.create(trackCount: 12);
    addTearDown(harness.close);
    harness.start();
    await _until(() => harness.bloc.state.queue.length == 5);

    final continuation = Completer<void>();
    harness.moods.holdCall = 2;
    harness.moods.hold = continuation;
    harness.player.index.add(1);
    await _until(
      () =>
          harness.moods.loadCalls == 2 &&
          harness.bloc.state.isMoodWaveGenerating,
    );
    harness.player.index.add(2);
    harness.player.index.add(2);
    continuation.complete();
    await _until(() => harness.player.appendCalls == 1);
    await _until(() => harness.bloc.state.currentIndex == 2);

    expect(harness.moods.loadCalls, 2);
    expect(harness.player.appendCalls, 1);
  });

  test('starting a new Wave replaces the active session', () async {
    final harness = await _Harness.create(trackCount: 12);
    addTearDown(harness.close);
    harness.start();
    await _until(() => harness.bloc.state.queue.length == 5);
    final firstSessionId = harness.bloc.state.waveSession!.id;

    harness.bloc.add(
      PlayerMoodWaveStarted(
        targetValence: 0.05,
        targetArousal: 0.05,
        radius: 0.4,
        mode: MoodWaveMode.explore,
        autoPlay: false,
      ),
    );
    await _until(
      () =>
          harness.bloc.state.waveSession != null &&
          harness.bloc.state.waveSession!.id != firstSessionId &&
          !harness.bloc.state.isWaveGenerating,
    );

    final secondSessionId = harness.bloc.state.waveSession!.id;
    expect(harness.bloc.state.waveSession!.source, isA<MoodWaveSource>());
    expect(harness.bloc.state.queue.first.id, isNot('track-0'));
    expect(
      harness.bloc.state.queueProvenance,
      everyElement(
        isA<QueueEntryProvenance>().having(
          (value) => value.waveSessionId,
          'waveSessionId',
          secondSessionId,
        ),
      ),
    );
  });

  test('Mood settings update is retained by the next batch', () async {
    final harness = await _Harness.create(trackCount: 12);
    addTearDown(harness.close);
    harness.start();
    await _until(() => harness.bloc.state.queue.length == 5);

    harness.bloc.add(
      PlayerWaveMoodSettingsUpdated(
        mode: MoodWaveMode.calm,
        radius: 0.75,
        targetValence: 0.2,
        targetArousal: -0.1,
      ),
    );
    await _until(
      () =>
          (harness.bloc.state.waveSession?.source as MoodWaveSource?)?.mode ==
          MoodWaveMode.calm,
    );
    harness.player.index.add(1);
    await _until(() => harness.player.appendCalls == 1);

    final source = harness.bloc.state.waveSession!.source as MoodWaveSource;
    expect(source.mode, MoodWaveMode.calm);
    expect(source.radius, 0.75);
    expect(source.userTarget, MoodPoint(valence: 0.2, arousal: -0.1));
  });

  test(
    'stop removes future Wave entries but keeps current and repeat',
    () async {
      final harness = await _Harness.create(trackCount: 12);
      addTearDown(harness.close);
      harness.bloc.add(PlayerRepeatCycled());
      await _until(() => harness.bloc.state.loopMode == PlaybackLoopMode.all);
      harness.start();
      await _until(() => harness.bloc.state.isMoodWaveActive);
      final currentBeforeStop = harness.bloc.state.currentTrack;

      harness.bloc.add(PlayerMoodWaveStopped());
      await _until(() => !harness.bloc.state.isMoodWaveActive);
      harness.player.index.add(1);
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(harness.bloc.state.queue, [currentBeforeStop]);
      expect(harness.bloc.state.queueProvenance, [isA<QueueEntryProvenance>()]);
      expect(harness.player.appendCalls, 0);
      expect(harness.moods.loadCalls, 1);
      expect(harness.bloc.state.loopMode, PlaybackLoopMode.all);
    },
  );

  test(
    'start replaces a manual queue and stop keeps only current Wave track',
    () async {
      final harness = await _Harness.create(trackCount: 12);
      addTearDown(harness.close);
      final manual = [
        _track('manual-0'),
        _track('manual-1'),
        _track('manual-2'),
      ];
      harness.bloc.add(PlayerQueueSet(manual, autoPlay: false));
      await _until(() => harness.bloc.state.queue.length == manual.length);

      harness.start(autoPlay: true);
      await _until(
        () =>
            harness.bloc.state.queue.length == 5 &&
            !harness.bloc.state.isWaveGenerating,
      );
      final sessionId = harness.bloc.state.waveSession!.id;
      expect(
        harness.bloc.state.queue.map((track) => track.id).toSet(),
        isNot(containsAll(manual.map((track) => track.id))),
      );
      expect(
        harness.bloc.state.queueProvenance,
        everyElement(
          isA<QueueEntryProvenance>().having(
            (value) => value.waveSessionId,
            'waveSessionId',
            sessionId,
          ),
        ),
      );
      expect(harness.player.playCalls, 1);
      final current = harness.bloc.state.currentTrack;

      harness.bloc.add(PlayerWaveStopped());
      await _until(() => !harness.bloc.state.isWaveActive);

      expect(harness.bloc.state.queue, [current]);
    },
  );

  test(
    'long manual queue is replaced by the first Wave batch immediately',
    () async {
      final harness = await _Harness.create(trackCount: 12);
      addTearDown(harness.close);
      final manual = List.generate(5, (index) => _track('manual-$index'));
      harness.bloc.add(PlayerQueueSet(manual, autoPlay: false));
      await _until(() => harness.bloc.state.queue.length == manual.length);

      harness.start();
      await _until(
        () =>
            harness.bloc.state.isWaveActive &&
            !harness.bloc.state.isWaveGenerating,
      );

      expect(harness.moods.loadCalls, 1);
      expect(harness.player.appendCalls, 0);
      expect(
        harness.bloc.state.waveContinuationStatus,
        WaveContinuationStatus.ready,
      );
      expect(harness.bloc.state.queue, hasLength(5));
      expect(
        harness.bloc.state.queue.map((track) => track.id),
        isNot(containsAll(manual.map((track) => track.id))),
      );
      expect(
        harness.bloc.state.queueProvenance,
        everyElement(
          isA<QueueEntryProvenance>().having(
            (value) => value.waveSessionId,
            'waveSessionId',
            harness.bloc.state.waveSession!.id,
          ),
        ),
      );
    },
  );

  test('exhausted pool starts a new cycle and allows cooled repeats', () async {
    final harness = await _Harness.create(trackCount: 6);
    addTearDown(harness.close);
    harness.start();
    await _until(() => harness.bloc.state.queue.length == 5);

    harness.player.index.add(1);
    await _until(() => harness.player.appendCalls == 1);
    expect(harness.bloc.state.queue, hasLength(6));

    harness.player.index.add(2);
    await _until(() => harness.player.appendCalls == 2);

    expect(harness.bloc.state.isWaveActive, isTrue);
    expect(harness.bloc.state.isWaveWaiting, isFalse);
    expect(harness.bloc.state.queue.length, greaterThan(6));
    expect(
      harness.bloc.state.queue.map((track) => track.id).toSet().length,
      lessThan(harness.bloc.state.queue.length),
    );
  });

  test('logical future queue follows shuffle playback order', () {
    final tracks = List.generate(4, (index) => _track('track-$index'));
    final state = PlayerState(
      queue: tracks,
      currentIndex: 2,
      currentTrack: tracks[2],
      isShuffleEnabled: true,
      shuffleIndices: const [1, 2, 0, 3],
    );

    expect(state.futureQueueIndices, [0, 3]);
    expect(state.futureQueueTrackIds, {'track-0', 'track-3'});
    expect(state.remainingQueueCount, 2);
  });

  test(
    'stop removes only logical future Wave entries while shuffled',
    () async {
      final harness = await _Harness.create(
        trackCount: 5,
        config: const MoodWaveConfig(remainingQueueThreshold: 0),
      );
      addTearDown(harness.close);
      harness.start();
      await _until(() => harness.bloc.state.queue.length == 5);

      harness.player.nextShuffleIndices = const [0, 2, 1, 4, 3];
      harness.bloc.add(PlayerShuffleToggled());
      await _until(() => harness.bloc.state.isShuffleEnabled);
      harness.player.index.add(2);
      await _until(() => harness.bloc.state.currentIndex == 2);

      harness.bloc.add(PlayerWaveStopped());
      await _until(() => !harness.bloc.state.isWaveActive);

      expect(harness.bloc.state.queue.map((track) => track.id), [
        'track-0',
        'track-2',
      ]);
      expect(harness.bloc.state.currentIndex, 1);
      expect(harness.bloc.state.currentTrack?.id, 'track-2');
    },
  );

  test(
    'zero candidates keeps an active waiting Wave and supports retry',
    () async {
      final harness = await _Harness.create(trackCount: 0);
      addTearDown(harness.close);
      final existing = _track('existing');
      harness.bloc.add(PlayerQueueSet([existing], autoPlay: false));
      await _until(() => harness.bloc.state.queue.isNotEmpty);

      harness.start();
      await _until(
        () =>
            harness.moods.loadCalls == 1 &&
            !harness.bloc.state.isMoodWaveGenerating,
      );

      expect(harness.bloc.state.queue, [existing]);
      expect(harness.bloc.state.isMoodWaveActive, isTrue);
      expect(harness.bloc.state.isWaveWaiting, isTrue);
      expect(harness.player.appendCalls, 0);

      harness.bloc.add(PlayerWaveMoodSettingsUpdated(radius: 0.8));
      await _until(() => harness.moods.loadCalls == 2);
      expect(harness.bloc.state.isWaveWaiting, isTrue);

      harness.bloc.add(PlayerWaveRetryRequested());
      await _until(() => harness.moods.loadCalls == 3);
      expect(harness.bloc.state.isMoodWaveActive, isTrue);
      expect(harness.bloc.state.isWaveWaiting, isTrue);
    },
  );
}

class _Harness {
  _Harness({required this.player, required this.moods, required this.bloc});

  final _FakeAudioPlayer player;
  final _MoodMapMemory moods;
  final PlayerBloc bloc;

  static Future<_Harness> create({
    required int trackCount,
    MoodWaveConfig config = const MoodWaveConfig(),
  }) async {
    final player = _FakeAudioPlayer();
    final moods = _MoodMapMemory(
      List.generate(trackCount, (index) => _moodTrack('track-$index', index)),
    );
    final sessions = _MemorySessions();
    final engine = MoodWaveEngine(
      moods: moods,
      globalEmbeddings: _EmptyGlobalEmbeddings(),
      temporalEmbeddings: _EmptyTemporalEmbeddings(),
      registry: MusicAnalysisModelRegistry(_EmptyAnalysisClient()),
      config: config,
    );
    final bloc = PlayerBloc(
      service: player,
      saveListeningSummary: SaveListeningSummaryUseCase(
        repo: _NoopListeningSummaries(),
      ),
      checkpoints: _NoopCheckpoints(),
      buildQueue: BuildPlaybackQueueUseCase(),
      restorePlayback: RestorePlaybackSessionUseCase(
        sessions: sessions,
        tracks: _EmptyTracks(),
      ),
      sessions: sessions,
      skipTrack: const SkipTrackUseCase(),
      commands: PlaybackCommandBusImpl(),
      listeningTracker: ListeningTracker.disabled(),
      moodWaveEngine: engine,
    );
    await _until(() => !bloc.state.isRestoring);
    return _Harness(player: player, moods: moods, bloc: bloc);
  }

  void start({bool autoPlay = false}) => bloc.add(
    PlayerMoodWaveStarted(
      targetValence: 0,
      targetArousal: 0,
      radius: 0.5,
      mode: MoodWaveMode.stay,
      autoPlay: autoPlay,
    ),
  );

  Future<void> close() async {
    await bloc.close();
    await player.close();
  }
}

Future<void> _until(bool Function() condition) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    if (condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  fail('Condition was not reached');
}

Track _track(String id) => Track(
  id: id,
  title: id,
  artists: const [Artist(id: 'artist', name: 'Artist')],
  duration: const Duration(minutes: 3),
  source: Source(type: SourceType.localFile, originalUrl: '/music/$id.mp3'),
  addedAt: DateTime.utc(2026),
  filePath: '$id.mp3',
);

MoodMapTrack _moodTrack(String id, int index) => MoodMapTrack(
  track: _track(id),
  modelAnalysis: TrackEmotionAnalysis(
    id: 'emotion-$id',
    trackId: id,
    representation: MusicAnalysisRepresentation.audioEmotionGlobal.apiName,
    modelId: 'emotion',
    modelVersion: '1',
    preprocessingVersion: '1',
    contentRevision: 'audio:0',
    audioRevision: 0,
    valence: index * 0.01,
    arousal: index * 0.01,
    moodDistribution: MoodDistribution(const {'calm': 1}),
    analyzedAt: DateTime.utc(2026),
  ),
);

class _MoodMapMemory implements MoodMapRepository {
  _MoodMapMemory(this.tracks);

  final List<MoodMapTrack> tracks;
  int loadCalls = 0;
  int? holdCall;
  Completer<void>? hold;

  @override
  Future<List<MoodMapTrack>> loadTracks() async {
    loadCalls++;
    if (loadCalls == holdCall) await hold?.future;
    return tracks;
  }

  @override
  Future<void> resetPersonalPosition(String trackId) async {}
  @override
  Future<void> savePersonalPosition(PersonalMoodAdjustment adjustment) async {}
  @override
  Stream<void> watchChanges() => const Stream.empty();
}

class _FakeAudioPlayer implements AudioPlayerPort {
  final position = StreamController<Duration>.broadcast();
  final duration = StreamController<Duration?>.broadcast();
  final playing = StreamController<bool>.broadcast();
  final index = StreamController<int?>.broadcast();
  final processing = StreamController<PlaybackProcessingState>.broadcast();
  List<Track> queue = [];
  List<Track> appended = [];
  int appendCalls = 0;
  int playCalls = 0;
  PlaybackLoopMode loopMode = PlaybackLoopMode.off;
  List<int>? nextShuffleIndices;

  @override
  Stream<Duration> get positionStream => position.stream;
  @override
  Stream<Duration?> get durationStream => duration.stream;
  @override
  Stream<int?> get indexStream => index.stream;
  @override
  Stream<bool> get playingStream => playing.stream;
  @override
  Stream<PlaybackProcessingState> get processingStream => processing.stream;
  @override
  List<int>? get shuffleIndices => nextShuffleIndices;

  @override
  Future<void> appendQueue(List<Track> tracks) async {
    appendCalls++;
    appended.addAll(tracks);
    queue.addAll(tracks);
  }

  @override
  Future<void> removeQueueItemsAt(List<int> indices) async {
    final descending = indices.toSet().toList()
      ..sort((left, right) => right.compareTo(left));
    for (final index in descending) {
      if (index >= 0 && index < queue.length) queue.removeAt(index);
    }
    nextShuffleIndices = null;
  }

  @override
  Future<void> clearQueue() async => queue.clear();
  @override
  Future<void> dispose() async {}
  @override
  Future<void> pause() async => playing.add(false);
  @override
  Future<void> play() async {
    playCalls++;
    playing.add(true);
  }

  @override
  Future<void> seek(Duration value) async => position.add(value);
  @override
  Future<void> seekToIndex(int value) async => index.add(value);
  @override
  Future<void> setLoopMode(PlaybackLoopMode mode) async => loopMode = mode;
  @override
  Future<void> setQueue(
    List<Track> tracks, {
    int index = 0,
    Duration initialPosition = Duration.zero,
  }) async => queue = List.of(tracks);
  @override
  Future<void> setShuffleModeEnabled(bool enabled) async {}
  @override
  Future<void> skipToNext() async {}
  @override
  Future<void> skipToPrevious() async {}

  Future<void> close() async {
    await position.close();
    await duration.close();
    await playing.close();
    await index.close();
    await processing.close();
  }
}

class _EmptyGlobalEmbeddings implements TrackEmbeddingRepository {
  @override
  Future<void> deleteForTrack(String trackId) async {}
  @override
  Future<TrackEmbedding?> get({
    required String trackId,
    required TrackEmbeddingModality modality,
    required String modelId,
    required String modelVersion,
    required TrackEmbeddingProvider provider,
    String preprocessingVersion = TrackEmbedding.legacyPreprocessingVersion,
    String? contentRevision,
  }) async => null;
  @override
  Future<List<TrackEmbedding>> getBySpace({
    required TrackEmbeddingModality modality,
    required String modelId,
    required String modelVersion,
    required String preprocessingVersion,
    required TrackEmbeddingProvider provider,
  }) async => const [];
  @override
  Future<List<TrackEmbedding>> getForTrack(String trackId) async => const [];
  @override
  Future<void> save(TrackEmbedding embedding) async {}
}

class _EmptyTemporalEmbeddings implements TrackTemporalEmbeddingRepository {
  @override
  Future<TrackTemporalEmbedding?> get({
    required String trackId,
    required String representation,
    required String modelId,
    required String modelVersion,
    required String preprocessingVersion,
    required TrackEmbeddingProvider provider,
    required int audioRevision,
  }) async => null;
  @override
  Future<List<TrackTemporalEmbedding>> getBySpace({
    required String representation,
    required String modelId,
    required String modelVersion,
    required String preprocessingVersion,
    required TrackEmbeddingProvider provider,
  }) async => const [];
  @override
  Future<bool> save(TrackTemporalEmbedding embedding) async => true;
}

class _EmptyAnalysisClient implements MusicAnalysisClient {
  @override
  String get baseUrl => 'memory://';
  @override
  Future<MusicAnalysisResponse> analyze({
    required String trackId,
    required String filePath,
    String? contentIdentity,
    String? lyrics,
    required Set<MusicAnalysisRepresentation> requestedRepresentations,
  }) => throw UnimplementedError();
  @override
  Future<MusicAnalysisModels> getModels() async =>
      const MusicAnalysisModels(schemaVersion: '1', models: []);
}

class _NoopListeningSummaries implements ListeningSummaryRepository {
  @override
  Future<ListeningStatsSummary> aggregate({required DateTime from}) async =>
      const ListeningStatsSummary(
        totalTracks: 0,
        totalTime: Duration.zero,
        uniqueArtists: 0,
        bySource: {},
      );
  @override
  Future<void> clear() async {}
  @override
  Future<List<String>> getRecentTrackIds({int limit = 20}) async => const [];
  @override
  Future<void> save(ListeningSummary record) async {}
  @override
  Stream<void> watchChanges() => const Stream.empty();
}

class _NoopCheckpoints implements ListeningCheckpointRepository {
  @override
  Future<void> clear(String id) async {}
  @override
  Future<ListeningCheckpoint?> load() async => null;
  @override
  Future<ListeningCheckpoint> save(Track track, Duration listenedDuration) =>
      throw UnimplementedError();
}

class _MemorySessions implements PlaybackSessionRepository {
  PlaybackSession? value;
  @override
  Future<void> clear() async => value = null;
  @override
  Future<PlaybackSession?> load() async => value;
  @override
  Future<void> replace(PlaybackSession session) async => value = session;
  @override
  Future<void> updatePlayback(PlaybackSession session) async => value = session;
}

class _EmptyTracks implements TrackRepository {
  @override
  Future<List<Track>> getTracks() async => const [];
  @override
  Future<Track?> getTrackById(String id) async => null;
  @override
  Future<List<Track>> getTracksByIds(List<String> ids) async => const [];
  @override
  Future<List<Track>> searchTracks(
    String query, {
    required int limit,
    required int offset,
  }) async => const [];
  @override
  Future<void> updateMetadata(Track track) async {}
  @override
  Stream<void> watchChanges() => const Stream.empty();
}
