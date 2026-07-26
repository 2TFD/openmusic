import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/track/drift/track_drift_local_source.dart';
import 'package:openmusic/layers/data/repositories/track_ingestion_repository_impl.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';

void main() {
  late AppDatabase database;
  late TrackIngestionRepositoryImpl repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = TrackIngestionRepositoryImpl(
      database: database,
      trackLocalDataSource: TrackDriftLocalSource(database),
    );
  });

  tearDown(() => database.close());

  test('concurrent ingestion creates one track and one queue task', () async {
    final track = _preview('same-track').toTrack(null);

    final results = await Future.wait([
      repository.ingestRemote(track),
      repository.ingestRemote(track),
    ]);

    expect(results.map((result) => result.id), everyElement('same-track'));
    expect(await database.select(database.trackTable).get(), hasLength(1));
    expect(
      await database.select(database.downloadTaskTable).get(),
      hasLength(1),
    );
    expect(
      await database.select(database.trackArtistTable).get(),
      hasLength(1),
    );
  });

  test('queue insertion failure rolls the track insertion back', () async {
    await database.customStatement('''
CREATE TRIGGER reject_test_download
BEFORE INSERT ON download_task_table
WHEN NEW.track_id = 'rollback-track'
BEGIN
  SELECT RAISE(ABORT, 'injected failure');
END
''');

    await expectLater(
      repository.ingestRemote(_preview('rollback-track').toTrack(null)),
      throwsA(anything),
    );

    expect(
      await (database.select(
        database.trackTable,
      )..where((track) => track.id.equals('rollback-track'))).getSingleOrNull(),
      isNull,
    );
  });
}

TrackPreview _preview(String id) => TrackPreview(
  id: id,
  title: id,
  artist: 'Artist',
  source: SourceType.soundcloud,
  originalUrl: 'https://example.com/$id',
  urlFile: '',
);
