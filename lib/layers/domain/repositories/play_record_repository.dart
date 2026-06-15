import 'package:openmusic/layers/domain/entities/play_record.dart';

abstract class PlayRecordRepository {
  Future<void> save(PlayRecord record);
  Future<List<PlayRecord>> getAll({DateTime? from});
  Future<void> clear();
  Stream<dynamic> watchPlayRecord();
}
