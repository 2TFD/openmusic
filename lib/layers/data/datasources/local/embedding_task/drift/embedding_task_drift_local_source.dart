import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:openmusic/core/utils/app_logger.dart';
import 'package:openmusic/layers/data/DTO/embedding_task_dto.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/embedding_task/embedding_task_local_data_source.dart';
import 'package:openmusic/layers/domain/entities/embedding_task.dart';

class EmbeddingTaskDriftLocalSource implements EmbeddingTaskLocalDataSource {
  final AppDatabase database;
  EmbeddingTaskDriftLocalSource(this.database);

  @override
  Future<List<EmbeddingTaskDto>> getAll() async {
    final List<EmbeddingTaskTableData> res = await database
        .select(database.embeddingTaskTable)
        .get();
    return res.map((e) => EmbeddingTaskDto.fromDataClass(e)).toList();
  }

  @override
  Future<EmbeddingTaskDto?> claimNext({
    required String ownerId,
    required DateTime leaseUntil,
  }) async {
    return database.transaction<EmbeddingTaskDto?>(() async {
      final now = DateTime.now();
      final row =
          await (database.select(database.embeddingTaskTable)
                ..where((t) {
                  final leaseExpired =
                      t.leaseUntil.isNull() |
                      t.leaseUntil.isSmallerThanValue(now);
                  return t.status.equals(EmbeddingStatus.queued.name) |
                      (t.status.equals(EmbeddingStatus.processing.name) &
                          leaseExpired);
                })
                ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
                ..limit(1))
              .getSingleOrNull();
      if (row == null) return null;

      final claimed =
          await (database.update(database.embeddingTaskTable)..where((t) {
                final leaseExpired =
                    t.leaseUntil.isNull() |
                    t.leaseUntil.isSmallerThanValue(now);
                final claimable =
                    t.status.equals(EmbeddingStatus.queued.name) |
                    (t.status.equals(EmbeddingStatus.processing.name) &
                        leaseExpired);
                return t.trackId.equals(row.trackId) & claimable;
              }))
              .write(
                EmbeddingTaskTableCompanion(
                  status: Value(EmbeddingStatus.processing.name),
                  leaseOwner: Value(ownerId),
                  leaseUntil: Value(leaseUntil),
                ),
              );
      if (claimed != 1) return null;
      return EmbeddingTaskDto.fromDataClass(
        row.copyWith(status: EmbeddingStatus.processing.name),
      );
    });
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
  Future<bool> updateStatusIfOwned({
    required String trackId,
    required String ownerId,
    required EmbeddingStatus status,
  }) async {
    final affected =
        await (database.update(database.embeddingTaskTable)..where(
              (t) => t.trackId.equals(trackId) & t.leaseOwner.equals(ownerId),
            ))
            .write(
              EmbeddingTaskTableCompanion(
                status: Value(status.name),
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
    required List<double> vector,
  }) {
    return database.transaction<bool>(() async {
      final completed =
          await (database.update(database.embeddingTaskTable)..where(
                (task) =>
                    task.trackId.equals(trackId) &
                    task.status.equals(EmbeddingStatus.processing.name) &
                    task.leaseOwner.equals(ownerId),
              ))
              .write(
                EmbeddingTaskTableCompanion(
                  status: Value(EmbeddingStatus.done.name),
                  leaseOwner: const Value(null),
                  leaseUntil: const Value(null),
                ),
              );
      if (completed != 1) return false;

      final trackUpdated =
          await (database.update(database.trackTable)
                ..where((track) => track.id.equals(trackId)))
              .write(TrackTableCompanion(embedding: Value(jsonEncode(vector))));
      if (trackUpdated != 1) {
        throw StateError('Cannot complete embedding: track $trackId not found');
      }
      return true;
    });
  }

  @override
  Future<void> save(EmbeddingTaskDto task) async {
    await database
        .into(database.embeddingTaskTable)
        .insert(
          EmbeddingTaskTableCompanion(
            id: Value(task.id),
            trackId: Value(task.trackId),
            filePath: Value(task.filePath),
            status: Value(task.status.name),
            createdAt: Value(task.createdAt),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  @override
  Future<void> deleteById(String id) async {
    await (database.delete(
      database.embeddingTaskTable,
    )..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> clear() async {
    await database.delete(database.embeddingTaskTable).go();
  }

  @override
  Stream<List<EmbeddingTaskDto>> watch() => watchAll();

  @override
  Stream<List<EmbeddingTaskDto>> watchAll() {
    return database
        .select(database.embeddingTaskTable)
        .watch()
        .map(
          (rows) => rows.map((e) => EmbeddingTaskDto.fromDataClass(e)).toList(),
        );
  }

  @override
  Future<EmbeddingTaskDto> getById(String id) async {
    final res = await (database.select(
      database.embeddingTaskTable,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (res == null) {
      throw Exception('Record with id $id not found');
    }
    return EmbeddingTaskDto.fromDataClass(res);
  }

  @override
  Future<EmbeddingTaskDto> getByTrackId(String id) async {
    final res = await (database.select(
      database.embeddingTaskTable,
    )..where((t) => t.trackId.equals(id))).getSingleOrNull();
    if (res == null) {
      throw Exception('Record with trackId $id not found');
    }
    return EmbeddingTaskDto.fromDataClass(res);
  }

  @override
  Future<void> update(EmbeddingTaskDto record) async {
    final updated = await database
        .update(database.embeddingTaskTable)
        .replace(
          EmbeddingTaskTableData(
            id: record.id,
            trackId: record.trackId,
            filePath: record.filePath,
            status: record.status.name,
            createdAt: record.createdAt,
          ),
        );
    if (!updated) {
      await AppLogger.log(
        '[EmbeddingTaskDriftLocalSource.update] Record not found for trackId ${record.trackId}',
      );
    }
  }

  @override
  Future<void> updateStatus(String trackId, EmbeddingStatus status) async {
    await (database.update(database.embeddingTaskTable)
          ..where((t) => t.trackId.equals(trackId)))
        .write(EmbeddingTaskTableCompanion(status: Value(status.name)));
  }
}
