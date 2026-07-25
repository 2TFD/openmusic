import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/repositories/track_download_completion_repository_impl.dart';
import 'package:openmusic/layers/domain/entities/download_track_task.dart';
import 'package:openmusic/layers/domain/entities/embedding_task.dart';

void main() {
  late AppDatabase database;
  late TrackDownloadCompletionRepositoryImpl repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = TrackDownloadCompletionRepositoryImpl(database);
  });

  tearDown(() => database.close());

  test(
    'claimed completion commits track, embedding task, and queue removal',
    () async {
      await _insertTrack(database, 'track-1');
      await _insertClaimedDownload(database, 'track-1', 'owner-a');

      final completed = await repository.completeClaimed(
        trackId: 'track-1',
        filePath: 'track-1.mp3',
        ownerId: 'owner-a',
      );

      expect(completed, isTrue);
      expect((await _track(database, 'track-1'))?.pathToFile, 'track-1.mp3');
      expect(
        (await _embedding(database, 'track-1'))?.status,
        EmbeddingStatus.queued.name,
      );
      expect(await _download(database, 'track-1'), isNull);
    },
  );

  test('wrong owner cannot partially complete a claimed download', () async {
    await _insertTrack(database, 'track-2');
    await _insertClaimedDownload(database, 'track-2', 'owner-a');

    final completed = await repository.completeClaimed(
      trackId: 'track-2',
      filePath: 'track-2.mp3',
      ownerId: 'owner-b',
    );

    expect(completed, isFalse);
    expect((await _track(database, 'track-2'))?.pathToFile, isNull);
    expect(await _embedding(database, 'track-2'), isNull);
    expect(await _download(database, 'track-2'), isNotNull);
  });

  test(
    'failure after queue removal rolls the whole transaction back',
    () async {
      await _insertClaimedDownload(database, 'missing-track', 'owner-a');

      await expectLater(
        repository.completeClaimed(
          trackId: 'missing-track',
          filePath: 'missing.mp3',
          ownerId: 'owner-a',
        ),
        throwsStateError,
      );

      expect(await _download(database, 'missing-track'), isNotNull);
      expect(await _embedding(database, 'missing-track'), isNull);
    },
  );

  test(
    'local completion atomically updates track and queues embedding',
    () async {
      await _insertTrack(database, 'local-track');

      await repository.completeLocal(
        trackId: 'local-track',
        filePath: 'local-track.flac',
      );

      expect(
        (await _track(database, 'local-track'))?.pathToFile,
        'local-track.flac',
      );
      expect(
        (await _embedding(database, 'local-track'))?.status,
        EmbeddingStatus.queued.name,
      );
    },
  );
}

Future<void> _insertTrack(AppDatabase database, String id) async {
  await database
      .into(database.trackTable)
      .insert(
        TrackTableCompanion.insert(
          id: id,
          title: id,
          artistIds: '[]',
          artistNames: '[]',
          sourceType: 'soundcloud',
          sourceUri: 'https://example.com/$id',
        ),
      );
}

Future<void> _insertClaimedDownload(
  AppDatabase database,
  String trackId,
  String ownerId,
) async {
  await database
      .into(database.downloadTaskTable)
      .insert(
        DownloadTaskTableCompanion.insert(
          trackId: trackId,
          originalUrl: 'https://example.com/$trackId',
          status: DownloadStatus.downloading.name,
          createdAt: DateTime.now(),
          leaseOwner: Value(ownerId),
          leaseUntil: Value(DateTime.now().add(const Duration(minutes: 1))),
        ),
      );
}

Future<TrackTableData?> _track(AppDatabase database, String trackId) =>
    (database.select(
      database.trackTable,
    )..where((track) => track.id.equals(trackId))).getSingleOrNull();

Future<EmbeddingTaskTableData?> _embedding(
  AppDatabase database,
  String trackId,
) => (database.select(
  database.embeddingTaskTable,
)..where((task) => task.trackId.equals(trackId))).getSingleOrNull();

Future<DownloadTaskTableData?> _download(
  AppDatabase database,
  String trackId,
) => (database.select(
  database.downloadTaskTable,
)..where((task) => task.trackId.equals(trackId))).getSingleOrNull();
