import 'package:openmusic/layers/data/datasources/local/play_record/play_record_local_data_source.dart';
import 'package:openmusic/layers/data/mappers/play_record_mapper.dart';
import 'package:openmusic/layers/domain/entities/play_record.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/repositories/play_record_repository.dart';

class PlayRecordRepositoryImpl implements PlayRecordRepository {
  final PlayRecordLocalDataSource localDataSource;

  PlayRecordRepositoryImpl({required this.localDataSource});

  @override
  Future<PlayRecordSummary> aggregate({required DateTime from}) async {
    final summary = await localDataSource.aggregate(from: from);
    return PlayRecordSummary(
      totalTracks: summary.totalTracks,
      totalTime: Duration(milliseconds: summary.totalMilliseconds),
      uniqueArtists: summary.uniqueArtists,
      bySource: {
        for (final entry in summary.bySource.entries)
          SourceType.values.firstWhere(
            (value) => value.name == entry.key,
            orElse: () => SourceType.unknown,
          ): entry.value,
      },
    );
  }

  @override
  Future<void> save(PlayRecord record) async {
    final model = PlayRecordMapper.toDto(record);
    await localDataSource.saveRecord(model);
  }

  @override
  Future<List<String>> getRecentTrackIds({int limit = 20}) =>
      localDataSource.getRecentTrackIds(limit: limit);

  @override
  Future<void> clear() async {
    await localDataSource.clear();
  }

  @override
  Stream<void> watchChanges() => localDataSource.watchChanges();
}
