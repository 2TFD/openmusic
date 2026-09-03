import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/music_analysis.dart';
import '../../domain/entities/music_analysis_failure.dart';
import '../../domain/entities/music_analysis_task.dart';
import '../../domain/repositories/music_analysis_task_repository.dart';
import '../database/app_database.dart';

class MusicAnalysisTaskRepositoryImpl implements MusicAnalysisTaskRepository {
  MusicAnalysisTaskRepositoryImpl(this.database);

  final AppDatabase database;

  @override
  Stream<List<MusicAnalysisTask>> watchAll() =>
      (database.select(database.musicAnalysisTaskTable)
            ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]))
          .watch()
          .map((rows) => rows.map(_toEntity).toList(growable: false));

  @override
  Stream<int> watchPendingCount() =>
      (database.select(database.musicAnalysisTaskTable)..where(
            (table) =>
                table.status.equals(MusicAnalysisTaskStatus.queued.name) |
                table.status.equals(MusicAnalysisTaskStatus.running.name),
          ))
          .watch()
          .map((rows) => rows.length);

  @override
  Future<List<MusicAnalysisTask>> getAll() async =>
      (await database.select(database.musicAnalysisTaskTable).get())
          .map(_toEntity)
          .toList(growable: false);

  @override
  Future<void> enqueue({
    required String trackId,
    required int audioRevision,
    required Set<MusicAnalysisRepresentation> representations,
  }) {
    if (representations.isEmpty) throw ArgumentError.value(representations);
    return database.transaction(() async {
      final now = DateTime.now();
      final queued =
          await (database.select(database.musicAnalysisTaskTable)
                ..where(
                  (table) =>
                      table.trackId.equals(trackId) &
                      table.status.equals(MusicAnalysisTaskStatus.queued.name),
                )
                ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)])
                ..limit(1))
              .getSingleOrNull();
      if (queued != null) {
        final requested = _encode({
          ..._decode(queued.requestedRepresentations),
          ...representations,
        });
        await (database.update(
          database.musicAnalysisTaskTable,
        )..where((table) => table.id.equals(queued.id))).write(
          MusicAnalysisTaskTableCompanion(
            requestedRepresentations: Value(requested),
            audioRevision: Value(audioRevision),
            updatedAt: Value(now),
          ),
        );
        return;
      }

      final running =
          await (database.select(database.musicAnalysisTaskTable)
                ..where(
                  (table) =>
                      table.trackId.equals(trackId) &
                      table.status.equals(MusicAnalysisTaskStatus.running.name),
                )
                ..limit(1))
              .getSingleOrNull();
      if (running == null) {
        final reusable =
            await (database.select(database.musicAnalysisTaskTable)
                  ..where((table) => table.trackId.equals(trackId))
                  ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)])
                  ..limit(1))
                .getSingleOrNull();
        if (reusable != null) {
          await (database.update(
            database.musicAnalysisTaskTable,
          )..where((table) => table.id.equals(reusable.id))).write(
            MusicAnalysisTaskTableCompanion(
              requestedRepresentations: Value(_encode(representations)),
              audioRevision: Value(audioRevision),
              status: Value(MusicAnalysisTaskStatus.queued.name),
              attemptCount: const Value(0),
              lastErrorCode: const Value(null),
              lastError: const Value(null),
              updatedAt: Value(now),
            ),
          );
          return;
        }
      }

      await database
          .into(database.musicAnalysisTaskTable)
          .insert(
            MusicAnalysisTaskTableCompanion.insert(
              id: const Uuid().v4(),
              trackId: trackId,
              requestedRepresentations: _encode(representations),
              audioRevision: audioRevision,
              status: MusicAnalysisTaskStatus.queued.name,
              createdAt: now,
              updatedAt: now,
            ),
          );
    });
  }

  @override
  Future<MusicAnalysisTask?> claimNext() {
    return database.transaction(() async {
      final row =
          await (database.select(database.musicAnalysisTaskTable)
                ..where(
                  (table) =>
                      table.status.equals(MusicAnalysisTaskStatus.queued.name),
                )
                ..orderBy([(table) => OrderingTerm.asc(table.createdAt)])
                ..limit(1))
              .getSingleOrNull();
      if (row == null) return null;
      final affected =
          await (database.update(database.musicAnalysisTaskTable)..where(
                (table) =>
                    table.id.equals(row.id) &
                    table.status.equals(MusicAnalysisTaskStatus.queued.name),
              ))
              .write(
                MusicAnalysisTaskTableCompanion(
                  status: Value(MusicAnalysisTaskStatus.running.name),
                  attemptCount: Value(row.attemptCount + 1),
                  updatedAt: Value(DateTime.now()),
                ),
              );
      if (affected != 1) return null;
      return _toEntity(
        await (database.select(
          database.musicAnalysisTaskTable,
        )..where((table) => table.id.equals(row.id))).getSingle(),
      );
    });
  }

  @override
  Future<void> complete(String id) =>
      (database.update(
        database.musicAnalysisTaskTable,
      )..where((table) => table.id.equals(id))).write(
        MusicAnalysisTaskTableCompanion(
          status: Value(MusicAnalysisTaskStatus.completed.name),
          lastErrorCode: const Value(null),
          lastError: const Value(null),
          updatedAt: Value(DateTime.now()),
        ),
      );

  @override
  Future<void> fail(
    String id,
    MusicAnalysisFailure failure, {
    required bool requeue,
  }) =>
      (database.update(
        database.musicAnalysisTaskTable,
      )..where((table) => table.id.equals(id))).write(
        MusicAnalysisTaskTableCompanion(
          status: Value(
            requeue
                ? MusicAnalysisTaskStatus.queued.name
                : MusicAnalysisTaskStatus.failed.name,
          ),
          lastErrorCode: Value(failure.kind.name),
          lastError: Value(failure.userMessage),
          updatedAt: Value(DateTime.now()),
        ),
      );

  @override
  Future<void> retryFailed() =>
      (database.update(database.musicAnalysisTaskTable)..where(
            (table) => table.status.equals(MusicAnalysisTaskStatus.failed.name),
          ))
          .write(
            MusicAnalysisTaskTableCompanion(
              status: Value(MusicAnalysisTaskStatus.queued.name),
              attemptCount: const Value(0),
              lastErrorCode: const Value(null),
              lastError: const Value(null),
              updatedAt: Value(DateTime.now()),
            ),
          );

  @override
  Future<void> resetRunning() =>
      (database.update(database.musicAnalysisTaskTable)..where(
            (table) =>
                table.status.equals(MusicAnalysisTaskStatus.running.name),
          ))
          .write(
            MusicAnalysisTaskTableCompanion(
              status: Value(MusicAnalysisTaskStatus.queued.name),
              updatedAt: Value(DateTime.now()),
            ),
          );

  static MusicAnalysisTask _toEntity(MusicAnalysisTaskTableData row) =>
      MusicAnalysisTask(
        id: row.id,
        trackId: row.trackId,
        requestedRepresentations: _decode(row.requestedRepresentations),
        audioRevision: row.audioRevision,
        status: MusicAnalysisTaskStatus.values.byName(row.status),
        attemptCount: row.attemptCount,
        lastErrorCode: row.lastErrorCode,
        lastError: row.lastError,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  static String _encode(Set<MusicAnalysisRepresentation> values) {
    final names = values.map((value) => value.apiName).toList()..sort();
    return names.join(',');
  }

  static Set<MusicAnalysisRepresentation> _decode(String value) => value
      .split(',')
      .where((entry) => entry.isNotEmpty)
      .map(MusicAnalysisRepresentation.parse)
      .toSet();
}
