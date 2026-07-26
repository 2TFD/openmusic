import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/embedding_task/drift/embedding_task_drift_local_source.dart';
import 'package:openmusic/layers/domain/entities/embedding_task.dart';

void main() {
  late AppDatabase database;
  late EmbeddingTaskDriftLocalSource source;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    source = EmbeddingTaskDriftLocalSource(database);
  });

  tearDown(() => database.close());

  test('owned completion commits vector and done status together', () async {
    await _insertTrack(database, 'track-1');
    await _insertProcessingTask(database, 'track-1', 'owner-a');

    final completed = await source.completeIfOwned(
      trackId: 'track-1',
      ownerId: 'owner-a',
      audioRevision: 0,
      vector: const [0.1, 0.2, 0.3],
    );

    final track = await _track(database, 'track-1');
    final task = await _task(database, 'track-1');
    expect(completed, isTrue);
    expect(jsonDecode(track!.embedding!), [0.1, 0.2, 0.3]);
    expect(task!.status, EmbeddingStatus.done.name);
    expect(task.leaseOwner, isNull);
    expect(task.leaseUntil, isNull);
  });

  test('wrong owner cannot write a vector or finish the task', () async {
    await _insertTrack(database, 'track-2');
    await _insertProcessingTask(database, 'track-2', 'owner-a');

    final completed = await source.completeIfOwned(
      trackId: 'track-2',
      ownerId: 'owner-b',
      audioRevision: 0,
      vector: const [9.0],
    );

    expect(completed, isFalse);
    expect((await _track(database, 'track-2'))?.embedding, isNull);
    expect(
      (await _task(database, 'track-2'))?.status,
      EmbeddingStatus.processing.name,
    );
    expect((await _task(database, 'track-2'))?.leaseOwner, 'owner-a');
  });

  test('stale audio revision cannot write a vector', () async {
    await _insertTrack(database, 'track-stale');
    await _insertProcessingTask(database, 'track-stale', 'owner-a');
    await (database.update(database.trackTable)
          ..where((track) => track.id.equals('track-stale')))
        .write(const TrackTableCompanion(audioRevision: Value(1)));

    final completed = await source.completeIfOwned(
      trackId: 'track-stale',
      ownerId: 'owner-a',
      audioRevision: 0,
      vector: const [9.0],
    );

    expect(completed, isFalse);
    expect((await _track(database, 'track-stale'))?.embedding, isNull);
    expect(
      (await _task(database, 'track-stale'))?.status,
      EmbeddingStatus.processing.name,
    );
  });

  test('missing track rolls task completion back', () async {
    await _insertProcessingTask(database, 'missing-track', 'owner-a');

    await expectLater(
      source.completeIfOwned(
        trackId: 'missing-track',
        ownerId: 'owner-a',
        audioRevision: 0,
        vector: const [1.0],
      ),
      throwsA(isA<NotFoundFailure>()),
    );

    final task = await _task(database, 'missing-track');
    expect(task!.status, EmbeddingStatus.processing.name);
    expect(task.leaseOwner, 'owner-a');
  });
}

Future<void> _insertTrack(AppDatabase database, String id) async {
  await database
      .into(database.trackTable)
      .insert(
        TrackTableCompanion.insert(
          id: id,
          title: id,
          sourceType: 'soundcloud',
          sourceUri: 'https://example.com/$id',
        ),
      );
}

Future<void> _insertProcessingTask(
  AppDatabase database,
  String trackId,
  String ownerId,
) async {
  await database
      .into(database.embeddingTaskTable)
      .insert(
        EmbeddingTaskTableCompanion.insert(
          id: trackId,
          trackId: trackId,
          status: EmbeddingStatus.processing.name,
          filePath: '$trackId.mp3',
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

Future<EmbeddingTaskTableData?> _task(AppDatabase database, String trackId) =>
    (database.select(
      database.embeddingTaskTable,
    )..where((task) => task.trackId.equals(trackId))).getSingleOrNull();
