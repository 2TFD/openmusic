import 'package:drift/drift.dart';
import 'package:openmusic/core/utils/app_logger.dart';
import 'package:openmusic/layers/data/DTO/download_task_dto.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/download_task/download_task_local_data_source.dart';

class DownloadTaskDriftLocalSource implements DownloadTaskLocalDataSource {
  final AppDatabase database;

  DownloadTaskDriftLocalSource(this.database);

  @override
  Future<List<DownloadTaskDto>> getAll() async {
    try {
      final rows = await database.select(database.downloadTaskTable).get();
      return rows.map(DownloadTaskDto.fromDataClass).toList();
    } catch (e, st) {
      await AppLogger.log(
        '[DownloadTaskDriftLocalSource.getAll] $e\n$st',
      );
      rethrow;
    }
  }

  @override
  Future<DownloadTaskDto?> getByTrackId(String trackId) async {
    try {
      final row = await (database.select(database.downloadTaskTable)
            ..where((t) => t.trackId.equals(trackId)))
          .getSingleOrNull();
      return row == null ? null : DownloadTaskDto.fromDataClass(row);
    } catch (e, st) {
      await AppLogger.log(
        '[DownloadTaskDriftLocalSource.getByTrackId] $e\n$st',
      );
      rethrow;
    }
  }

  @override
  Future<void> save(DownloadTaskDto task) async {
    try {
      await database.into(database.downloadTaskTable).insert(
            DownloadTaskTableCompanion(
              trackId: Value(task.trackId),
              originalUrl: Value(task.originalUrl),
              status: Value(task.status.name),
              createdAt: Value(task.createdAt),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    } catch (e, st) {
      await AppLogger.log(
        '[DownloadTaskDriftLocalSource.save] $e\n$st',
      );
      rethrow;
    }
  }

  @override
  Future<void> update(DownloadTaskDto task) async {
    try {
      await database.update(database.downloadTaskTable).replace(
            DownloadTaskTableData(
              trackId: task.trackId,
              originalUrl: task.originalUrl,
              status: task.status.name,
              createdAt: task.createdAt,
            ),
          );
    } catch (e, st) {
      await AppLogger.log(
        '[DownloadTaskDriftLocalSource.update] $e\n$st',
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteByTrackId(String trackId) async {
    try {
      await (database.delete(database.downloadTaskTable)
            ..where((t) => t.trackId.equals(trackId)))
          .go();
    } catch (e, st) {
      await AppLogger.log(
        '[DownloadTaskDriftLocalSource.deleteByTrackId] $e\n$st',
      );
      rethrow;
    }
  }
}
