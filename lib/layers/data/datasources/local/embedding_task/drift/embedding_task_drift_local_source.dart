import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/layers/data/models/embedding_task_dto.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/embedding_task/embedding_task_local_data_source.dart';
import 'package:openmusic/layers/domain/entities/embedding_task.dart';

class EmbeddingTaskDriftLocalSource implements EmbeddingTaskLocalDataSource {
  final AppDatabase database;
  EmbeddingTaskDriftLocalSource(this.database);

  @override
  Future<EmbeddingTaskDto?> claimNext({
    required String ownerId,
    required DateTime leaseUntil,
  }) async {
    final now = DateTime.now();
    final rows = await database.customWriteReturning(
      '''
UPDATE embedding_task_table
SET status = ?, lease_owner = ?, lease_until = ?
WHERE track_id = (
  SELECT track_id
  FROM embedding_task_table
  WHERE status = ?
     OR (status = ? AND (lease_until IS NULL OR lease_until < ?))
  ORDER BY created_at ASC
  LIMIT 1
)
AND (
  status = ?
  OR (status = ? AND (lease_until IS NULL OR lease_until < ?))
)
RETURNING id, track_id, status, file_path, created_at, audio_revision
''',
      variables: [
        Variable<String>(EmbeddingStatus.processing.name),
        Variable<String>(ownerId),
        Variable<DateTime>(leaseUntil),
        Variable<String>(EmbeddingStatus.queued.name),
        Variable<String>(EmbeddingStatus.processing.name),
        Variable<DateTime>(now),
        Variable<String>(EmbeddingStatus.queued.name),
        Variable<String>(EmbeddingStatus.processing.name),
        Variable<DateTime>(now),
      ],
      updates: {database.embeddingTaskTable},
      updateKind: UpdateKind.update,
    );
    if (rows.isEmpty) return null;
    final row = rows.single;
    return EmbeddingTaskDto(
      id: row.read<String>('id'),
      trackId: row.read<String>('track_id'),
      status: EmbeddingStatus.values.byName(row.read<String>('status')),
      filePath: row.read<String>('file_path'),
      createdAt: row.read<DateTime>('created_at'),
      audioRevision: row.read<int>('audio_revision'),
    );
  }

  @override
  Future<bool> renewLease({
    required String trackId,
    required String ownerId,
    required DateTime leaseUntil,
  }) async {
    final affected =
        await (database.update(database.embeddingTaskTable)..where(
              (t) =>
                  t.trackId.equals(trackId) &
                  t.status.equals(EmbeddingStatus.processing.name) &
                  t.leaseOwner.equals(ownerId),
            ))
            .write(EmbeddingTaskTableCompanion(leaseUntil: Value(leaseUntil)));
    return affected == 1;
  }

  @override
  Future<bool> releaseLease({
    required String trackId,
    required String ownerId,
  }) async {
    final affected =
        await (database.update(database.embeddingTaskTable)..where(
              (t) => t.trackId.equals(trackId) & t.leaseOwner.equals(ownerId),
            ))
            .write(
              EmbeddingTaskTableCompanion(
                status: Value(EmbeddingStatus.queued.name),
                leaseOwner: const Value(null),
                leaseUntil: const Value(null),
              ),
            );
    return affected == 1;
  }

  @override
  Future<bool> markFailedIfOwned({
    required String trackId,
    required String ownerId,
  }) async {
    final affected =
        await (database.update(database.embeddingTaskTable)..where(
              (t) => t.trackId.equals(trackId) & t.leaseOwner.equals(ownerId),
            ))
            .write(
              EmbeddingTaskTableCompanion(
                status: Value(EmbeddingStatus.failed.name),
                leaseOwner: const Value(null),
                leaseUntil: const Value(null),
              ),
            );
    return affected == 1;
  }

  @override
  Future<bool> completeIfOwned({
    required String trackId,
    required String ownerId,
    required int audioRevision,
    required List<double> vector,
  }) {
    return _completeIfOwned(
      trackId: trackId,
      ownerId: ownerId,
      audioRevision: audioRevision,
      vector: vector,
    );
  }

  Future<bool> _completeIfOwned({
    required String trackId,
    required String ownerId,
    required int audioRevision,
    required List<double> vector,
  }) async {
    try {
      return await database.transaction<bool>(() async {
        final ownedTask =
            await (database.select(database.embeddingTaskTable)..where(
                  (task) =>
                      task.trackId.equals(trackId) &
                      task.status.equals(EmbeddingStatus.processing.name) &
                      task.leaseOwner.equals(ownerId) &
                      task.audioRevision.equals(audioRevision),
                ))
                .getSingleOrNull();
        if (ownedTask == null) return false;

        final track = await (database.select(
          database.trackTable,
        )..where((track) => track.id.equals(trackId))).getSingleOrNull();
        if (track == null) throw NotFoundFailure('track', trackId);
        if (track.audioRevision != audioRevision) return false;

        final trackUpdated =
            await (database.update(database.trackTable)..where(
                  (track) =>
                      track.id.equals(trackId) &
                      track.audioRevision.equals(audioRevision),
                ))
                .write(
                  TrackTableCompanion(embedding: Value(jsonEncode(vector))),
                );
        if (trackUpdated != 1) throw const _EmbeddingCompletionConflict();

        final completed =
            await (database.update(database.embeddingTaskTable)..where(
                  (task) =>
                      task.trackId.equals(trackId) &
                      task.status.equals(EmbeddingStatus.processing.name) &
                      task.leaseOwner.equals(ownerId) &
                      task.audioRevision.equals(audioRevision),
                ))
                .write(
                  EmbeddingTaskTableCompanion(
                    status: Value(EmbeddingStatus.done.name),
                    leaseOwner: const Value(null),
                    leaseUntil: const Value(null),
                  ),
                );
        if (completed != 1) throw const _EmbeddingCompletionConflict();
        return true;
      });
    } on _EmbeddingCompletionConflict {
      return false;
    }
  }

  @override
  Stream<List<EmbeddingTaskDto>> watchAll() {
    return database
        .select(database.embeddingTaskTable)
        .watch()
        .map(
          (rows) => rows.map((e) => EmbeddingTaskDto.fromDataClass(e)).toList(),
        );
  }
}

class _EmbeddingCompletionConflict implements Exception {
  const _EmbeddingCompletionConflict();
}
