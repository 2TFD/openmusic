import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/lyrics_resolution_task.dart';
import '../../domain/repositories/lyrics_resolution_task_repository.dart';
import '../database/app_database.dart';

class LyricsResolutionTaskRepositoryImpl
    implements LyricsResolutionTaskRepository {
  LyricsResolutionTaskRepositoryImpl(this.database);

  final AppDatabase database;

  @override
  Stream<int> watchPendingCount() =>
      (database.select(database.lyricsResolutionTaskTable)..where(
            (table) =>
                table.status.equals(LyricsResolutionTaskStatus.queued.name) |
                table.status.equals(LyricsResolutionTaskStatus.running.name),
          ))
          .watch()
          .map((rows) => rows.length);

  @override
  Future<void> enqueue(String trackId) => database.transaction(() async {
    final now = DateTime.now();
    final existing = await (database.select(
      database.lyricsResolutionTaskTable,
    )..where((table) => table.trackId.equals(trackId))).getSingleOrNull();
    if (existing == null) {
      await database
          .into(database.lyricsResolutionTaskTable)
          .insert(
            LyricsResolutionTaskTableCompanion.insert(
              id: const Uuid().v4(),
              trackId: trackId,
              status: LyricsResolutionTaskStatus.queued.name,
              createdAt: now,
              updatedAt: now,
            ),
          );
      return;
    }
    if (existing.status == LyricsResolutionTaskStatus.running.name ||
        existing.status == LyricsResolutionTaskStatus.queued.name) {
      return;
    }
    await (database.update(
      database.lyricsResolutionTaskTable,
    )..where((table) => table.id.equals(existing.id))).write(
      LyricsResolutionTaskTableCompanion(
        status: Value(LyricsResolutionTaskStatus.queued.name),
        attemptCount: const Value(0),
        nextAttemptAt: const Value(null),
        lastErrorCode: const Value(null),
        lastError: const Value(null),
        updatedAt: Value(now),
      ),
    );
  });

  @override
  Future<LyricsResolutionTask?> claimNext() => database.transaction(() async {
    final now = DateTime.now();
    final row =
        await (database.select(database.lyricsResolutionTaskTable)
              ..where(
                (table) =>
                    table.status.equals(
                      LyricsResolutionTaskStatus.queued.name,
                    ) &
                    (table.nextAttemptAt.isNull() |
                        table.nextAttemptAt.isSmallerOrEqualValue(now)),
              )
              ..orderBy([(table) => OrderingTerm.asc(table.createdAt)])
              ..limit(1))
            .getSingleOrNull();
    if (row == null) return null;
    final affected =
        await (database.update(database.lyricsResolutionTaskTable)..where(
              (table) =>
                  table.id.equals(row.id) &
                  table.status.equals(LyricsResolutionTaskStatus.queued.name),
            ))
            .write(
              LyricsResolutionTaskTableCompanion(
                status: Value(LyricsResolutionTaskStatus.running.name),
                attemptCount: Value(row.attemptCount + 1),
                updatedAt: Value(now),
              ),
            );
    if (affected != 1) return null;
    return _task(
      await (database.select(
        database.lyricsResolutionTaskTable,
      )..where((table) => table.id.equals(row.id))).getSingle(),
    );
  });

  @override
  Future<void> complete(String id) =>
      (database.update(
        database.lyricsResolutionTaskTable,
      )..where((table) => table.id.equals(id))).write(
        LyricsResolutionTaskTableCompanion(
          status: Value(LyricsResolutionTaskStatus.completed.name),
          nextAttemptAt: const Value(null),
          lastErrorCode: const Value(null),
          lastError: const Value(null),
          updatedAt: Value(DateTime.now()),
        ),
      );

  @override
  Future<void> fail(
    String id, {
    required String errorCode,
    String? errorMessage,
    required bool requeue,
    DateTime? retryAt,
  }) =>
      (database.update(
        database.lyricsResolutionTaskTable,
      )..where((table) => table.id.equals(id))).write(
        LyricsResolutionTaskTableCompanion(
          status: Value(
            requeue
                ? LyricsResolutionTaskStatus.queued.name
                : LyricsResolutionTaskStatus.failed.name,
          ),
          nextAttemptAt: Value(requeue ? retryAt : null),
          lastErrorCode: Value(errorCode),
          lastError: Value(errorMessage),
          updatedAt: Value(DateTime.now()),
        ),
      );

  @override
  Future<void> resetRunning() =>
      (database.update(database.lyricsResolutionTaskTable)..where(
            (table) =>
                table.status.equals(LyricsResolutionTaskStatus.running.name),
          ))
          .write(
            LyricsResolutionTaskTableCompanion(
              status: Value(LyricsResolutionTaskStatus.queued.name),
              updatedAt: Value(DateTime.now()),
            ),
          );

  static LyricsResolutionTask _task(LyricsResolutionTaskTableData row) =>
      LyricsResolutionTask(
        id: row.id,
        trackId: row.trackId,
        status: LyricsResolutionTaskStatus.values.byName(row.status),
        attemptCount: row.attemptCount,
        scheduledAt: row.nextAttemptAt,
        lastErrorCode: row.lastErrorCode,
        lastError: row.lastError,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
}
