import 'package:drift/drift.dart';
import 'package:openmusic/core/utils/app_logger.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/play_record/play_record_local_data_source.dart';
import 'package:openmusic/layers/data/DTO/play_record_dto.dart';

class PlayRecordDriftLocalSource implements PlayRecordLocalDataSource {
  final AppDatabase database;
  PlayRecordDriftLocalSource(this.database);

  @override
  Future<void> clear() async {
    try {
      await database.delete(database.playRecordTable).go();
    } catch (e, st) {
      await AppLogger.log(
        '[PlayRecordDriftLocalSource.clear] Error clearing records: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteRecord(String id) async {
    try {
      await (database.delete(
        database.playRecordTable,
      )..where((t) => t.id.equals(id))).go();
    } catch (e, st) {
      await AppLogger.log(
        '[PlayRecordDriftLocalSource.deleteRecord] Error deleting record $id: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Future<List<PlayRecordDto>> getRecords() async {
    try {
      final List<PlayRecordTableData> res = await database
          .select(database.playRecordTable)
          .get();
      return res.map((e) => PlayRecordDto.fromDataClass(e)).toList();
    } catch (e, st) {
      await AppLogger.log(
        '[PlayRecordDriftLocalSource.getRecords] Error getting records: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Future<void> saveRecord(PlayRecordDto record) async {
    try {
      await database
          .into(database.playRecordTable)
          .insert(
            PlayRecordTableCompanion(
              id: Value(record.id),
              trackId: Value(record.trackId),
              trackTitle: Value(record.trackTitle),
              artistName: Value(record.artistName),
              sourceType: Value(record.sourceType.name),
              listenedDurationMilisecond: Value(record.listenedMs),
              playedAt: Value(record.playedAt),
            ),
          );
    } catch (e, st) {
      await AppLogger.log(
        '[PlayRecordDriftLocalSource.saveRecord] Error saving record ${record.id}: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Stream<dynamic> watchPlayRecord() {
    try {
      return database.select(database.playRecordTable).watch();
    } catch (e, st) {
      AppLogger.log(
        '[PlayRecordDriftLocalSource.watchPlayRecord] Error watching records: $e, stackTrace: $st',
      );
      rethrow;
    }
  }
}
