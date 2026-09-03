import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/data/models/download_task_dto.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/download_task/drift/download_task_drift_local_source.dart';
import 'package:openmusic/layers/domain/entities/download_track_task.dart';

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
    await source.enqueue(
      trackId: 'download-1',
      originalUrl: 'https://example.com/download-1',
      createdAt: DateTime.now(),
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

  test('claim stays atomic across independent database connections', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'openmusic_atomic_claim_',
    );
    addTearDown(() => tempDir.delete(recursive: true));
    final file = File('${tempDir.path}/queue.sqlite');
    final (firstDatabase, secondDatabase) = _openIndependentDatabases(file);
    addTearDown(firstDatabase.close);
    addTearDown(secondDatabase.close);
    await firstDatabase.customStatement('PRAGMA journal_mode = WAL');
    await firstDatabase.customStatement('PRAGMA busy_timeout = 5000');
    await secondDatabase.customStatement('PRAGMA busy_timeout = 5000');

    final first = DownloadTaskDriftLocalSource(firstDatabase);
    final second = DownloadTaskDriftLocalSource(secondDatabase);
    await first.enqueue(
      trackId: 'shared-task',
      originalUrl: 'https://example.com/shared',
      createdAt: DateTime.now(),
    );
    final leaseUntil = DateTime.now().add(const Duration(minutes: 1));

    final claims = await Future.wait([
      first.claimNext(ownerId: 'owner-a', leaseUntil: leaseUntil),
      second.claimNext(ownerId: 'owner-b', leaseUntil: leaseUntil),
    ]);

    expect(claims.whereType<DownloadTaskDto>(), hasLength(1));
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
    await source.markFailedIfOwned(
      trackId: 'failed-task',
      ownerId: 'owner-a',
      failure: _downloadFailure(),
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
    expect(row.failureCode, isNull);
    expect(row.failureMessage, isNull);
    expect(row.failureDetails, isNull);
    expect(row.failedAt, isNull);
  });

  test('download failure metadata is stored for diagnostics', () async {
    final source = DownloadTaskDriftLocalSource(database);
    final failure = _downloadFailure();
    await source.enqueue(
      trackId: 'diagnostic-task',
      originalUrl: 'https://example.com/diagnostic',
      createdAt: DateTime.now(),
    );
    await source.claimNext(
      ownerId: 'owner-a',
      leaseUntil: DateTime.now().add(const Duration(minutes: 1)),
    );

    final marked = await source.markFailedIfOwned(
      trackId: 'diagnostic-task',
      ownerId: 'owner-a',
      failure: failure,
    );
    final stored = await source.getByTrackId('diagnostic-task');

    expect(marked, isTrue);
    expect(stored?.status, DownloadStatus.failed);
    expect(stored?.failure?.code, DownloadFailureCodes.network);
    expect(stored?.failure?.message, 'Network request failed');
    expect(stored?.failure?.details, contains('stackTrace'));
    expect(
      stored?.failure?.failedAt.isAtSameMomentAs(failure.failedAt),
      isTrue,
    );
  });

  test(
    'a live download lease cannot be stolen or released by another owner',
    () async {
      final source = DownloadTaskDriftLocalSource(database);
      await source.enqueue(
        trackId: 'download-live',
        originalUrl: 'https://example.com/download-live',
        createdAt: DateTime.now(),
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
    await source.enqueue(
      trackId: 'download-expired',
      originalUrl: 'https://example.com/download-expired',
      createdAt: DateTime.now(),
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
}

DownloadFailureInfo _downloadFailure() => DownloadFailureInfo(
  code: DownloadFailureCodes.network,
  message: 'Network request failed',
  details: 'stackTrace',
  failedAt: DateTime.utc(2026, 8, 18),
);

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
