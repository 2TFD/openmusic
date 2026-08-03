import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/core/services/audio_player/playback_command_bus_impl.dart';
import 'package:openmusic/layers/domain/entities/artist.dart';
import 'package:openmusic/layers/domain/entities/play_record.dart';
import 'package:openmusic/layers/domain/entities/playback_session.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/repositories/audio_player_port.dart';
import 'package:openmusic/layers/domain/repositories/listening_checkpoint_repository.dart';
import 'package:openmusic/layers/domain/repositories/play_record_repository.dart';
import 'package:openmusic/layers/domain/repositories/playback_command_bus.dart';
import 'package:openmusic/layers/domain/repositories/playback_session_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_repository.dart';
import 'package:openmusic/layers/domain/usecases/build_playback_queue_use_case.dart';
import 'package:openmusic/layers/domain/usecases/restore_playback_session_use_case.dart';
import 'package:openmusic/layers/domain/usecases/save_statistic_use_case.dart';
import 'package:openmusic/layers/domain/usecases/skip_track_use_case.dart';
import 'package:openmusic/layers/presentation/blocs/player/player_bloc.dart';

/// Экран блокировки, наушники и Bluetooth обязаны вести себя ровно так же, как
/// кнопки в приложении: политика живёт в SkipTrackUseCase, а не в адаптере.
void main() {
  test('system previous restarts the track past the threshold', () async {
    final harness = await _Harness.playingSecondTrack();

    harness.player.position.add(const Duration(seconds: 10));
    await _pump();

    harness.commands.send(const SkipPreviousRequested());
    await _pump();

    expect(harness.player.seekCalls, [Duration.zero]);
    expect(harness.player.skipPreviousCalls, 0);

    await harness.dispose();
  });

  test('system previous steps back within the threshold', () async {
    final harness = await _Harness.playingSecondTrack();

    harness.player.position.add(const Duration(seconds: 1));
    await _pump();

    harness.commands.send(const SkipPreviousRequested());
    await _pump();

    expect(harness.player.skipPreviousCalls, 1);
    expect(harness.player.seekCalls, isEmpty);

    await harness.dispose();
  });

  test('system next is ignored at the end of the queue', () async {
    final harness = await _Harness.playingSecondTrack();

    harness.commands.send(const SkipNextRequested());
    await _pump();

    expect(harness.player.skipNextCalls, 0);

    await harness.dispose();
  });

  test('system seek does not count as listened time', () async {
    final harness = await _Harness.playingSecondTrack();

    harness.player.playing.add(true);
    await _pump();
    // 1..40: первый тик только ставит точку отсчёта, дальше 39 секунд дельт.
    for (var second = 1; second <= 40; second++) {
      harness.player.position.add(Duration(seconds: second));
    }
    await _pump();

    harness.commands.send(const SeekRequested(Duration(minutes: 2)));
    await _pump();
    harness.player.position.add(const Duration(minutes: 2, seconds: 1));
    await _pump();

    await harness.bloc.close();
    // 39 + 1: перемотанные 80 секунд в статистику не попали.
    expect(harness.records.saved.single.listenedDuration.inSeconds, 40);

    await harness.player.close();
    await harness.commands.dispose();
  });
}

class _Harness {
  _Harness({
    required this.bloc,
    required this.player,
    required this.commands,
    required this.records,
  });

  final PlayerBloc bloc;
  final _FakeAudioPlayer player;
  final PlaybackCommandBus commands;
  final _RecordingRecords records;

  /// Очередь из двух треков, текущий — второй: есть предыдущий, нет следующего.
  static Future<_Harness> playingSecondTrack() async {
    final player = _FakeAudioPlayer();
    final commands = PlaybackCommandBusImpl();
    final records = _RecordingRecords();
    final sessions = _MemorySessions();
    final tracks = [_track('a'), _track('b')];
    final bloc = PlayerBloc(
      service: player,
      recordPlay: SaveRecordPlayUseCase(repo: records),
      checkpoints: _NoopCheckpoints(),
      buildQueue: BuildPlaybackQueueUseCase(),
      restorePlayback: RestorePlaybackSessionUseCase(
        sessions: sessions,
        tracks: _NoopTracks(),
      ),
      sessions: sessions,
      skipTrack: const SkipTrackUseCase(),
      commands: commands,
    );
    await _pump();
    bloc.add(PlayerQueueSet(tracks, startTrack: tracks[1], autoPlay: false));
    await _pump();
    player.reset();
    return _Harness(
      bloc: bloc,
      player: player,
      commands: commands,
      records: records,
    );
  }

  Future<void> dispose() async {
    await bloc.close();
    await player.close();
    await commands.dispose();
  }
}

Future<void> _pump() => Future<void>.delayed(const Duration(milliseconds: 10));

Track _track(String id) => Track(
  id: id,
  title: 'Track $id',
  artists: const [Artist(id: 'artist-1', name: 'Artist')],
  duration: const Duration(minutes: 3),
  source: Source(type: SourceType.localFile, originalUrl: '/music/$id.mp3'),
  addedAt: DateTime.utc(2026),
  filePath: '$id.mp3',
);

class _FakeAudioPlayer implements AudioPlayerPort {
  final position = StreamController<Duration>.broadcast();
  final duration = StreamController<Duration?>.broadcast();
  final playing = StreamController<bool>.broadcast();
  final index = StreamController<int?>.broadcast();
  final processing = StreamController<PlaybackProcessingState>.broadcast();

  final List<Duration> seekCalls = [];
  int skipNextCalls = 0;
  int skipPreviousCalls = 0;

  void reset() {
    seekCalls.clear();
    skipNextCalls = 0;
    skipPreviousCalls = 0;
  }

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
  Future<void> seek(Duration value) async {
    seekCalls.add(value);
    position.add(value);
  }

  @override
  Future<void> skipToNext() async => skipNextCalls++;
  @override
  Future<void> skipToPrevious() async => skipPreviousCalls++;

  @override
  Future<void> play() async => playing.add(true);
  @override
  Future<void> pause() async => playing.add(false);
  @override
  Future<void> seekToIndex(int value) async => index.add(value);
  @override
  Future<void> setLoopMode(PlaybackLoopMode mode) async {}
  @override
  Future<void> setShuffleModeEnabled(bool enabled) async {}
  @override
  Future<void> setQueue(
    List<Track> tracks, {
    int index = 0,
    Duration initialPosition = Duration.zero,
  }) async {}
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

class _RecordingRecords implements PlayRecordRepository {
  final List<PlayRecord> saved = [];

  @override
  Future<void> save(PlayRecord record) async => saved.add(record);

  @override
  Future<PlayRecordSummary> aggregate({required DateTime from}) async =>
      const PlayRecordSummary(
        totalTracks: 0,
        totalTime: Duration.zero,
        uniqueArtists: 0,
        bySource: {},
      );

  @override
  Future<List<String>> getRecentTrackIds({int limit = 20}) async => const [];

  @override
  Future<void> clear() async => saved.clear();

  @override
  Stream<void> watchChanges() => const Stream.empty();
}

class _NoopCheckpoints implements ListeningCheckpointRepository {
  @override
  Future<ListeningCheckpoint?> load() async => null;

  @override
  Future<ListeningCheckpoint> save(Track track, Duration listened) async =>
      ListeningCheckpoint(
        id: 'checkpoint',
        trackId: track.id,
        trackTitle: track.title,
        artistName: 'Artist',
        sourceType: track.source.type,
        listenedDuration: listened,
        updatedAt: DateTime.utc(2026),
      );

  @override
  Future<void> clear(String id) async {}
}

class _MemorySessions implements PlaybackSessionRepository {
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

class _NoopTracks implements TrackRepository {
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
