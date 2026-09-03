import 'package:openmusic/layers/data/models/listening_summary_dto.dart';
import 'package:openmusic/layers/data/models/listening_stats_summary_dto.dart';

abstract class ListeningSummaryLocalDataSource {
  Future<ListeningStatsSummaryDto> aggregate({required DateTime from});
  Future<List<String>> getRecentTrackIds({int limit = 20});
  Future<void> saveListeningSummary(ListeningSummaryDto record);
  Future<void> deleteRecord(String id);
  Future<void> clear();
  Stream<void> watchChanges();
}
