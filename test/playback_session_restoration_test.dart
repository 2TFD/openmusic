import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/repositories/playback_session_repository_impl.dart';
import 'package:openmusic/layers/domain/entities/artist.dart';
import 'package:openmusic/layers/domain/entities/playback_session.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/repositories/audio_player_port.dart';
import 'package:openmusic/layers/domain/repositories/playback_session_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_repository.dart';
import 'package:openmusic/layers/domain/usecases/restore_playback_session_use_case.dart';

void main() {
  group('PlaybackSessionRepositoryImpl', () {
    late AppDatabase database;
    late PlaybackSessionRepositoryImpl repository;

    setUp(() async {
      database = AppDatabase(NativeDatabase.memory());
      repository = PlaybackSessionRepositoryImpl(database);
      for (final id in ['a', 'b', 'c']) {
        await database
            .into(database.trackTable)
            .insert(
              TrackTableCompanion.insert(
                id: id,
                title: id,
                sourceType: 'localFile',
                sourceUri: '/$id.mp3',
                pathToFile: Value('$id.mp3'),
              ),
            );
      }
    });

    tearDown(() => database.close());

    test('atomically replaces queue and updates playback fields', () async {
      await repository.replace(
        _session(
          ids: const ['a', 'b'],
          currentId: 'b',
          index: 1,
          position: const Duration(seconds: 12),
        ),
      );
      await repository.updatePlayback(
        _session(
          ids: const ['a', 'b'],
          currentId: 'a',
          index: 0,
          position: const Duration(seconds: 25),
          shuffle: true,
          loopMode: PlaybackLoopMode.all,
        ),
      );

      final updated = await repository.load();
      expect(updated!.queueTrackIds, ['a', 'b']);
      expect(updated.currentTrackId, 'a');
      expect(updated.currentQueuePosition, 0);
      expect(updated.position, const Duration(seconds: 25));
      expect(updated.shuffleEnabled, isTrue);
      expect(updated.loopMode, PlaybackLoopMode.all);

      await repository.replace(
        _session(ids: const ['b', 'c'], currentId: 'c', index: 1),
      );
      expect((await repository.load())!.queueTrackIds, ['b', 'c']);
    });

    test(
      'track deletion cascades queue rows and clears empty snapshot',
      () async {
        await repository.replace(
          _session(ids: const ['a', 'b'], currentId: 'b', index: 1),
        );

        await (database.delete(
          database.trackTable,
        )..where((row) => row.id.equals('b'))).go();
        final afterCurrentDeletion = await repository.load();
        expect(afterCurrentDeletion!.queueTrackIds, ['a']);
        expect(afterCurrentDeletion.currentTrackId, isNull);

        await (database.delete(
          database.trackTable,
        )..where((row) => row.id.equals('a'))).go();
        expect(await repository.load(), isNull);
        expect(
          await database.select(database.playbackSessionTable).get(),
          isEmpty,
        );
      },
    );
  });

  group('RestorePlaybackSessionUseCase', () {
    test('filters unavailable tracks and selects nearest next track', () async {
      final sessions = _MemorySessions(
        _session(
          ids: const ['a', 'missing', 'c', 'd'],
          currentId: 'missing',
          index: 1,
          position: const Duration(seconds: 40),
        ),
      );
      final useCase = RestorePlaybackSessionUseCase(
        sessions: sessions,
        tracks: _MemoryTracks([
          _track('a', ready: false),
          _track('c'),
          _track('d'),
        ]),
      );

      final restored = await useCase();

      expect(restored!.tracks.map((track) => track.id), ['c', 'd']);
      expect(restored.startIndex, 0);
      expect(restored.position, Duration.zero);
      expect(sessions.value!.queueTrackIds, ['c', 'd']);
      expect(sessions.value!.currentTrackId, 'c');
      expect(sessions.value!.currentQueuePosition, 0);
    });

    test('resets a saved position close to the track end', () async {
      final sessions = _MemorySessions(
        _session(
          ids: const ['a'],
          currentId: 'a',
          index: 0,
          position: const Duration(seconds: 98),
        ),
      );
      final restored = await RestorePlaybackSessionUseCase(
        sessions: sessions,
        tracks: _MemoryTracks([_track('a')]),
      )();

      expect(restored!.position, Duration.zero);
      expect(sessions.value!.position, Duration.zero);
    });

    test('clears a snapshot with no playable tracks', () async {
      final sessions = _MemorySessions(
        _session(ids: const ['a'], currentId: 'a', index: 0),
      );

      final restored = await RestorePlaybackSessionUseCase(
        sessions: sessions,
        tracks: _MemoryTracks([_track('a', ready: false)]),
      )();

      expect(restored, isNull);
      expect(sessions.value, isNull);
    });
  });
}

PlaybackSession _session({
  required List<String> ids,
  required String currentId,
  required int index,
  Duration position = Duration.zero,
  bool shuffle = false,
  PlaybackLoopMode loopMode = PlaybackLoopMode.off,
}) => PlaybackSession(
  queueTrackIds: ids,
  currentTrackId: currentId,
  currentQueuePosition: index,
  position: position,
  shuffleEnabled: shuffle,
  loopMode: loopMode,
  updatedAt: DateTime.utc(2026),
);

Track _track(String id, {bool ready = true}) => Track(
  id: id,
  title: id,
  artists: const [Artist(id: 'artist', name: 'Artist')],
  duration: const Duration(seconds: 100),
  source: Source(type: SourceType.localFile, originalUrl: '/$id.mp3'),
  addedAt: DateTime.utc(2026),
  filePath: ready ? '$id.mp3' : null,
);

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
    : _tracks = {for (final track in tracks) track.id: track};

  final Map<String, Track> _tracks;

  @override
  Future<List<Track>> getTracksByIds(List<String> ids) async =>
      ids.map((id) => _tracks[id]).whereType<Track>().toList();

  @override
  Future<List<Track>> getTracks() async => _tracks.values.toList();

  @override
  Future<Track?> getTrackById(String id) async => _tracks[id];

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
