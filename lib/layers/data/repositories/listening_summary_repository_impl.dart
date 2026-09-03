import 'package:openmusic/layers/data/datasources/local/listening_summary/listening_summary_local_data_source.dart';
import 'package:openmusic/layers/data/mappers/listening_summary_mapper.dart';
import 'package:openmusic/layers/domain/entities/listening_summary.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/repositories/listening_summary_repository.dart';

class ListeningSummaryRepositoryImpl implements ListeningSummaryRepository {
  final ListeningSummaryLocalDataSource localDataSource;

  ListeningSummaryRepositoryImpl({required this.localDataSource});

  @override
  Future<ListeningStatsSummary> aggregate({required DateTime from}) async {
    final summary = await localDataSource.aggregate(from: from);
    return ListeningStatsSummary(
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
  Future<void> save(ListeningSummary record) async {
    final model = ListeningSummaryMapper.toDto(record);
    await localDataSource.saveListeningSummary(model);
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
