import 'package:openmusic/layers/domain/entities/source.dart';

enum StatsPeriod { today, week, twoWeeks, month, allTime }

extension StatsPeriodLabel on StatsPeriod {
  String get label => switch (this) {
    StatsPeriod.today => 'today',
    StatsPeriod.week => '7 days',
    StatsPeriod.twoWeeks => '2 weeks',
    StatsPeriod.month => 'month',
    StatsPeriod.allTime => 'all time',
  };

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

  String get formattedTime {
    final h = totalTime.inHours;
    final m = totalTime.inMinutes % 60;
    final s = totalTime.inSeconds % 60;
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m';
    return '${s}s';
  }
}
