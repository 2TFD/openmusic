import 'package:openmusic/layers/domain/entities/play_record.dart';

abstract class PlayRecordRepository {
  Future<void> save(PlayRecord record);
  Future<PlayRecordSummary> aggregate({required DateTime from});
  Future<List<String>> getRecentTrackIds({int limit = 20});
  Future<void> clear();
  Stream<void> watchChanges();
}
