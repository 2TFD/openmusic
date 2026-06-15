import 'package:openmusic/layers/data/DTO/play_record_dto.dart';

abstract class PlayRecordLocalDataSource {
  Future<List<PlayRecordDto>> getRecords();
  Future<void> saveRecord(PlayRecordDto record);
  Future<void> deleteRecord(String id);
  Future<void> clear();
  Stream<dynamic> watchPlayRecord();
}
