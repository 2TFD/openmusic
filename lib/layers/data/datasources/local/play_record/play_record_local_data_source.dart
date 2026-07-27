import 'package:openmusic/layers/data/models/play_record_dto.dart';
import 'package:openmusic/layers/data/models/play_record_summary_dto.dart';

abstract class PlayRecordLocalDataSource {
  Future<PlayRecordSummaryDto> aggregate({required DateTime from});
  Future<List<String>> getRecentTrackIds({int limit = 20});
  Future<void> saveRecord(PlayRecordDto record);
  Future<void> deleteRecord(String id);
  Future<void> clear();
  Stream<void> watchChanges();
}
