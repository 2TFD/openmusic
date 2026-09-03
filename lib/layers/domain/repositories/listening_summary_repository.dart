import 'package:openmusic/layers/domain/entities/listening_summary.dart';

abstract class ListeningSummaryRepository {
  Future<void> save(ListeningSummary record);
  Future<ListeningStatsSummary> aggregate({required DateTime from});
  Future<List<String>> getRecentTrackIds({int limit = 20});
  Future<void> clear();
  Stream<void> watchChanges();
}
