import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:openmusic/layers/data/datasources/local/download_task/drift/download_task_table.dart';
import 'package:openmusic/layers/data/datasources/local/listening_summary/drift/listening_summary_table.dart';
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
import 'package:openmusic/layers/data/datasources/local/listening_event/drift/listening_event_table.dart';
import 'package:openmusic/layers/data/datasources/local/lyrics/lyrics_resolution_state_table.dart';
import 'package:openmusic/layers/data/datasources/local/lyrics/lyrics_resolution_task_table.dart';
import 'package:openmusic/layers/data/datasources/local/lyrics/track_lyrics_table.dart';
import 'package:openmusic/layers/data/datasources/local/music_analysis/music_analysis_task_table.dart';
import 'package:openmusic/layers/data/datasources/local/music_analysis/music_analysis_settings_table.dart';
import 'package:openmusic/layers/data/datasources/local/similarity_evaluation/similarity_evaluation_table.dart';
import 'package:openmusic/layers/data/datasources/local/track_embedding/drift/track_embedding_table.dart';
import 'package:openmusic/layers/data/datasources/local/track_temporal_embedding/track_temporal_embedding_segment_table.dart';
import 'package:openmusic/layers/data/datasources/local/track_temporal_embedding/track_temporal_embedding_table.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    ListeningSummaryTable,
    PlaylistTable,
    TrackTable,
    DownloadTaskTable,
    ArtistTable,
    TrackArtistTable,
    PlaylistTrackTable,
    FileCleanupTaskTable,
    ListeningCheckpointTable,
    PlaybackSessionTable,
    PlaybackQueueItemTable,
    AppNavigationStateTable,
    TrackEmbeddingTable,
    ListeningEventTable,
    TrackTemporalEmbeddingTable,
    TrackTemporalEmbeddingSegmentTable,
    MusicAnalysisTaskTable,
    MusicAnalysisSettingsTable,
    SimilarityEvaluationTable,
    TrackLyricsTable,
    LyricsResolutionStateTable,
    LyricsResolutionTaskTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 17;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createV16Indexes(m.database);
      await m.database.customStatement(
        'CREATE INDEX IF NOT EXISTS idx_track_added_at'
        ' ON track_table(added_at DESC)',
      );
      await _createV6Indexes(m.database);
      await _createV7Indexes(m.database);
      await _createV12Indexes(m.database);
      await _createV14Indexes(m.database);
      await _createV17Indexes(m.database);
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(downloadTaskTable);
      }
      if (from < 3) {
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
        if (await _hasTable(m.database, 'embedding_task_table')) {
          if (!await _hasColumn(
            m.database,
            'embedding_task_table',
            'lease_owner',
          )) {
            await m.database.customStatement(
              'ALTER TABLE embedding_task_table ADD COLUMN lease_owner TEXT',
            );
          }
          if (!await _hasColumn(
            m.database,
            'embedding_task_table',
            'lease_until',
          )) {
            await m.database.customStatement(
              'ALTER TABLE embedding_task_table ADD COLUMN lease_until '
              'INTEGER',
            );
          }
        }
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
        if (await _hasTable(m.database, 'embedding_task_table') &&
            !await _hasColumn(
              m.database,
              'embedding_task_table',
              'audio_revision',
            )) {
          await m.database.customStatement(
            'ALTER TABLE embedding_task_table ADD COLUMN audio_revision '
            'INTEGER NOT NULL DEFAULT 0',
          );
        }
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
      if (from < 11) {
        await m.addColumn(downloadTaskTable, downloadTaskTable.failureCode);
        await m.addColumn(downloadTaskTable, downloadTaskTable.failureMessage);
        await m.addColumn(downloadTaskTable, downloadTaskTable.failureDetails);
        await m.addColumn(downloadTaskTable, downloadTaskTable.failedAt);
      }
      if (from < 12) {
        if (!await _hasColumn(
          m.database,
          trackTable.actualTableName,
          trackTable.contentIdentity.$name,
        )) {
          await m.addColumn(trackTable, trackTable.contentIdentity);
        }
        if (!await _hasTable(m.database, trackEmbeddingTable.actualTableName)) {
          await m.createTable(trackEmbeddingTable);
        }
        if (!await _hasTable(m.database, listeningEventTable.actualTableName)) {
          await m.createTable(listeningEventTable);
        }
        await _createV12Indexes(m.database);
      }
      if (from < 13 &&
          await _hasTable(m.database, trackEmbeddingTable.actualTableName) &&
          !await _hasColumn(
            m.database,
            trackEmbeddingTable.actualTableName,
            trackEmbeddingTable.audioRevision.$name,
          )) {
        await m.addColumn(
          trackEmbeddingTable,
          trackEmbeddingTable.audioRevision,
        );
      }
      if (from < 14 &&
          await _hasTable(m.database, trackEmbeddingTable.actualTableName) &&
          !await _hasColumn(
            m.database,
            trackEmbeddingTable.actualTableName,
            trackEmbeddingTable.preprocessingVersion.$name,
          )) {
        await _rebuildTrackEmbeddingForV14(m.database);
      }
      if (from < 14) {
        if (!await _hasTable(
          m.database,
          trackTemporalEmbeddingTable.actualTableName,
        )) {
          await m.createTable(trackTemporalEmbeddingTable);
        }
        if (!await _hasTable(
          m.database,
          trackTemporalEmbeddingSegmentTable.actualTableName,
        )) {
          await m.createTable(trackTemporalEmbeddingSegmentTable);
        }
        if (!await _hasTable(
          m.database,
          musicAnalysisTaskTable.actualTableName,
        )) {
          await m.createTable(musicAnalysisTaskTable);
        }
        if (!await _hasTable(
          m.database,
          similarityEvaluationTable.actualTableName,
        )) {
          await m.createTable(similarityEvaluationTable);
        }
        await _createV14Indexes(m.database);
      }
      if (from < 15) {
        if (!await _hasTable(
          m.database,
          musicAnalysisSettingsTable.actualTableName,
        )) {
          await m.createTable(musicAnalysisSettingsTable);
        }
        if (await _hasTable(m.database, 'embedding_task_table')) {
          await m.database.customStatement('DROP TABLE embedding_task_table');
        }
        if (await _hasColumn(
          m.database,
          trackTable.actualTableName,
          'embedding',
        )) {
          await m.alterTable(TableMigration(trackTable));
        }
      }
      if (from < 16) {
        await m.database.customStatement(
          'DROP INDEX IF EXISTS idx_play_record_played_at',
        );
        await m.database.customStatement(
          'DROP INDEX IF EXISTS idx_play_record_track_played',
        );
        if (await _hasTable(m.database, 'play_record_table') &&
            !await _hasTable(
              m.database,
              listeningSummaryTable.actualTableName,
            )) {
          await m.database.customStatement(
            'ALTER TABLE play_record_table RENAME TO '
            '${listeningSummaryTable.actualTableName}',
          );
        }
        await _createV16Indexes(m.database);
      }
      if (from < 17) {
        if (await _hasTable(m.database, trackEmbeddingTable.actualTableName) &&
            !await _hasColumn(
              m.database,
              trackEmbeddingTable.actualTableName,
              trackEmbeddingTable.contentRevision.$name,
            )) {
          await m.addColumn(
            trackEmbeddingTable,
            trackEmbeddingTable.contentRevision,
          );
          await m.database.customStatement('''
UPDATE track_embedding_table
SET content_revision = 'audio:' || audio_revision
WHERE modality = 'audio' AND audio_revision IS NOT NULL
''');
        }
        if (!await _hasTable(
          m.database,
          trackLyricsTable.actualTableName,
        )) {
          await m.createTable(trackLyricsTable);
        }
        if (!await _hasTable(
          m.database,
          lyricsResolutionStateTable.actualTableName,
        )) {
          await m.createTable(lyricsResolutionStateTable);
        }
        if (!await _hasTable(
          m.database,
          lyricsResolutionTaskTable.actualTableName,
        )) {
          await m.createTable(lyricsResolutionTaskTable);
        }
        if (await _hasTable(
          m.database,
          musicAnalysisTaskTable.actualTableName,
        )) {
          await _rebuildMusicAnalysisTaskForV17(m.database);
        }
        await _createV17Indexes(m.database);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  static Future<bool> _hasTable(
    GeneratedDatabase database,
    String tableName,
  ) async {
    final row = await database
        .customSelect(
          "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ? "
          'LIMIT 1',
          variables: [Variable<String>(tableName)],
        )
        .getSingleOrNull();
    return row != null;
  }

  static Future<bool> _hasColumn(
    GeneratedDatabase database,
    String tableName,
    String columnName,
  ) async {
    final escapedTableName = tableName.replaceAll('"', '""');
    final columns = await database
        .customSelect('PRAGMA table_info("$escapedTableName")')
        .get();
    return columns.any((row) => row.read<String>('name') == columnName);
  }

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
  }

  static Future<void> _createV12Indexes(GeneratedDatabase database) async {
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_track_content_identity'
      ' ON track_table(content_identity)',
    );
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_track_embedding_track_id'
      ' ON track_embedding_table(track_id)',
    );
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_listening_event_track_id'
      ' ON listening_event_table(track_id)',
    );
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_listening_event_occurred_at'
      ' ON listening_event_table(occurred_at)',
    );
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_listening_event_session_id'
      ' ON listening_event_table(session_id)',
    );
  }

  static Future<void> _createV14Indexes(GeneratedDatabase database) async {
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_temporal_embedding_track'
      ' ON track_temporal_embedding_table(track_id)',
    );
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_analysis_task_status_created'
      ' ON music_analysis_task_table(status, created_at)',
    );
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_similarity_evaluation_seed'
      ' ON similarity_evaluation_table(seed_track_id, updated_at)',
    );
  }

  static Future<void> _createV16Indexes(GeneratedDatabase database) async {
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS'
      ' idx_listening_summary_played_at'
      ' ON listening_summary_table(played_at)',
    );
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_listening_summary_track_played'
      ' ON listening_summary_table(track_id, played_at)',
    );
  }

  static Future<void> _createV17Indexes(GeneratedDatabase database) async {
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_track_lyrics_content_hash'
      ' ON track_lyrics_table(content_hash)',
    );
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_lyrics_resolution_status_updated'
      ' ON lyrics_resolution_state_table(status, updated_at)',
    );
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_lyrics_task_claim'
      ' ON lyrics_resolution_task_table(status, next_attempt_at, created_at)',
    );
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_analysis_task_status_created'
      ' ON music_analysis_task_table(status, created_at)',
    );
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_analysis_task_track_status'
      ' ON music_analysis_task_table(track_id, status)',
    );
  }

  static Future<void> _rebuildMusicAnalysisTaskForV17(
    GeneratedDatabase database,
  ) async {
    await database.customStatement(
      'DROP TABLE IF EXISTS music_analysis_task_table_v17',
    );
    await database.customStatement('''
CREATE TABLE music_analysis_task_table_v17 (
  id TEXT NOT NULL PRIMARY KEY,
  track_id TEXT NOT NULL REFERENCES track_table(id) ON DELETE CASCADE,
  requested_representations TEXT NOT NULL,
  audio_revision INTEGER NOT NULL,
  status TEXT NOT NULL,
  attempt_count INTEGER NOT NULL DEFAULT 0,
  last_error_code TEXT NULL,
  last_error TEXT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
)
''');
    await database.customStatement('''
INSERT INTO music_analysis_task_table_v17 (
  id, track_id, requested_representations, audio_revision, status,
  attempt_count, last_error_code, last_error, created_at, updated_at
)
SELECT
  id, track_id, requested_representations, audio_revision, status,
  attempt_count, last_error_code, last_error, created_at, updated_at
FROM music_analysis_task_table
''');
    await database.customStatement('DROP TABLE music_analysis_task_table');
    await database.customStatement(
      'ALTER TABLE music_analysis_task_table_v17'
      ' RENAME TO music_analysis_task_table',
    );
  }

  static Future<void> _rebuildTrackEmbeddingForV14(
    GeneratedDatabase database,
  ) async {
    await database.customStatement('''
CREATE TABLE track_embedding_table_v14 (
  track_id TEXT NOT NULL REFERENCES track_table(id) ON DELETE CASCADE,
  modality TEXT NOT NULL,
  model_id TEXT NOT NULL,
  model_version TEXT NOT NULL,
  preprocessing_version TEXT NOT NULL DEFAULT 'legacy-unknown',
  provider TEXT NOT NULL,
  audio_revision INTEGER NULL,
  dtype TEXT NOT NULL DEFAULT 'float32',
  normalized INTEGER NULL CHECK (normalized IN (0, 1)),
  dimensions INTEGER NOT NULL,
  vector BLOB NOT NULL,
  created_at INTEGER NOT NULL,
  PRIMARY KEY (
    track_id, modality, model_id, model_version,
    preprocessing_version, provider
  )
)
''');
    await database.customStatement('''
INSERT INTO track_embedding_table_v14 (
  track_id, modality, model_id, model_version, preprocessing_version,
  provider, audio_revision, dtype, normalized, dimensions, vector, created_at
)
SELECT
  track_id, modality, model_id, model_version, 'legacy-unknown',
  provider, audio_revision, 'float32', NULL, dimensions, vector, created_at
FROM track_embedding_table
''');
    await database.customStatement('DROP TABLE track_embedding_table');
    await database.customStatement(
      'ALTER TABLE track_embedding_table_v14 RENAME TO track_embedding_table',
    );
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_track_embedding_track_id'
      ' ON track_embedding_table(track_id)',
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
