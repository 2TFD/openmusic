import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/track/drift/track_drift_local_source.dart';
import 'package:openmusic/layers/data/models/track_dto.dart';

void main() {
  test(
    'metadata update preserves audio state and embedding revision',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final source = TrackDriftLocalSource(database);
      await source.saveTrack(_dto(title: 'Old', filePath: 'old.mp3'));
      await (database.update(
        database.trackTable,
      )..where((track) => track.id.equals('track-1'))).write(
        const TrackTableCompanion(
          pathToFile: Value('fresh.mp3'),
          embedding: Value('[1.0,2.0]'),
          audioRevision: Value(4),
        ),
      );

      await source.updateTrackMetadata(
        _dto(title: 'Renamed', filePath: 'stale.mp3'),
      );

      final row = await database.select(database.trackTable).getSingle();
      expect(row.title, 'Renamed');
      expect(row.pathToFile, 'fresh.mp3');
      expect(row.embedding, '[1.0,2.0]');
      expect(row.audioRevision, 4);
    },
  );
}

TrackDto _dto({required String title, required String filePath}) => TrackDto(
  id: 'track-1',
  title: title,
  filePath: filePath,
  artists: const [ArtistDto(id: 'artist-1', name: 'Artist')],
  durationMs: 1000,
  sourceType: 'soundcloud',
  originalUrl: 'https://example.com/track',
  addedAt: DateTime.utc(2026),
  embedding: const [9],
);
