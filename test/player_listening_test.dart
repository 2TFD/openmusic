import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/domain/entities/artist.dart';
import 'package:openmusic/layers/domain/entities/play_record.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/repositories/audio_player_port.dart';
import 'package:openmusic/layers/domain/repositories/play_record_repository.dart';
import 'package:openmusic/layers/domain/usecases/build_playback_queue_use_case.dart';
import 'package:openmusic/layers/domain/usecases/save_statistic_use_case.dart';
import 'package:openmusic/layers/presentation/blocs/player/player_bloc.dart';

void main() {
  test(
    'records played deltas, ignores seek jump, and flushes on close',
    () async {
      final player = _FakeAudioPlayer();
      final records = _FakePlayRecordRepository();
      final bloc = PlayerBloc(
        service: player,
        recordPlay: SaveRecordPlayUseCase(repo: records),
        buildQueue: BuildPlaybackQueueUseCase(),
      );
      bloc.add(PlayerQueueSet([_track()], autoPlay: false));
      await _pump();
      player.playing.add(true);
      await _pump();

      for (var second = 0; second <= 31; second++) {
        player.position.add(Duration(seconds: second));
      }
      await _pump();

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
}

Future<void> _pump() => Future<void>.delayed(const Duration(milliseconds: 10));

Track _track() => Track(
  id: 'track-1',
  title: 'Track',
  artists: const [Artist(id: 'artist-1', name: 'Artist')],
  duration: const Duration(minutes: 3),
  source: const Source(
    type: SourceType.localFile,
    originalUrl: '/music/track.mp3',
  ),
  addedAt: DateTime.utc(2026),
  filePath: 'track.mp3',
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
  Future<void> skipToNext() async {}
  @override
  Future<void> skipToPrevious() async {}
  @override
  Future<void> setLoopMode(PlaybackLoopMode mode) async {}
  @override
  Future<void> setQueue(List<Track> tracks, {int index = 0}) async {}
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

class _FakePlayRecordRepository implements PlayRecordRepository {
  final saved = <PlayRecord>[];

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
  Future<void> clear() async {}
  @override
  Future<List<String>> getRecentTrackIds({int limit = 20}) async => const [];
  @override
  Stream<List<PlayRecord>> watchPlayRecord() => const Stream.empty();
}
