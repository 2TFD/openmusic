import 'package:openmusic/layers/domain/entities/source.dart';

enum StatsPeriod { today, week, twoWeeks, month, allTime }

extension StatsPeriodDateRange on StatsPeriod {
  DateTime get startDate => switch (this) {
    StatsPeriod.today => DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    ),
    StatsPeriod.week => DateTime.now().subtract(const Duration(days: 7)),
    StatsPeriod.twoWeeks => DateTime.now().subtract(const Duration(days: 14)),
    StatsPeriod.month => DateTime.now().subtract(const Duration(days: 30)),
    StatsPeriod.allTime => DateTime(2000),
  };
}

class Statistic {
  final int totalTracks;
  final Duration totalTime;
  final int uniqueArtists;
  final Map<SourceType, int> bySource;
  final StatsPeriod period;

  const Statistic({
    required this.totalTracks,
    required this.totalTime,
    required this.uniqueArtists,
    required this.bySource,
    required this.period,
  });

  static Statistic empty(StatsPeriod period) => Statistic(
    totalTracks: 0,
    totalTime: Duration.zero,
    uniqueArtists: 0,
    bySource: {},
    period: period,
  );
}
