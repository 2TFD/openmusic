import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/domain/entities/artist.dart';
import 'package:openmusic/layers/domain/entities/listening_summary.dart';
import 'package:openmusic/layers/domain/entities/listening_event.dart';
import 'package:openmusic/layers/domain/entities/playback_session.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/repositories/audio_player_port.dart';
import 'package:openmusic/layers/domain/repositories/listening_checkpoint_repository.dart';
import 'package:openmusic/layers/domain/repositories/listening_event_repository.dart';
import 'package:openmusic/layers/domain/repositories/listening_summary_repository.dart';
import 'package:openmusic/layers/domain/repositories/playback_session_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_repository.dart';
import 'package:openmusic/layers/domain/usecases/build_playback_queue_use_case.dart';
import 'package:openmusic/layers/domain/usecases/save_listening_summary_use_case.dart';
import 'package:openmusic/layers/domain/usecases/restore_playback_session_use_case.dart';
import 'package:openmusic/layers/domain/usecases/skip_track_use_case.dart';
import 'package:openmusic/layers/domain/usecases/save_listening_event_use_case.dart';
import 'package:openmusic/layers/domain/services/listening_tracker.dart';
import 'package:openmusic/core/services/audio_player/playback_command_bus_impl.dart';
import 'package:openmusic/layers/presentation/blocs/player/player_bloc.dart';

void main() {
  test(
    'records played deltas, ignores seek jump, and flushes on close',
    () async {
      final player = _FakeAudioPlayer();
      final records = _FakeListeningSummaryRepository();
      final checkpoints = _FakeCheckpointRepository();
      final sessions = _FakePlaybackSessionRepository();
      final bloc = PlayerBloc(
        service: player,
        saveListeningSummary: SaveListeningSummaryUseCase(repo: records),
        checkpoints: checkpoints,
        buildQueue: BuildPlaybackQueueUseCase(),
        restorePlayback: RestorePlaybackSessionUseCase(
          sessions: sessions,
          tracks: _FakeTrackRepository(),
        ),
        sessions: sessions,
        skipTrack: const SkipTrackUseCase(),
        commands: PlaybackCommandBusImpl(),
        listeningTracker: ListeningTracker.disabled(),
      );
      bloc.add(PlayerQueueSet([_track()], autoPlay: false));
      await _pump();
      player.playing.add(true);
      await _pump();

      for (var second = 0; second <= 31; second++) {
        player.position.add(Duration(seconds: second));
      }
      await _pump();
      expect(
        checkpoints.checkpoint?.listenedDuration,
        const Duration(seconds: 30),
      );

      bloc.add(PlayerSeeked(const Duration(seconds: 100)));
      await _pump();
      player.position.add(const Duration(seconds: 101));
      await _pump();
      await bloc.close();
      await player.close();

      expect(records.saved, hasLength(1));
      expect(
        records.saved.single.listenedDuration,
        const Duration(seconds: 32),
      );
    },
  );

  test(
    'PlayerBloc persists a confirmed early skip independently of ListeningSummary',
    () async {
      final player = _FakeAudioPlayer();
      final records = _FakeListeningSummaryRepository();
      final events = _FakeListeningEventRepository();
      final checkpoints = _FakeCheckpointRepository();
      final sessions = _FakePlaybackSessionRepository();
      final bloc = PlayerBloc(
        service: player,
        saveListeningSummary: SaveListeningSummaryUseCase(repo: records),
        checkpoints: checkpoints,
        buildQueue: BuildPlaybackQueueUseCase(),
        restorePlayback: RestorePlaybackSessionUseCase(
          sessions: sessions,
          tracks: _FakeTrackRepository(),
        ),
        sessions: sessions,
        skipTrack: const SkipTrackUseCase(),
        commands: PlaybackCommandBusImpl(),
        listeningTracker: ListeningTracker(
          saveEvent: SaveListeningEventUseCase(events),
          sessionId: 'runtime-session',
        ),
      );
      bloc.add(
        PlayerQueueSet([_track('track-1'), _track('track-2')], autoPlay: false),
      );
      await _pump();
      player.playing.add(true);
      player.position.add(Duration.zero);
      player.position.add(const Duration(seconds: 5));
      await _pump();

      bloc.add(PlayerSkippedNext());
      await _pump();

      final skip = events.saved.singleWhere(
        (event) => event.type == ListeningEventType.skipNext,
      );
      expect(skip.trackId, 'track-1');
      expect(skip.listenedMs, 5000);
      expect(skip.transitionReason, ListeningTransitionReason.userNext);
      expect(
        events.saved
            .singleWhere(
              (event) => event.type == ListeningEventType.trackChanged,
            )
            .trackId,
        'track-2',
      );
      expect(records.saved, isEmpty, reason: 'legacy threshold remains 30 sec');

      await bloc.close();
      await player.close();
    },
  );

  test(
    'PlayerBloc keeps pre-reset position for natural autoplay completion',
    () async {
      final player = _FakeAudioPlayer();
      final events = _FakeListeningEventRepository();
      final checkpoints = _FakeCheckpointRepository();
      final sessions = _FakePlaybackSessionRepository();
      final bloc = PlayerBloc(
        service: player,
        saveListeningSummary: SaveListeningSummaryUseCase(
          repo: _FakeListeningSummaryRepository(),
        ),
        checkpoints: checkpoints,
        buildQueue: BuildPlaybackQueueUseCase(),
        restorePlayback: RestorePlaybackSessionUseCase(
          sessions: sessions,
          tracks: _FakeTrackRepository(),
        ),
        sessions: sessions,
        skipTrack: const SkipTrackUseCase(),
        commands: PlaybackCommandBusImpl(),
        listeningTracker: ListeningTracker(
          saveEvent: SaveListeningEventUseCase(events),
          sessionId: 'runtime-session',
        ),
      );
      bloc.add(
        PlayerQueueSet([_track('track-1'), _track('track-2')], autoPlay: false),
      );
      await _pump();
      player.playing.add(true);
      player.position.add(Duration.zero);
      player.position.add(const Duration(minutes: 2, seconds: 59));
      await _pump();

      player.position.add(Duration.zero);
      player.index.add(1);
      await _pump();

      final completed = events.saved.singleWhere(
        (event) => event.type == ListeningEventType.trackCompleted,
      );
      expect(completed.trackId, 'track-1');
      expect(completed.transitionReason, ListeningTransitionReason.natural);

      await bloc.close();
      await player.close();
    },
  );
}

class _FakeCheckpointRepository implements ListeningCheckpointRepository {
  ListeningCheckpoint? checkpoint;

  @override
  Future<ListeningCheckpoint> save(
    Track track,
    Duration listenedDuration,
  ) async {
    return checkpoint = ListeningCheckpoint(
      id: 'checkpoint-1',
      trackId: track.id,
      trackTitle: track.title,
      artistName: track.artists.map((artist) => artist.name).join(', '),
      sourceType: track.source.type,
      listenedDuration: listenedDuration,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<ListeningCheckpoint?> load() async => checkpoint;

  @override
  Future<void> clear(String id) async => checkpoint = null;
}

Future<void> _pump() => Future<void>.delayed(const Duration(milliseconds: 10));

Track _track([String id = 'track-1']) => Track(
  id: id,
  title: 'Track $id',
  artists: const [Artist(id: 'artist-1', name: 'Artist')],
  duration: const Duration(minutes: 3),
  source: const Source(
    type: SourceType.localFile,
    originalUrl: '/music/track.mp3',
  ),
  addedAt: DateTime.utc(2026),
  filePath: '$id.mp3',
);

class _FakeAudioPlayer implements AudioPlayerPort {
  final position = StreamController<Duration>.broadcast();
  final duration = StreamController<Duration?>.broadcast();
  final playing = StreamController<bool>.broadcast();
  final index = StreamController<int?>.broadcast();
  final processing = StreamController<PlaybackProcessingState>.broadcast();

  @override
  Stream<Duration> get positionStream => position.stream;
  @override
  Stream<Duration?> get durationStream => duration.stream;
  @override
  Stream<bool> get playingStream => playing.stream;
  @override
  Stream<int?> get indexStream => index.stream;
  @override
  Stream<PlaybackProcessingState> get processingStream => processing.stream;
  @override
  List<int>? get shuffleIndices => null;

  @override
  Future<void> seek(Duration value) async => position.add(value);
  @override
  Future<void> pause() async => playing.add(false);
  @override
  Future<void> play() async => playing.add(true);
  @override
  Future<void> seekToIndex(int index) async => this.index.add(index);
  @override
  Future<void> skipToNext() async => index.add(1);
  @override
  Future<void> skipToPrevious() async {}
  @override
  Future<void> setLoopMode(PlaybackLoopMode mode) async {}
  @override
  Future<void> setQueue(
    List<Track> tracks, {
    int index = 0,
    Duration initialPosition = Duration.zero,
  }) async {}
  @override
  Future<void> appendQueue(List<Track> tracks) async {}
  @override
  Future<void> removeQueueItemsAt(List<int> indices) async {}
  @override
  Future<void> clearQueue() async => playing.add(false);
  @override
  Future<void> setShuffleModeEnabled(bool enabled) async {}
  @override
  Future<void> dispose() async {}

  Future<void> close() async {
    await position.close();
    await duration.close();
    await playing.close();
    await index.close();
    await processing.close();
  }
}

class _FakePlaybackSessionRepository implements PlaybackSessionRepository {
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

class _FakeTrackRepository implements TrackRepository {
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

class _FakeListeningSummaryRepository implements ListeningSummaryRepository {
  final saved = <ListeningSummary>[];

  @override
  Future<void> save(ListeningSummary record) async => saved.add(record);
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
  Stream<void> watchChanges() => const Stream.empty();
}

class _FakeListeningEventRepository implements ListeningEventRepository {
  final saved = <ListeningEvent>[];

  @override
  Future<void> save(ListeningEvent event) async => saved.add(event);

  @override
  Future<List<ListeningEvent>> getAll() async => List.of(saved);

  @override
  Future<List<ListeningEvent>> getForTrack(String trackId) async =>
      saved.where((event) => event.trackId == trackId).toList();
}
