import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/repositories/track_removal_repository_impl.dart';
import 'package:openmusic/layers/domain/entities/download_track_task.dart';
import 'package:openmusic/layers/domain/entities/embedding_task.dart';

void main() {
  test(
    'removal clears dependent work, orphan artist, and owned files',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'openmusic_remove_',
      );
      addTearDown(() => tempDir.delete(recursive: true));
      final audio = File('${tempDir.path}/track.mp3');
      final artwork = File('${tempDir.path}/artwork.jpg');
      await audio.writeAsString('audio');
      await artwork.writeAsString('artwork');
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      await database
          .into(database.trackTable)
          .insert(
            TrackTableCompanion.insert(
              id: 'track-1',
              title: 'Track',
              sourceType: 'soundcloud',
              sourceUri: 'https://example.com/track',
              pathToFile: const Value('track.mp3'),
              imageUrl: Value(artwork.path),
            ),
          );
      await database
          .into(database.artistTable)
          .insert(ArtistTableCompanion.insert(id: 'artist-1', name: 'Artist'));
      await database
          .into(database.trackArtistTable)
          .insert(
            TrackArtistTableCompanion.insert(
              trackId: 'track-1',
              artistId: 'artist-1',
              position: 0,
            ),
          );
      await database
          .into(database.playlistTable)
          .insert(
            PlaylistTableCompanion.insert(
              id: 'playlist-1',
              name: 'Playlist',
              createdAt: DateTime.now(),
            ),
          );
      await database
          .into(database.playlistTrackTable)
          .insert(
            PlaylistTrackTableCompanion.insert(
              playlistId: 'playlist-1',
              trackId: 'track-1',
              position: 0,
            ),
          );
      await database
          .into(database.downloadTaskTable)
          .insert(
            DownloadTaskTableCompanion.insert(
              trackId: 'track-1',
              originalUrl: 'https://example.com/track',
              status: DownloadStatus.queued.name,
              createdAt: DateTime.now(),
            ),
          );
      await database
          .into(database.embeddingTaskTable)
          .insert(
            EmbeddingTaskTableCompanion.insert(
              id: 'track-1',
              trackId: 'track-1',
              status: EmbeddingStatus.queued.name,
              filePath: 'track.mp3',
              createdAt: DateTime.now(),
            ),
          );

      await TrackRemovalRepositoryImpl(
        database: database,
        appDir: tempDir.path,
      ).removeTrack('track-1');

      expect(await database.select(database.trackTable).get(), isEmpty);
      expect(await database.select(database.downloadTaskTable).get(), isEmpty);
      expect(await database.select(database.embeddingTaskTable).get(), isEmpty);
      expect(await database.select(database.playlistTrackTable).get(), isEmpty);
      expect(await database.select(database.artistTable).get(), isEmpty);
      expect(await database.select(database.playlistTable).get(), hasLength(1));
      expect(await audio.exists(), isFalse);
      expect(await artwork.exists(), isFalse);
    },
  );

  test('removal never deletes a path outside the app directory', () async {
    final root = await Directory.systemTemp.createTemp('openmusic_safe_');
    final outside = await Directory.systemTemp.createTemp('openmusic_outside_');
    addTearDown(() => root.delete(recursive: true));
    addTearDown(() => outside.delete(recursive: true));
    final protected = File('${outside.path}/protected.mp3');
    await protected.writeAsString('keep');
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await database
        .into(database.trackTable)
        .insert(
          TrackTableCompanion.insert(
            id: 'track-2',
            title: 'Track',
            sourceType: 'localFile',
            sourceUri: protected.path,
            pathToFile: Value(protected.path),
          ),
        );

    await TrackRemovalRepositoryImpl(
      database: database,
      appDir: root.path,
    ).removeTrack('track-2');

    expect(await protected.exists(), isTrue);
  });
}
