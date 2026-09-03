import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/core/services/track_identity/sha256_track_content_identity_service.dart';
import 'package:openmusic/core/services/track_source_resolver.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/playlist/drift/playlist_drift_local_source.dart';
import 'package:openmusic/layers/data/datasources/local/track/drift/track_drift_local_source.dart';
import 'package:openmusic/layers/data/repositories/playlist_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/track_ingestion_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/track_repository_impl.dart';
import 'package:openmusic/layers/domain/entities/operation_cancellation.dart';
import 'package:openmusic/layers/domain/entities/resolved_track_input.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';
import 'package:openmusic/layers/domain/repositories/track_source.dart';
import 'package:openmusic/layers/domain/usecases/add_track_use_case.dart';

void main() {
  const identity = Sha256TrackContentIdentityService();

  test('same local content has the same identity', () async {
    final directory = await Directory.systemTemp.createTemp('identity_same_');
    addTearDown(() => directory.delete(recursive: true));
    final first = File('${directory.path}/first.mp3');
    final second = File('${directory.path}/second.flac');
    await first.writeAsBytes([1, 2, 3, 4, 5]);
    await second.writeAsBytes([1, 2, 3, 4, 5]);

    expect(
      await identity.forLocalFile(first.path),
      await identity.forLocalFile(second.path),
    );
  });

  test('different local content has different identities', () async {
    final directory = await Directory.systemTemp.createTemp('identity_diff_');
    addTearDown(() => directory.delete(recursive: true));
    final first = File('${directory.path}/first.mp3');
    final second = File('${directory.path}/second.mp3');
    await first.writeAsBytes([1, 2, 3]);
    await second.writeAsBytes([1, 2, 4]);

    expect(
      await identity.forLocalFile(first.path),
      isNot(await identity.forLocalFile(second.path)),
    );
  });

  test('rename does not change local content identity', () async {
    final directory = await Directory.systemTemp.createTemp('identity_move_');
    addTearDown(() => directory.delete(recursive: true));
    final original = File('${directory.path}/original.mp3');
    await original.writeAsBytes([9, 8, 7, 6]);
    final before = await identity.forLocalFile(original.path);
    final renamed = await original.rename('${directory.path}/renamed.mp3');

    expect(await identity.forLocalFile(renamed.path), before);
  });

  test('SoundCloud identity is namespaced', () {
    expect(identity.forSoundCloudTrack('12345'), 'soundcloud:12345');
    expect(
      identity.forSoundCloudTrack('12345'),
      isNot(startsWith('local:sha256:')),
    );
  });

  test('new local import persists SHA-256 content identity', () async {
    final directory = await Directory.systemTemp.createTemp('identity_add_');
    addTearDown(() => directory.delete(recursive: true));
    final sourceFile = File('${directory.path}/source.mp3');
    await sourceFile.writeAsBytes([10, 20, 30, 40]);
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final trackSource = _LocalSource(sourceFile.path);
    final trackLocal = TrackDriftLocalSource(database);
    final tracks = TrackRepositoryImpl(localDataSource: trackLocal);
    final useCase = AddTrackUseCase(
      trackResolver: TrackSourceResolver([trackSource]),
      trackRepository: tracks,
      ingestionRepository: TrackIngestionRepositoryImpl(
        database: database,
        trackLocalDataSource: trackLocal,
      ),
      playlistRepository: PlaylistRepositoryImpl(
        localDataSource: PlaylistDriftLocalSource(database),
      ),
      contentIdentityService: identity,
    );

    final result = await useCase.addResolved(await trackSource.resolve('x'));
    final stored = await tracks.getTrackById('local-track');

    expect(result.failures, isEmpty);
    expect(
      stored?.contentIdentity,
      await identity.forLocalFile(sourceFile.path),
    );

    await (database.update(database.trackTable)
          ..where((row) => row.id.equals('local-track')))
        .write(const TrackTableCompanion(contentIdentity: Value(null)));
    await useCase.addResolved(await trackSource.resolve('x'));

    expect(
      (await tracks.getTrackById('local-track'))?.contentIdentity,
      await identity.forLocalFile(sourceFile.path),
      reason: 're-import lazily backfills an existing local track',
    );
  });
}

class _LocalSource implements TrackSource {
  _LocalSource(this.path);

  final String path;

  @override
  SourceType get sourceType => SourceType.localFile;

  @override
  bool canHandle(String input) => true;

  @override
  Future<String> download(
    TrackPreview track, {
    OperationCancellation? cancellation,
  }) async => 'local-track.mp3';

  @override
  Future<ResolvedTrackInput> resolve(String input) async {
    return ResolvedTrackInput.single(
      TrackPreview(
        id: 'local-track',
        title: 'Local track',
        artist: 'Artist',
        source: SourceType.localFile,
        originalUrl: path,
        urlFile: path,
      ),
    );
  }
}
