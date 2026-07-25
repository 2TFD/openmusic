import 'package:openmusic/layers/domain/entities/play_record.dart';

abstract class PlayRecordRepository {
  Future<void> save(PlayRecord record);
  Future<List<PlayRecord>> getAll({DateTime? from});
  Future<PlayRecord?> getLatestByTrackId(String trackId);
  Future<List<String>> getRecentTrackIds({int limit = 20});
  Future<void> clear();
  Stream<List<PlayRecord>> watchPlayRecord();
}
