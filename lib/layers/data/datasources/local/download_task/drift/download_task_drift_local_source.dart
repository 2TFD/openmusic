import 'package:drift/drift.dart';
import 'package:openmusic/layers/data/models/download_task_dto.dart';
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
    final now = DateTime.now();
    final rows = await database.customWriteReturning(
      '''
UPDATE download_task_table
SET status = ?, lease_owner = ?, lease_until = ?
WHERE track_id = (
  SELECT track_id
  FROM download_task_table
  WHERE status = ?
     OR (status = ? AND (lease_until IS NULL OR lease_until < ?))
  ORDER BY created_at ASC
  LIMIT 1
)
AND (
  status = ?
  OR (status = ? AND (lease_until IS NULL OR lease_until < ?))
)
RETURNING track_id, original_url, status, created_at
''',
      variables: [
        Variable<String>(DownloadStatus.downloading.name),
        Variable<String>(ownerId),
        Variable<DateTime>(leaseUntil),
        Variable<String>(DownloadStatus.queued.name),
        Variable<String>(DownloadStatus.downloading.name),
        Variable<DateTime>(now),
        Variable<String>(DownloadStatus.queued.name),
        Variable<String>(DownloadStatus.downloading.name),
        Variable<DateTime>(now),
      ],
      updates: {database.downloadTaskTable},
      updateKind: UpdateKind.update,
    );
    if (rows.isEmpty) return null;
    final row = rows.single;
    return DownloadTaskDto(
      trackId: row.read<String>('track_id'),
      originalUrl: row.read<String>('original_url'),
      status: DownloadStatus.values.byName(row.read<String>('status')),
      createdAt: row.read<DateTime>('created_at'),
    );
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
  Future<bool> markFailedIfOwned({
    required String trackId,
    required String ownerId,
  }) async {
    final affected =
        await (database.update(database.downloadTaskTable)..where(
              (t) => t.trackId.equals(trackId) & t.leaseOwner.equals(ownerId),
            ))
            .write(
              DownloadTaskTableCompanion(
                status: Value(DownloadStatus.failed.name),
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
}
