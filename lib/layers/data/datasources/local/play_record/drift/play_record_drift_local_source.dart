import 'package:drift/drift.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/play_record/play_record_local_data_source.dart';
import 'package:openmusic/layers/data/DTO/play_record_dto.dart';

class PlayRecordDriftLocalSource implements PlayRecordLocalDataSource {
  final AppDatabase database;
  PlayRecordDriftLocalSource(this.database);

  @override
  Future<void> clear() async {
    await database.delete(database.playRecordTable).go();
  }

  @override
  Future<void> deleteRecord(String id) async {
    await (database.delete(
      database.playRecordTable,
    )..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<List<String>> getRecentTrackIds({int limit = 20}) async {
    final rows = await database.customSelect(
      'SELECT track_id FROM play_record_table'
      ' GROUP BY track_id'
      ' ORDER BY MAX(played_at) DESC'
      ' LIMIT ?',
      variables: [Variable.withInt(limit)],
      readsFrom: {database.playRecordTable},
    ).get();
    return rows.map((r) => r.read<String>('track_id')).toList();
  }

  @override
  Future<List<PlayRecordDto>> getRecords({DateTime? from}) async {
    final query = database.select(database.playRecordTable);
    if (from != null) {
      query.where((t) => t.playedAt.isBiggerThanValue(from));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.playedAt)]);
    final rows = await query.get();
    return rows.map(PlayRecordDto.fromDataClass).toList();
  }

  @override
  Future<PlayRecordDto?> getLatestByTrackId(String trackId) async {
    final row = await (database.select(database.playRecordTable)
          ..where((t) => t.trackId.equals(trackId))
          ..orderBy([(t) => OrderingTerm.desc(t.playedAt)])
          ..limit(1))
        .getSingleOrNull();
    return row != null ? PlayRecordDto.fromDataClass(row) : null;
  }

  @override
  Future<void> saveRecord(PlayRecordDto record) async {
    await database
        .into(database.playRecordTable)
        .insert(
          PlayRecordTableCompanion(
            id: Value(record.id),
            trackId: Value(record.trackId),
            trackTitle: Value(record.trackTitle),
            artistName: Value(record.artistName),
            sourceType: Value(record.sourceType.name),
            listenedDurationMilisecond: Value(record.listenedMs),
            playedAt: Value(record.playedAt),
          ),
        );
  }

  @override
  Stream<List<PlayRecordDto>> watchPlayRecord() {
    return database
        .select(database.playRecordTable)
        .watch()
        .map((rows) => rows.map(PlayRecordDto.fromDataClass).toList());
  }
}
