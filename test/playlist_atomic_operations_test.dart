import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/playlist/drift/playlist_drift_local_source.dart';
import 'package:openmusic/layers/data/datasources/local/playlist/playlist_local_data_source.dart';
import 'package:openmusic/layers/data/datasources/local/track/drift/track_drift_local_source.dart';
import 'package:openmusic/layers/data/models/playlist_dto.dart';
import 'package:openmusic/layers/data/models/track_dto.dart';
import 'package:openmusic/layers/data/repositories/playlist_repository_impl.dart';

void main() {
  late AppDatabase database;
  late PlaylistDriftLocalSource source;
  late PlaylistRepositoryImpl repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    source = PlaylistDriftLocalSource(database);
    repository = PlaylistRepositoryImpl(localDataSource: source);
  });

  tearDown(() => database.close());

  test(
    'stale metadata update cannot overwrite a concurrent track add',
    () async {
      await _saveTracks(database, ['a', 'b']);
      await source.savePlaylist(_playlist(['a']));
      final stale = (await repository.getPlaylistById('playlist'))!;

      await repository.addTrackToPlaylist('playlist', 'b');

      await expectLater(
        repository.updateMetadata(stale.copyWith(name: 'Stale rename')),
        throwsA(isA<ConflictFailure>()),
      );
      final afterConflict = (await repository.getPlaylistById('playlist'))!;
      expect(afterConflict.name, 'Playlist');
      expect(afterConflict.trackIds, ['a', 'b']);
      expect(afterConflict.revision, 1);

      await repository.updateMetadata(afterConflict.copyWith(name: 'Renamed'));
      final renamed = (await repository.getPlaylistById('playlist'))!;
      expect(renamed.name, 'Renamed');
      expect(renamed.trackIds, ['a', 'b']);
      expect(renamed.revision, 2);
    },
  );

  test(
    'reorder and removal are revision fenced and positions stay dense',
    () async {
      await _saveTracks(database, ['a', 'b', 'c']);
      await source.savePlaylist(_playlist(['a', 'b', 'c']));

      await repository.reorderTracks('playlist', [
        'c',
        'a',
        'b',
      ], expectedRevision: 0);
      await expectLater(
        repository.removeTrackFromPlaylist(
          'playlist',
          'b',
          expectedRevision: 0,
        ),
        throwsA(isA<ConflictFailure>()),
      );
      await repository.removeTrackFromPlaylist(
        'playlist',
        'b',
        expectedRevision: 1,
      );

      final stored = (await repository.getPlaylistById('playlist'))!;
      final positions = await database.customSelect('''
SELECT position FROM playlist_track_table
WHERE playlist_id = 'playlist'
ORDER BY position
''').get();
      expect(stored.trackIds, ['c', 'a']);
      expect(stored.revision, 2);
      expect(positions.map((row) => row.read<int>('position')), [0, 1]);

      await repository.removeTrackFromPlaylist(
        'playlist',
        'c',
        expectedRevision: 2,
      );
      final afterFirstRemoval = (await repository.getPlaylistById('playlist'))!;
      expect(afterFirstRemoval.trackIds, ['a']);
      expect(afterFirstRemoval.revision, 3);
      final finalPositions = await database.customSelect('''
SELECT position FROM playlist_track_table
WHERE playlist_id = 'playlist'
ORDER BY position
''').get();
      expect(finalPositions.map((row) => row.read<int>('position')), [0]);
    },
  );

  test('remove of a missing membership does not consume revision', () async {
    await _saveTracks(database, ['a', 'b']);
    await source.savePlaylist(_playlist(['a']));

    final result = await source.removeTrack(
      'playlist',
      'b',
      expectedRevision: 0,
    );

    expect(result, PlaylistMutationResult.conflict);
    final stored = await source.getPlaylistById('playlist');
    expect(stored!.trackIds, ['a']);
    expect(stored.revision, 0);
  });

  test('reorder cannot change playlist membership', () async {
    await _saveTracks(database, ['a', 'b', 'c']);
    await source.savePlaylist(_playlist(['a', 'b']));

    final omitted = await source.reorderTracks('playlist', [
      'a',
    ], expectedRevision: 0);
    final replaced = await source.reorderTracks('playlist', [
      'a',
      'c',
    ], expectedRevision: 0);
    final duplicated = await source.reorderTracks('playlist', [
      'a',
      'a',
    ], expectedRevision: 0);

    expect(omitted, PlaylistMutationResult.conflict);
    expect(replaced, PlaylistMutationResult.conflict);
    expect(duplicated, PlaylistMutationResult.conflict);
    final stored = await source.getPlaylistById('playlist');
    expect(stored!.trackIds, ['a', 'b']);
    expect(stored.revision, 0);
  });

  test('missing delete reports NotFoundFailure', () async {
    await expectLater(
      repository.deletePlaylist('missing'),
      throwsA(isA<NotFoundFailure>()),
    );
  });

  test(
    'summary stream returns counts without materializing memberships',
    () async {
      await _saveTracks(database, ['a', 'b']);
      await source.savePlaylist(_playlist(['a', 'b']));

      final summaries = await source.watchPlaylistSummaries().first;

      expect(summaries.single.id, 'playlist');
      expect(summaries.single.trackCount, 2);
      expect(summaries.single.revision, 0);
    },
  );

  test('independent connections append different tracks atomically', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'openmusic_playlist_add_',
    );
    addTearDown(() => tempDir.delete(recursive: true));
    final file = File('${tempDir.path}/playlist.sqlite');
    final (firstDatabase, secondDatabase) = _openIndependentDatabases(file);
    addTearDown(firstDatabase.close);
    addTearDown(secondDatabase.close);
    await firstDatabase.customStatement('PRAGMA journal_mode = WAL');
    await firstDatabase.customStatement('PRAGMA busy_timeout = 5000');
    await secondDatabase.customStatement('PRAGMA busy_timeout = 5000');
    await _saveTracks(firstDatabase, ['a', 'b']);
    final first = PlaylistDriftLocalSource(firstDatabase);
    final second = PlaylistDriftLocalSource(secondDatabase);
    await first.savePlaylist(_playlist(const []));

    await Future.wait([
      first.addTrack('playlist', 'a'),
      second.addTrack('playlist', 'b'),
    ]);

    final stored = await first.getPlaylistById('playlist');
    expect(stored!.trackIds.toSet(), {'a', 'b'});
    expect(stored.revision, 2);
  });
}

(AppDatabase, AppDatabase) _openIndependentDatabases(File file) {
  final previous = driftRuntimeOptions.dontWarnAboutMultipleDatabases;
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  try {
    return (
      AppDatabase(NativeDatabase.createInBackground(file)),
      AppDatabase(NativeDatabase.createInBackground(file)),
    );
  } finally {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = previous;
  }
}

PlaylistDto _playlist(List<String> trackIds) {
  return PlaylistDto(
    id: 'playlist',
    name: 'Playlist',
    trackIds: trackIds,
    createdAt: DateTime.utc(2026),
  );
}

Future<void> _saveTracks(AppDatabase database, List<String> ids) async {
  final tracks = TrackDriftLocalSource(database);
  for (final id in ids) {
    await tracks.saveTrack(
      TrackDto(
        id: id,
        title: id,
        filePath: null,
        artists: const [ArtistDto(id: 'artist', name: 'Artist')],
        durationMs: 1000,
        sourceType: 'localFile',
        originalUrl: '/$id.mp3',
        addedAt: DateTime.utc(2026),
      ),
    );
  }
}
