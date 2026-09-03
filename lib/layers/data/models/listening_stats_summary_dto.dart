class ListeningStatsSummaryDto {
  const ListeningStatsSummaryDto({
    required this.totalTracks,
    required this.totalMilliseconds,
    required this.uniqueArtists,
    required this.bySource,
  });

  final int totalTracks;
  final int totalMilliseconds;
  final int uniqueArtists;
  final Map<String, int> bySource;
}
