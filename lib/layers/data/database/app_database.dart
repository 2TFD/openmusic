import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:openmusic/layers/data/datasources/local/download_task/drift/download_task_table.dart';
import 'package:openmusic/layers/data/datasources/local/embedding_task/drift/embedding_task_table.dart';
import 'package:openmusic/layers/data/datasources/local/play_record/drift/play_record_table.dart';
import 'package:openmusic/layers/data/datasources/local/playlist/drift/playlist_table.dart';
import 'package:openmusic/layers/data/datasources/local/track/drift/track_table.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

final AppDatabase appDatabase = AppDatabase();

@DriftDatabase(
  tables: [
    PlayRecordTable,
    PlaylistTable,
    TrackTable,
    EmbeddingTaskTable,
    DownloadTaskTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await m.database.customStatement(
        'CREATE UNIQUE INDEX IF NOT EXISTS'
        ' idx_embedding_task_id ON embedding_task_table(id)',
      );
      await m.database.customStatement(
        'CREATE INDEX IF NOT EXISTS'
        ' idx_play_record_played_at ON play_record_table(played_at)',
      );
      await m.database.customStatement(
        'CREATE INDEX IF NOT EXISTS idx_play_record_track_played'
        ' ON play_record_table(track_id, played_at)',
      );
      await m.database.customStatement(
        'CREATE INDEX IF NOT EXISTS idx_track_added_at'
        ' ON track_table(added_at DESC)',
      );
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(downloadTaskTable);
      }
      if (from < 3) {
        await m.database.customStatement(
          'CREATE UNIQUE INDEX IF NOT EXISTS'
          ' idx_embedding_task_id ON embedding_task_table(id)',
        );
        await m.database.customStatement(
          'CREATE INDEX IF NOT EXISTS'
          ' idx_play_record_played_at ON play_record_table(played_at)',
        );
        await m.database.customStatement(
          'CREATE INDEX IF NOT EXISTS'
          ' idx_play_record_track_played'
          ' ON play_record_table(track_id, played_at)',
        );
      }
      if (from < 4) {
        await m.addColumn(downloadTaskTable, downloadTaskTable.leaseOwner);
        await m.addColumn(downloadTaskTable, downloadTaskTable.leaseUntil);
        await m.addColumn(embeddingTaskTable, embeddingTaskTable.leaseOwner);
        await m.addColumn(embeddingTaskTable, embeddingTaskTable.leaseUntil);
      }
      if (from < 5) {
        await m.database.customStatement('''
CREATE TABLE track_table_v5 (
  id TEXT NOT NULL PRIMARY KEY,
  title TEXT NOT NULL,
  path_to_file TEXT NULL,
  artist_ids TEXT NOT NULL,
  artist_names TEXT NOT NULL,
  duration_ms INTEGER NULL,
  source_type TEXT NOT NULL,
  source_uri TEXT NOT NULL,
  added_at INTEGER NULL,
  album TEXT NULL,
  image_url TEXT NULL,
  track_descriptor_json TEXT NULL,
  embedding TEXT NULL
)
''');
        await m.database.customStatement('''
INSERT INTO track_table_v5 (
  id, title, path_to_file, artist_ids, artist_names, duration_ms,
  source_type, source_uri, added_at, album, image_url,
  track_descriptor_json, embedding
)
SELECT
  id, title, path_to_file, artist_ids, artist_names, duration_ms,
  source_type, source_uri,
  CASE
    WHEN added_at IS NULL THEN NULL
    WHEN typeof(added_at) IN ('integer', 'real') THEN CAST(added_at AS INTEGER)
    ELSE CAST(strftime('%s', added_at) AS INTEGER)
  END,
  album, image_url, track_descriptor_json, embedding
FROM track_table
''');
        await m.database.customStatement('DROP TABLE track_table');
        await m.database.customStatement(
          'ALTER TABLE track_table_v5 RENAME TO track_table',
        );
        await m.database.customStatement(
          'CREATE INDEX idx_track_added_at ON track_table(added_at DESC)',
        );
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: "openmusic_database",
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
        shareAcrossIsolates: true,
      ),
    );
  }
}
