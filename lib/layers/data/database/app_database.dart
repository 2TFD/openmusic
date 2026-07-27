import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:openmusic/layers/data/datasources/local/download_task/drift/download_task_table.dart';
import 'package:openmusic/layers/data/datasources/local/embedding_task/drift/embedding_task_table.dart';
import 'package:openmusic/layers/data/datasources/local/play_record/drift/play_record_table.dart';
import 'package:openmusic/layers/data/datasources/local/playlist/drift/playlist_table.dart';
import 'package:openmusic/layers/data/datasources/local/playlist/drift/playlist_track_table.dart';
import 'package:openmusic/layers/data/datasources/local/track/drift/artist_table.dart';
import 'package:openmusic/layers/data/datasources/local/track/drift/track_artist_table.dart';
import 'package:openmusic/layers/data/datasources/local/track/drift/track_table.dart';
import 'package:openmusic/layers/data/database/file_cleanup_task_table.dart';
import 'package:openmusic/layers/data/database/listening_checkpoint_table.dart';
import 'package:openmusic/layers/data/database/playback_session_table.dart';
import 'package:openmusic/layers/data/database/playback_queue_item_table.dart';
import 'package:openmusic/layers/data/database/app_navigation_state_table.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    PlayRecordTable,
    PlaylistTable,
    TrackTable,
    EmbeddingTaskTable,
    DownloadTaskTable,
    ArtistTable,
    TrackArtistTable,
    PlaylistTrackTable,
    FileCleanupTaskTable,
    ListeningCheckpointTable,
    PlaybackSessionTable,
    PlaybackQueueItemTable,
    AppNavigationStateTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 10;

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
      await _createV6Indexes(m.database);
      await _createV7Indexes(m.database);
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
      if (from < 6) {
        await _migrateToV6(m.database);
      }
      if (from < 7) {
        await m.addColumn(trackTable, trackTable.audioRevision);
        await m.addColumn(embeddingTaskTable, embeddingTaskTable.audioRevision);
        await _createV7Indexes(m.database);
      }
      if (from < 8) {
        await m.addColumn(trackTable, trackTable.metadataRevision);
        await m.createTable(fileCleanupTaskTable);
        await m.createTable(listeningCheckpointTable);
      }
      if (from < 9) {
        await m.addColumn(playlistTable, playlistTable.revision);
      }
      if (from < 10) {
        await m.createTable(playbackSessionTable);
        await m.createTable(playbackQueueItemTable);
        await m.createTable(appNavigationStateTable);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  static Future<void> _createV6Indexes(GeneratedDatabase database) async {
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_track_added_at'
      ' ON track_table(added_at DESC)',
    );
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_track_title ON track_table(title)',
    );
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_artist_name ON artist_table(name)',
    );
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_track_artist_track_position'
      ' ON track_artist_table(track_id, position)',
    );
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_playlist_track_playlist_position'
      ' ON playlist_track_table(playlist_id, position)',
    );
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_playlist_created_at'
      ' ON playlist_table(created_at DESC)',
    );
  }

  static Future<void> _createV7Indexes(GeneratedDatabase database) async {
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_download_task_claim'
      ' ON download_task_table(status, lease_until, created_at)',
    );
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_embedding_task_claim'
      ' ON embedding_task_table(status, lease_until, created_at)',
    );
  }

  static Future<void> _migrateToV6(GeneratedDatabase database) async {
    await database.customStatement('''
CREATE TEMP TABLE legacy_track_artist (
  track_id TEXT NOT NULL,
  artist_id TEXT NOT NULL,
  artist_name TEXT NOT NULL,
  position INTEGER NOT NULL
)
''');
    await database.customStatement('''
INSERT INTO legacy_track_artist (track_id, artist_id, artist_name, position)
SELECT
  track_table.id,
  CAST(ids.value AS TEXT),
  COALESCE(CAST(names.value AS TEXT), 'Unknown Artist'),
  CAST(ids.key AS INTEGER)
FROM track_table
JOIN json_each(
  CASE WHEN json_valid(track_table.artist_ids)
       THEN track_table.artist_ids ELSE '[]' END
) AS ids
LEFT JOIN json_each(
  CASE WHEN json_valid(track_table.artist_names)
       THEN track_table.artist_names ELSE '[]' END
) AS names ON names.key = ids.key
WHERE CAST(ids.value AS TEXT) <> ''
''');
    await database.customStatement('''
CREATE TEMP TABLE legacy_playlist_track (
  playlist_id TEXT NOT NULL,
  track_id TEXT NOT NULL,
  position INTEGER NOT NULL
)
''');
    await database.customStatement('''
WITH RECURSIVE split(playlist_id, rest, track_id, position) AS (
  SELECT id, track_ids || ',', '', -1 FROM playlist_table
  UNION ALL
  SELECT
    playlist_id,
    substr(rest, instr(rest, ',') + 1),
    substr(rest, 1, instr(rest, ',') - 1),
    position + 1
  FROM split
  WHERE rest <> ''
)
INSERT INTO legacy_playlist_track (playlist_id, track_id, position)
SELECT playlist_id, track_id, position
FROM split
WHERE track_id <> ''
''');
    await database.customStatement('''
CREATE TABLE track_table_v6 (
  id TEXT NOT NULL PRIMARY KEY,
  title TEXT NOT NULL,
  path_to_file TEXT NULL,
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
    await database.customStatement('''
INSERT INTO track_table_v6 (
  id, title, path_to_file, duration_ms, source_type, source_uri, added_at,
  album, image_url, track_descriptor_json, embedding
)
SELECT
  id, title, path_to_file, duration_ms, source_type, source_uri, added_at,
  album, image_url, track_descriptor_json, embedding
FROM track_table
''');
    await database.customStatement('''
CREATE TABLE playlist_table_v6 (
  id TEXT NOT NULL PRIMARY KEY,
  name TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  description TEXT NULL,
  image_url TEXT NULL
)
''');
    await database.customStatement('''
INSERT INTO playlist_table_v6 (
  id, name, created_at, description, image_url
)
SELECT id, name, created_at, description, image_url FROM playlist_table
''');
    await database.customStatement('DROP INDEX IF EXISTS idx_track_added_at');
    await database.customStatement('DROP TABLE track_table');
    await database.customStatement('DROP TABLE playlist_table');
    await database.customStatement(
      'ALTER TABLE track_table_v6 RENAME TO track_table',
    );
    await database.customStatement(
      'ALTER TABLE playlist_table_v6 RENAME TO playlist_table',
    );
    await database.customStatement('''
CREATE TABLE artist_table (
  id TEXT NOT NULL PRIMARY KEY,
  name TEXT NOT NULL
)
''');
    await database.customStatement('''
CREATE TABLE track_artist_table (
  track_id TEXT NOT NULL REFERENCES track_table(id) ON DELETE CASCADE,
  artist_id TEXT NOT NULL REFERENCES artist_table(id) ON DELETE CASCADE,
  position INTEGER NOT NULL,
  PRIMARY KEY (track_id, artist_id),
  UNIQUE (track_id, position)
)
''');
    await database.customStatement('''
CREATE TABLE playlist_track_table (
  playlist_id TEXT NOT NULL REFERENCES playlist_table(id) ON DELETE CASCADE,
  track_id TEXT NOT NULL REFERENCES track_table(id) ON DELETE CASCADE,
  position INTEGER NOT NULL,
  PRIMARY KEY (playlist_id, track_id),
  UNIQUE (playlist_id, position)
)
''');
    await database.customStatement('''
INSERT OR IGNORE INTO artist_table (id, name)
SELECT artist_id, artist_name FROM legacy_track_artist
''');
    await database.customStatement('''
INSERT OR IGNORE INTO track_artist_table (track_id, artist_id, position)
SELECT legacy.track_id, legacy.artist_id, legacy.position
FROM legacy_track_artist AS legacy
JOIN track_table ON track_table.id = legacy.track_id
JOIN artist_table ON artist_table.id = legacy.artist_id
''');
    await database.customStatement('''
INSERT OR IGNORE INTO playlist_track_table (playlist_id, track_id, position)
SELECT legacy.playlist_id, legacy.track_id, legacy.position
FROM legacy_playlist_track AS legacy
JOIN playlist_table ON playlist_table.id = legacy.playlist_id
JOIN track_table ON track_table.id = legacy.track_id
''');
    await database.customStatement(
      'ALTER TABLE play_record_table RENAME COLUMN'
      ' listened_duration_milisecond TO listened_duration_milliseconds',
    );
    await _createV6Indexes(database);
  }

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
