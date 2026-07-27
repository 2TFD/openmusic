import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/domain/entities/artist.dart';
import 'package:openmusic/layers/domain/entities/play_record.dart';
import 'package:openmusic/layers/domain/entities/playback_session.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/repositories/audio_player_port.dart';
import 'package:openmusic/layers/domain/repositories/listening_checkpoint_repository.dart';
import 'package:openmusic/layers/domain/repositories/play_record_repository.dart';
import 'package:openmusic/layers/domain/repositories/playback_session_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_repository.dart';
import 'package:openmusic/layers/domain/usecases/build_playback_queue_use_case.dart';
import 'package:openmusic/layers/domain/usecases/restore_playback_session_use_case.dart';
import 'package:openmusic/layers/domain/usecases/save_statistic_use_case.dart';
import 'package:openmusic/layers/presentation/blocs/player/player_bloc.dart';

void main() {
  test(
    'cold restore loads the queue and always leaves playback paused',
    () async {
      final tracks = [_track('a'), _track('b')];
      final sessions = _MemorySessions(
        PlaybackSession(
          queueTrackIds: const ['a', 'b'],
          currentTrackId: 'b',
          currentQueuePosition: 1,
          position: const Duration(seconds: 40),
          shuffleEnabled: true,
          loopMode: PlaybackLoopMode.one,
          updatedAt: DateTime.utc(2026),
        ),
      );
      final player = _FakeAudioPlayer();
      final bloc = _bloc(player: player, sessions: sessions, tracks: tracks);
      addTearDown(() async {
        await bloc.close();
        await player.close();
      });

      final restored = await bloc.stream.firstWhere(
        (state) => !state.isRestoring,
      );

      expect(player.queue.map((track) => track.id), ['a', 'b']);
      expect(player.initialIndex, 1);
      expect(player.initialPosition, const Duration(seconds: 40));
      expect(player.loopMode, PlaybackLoopMode.one);
      expect(player.shuffleEnabled, isTrue);
      expect(player.pauseCalls, 1);
      expect(player.playCalls, 0);
      expect(restored.currentTrack?.id, 'b');
      expect(restored.position, const Duration(seconds: 40));
      expect(restored.isPlaying, isFalse);
    },
  );

  test('a cold start without a snapshot keeps the player empty', () async {
    final sessions = _MemorySessions(null);
    final player = _FakeAudioPlayer();
    final bloc = _bloc(player: player, sessions: sessions, tracks: const []);
    addTearDown(() async {
      await bloc.close();
      await player.close();
    });

    final restored = await bloc.stream.firstWhere(
      (state) => !state.isRestoring,
    );

    expect(restored.queue, isEmpty);
    expect(restored.currentTrack, isNull);
    expect(player.setQueueCalls, 0);
  });

  test('queue and seek changes are flushed to the session store', () async {
    final sessions = _MemorySessions(null);
    final player = _FakeAudioPlayer();
    final track = _track('a');
    final bloc = _bloc(player: player, sessions: sessions, tracks: [track]);
    addTearDown(() async {
      await bloc.close();
      await player.close();
    });
    await bloc.stream.firstWhere((state) => !state.isRestoring);

    bloc.add(PlayerQueueSet([track], autoPlay: false));
    bloc.add(PlayerSeeked(const Duration(seconds: 27)));
    bloc.add(PlayerSessionFlushRequested());
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(sessions.value!.queueTrackIds, ['a']);
    expect(sessions.value!.position, const Duration(seconds: 27));
  });

  test(
    'playback controls stay responsive while play future is pending',
    () async {
      final sessions = _MemorySessions(null);
      final player = _FakeAudioPlayer(holdPlay: true);
      final tracks = [_track('a'), _track('b')];
      final bloc = _bloc(player: player, sessions: sessions, tracks: tracks);
      addTearDown(() async {
        await bloc.close();
        await player.close();
      });
      await bloc.stream.firstWhere((state) => !state.isRestoring);

      final playing = bloc.stream.firstWhere((state) => state.isPlaying);
      bloc.add(PlayerQueueSet(tracks));
      expect((await playing).currentTrack?.id, 'a');

      final switched = bloc.stream.firstWhere(
        (state) => state.currentTrack?.id == 'b',
      );
      bloc.add(PlayerSkippedNext());
      expect((await switched).currentIndex, 1);

      final paused = bloc.stream.firstWhere((state) => !state.isPlaying);
      bloc.add(PlayerPlayPauseToggled());
      await paused;

      expect(player.playCalls, 1);
      expect(player.pauseCalls, 1);
    },
  );

  test('next and previous availability follows the shuffle order', () {
    final tracks = [_track('a'), _track('b')];
    final state = PlayerState(
      queue: tracks,
      currentTrack: tracks[1],
      currentIndex: 1,
      isShuffleEnabled: true,
      shuffleIndices: const [1, 0],
    );

    expect(state.hasPrev, isFalse);
    expect(state.hasNext, isTrue);
  });
}

PlayerBloc _bloc({
  required _FakeAudioPlayer player,
  required _MemorySessions sessions,
  required List<Track> tracks,
}) => PlayerBloc(
  service: player,
  recordPlay: SaveRecordPlayUseCase(repo: _NoopRecords()),
  checkpoints: _NoopCheckpoints(),
  buildQueue: BuildPlaybackQueueUseCase(),
  restorePlayback: RestorePlaybackSessionUseCase(
    sessions: sessions,
    tracks: _MemoryTracks(tracks),
  ),
  sessions: sessions,
);

Track _track(String id) => Track(
  id: id,
  title: id,
  artists: const [Artist(id: 'artist', name: 'Artist')],
  duration: const Duration(minutes: 3),
  source: Source(type: SourceType.localFile, originalUrl: '/$id.mp3'),
  addedAt: DateTime.utc(2026),
  filePath: '$id.mp3',
);

class _FakeAudioPlayer implements AudioPlayerPort {
  _FakeAudioPlayer({this.holdPlay = false});

  final bool holdPlay;
  final _position = StreamController<Duration>.broadcast();
  final _duration = StreamController<Duration?>.broadcast();
  final _playing = StreamController<bool>.broadcast();
  final _index = StreamController<int?>.broadcast();
  final _processing = StreamController<PlaybackProcessingState>.broadcast();

  List<Track> queue = const [];
  int initialIndex = 0;
  Duration initialPosition = Duration.zero;
  PlaybackLoopMode loopMode = PlaybackLoopMode.off;
  bool shuffleEnabled = false;
  int pauseCalls = 0;
  int playCalls = 0;
  int setQueueCalls = 0;
  Completer<void>? _playCompleter;

  @override
  Stream<Duration> get positionStream => _position.stream;
  @override
  Stream<Duration?> get durationStream => _duration.stream;
  @override
  Stream<bool> get playingStream => _playing.stream;
  @override
  Stream<int?> get indexStream => _index.stream;
  @override
  Stream<PlaybackProcessingState> get processingStream => _processing.stream;
  @override
  List<int>? get shuffleIndices => shuffleEnabled ? [1, 0] : null;

  @override
  Future<void> setQueue(
    List<Track> tracks, {
    int index = 0,
    Duration initialPosition = Duration.zero,
  }) async {
    setQueueCalls++;
    queue = tracks;
    initialIndex = index;
    this.initialPosition = initialPosition;
  }

  @override
  Future<void> pause() async {
    pauseCalls++;
    _playing.add(false);
    final completer = _playCompleter;
    if (completer != null && !completer.isCompleted) completer.complete();
  }

  @override
  Future<void> play() {
    playCalls++;
    _playing.add(true);
    if (!holdPlay) return Future.value();
    _playCompleter = Completer<void>();
    return _playCompleter!.future;
  }

  @override
  Future<void> seek(Duration position) async => _position.add(position);
  @override
  Future<void> seekToIndex(int index) async {
    initialIndex = index;
    _index.add(index);
  }

  @override
  Future<void> skipToNext() async {
    if (initialIndex >= queue.length - 1) return;
    initialIndex++;
    _index.add(initialIndex);
  }

  @override
  Future<void> skipToPrevious() async {
    if (initialIndex <= 0) return;
    initialIndex--;
    _index.add(initialIndex);
  }

  @override
  Future<void> setLoopMode(PlaybackLoopMode mode) async => loopMode = mode;
  @override
  Future<void> setShuffleModeEnabled(bool enabled) async =>
      shuffleEnabled = enabled;
  @override
  Future<void> dispose() async {}

  Future<void> close() async {
    await _position.close();
    await _duration.close();
    await _playing.close();
    await _index.close();
    await _processing.close();
  }
}

class _MemorySessions implements PlaybackSessionRepository {
  _MemorySessions(this.value);

  PlaybackSession? value;

  @override
  Future<PlaybackSession?> load() async => value;
  @override
  Future<void> replace(PlaybackSession session) async => value = session;
  @override
  Future<void> updatePlayback(PlaybackSession session) async => value = session;
  @override
  Future<void> clear() async => value = null;
}

class _MemoryTracks implements TrackRepository {
  _MemoryTracks(List<Track> tracks)
    : tracks = {for (final track in tracks) track.id: track};

  final Map<String, Track> tracks;

  @override
  Future<List<Track>> getTracksByIds(List<String> ids) async =>
      ids.map((id) => tracks[id]).whereType<Track>().toList();
  @override
  Future<List<Track>> getTracks() async => tracks.values.toList();
  @override
  Future<Track?> getTrackById(String id) async => tracks[id];
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

class _NoopCheckpoints implements ListeningCheckpointRepository {
  @override
  Future<ListeningCheckpoint?> load() async => null;
  @override
  Future<void> clear(String id) async {}
  @override
  Future<ListeningCheckpoint> save(
    Track track,
    Duration listenedDuration,
  ) async => ListeningCheckpoint(
    id: 'checkpoint',
    trackId: track.id,
    trackTitle: track.title,
    artistName: 'Artist',
    sourceType: track.source.type,
    listenedDuration: listenedDuration,
    updatedAt: DateTime.now(),
  );
}

class _NoopRecords implements PlayRecordRepository {
  @override
  Future<void> save(PlayRecord record) async {}
  @override
  Future<PlayRecordSummary> aggregate({required DateTime from}) async =>
      const PlayRecordSummary(
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
  Stream<void> watchChanges() => const Stream.empty();
}
