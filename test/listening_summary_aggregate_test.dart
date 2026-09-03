import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/listening_summary/drift/listening_summary_drift_local_source.dart';
import 'package:openmusic/layers/data/models/listening_summary_dto.dart';
import 'package:openmusic/layers/domain/entities/source.dart';

void main() {
  test('statistics are aggregated and filtered by SQLite', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final source = ListeningSummaryDriftLocalSource(database);
    final changes = StreamIterator<void>(source.watchChanges());
    expect(await changes.moveNext(), isTrue);
    final changed = changes.moveNext();
    await source.saveListeningSummary(_record('old', DateTime.utc(2025), 9000));
    expect(await changed, isTrue);
    await changes.cancel();
    await source.saveListeningSummary(
      _record('new-1', DateTime.utc(2026, 2), 1000),
    );
    await source.saveListeningSummary(
      _record('new-2', DateTime.utc(2026, 3), 2000, artist: 'Other'),
    );

    final summary = await source.aggregate(from: DateTime.utc(2026));

    expect(summary.totalTracks, 2);
    expect(summary.totalMilliseconds, 3000);
    expect(summary.uniqueArtists, 2);
    expect(summary.bySource, {'soundcloud': 2});
  });
}

ListeningSummaryDto _record(
  String id,
  DateTime playedAt,
  int listenedMs, {
  String artist = 'Artist',
}) => ListeningSummaryDto(
  id: id,
  trackId: id,
  trackTitle: id,
  artistName: artist,
  sourceType: SourceType.soundcloud,
  listenedMs: listenedMs,
  playedAt: playedAt,
);
