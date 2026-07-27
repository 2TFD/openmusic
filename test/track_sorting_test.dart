import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/data/models/track_dto.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/track/drift/track_drift_local_source.dart';

void main() {
  late AppDatabase database;
  late TrackDriftLocalSource source;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    source = TrackDriftLocalSource(database);
  });

  tearDown(() => database.close());

  test(
    'getTracks is deterministic and watchChanges emits without loading rows',
    () async {
      final sameDate = DateTime.utc(2025, 1, 1);
      await source.saveTrack(_track('old', DateTime.utc(2024, 1, 1)));
      await source.saveTrack(_track('same-b', sameDate));
      await source.saveTrack(_track('unknown', null));
      await source.saveTrack(_track('same-a', sameDate));

      final expected = ['same-a', 'same-b', 'old', 'unknown'];

      expect((await source.getTracks()).map((track) => track.id), expected);
      final changes = StreamIterator<void>(source.watchChanges());
      expect(await changes.moveNext(), isTrue);
      final changed = changes.moveNext();
      await source.saveTrack(_track('newest', DateTime.utc(2026)));
      expect(await changed, isTrue);
      await changes.cancel();
    },
  );
}

TrackDto _track(String id, DateTime? addedAt) {
  return TrackDto(
    id: id,
    title: id,
    filePath: null,
    artists: const [],
    durationMs: 1000,
    sourceType: 'soundcloud',
    originalUrl: 'https://example.com/$id',
    addedAt: addedAt,
  );
}
