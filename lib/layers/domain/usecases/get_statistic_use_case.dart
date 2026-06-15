import 'package:openmusic/layers/domain/entities/statistic.dart';
import 'package:openmusic/layers/domain/repositories/play_record_repository.dart';

class GetStatisticsUseCase {
  final PlayRecordRepository _repo;

  GetStatisticsUseCase({required PlayRecordRepository repo}) : _repo = repo;

  Future<Statistic> execute(StatsPeriod period) async {
    final records = await _repo.getAll(from: period.startDate);
    if (records.isEmpty) return Statistic.empty(period);

    final totalTime = records.fold(
      Duration.zero,
      (sum, r) => sum + r.listenedDuration,
    );

    final uniqueArtists = records.map((r) => r.artistName).toSet().length;

    final bySource = <dynamic, int>{};
    for (final r in records) {
      bySource[r.sourceType] = (bySource[r.sourceType] ?? 0) + 1;
    }

    return Statistic(
      totalTracks: records.length,
      totalTime: totalTime,
      uniqueArtists: uniqueArtists,
      bySource: Map.from(bySource),
      period: period,
    );
  }
}
