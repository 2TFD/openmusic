import 'package:openmusic/layers/data/DTO/play_record_dto.dart';

abstract class PlayRecordLocalDataSource {
  Future<List<PlayRecordDto>> getRecords({DateTime? from});
  Future<PlayRecordDto?> getLatestByTrackId(String trackId);
  Future<List<String>> getRecentTrackIds({int limit = 20});
  Future<void> saveRecord(PlayRecordDto record);
  Future<void> deleteRecord(String id);
  Future<void> clear();
  Stream<List<PlayRecordDto>> watchPlayRecord();
}
