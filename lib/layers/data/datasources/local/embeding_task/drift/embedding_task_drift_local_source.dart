import 'package:drift/drift.dart';
import 'package:openmusic/core/utils/app_logger.dart';
import 'package:openmusic/layers/data/DTO/embedding_task_dto.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/embeding_task/embedding_task_local_data_source.dart';

class EmbeddingTaskDriftLocalSource implements EmbeddingTaskLocalDataSource {
  final AppDatabase database;
  EmbeddingTaskDriftLocalSource(this.database);

  @override
  Future<List<EmbeddingTaskDto>> getAll() async {
    try {
      final List<EmbeddingTaskTableData> res = await database
          .select(database.embeddingTaskTable)
          .get();
      return res.map((e) => EmbeddingTaskDto.fromDataClass(e)).toList();
    } catch (e, st) {
      await AppLogger.log(
        '[EmbeddingTaskDriftLocalSouce.get] Error getting records: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Future<void> save(EmbeddingTaskDto task) async {
    try {
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
          );
    } catch (e, st) {
      await AppLogger.log(
        '[EmbeddingTaskDriftLocalSouce.save] Error saving record ${task.id}: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteById(String id) async {
    try {
      await (database.delete(
        database.embeddingTaskTable,
      )..where((t) => t.id.equals(id))).go();
    } catch (e, st) {
      await AppLogger.log(
        '[EmbeddingTaskDriftLocalSouce.deleteById] Error deleting record $id: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Future<void> clear() async {
    try {
      await database.delete(database.embeddingTaskTable).go();
    } catch (e, st) {
      await AppLogger.log(
        '[EmbeddingTaskDriftLocalSouce.clear] Error clearing records: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Stream<List<dynamic>> watch() {
    try {
      return database.select(database.embeddingTaskTable).watch();
    } catch (e, st) {
      AppLogger.log(
        '[EmbeddingTaskDriftLocalSouce.watch] Error watching records: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Future<EmbeddingTaskDto> getById(String id) async {
    try {
      final res = await (database.select(
        database.embeddingTaskTable,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (res == null) {
        throw Exception('Record with id $id not found');
      }
      return EmbeddingTaskDto.fromDataClass(res);
    } catch (e, st) {
      await AppLogger.log(
        '[EmbeddingTaskDriftLocalSouce.getById] Error getting record by id $id: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Future<EmbeddingTaskDto> getByTrackId(String id) async {
    try {
      final res = await (database.select(
        database.embeddingTaskTable,
      )..where((t) => t.trackId.equals(id))).getSingleOrNull();
      if (res == null) {
        throw Exception('Record with trackId $id not found');
      }
      return EmbeddingTaskDto.fromDataClass(res);
    } catch (e, st) {
      await AppLogger.log(
        '[EmbeddingTaskDriftLocalSouce.getByTrackId] Error getting record by trackId $id: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Future<void> update(EmbeddingTaskDto record) async {
    try {
      await database
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
    } catch (e, st) {
      await AppLogger.log(
        '[EmbeddingTaskDriftLocalSouce.update] Error updating record ${record.id}: $e, stackTrace: $st',
      );
      rethrow;
    }
  }
}
