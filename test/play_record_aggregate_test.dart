import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/play_record/drift/play_record_drift_local_source.dart';
import 'package:openmusic/layers/data/models/play_record_dto.dart';
import 'package:openmusic/layers/domain/entities/source.dart';

void main() {
  test('statistics are aggregated and filtered by SQLite', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final source = PlayRecordDriftLocalSource(database);
    await source.saveRecord(_record('old', DateTime.utc(2025), 9000));
    await source.saveRecord(_record('new-1', DateTime.utc(2026, 2), 1000));
    await source.saveRecord(
      _record('new-2', DateTime.utc(2026, 3), 2000, artist: 'Other'),
    );

    final summary = await source.aggregate(from: DateTime.utc(2026));

    expect(summary.totalTracks, 2);
    expect(summary.totalMilliseconds, 3000);
    expect(summary.uniqueArtists, 2);
    expect(summary.bySource, {'soundcloud': 2});
  });
}

PlayRecordDto _record(
  String id,
  DateTime playedAt,
  int listenedMs, {
  String artist = 'Artist',
}) => PlayRecordDto(
  id: id,
  trackId: id,
  trackTitle: id,
  artistName: artist,
  sourceType: SourceType.soundcloud,
  listenedMs: listenedMs,
  playedAt: playedAt,
);
