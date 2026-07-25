import 'package:drift/drift.dart';
import 'package:openmusic/core/utils/app_logger.dart';
import 'package:openmusic/layers/data/DTO/download_task_dto.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/download_task/download_task_local_data_source.dart';
import 'package:openmusic/layers/domain/entities/download_track_task.dart';

class DownloadTaskDriftLocalSource implements DownloadTaskLocalDataSource {
  final AppDatabase database;

  DownloadTaskDriftLocalSource(this.database);

  @override
  Future<List<DownloadTaskDto>> getAll() async {
    final rows = await database.select(database.downloadTaskTable).get();
    return rows.map(DownloadTaskDto.fromDataClass).toList();
  }

  @override
  Future<bool> enqueue({
    required String trackId,
    required String originalUrl,
    required DateTime createdAt,
  }) async {
    final affected = await database.customUpdate(
      '''
INSERT INTO download_task_table (
  track_id, original_url, status, created_at, lease_owner, lease_until
) VALUES (?, ?, ?, ?, NULL, NULL)
ON CONFLICT(track_id) DO UPDATE SET
  original_url = excluded.original_url,
  status = excluded.status,
  created_at = excluded.created_at,
  lease_owner = NULL,
  lease_until = NULL
WHERE download_task_table.status IN (?, ?)
''',
      variables: [
        Variable<String>(trackId),
        Variable<String>(originalUrl),
        Variable<String>(DownloadStatus.queued.name),
        Variable<DateTime>(createdAt),
        Variable<String>(DownloadStatus.completed.name),
        Variable<String>(DownloadStatus.failed.name),
      ],
      updates: {database.downloadTaskTable},
    );
    return affected == 1;
  }

  @override
  Future<DownloadTaskDto?> claimNext({
    required String ownerId,
    required DateTime leaseUntil,
  }) async {
    return database.transaction<DownloadTaskDto?>(() async {
      final now = DateTime.now();
      final row =
          await (database.select(database.downloadTaskTable)
                ..where((t) {
                  final leaseExpired =
                      t.leaseUntil.isNull() |
                      t.leaseUntil.isSmallerThanValue(now);
                  return t.status.equals(DownloadStatus.queued.name) |
                      (t.status.equals(DownloadStatus.downloading.name) &
                          leaseExpired);
                })
                ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
                ..limit(1))
              .getSingleOrNull();
      if (row == null) return null;

      final claimed =
          await (database.update(database.downloadTaskTable)..where((t) {
                final leaseExpired =
                    t.leaseUntil.isNull() |
                    t.leaseUntil.isSmallerThanValue(now);
                final claimable =
                    t.status.equals(DownloadStatus.queued.name) |
                    (t.status.equals(DownloadStatus.downloading.name) &
                        leaseExpired);
                return t.trackId.equals(row.trackId) & claimable;
              }))
              .write(
                DownloadTaskTableCompanion(
                  status: Value(DownloadStatus.downloading.name),
                  leaseOwner: Value(ownerId),
                  leaseUntil: Value(leaseUntil),
                ),
              );
      if (claimed != 1) return null;
      return DownloadTaskDto.fromDataClass(
        row.copyWith(status: DownloadStatus.downloading.name),
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
        await (database.update(database.downloadTaskTable)..where(
              (t) =>
                  t.trackId.equals(trackId) &
                  t.status.equals(DownloadStatus.downloading.name) &
                  t.leaseOwner.equals(ownerId),
            ))
            .write(DownloadTaskTableCompanion(leaseUntil: Value(leaseUntil)));
    return affected == 1;
  }

  @override
  Future<bool> releaseLease({
    required String trackId,
    required String ownerId,
  }) async {
    final affected =
        await (database.update(database.downloadTaskTable)..where(
              (t) => t.trackId.equals(trackId) & t.leaseOwner.equals(ownerId),
            ))
            .write(
              DownloadTaskTableCompanion(
                status: Value(DownloadStatus.queued.name),
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
    required DownloadStatus status,
  }) async {
    final affected =
        await (database.update(database.downloadTaskTable)..where(
              (t) => t.trackId.equals(trackId) & t.leaseOwner.equals(ownerId),
            ))
            .write(
              DownloadTaskTableCompanion(
                status: Value(status.name),
                leaseOwner: const Value(null),
                leaseUntil: const Value(null),
              ),
            );
    return affected == 1;
  }

  @override
  Future<DownloadTaskDto?> getByTrackId(String trackId) async {
    final row = await (database.select(
      database.downloadTaskTable,
    )..where((t) => t.trackId.equals(trackId))).getSingleOrNull();
    return row == null ? null : DownloadTaskDto.fromDataClass(row);
  }

  @override
  Future<void> save(DownloadTaskDto task) async {
    await database
        .into(database.downloadTaskTable)
        .insert(
          DownloadTaskTableCompanion(
            trackId: Value(task.trackId),
            originalUrl: Value(task.originalUrl),
            status: Value(task.status.name),
            createdAt: Value(task.createdAt),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  @override
  Future<void> update(DownloadTaskDto task) async {
    final updated = await database
        .update(database.downloadTaskTable)
        .replace(
          DownloadTaskTableData(
            trackId: task.trackId,
            originalUrl: task.originalUrl,
            status: task.status.name,
            createdAt: task.createdAt,
          ),
        );
    if (!updated) {
      await AppLogger.log(
        '[DownloadTaskDriftLocalSource.update] Record not found for trackId ${task.trackId}',
      );
    }
  }

  @override
  Future<void> updateStatus(String trackId, DownloadStatus status) async {
    await (database.update(database.downloadTaskTable)
          ..where((t) => t.trackId.equals(trackId)))
        .write(DownloadTaskTableCompanion(status: Value(status.name)));
  }

  @override
  Future<void> deleteByTrackId(String trackId) async {
    await (database.delete(
      database.downloadTaskTable,
    )..where((t) => t.trackId.equals(trackId))).go();
  }
}
