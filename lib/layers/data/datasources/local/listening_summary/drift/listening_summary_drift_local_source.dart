import 'package:drift/drift.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/listening_summary/listening_summary_local_data_source.dart';
import 'package:openmusic/layers/data/models/listening_summary_dto.dart';
import 'package:openmusic/layers/data/models/listening_stats_summary_dto.dart';

class ListeningSummaryDriftLocalSource
    implements ListeningSummaryLocalDataSource {
  final AppDatabase database;
  ListeningSummaryDriftLocalSource(this.database);

  @override
  Future<ListeningStatsSummaryDto> aggregate({required DateTime from}) async {
    final summary = await database
        .customSelect(
          '''
SELECT
  COUNT(*) AS total_tracks,
  COALESCE(SUM(listened_duration_milliseconds), 0) AS total_ms,
  COUNT(DISTINCT artist_name) AS unique_artists
FROM listening_summary_table
WHERE played_at >= ?
''',
          variables: [Variable<DateTime>(from)],
          readsFrom: {database.listeningSummaryTable},
        )
        .getSingle();
    final sourceRows = await database
        .customSelect(
          '''
SELECT source_type, COUNT(*) AS play_count
FROM listening_summary_table
WHERE played_at >= ?
GROUP BY source_type
''',
          variables: [Variable<DateTime>(from)],
          readsFrom: {database.listeningSummaryTable},
        )
        .get();
    return ListeningStatsSummaryDto(
      totalTracks: summary.read<int>('total_tracks'),
      totalMilliseconds: summary.read<int>('total_ms'),
      uniqueArtists: summary.read<int>('unique_artists'),
      bySource: {
        for (final row in sourceRows)
          row.read<String>('source_type'): row.read<int>('play_count'),
      },
    );
  }

  @override
  Future<void> clear() async {
    await database.delete(database.listeningSummaryTable).go();
  }

  @override
  Future<void> deleteRecord(String id) async {
    await (database.delete(
      database.listeningSummaryTable,
    )..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<List<String>> getRecentTrackIds({int limit = 20}) async {
    final rows = await database
        .customSelect(
          'SELECT track_id FROM listening_summary_table'
          ' GROUP BY track_id'
          ' ORDER BY MAX(played_at) DESC'
          ' LIMIT ?',
          variables: [Variable.withInt(limit)],
          readsFrom: {database.listeningSummaryTable},
        )
        .get();
    return rows.map((r) => r.read<String>('track_id')).toList();
  }

  @override
  Future<void> saveListeningSummary(ListeningSummaryDto record) async {
    await database
        .into(database.listeningSummaryTable)
        .insert(
          ListeningSummaryTableCompanion(
            id: Value(record.id),
            trackId: Value(record.trackId),
            trackTitle: Value(record.trackTitle),
            artistName: Value(record.artistName),
            sourceType: Value(record.sourceType.name),
            listenedDurationMilliseconds: Value(record.listenedMs),
            playedAt: Value(record.playedAt),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  @override
  Stream<void> watchChanges() => database
      .customSelect(
        'SELECT 1 AS change_signal',
        readsFrom: {database.listeningSummaryTable},
      )
      .watch()
      .map((_) {});
}
