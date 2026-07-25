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
    final models = await localDataSource.getRecords(from: from);
    return models.map(PlayRecordMapper.toEntity).toList();
  }

  @override
  Future<PlayRecord?> getLatestByTrackId(String trackId) async {
    final dto = await localDataSource.getLatestByTrackId(trackId);
    return dto != null ? PlayRecordMapper.toEntity(dto) : null;
  }

  @override
  Future<List<String>> getRecentTrackIds({int limit = 20}) =>
      localDataSource.getRecentTrackIds(limit: limit);

  @override
  Future<void> clear() async {
    await localDataSource.clear();
  }

  @override
  Stream<List<PlayRecord>> watchPlayRecord() {
    return localDataSource
        .watchPlayRecord()
        .map((dtos) => dtos.map(PlayRecordMapper.toEntity).toList());
  }
}
