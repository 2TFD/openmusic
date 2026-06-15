import 'package:openmusic/layers/data/datasources/local/play_record/play_record_local_data_source.dart';
import 'package:openmusic/layers/data/mappers/play_record_mapper.dart';
import 'package:openmusic/layers/domain/entities/play_record.dart';
import 'package:openmusic/layers/domain/repositories/play_record_repository.dart';

class PlayRecordRepositoryImpl implements PlayRecordRepository {
  final PlayRecordLocalDataSource localDataSource;

  PlayRecordRepositoryImpl({required this.localDataSource});

  @override
  Future<void> save(PlayRecord record) async {
    final model = PlayRecordMapper.toDto(record);
    await localDataSource.saveRecord(model);
  }

  @override
  Future<List<PlayRecord>> getAll({DateTime? from}) async {
    final models = await localDataSource.getRecords();
    var records = models.map(PlayRecordMapper.toEntity).toList();
    if (from != null) {
      records = records.where((r) => r.playedAt.isAfter(from)).toList();
    }
    records.sort((a, b) => b.playedAt.compareTo(a.playedAt));
    return records;
  }

  @override
  Future<void> clear() async {
    await localDataSource.clear();
  }

  @override
  Stream<dynamic> watchPlayRecord() {
    return localDataSource.watchPlayRecord();
  }
}
