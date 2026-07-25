import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/data/DTO/download_task_dto.dart';
import 'package:openmusic/layers/data/DTO/embedding_task_dto.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/download_task/drift/download_task_drift_local_source.dart';
import 'package:openmusic/layers/data/datasources/local/embedding_task/drift/embedding_task_drift_local_source.dart';
import 'package:openmusic/layers/domain/entities/download_track_task.dart';
import 'package:openmusic/layers/domain/entities/embedding_task.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('only one concurrent caller can claim a download task', () async {
    final source = DownloadTaskDriftLocalSource(database);
    await source.save(
      DownloadTaskDto(
        trackId: 'download-1',
        originalUrl: 'https://example.com/download-1',
        status: DownloadStatus.queued,
        createdAt: DateTime.now(),
      ),
    );

    final leaseUntil = DateTime.now().add(const Duration(minutes: 1));
    final claims = await Future.wait([
      source.claimNext(ownerId: 'download-owner-a', leaseUntil: leaseUntil),
      source.claimNext(ownerId: 'download-owner-b', leaseUntil: leaseUntil),
    ]);

    expect(claims.whereType<DownloadTaskDto>(), hasLength(1));
    expect(
      claims.whereType<DownloadTaskDto>().single.status,
      DownloadStatus.downloading,
    );
    expect(
      (await source.getByTrackId('download-1'))?.status,
      DownloadStatus.downloading,
    );
  });

  test('only one concurrent enqueue creates a download task', () async {
    final source = DownloadTaskDriftLocalSource(database);
    final createdAt = DateTime.now();

    final results = await Future.wait([
      source.enqueue(
        trackId: 'enqueue-once',
        originalUrl: 'https://example.com/a',
        createdAt: createdAt,
      ),
      source.enqueue(
        trackId: 'enqueue-once',
        originalUrl: 'https://example.com/b',
        createdAt: createdAt,
      ),
    ]);

    expect(results.where((inserted) => inserted), hasLength(1));
    expect(
      (await source.getByTrackId('enqueue-once'))?.status,
      DownloadStatus.queued,
    );
    expect(await source.getAll(), hasLength(1));
  });

  test('enqueue does not overwrite an active task or its lease', () async {
    final source = DownloadTaskDriftLocalSource(database);
    await source.enqueue(
      trackId: 'active-task',
      originalUrl: 'https://example.com/original',
      createdAt: DateTime.now(),
    );
    await source.claimNext(
      ownerId: 'owner-a',
      leaseUntil: DateTime.now().add(const Duration(minutes: 1)),
    );

    final enqueued = await source.enqueue(
      trackId: 'active-task',
      originalUrl: 'https://example.com/replacement',
      createdAt: DateTime.now(),
    );
    final row = await (database.select(
      database.downloadTaskTable,
    )..where((task) => task.trackId.equals('active-task'))).getSingle();

    expect(enqueued, isFalse);
    expect(row.originalUrl, 'https://example.com/original');
    expect(row.status, DownloadStatus.downloading.name);
    expect(row.leaseOwner, 'owner-a');
  });

  test('enqueue atomically reopens a failed task', () async {
    final source = DownloadTaskDriftLocalSource(database);
    await source.enqueue(
      trackId: 'failed-task',
      originalUrl: 'https://example.com/original',
      createdAt: DateTime.now(),
    );
    await source.claimNext(
      ownerId: 'owner-a',
      leaseUntil: DateTime.now().add(const Duration(minutes: 1)),
    );
    await source.updateStatusIfOwned(
      trackId: 'failed-task',
      ownerId: 'owner-a',
      status: DownloadStatus.failed,
    );

    final enqueued = await source.enqueue(
      trackId: 'failed-task',
      originalUrl: 'https://example.com/retry',
      createdAt: DateTime.now(),
    );
    final row = await (database.select(
      database.downloadTaskTable,
    )..where((task) => task.trackId.equals('failed-task'))).getSingle();

    expect(enqueued, isTrue);
    expect(row.originalUrl, 'https://example.com/retry');
    expect(row.status, DownloadStatus.queued.name);
    expect(row.leaseOwner, isNull);
    expect(row.leaseUntil, isNull);
  });

  test('only one concurrent caller can claim an embedding task', () async {
    final source = EmbeddingTaskDriftLocalSource(database);
    await source.save(
      EmbeddingTaskDto(
        id: 'embedding-1',
        trackId: 'track-1',
        status: EmbeddingStatus.queued,
        filePath: '/music/track-1.mp3',
        createdAt: DateTime.now(),
      ),
    );

    final leaseUntil = DateTime.now().add(const Duration(minutes: 1));
    final claims = await Future.wait([
      source.claimNext(ownerId: 'embedding-owner-a', leaseUntil: leaseUntil),
      source.claimNext(ownerId: 'embedding-owner-b', leaseUntil: leaseUntil),
    ]);

    expect(claims.whereType<EmbeddingTaskDto>(), hasLength(1));
    expect(
      claims.whereType<EmbeddingTaskDto>().single.status,
      EmbeddingStatus.processing,
    );
    expect(
      (await source.getByTrackId('track-1')).status,
      EmbeddingStatus.processing,
    );
  });

  test(
    'a live download lease cannot be stolen or released by another owner',
    () async {
      final source = DownloadTaskDriftLocalSource(database);
      await source.save(
        DownloadTaskDto(
          trackId: 'download-live',
          originalUrl: 'https://example.com/download-live',
          status: DownloadStatus.queued,
          createdAt: DateTime.now(),
        ),
      );
      final leaseUntil = DateTime.now().add(const Duration(minutes: 1));

      expect(
        await source.claimNext(ownerId: 'owner-a', leaseUntil: leaseUntil),
        isNotNull,
      );
      expect(
        await source.claimNext(ownerId: 'owner-b', leaseUntil: leaseUntil),
        isNull,
      );
      expect(
        await source.releaseLease(trackId: 'download-live', ownerId: 'owner-b'),
        isFalse,
      );
      expect(await source.getByTrackId('download-live'), isNotNull);
    },
  );

  test('an expired download lease can be reclaimed by a new owner', () async {
    final source = DownloadTaskDriftLocalSource(database);
    await source.save(
      DownloadTaskDto(
        trackId: 'download-expired',
        originalUrl: 'https://example.com/download-expired',
        status: DownloadStatus.queued,
        createdAt: DateTime.now(),
      ),
    );

    await source.claimNext(
      ownerId: 'owner-a',
      leaseUntil: DateTime.now().subtract(const Duration(seconds: 1)),
    );
    final reclaimed = await source.claimNext(
      ownerId: 'owner-b',
      leaseUntil: DateTime.now().add(const Duration(minutes: 1)),
    );

    expect(reclaimed, isNotNull);
    expect(
      await source.renewLease(
        trackId: 'download-expired',
        ownerId: 'owner-a',
        leaseUntil: DateTime.now().add(const Duration(minutes: 1)),
      ),
      isFalse,
    );
  });

  test('an expired embedding lease can be reclaimed by a new owner', () async {
    final source = EmbeddingTaskDriftLocalSource(database);
    await source.save(
      EmbeddingTaskDto(
        id: 'embedding-expired',
        trackId: 'track-expired',
        status: EmbeddingStatus.queued,
        filePath: '/music/track-expired.mp3',
        createdAt: DateTime.now(),
      ),
    );

    await source.claimNext(
      ownerId: 'owner-a',
      leaseUntil: DateTime.now().subtract(const Duration(seconds: 1)),
    );
    final reclaimed = await source.claimNext(
      ownerId: 'owner-b',
      leaseUntil: DateTime.now().add(const Duration(minutes: 1)),
    );

    expect(reclaimed, isNotNull);
    expect(
      await source.updateStatusIfOwned(
        trackId: 'track-expired',
        ownerId: 'owner-a',
        status: EmbeddingStatus.done,
      ),
      isFalse,
    );
  });
}
