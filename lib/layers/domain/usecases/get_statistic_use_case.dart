import 'package:openmusic/layers/domain/entities/statistic.dart';
import 'package:openmusic/layers/domain/repositories/play_record_repository.dart';

class GetStatisticsUseCase {
  final PlayRecordRepository _repo;

  GetStatisticsUseCase({required PlayRecordRepository repo}) : _repo = repo;

  Future<Statistic> execute(StatsPeriod period) async {
    final summary = await _repo.aggregate(from: period.startDate);
    if (summary.totalTracks == 0) return Statistic.empty(period);

    return Statistic(
      totalTracks: summary.totalTracks,
      totalTime: summary.totalTime,
      uniqueArtists: summary.uniqueArtists,
      bySource: summary.bySource,
      period: period,
    );
  }
}
