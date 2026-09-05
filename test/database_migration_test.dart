import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/data/database/app_database.dart';

void main() {
  test(
    'schema v6 migrates through revisions, indexes, and durable work tables',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'openmusic_schema_v7_migration_',
      );
      addTearDown(() => tempDir.delete(recursive: true));
      final databaseFile = File('${tempDir.path}/migration.sqlite');

      final legacy = AppDatabase(NativeDatabase(databaseFile));
      await legacy.customSelect('SELECT 1').get();
      await _createLegacyEmbeddingTaskTable(legacy);
      await _dropV12Schema(legacy);
      await legacy.customStatement(
        'ALTER TABLE track_table DROP COLUMN audio_revision',
      );
      await legacy.customStatement(
        'ALTER TABLE embedding_task_table DROP COLUMN audio_revision',
      );
      await legacy.customStatement(
        'ALTER TABLE track_table DROP COLUMN metadata_revision',
      );
      await legacy.customStatement(
        'ALTER TABLE playlist_table DROP COLUMN revision',
      );
      await _dropDownloadFailureColumns(legacy);
      await legacy.customStatement('DROP TABLE file_cleanup_task_table');
      await legacy.customStatement('DROP TABLE listening_checkpoint_table');
      await legacy.customStatement(
        'DROP INDEX IF EXISTS idx_download_task_claim',
      );
      await legacy.customStatement(
        'DROP INDEX IF EXISTS idx_embedding_task_claim',
      );
      await legacy.customStatement('PRAGMA user_version = 6');
      await legacy.close();

      final migrated = AppDatabase(NativeDatabase(databaseFile));
      addTearDown(migrated.close);
      await migrated.customSelect('SELECT 1').get();

      final trackColumns = await migrated
          .customSelect('PRAGMA table_info(track_table)')
          .get();
      final playlistColumns = await migrated
          .customSelect('PRAGMA table_info(playlist_table)')
          .get();
      final downloadColumns = await migrated
          .customSelect('PRAGMA table_info(download_task_table)')
          .get();
      final downloadIndexes = await migrated
          .customSelect('PRAGMA index_list(download_task_table)')
          .get();
      final tables = await migrated
          .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
          .get();

      expect(
        trackColumns.map((row) => row.read<String>('name')),
        contains('audio_revision'),
      );
      expect(
        trackColumns.map((row) => row.read<String>('name')),
        contains('metadata_revision'),
      );
      expect(
        playlistColumns.map((row) => row.read<String>('name')),
        contains('revision'),
      );
      expect(
        downloadColumns.map((row) => row.read<String>('name')),
        containsAll([
          'failure_code',
          'failure_message',
          'failure_details',
          'failed_at',
        ]),
      );
      expect(
        downloadIndexes.map((row) => row.read<String>('name')),
        contains('idx_download_task_claim'),
      );
      expect(
        tables.map((row) => row.read<String>('name')),
        isNot(contains('embedding_task_table')),
      );
      expect(
        tables.map((row) => row.read<String>('name')),
        containsAll(['file_cleanup_task_table', 'listening_checkpoint_table']),
      );
    },
  );

  test('schema v3 migrates both task tables to lease columns', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'openmusic_schema_migration_',
    );
    addTearDown(() => tempDir.delete(recursive: true));
    final databaseFile = File('${tempDir.path}/migration.sqlite');

    final v4 = AppDatabase(NativeDatabase(databaseFile));
    await v4.customSelect('SELECT 1').get();
    await _restoreLegacyBaseTables(v4);
    await v4.customStatement(
      'ALTER TABLE download_task_table DROP COLUMN lease_owner',
    );
    await v4.customStatement(
      'ALTER TABLE download_task_table DROP COLUMN lease_until',
    );
    await v4.customStatement(
      'ALTER TABLE embedding_task_table DROP COLUMN lease_owner',
    );
    await v4.customStatement(
      'ALTER TABLE embedding_task_table DROP COLUMN lease_until',
    );
    await v4.customStatement('PRAGMA user_version = 3');
    await v4.close();

    final migrated = AppDatabase(NativeDatabase(databaseFile));
    addTearDown(migrated.close);
    final downloadColumns = await migrated
        .customSelect('PRAGMA table_info(download_task_table)')
        .get();

    expect(
      downloadColumns.map((row) => row.read<String>('name')),
      containsAll(['lease_owner', 'lease_until']),
    );
    final tables = await migrated
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    expect(
      tables.map((row) => row.read<String>('name')),
      isNot(contains('embedding_task_table')),
    );
  });

  test('schema v4 converts ISO addedAt text to an indexed timestamp', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'openmusic_track_date_migration_',
    );
    addTearDown(() => tempDir.delete(recursive: true));
    final databaseFile = File('${tempDir.path}/migration.sqlite');

    final current = AppDatabase(NativeDatabase(databaseFile));
    await current.customSelect('SELECT 1').get();
    await _restoreLegacyBaseTables(current, addedAtType: 'TEXT');
    await current.customStatement('''
INSERT INTO track_table (
  id, title, artist_ids, artist_names, source_type, source_uri, added_at
) VALUES (
  'legacy-track', 'Legacy', '[]', '[]', 'soundcloud',
  'https://example.com/legacy', '2024-01-02T03:04:05.000Z'
)
''');
    await current.customStatement('PRAGMA user_version = 4');
    await current.close();

    final migrated = AppDatabase(NativeDatabase(databaseFile));
    addTearDown(migrated.close);
    final track = await migrated.select(migrated.trackTable).getSingle();
    final columns = await migrated
        .customSelect('PRAGMA table_info(track_table)')
        .get();
    final indexes = await migrated
        .customSelect('PRAGMA index_list(track_table)')
        .get();

    expect(
      track.addedAt?.isAtSameMomentAs(DateTime.utc(2024, 1, 2, 3, 4, 5)),
      isTrue,
    );
    expect(
      columns
          .singleWhere((row) => row.read<String>('name') == 'added_at')
          .read<String>('type'),
      'INTEGER',
    );
    expect(
      indexes.map((row) => row.read<String>('name')),
      contains('idx_track_added_at'),
    );
  });

  test('schema v5 normalizes artists, playlists, and play duration', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'openmusic_normalized_schema_migration_',
    );
    addTearDown(() => tempDir.delete(recursive: true));
    final databaseFile = File('${tempDir.path}/migration.sqlite');

    final legacy = AppDatabase(NativeDatabase(databaseFile));
    await legacy.customSelect('SELECT 1').get();
    await _restoreLegacyBaseTables(legacy);
    await legacy.customStatement('''
INSERT INTO track_table (
  id, title, artist_ids, artist_names, source_type, source_uri, added_at
) VALUES
  ('track-a', 'A', '["artist-1","artist-2"]', '["One","Two"]',
   'soundcloud', 'https://example.com/a', 1700000000),
  ('track-b', 'B', '["artist-1"]', '[]',
   'soundcloud', 'https://example.com/b', 1700000001)
''');
    await legacy.customStatement('''
INSERT INTO playlist_table (
  id, name, track_ids, created_at
) VALUES ('playlist-1', 'Legacy', 'track-b,track-a', 1700000000)
''');
    await legacy.customStatement('''
INSERT INTO play_record_table (
  id, track_id, track_title, artist_name, source_type,
  listened_duration_milisecond, played_at
) VALUES ('record-1', 'track-a', 'A', 'One', 'soundcloud', 1234, 1700000000)
''');
    await legacy.customStatement('PRAGMA user_version = 5');
    await legacy.close();

    final migrated = AppDatabase(NativeDatabase(databaseFile));
    addTearDown(migrated.close);
    await migrated.customSelect('SELECT 1').get();

    final trackArtists = await migrated.customSelect('''
SELECT track_id, artist_id, position
FROM track_artist_table
ORDER BY track_id, position
''').get();
    final playlistTracks = await migrated.customSelect('''
SELECT track_id, position
FROM playlist_track_table
WHERE playlist_id = 'playlist-1'
ORDER BY position
''').get();
    final trackColumns = await migrated
        .customSelect('PRAGMA table_info(track_table)')
        .get();
    final playlistColumns = await migrated
        .customSelect('PRAGMA table_info(playlist_table)')
        .get();
    final recordColumns = await migrated
        .customSelect('PRAGMA table_info(listening_summary_table)')
        .get();

    expect(
      trackArtists
          .map(
            (row) => (
              row.read<String>('track_id'),
              row.read<String>('artist_id'),
              row.read<int>('position'),
            ),
          )
          .toList(),
      [
        ('track-a', 'artist-1', 0),
        ('track-a', 'artist-2', 1),
        ('track-b', 'artist-1', 0),
      ],
    );
    expect(
      playlistTracks
          .map(
            (row) => (row.read<String>('track_id'), row.read<int>('position')),
          )
          .toList(),
      [('track-b', 0), ('track-a', 1)],
    );
    expect(
      trackColumns.map((row) => row.read<String>('name')),
      isNot(contains('artist_ids')),
    );
    expect(
      playlistColumns.map((row) => row.read<String>('name')),
      isNot(contains('track_ids')),
    );
    expect(
      recordColumns.map((row) => row.read<String>('name')),
      contains('listened_duration_milliseconds'),
    );
  });

  test('schema v9 migrates playback and navigation state tables', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'openmusic_state_schema_migration_',
    );
    addTearDown(() => tempDir.delete(recursive: true));
    final databaseFile = File('${tempDir.path}/migration.sqlite');

    final legacy = AppDatabase(NativeDatabase(databaseFile));
    await legacy.customSelect('SELECT 1').get();
    await _dropV12Schema(legacy);
    await legacy.customStatement('DROP TABLE playback_queue_item_table');
    await legacy.customStatement('DROP TABLE playback_session_table');
    await legacy.customStatement('DROP TABLE app_navigation_state_table');
    await _dropDownloadFailureColumns(legacy);
    await legacy.customStatement('PRAGMA user_version = 9');
    await legacy.close();

    final migrated = AppDatabase(NativeDatabase(databaseFile));
    addTearDown(migrated.close);
    await migrated.customSelect('SELECT 1').get();
    final tables = await migrated
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();

    expect(
      tables.map((row) => row.read<String>('name')),
      containsAll([
        'playback_session_table',
        'playback_queue_item_table',
        'app_navigation_state_table',
      ]),
    );
  });

  test('schema v11 adds recommendation foundation without data loss', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'openmusic_schema_v12_migration_',
    );
    addTearDown(() => tempDir.delete(recursive: true));
    final databaseFile = File('${tempDir.path}/migration.sqlite');

    final legacy = AppDatabase(NativeDatabase(databaseFile));
    await legacy.customSelect('SELECT 1').get();
    await legacy.customStatement(
      'ALTER TABLE track_table ADD COLUMN embedding TEXT NULL',
    );
    await legacy.customStatement('''
INSERT INTO track_table (
  id, title, source_type, source_uri, embedding,
  audio_revision, metadata_revision
) VALUES (
  'legacy-track', 'Legacy', 'localFile', '/old/location.mp3', '[0.25,0.5]',
  3, 4
)
''');
    await _dropV12Schema(legacy);
    await legacy.customStatement('PRAGMA user_version = 11');
    await legacy.close();

    final migrated = AppDatabase(NativeDatabase(databaseFile));
    addTearDown(migrated.close);
    await migrated.customSelect('SELECT 1').get();

    final track = await migrated.select(migrated.trackTable).getSingle();
    final trackColumns = await migrated
        .customSelect('PRAGMA table_info(track_table)')
        .get();
    final tables = await migrated
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    final indexes = await migrated
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
        .get();
    final embeddingColumns = await migrated
        .customSelect('PRAGMA table_info(track_embedding_table)')
        .get();

    expect(track.id, 'legacy-track');
    expect(track.audioRevision, 3);
    expect(track.metadataRevision, 4);
    expect(track.contentIdentity, isNull);
    expect(
      trackColumns.map((row) => row.read<String>('name')),
      contains('content_identity'),
    );
    expect(
      trackColumns.map((row) => row.read<String>('name')),
      isNot(contains('embedding')),
    );
    expect(
      tables.map((row) => row.read<String>('name')),
      containsAll(['track_embedding_table', 'listening_event_table']),
    );
    expect(
      embeddingColumns.map((row) => row.read<String>('name')),
      contains('audio_revision'),
    );
    expect(
      indexes.map((row) => row.read<String>('name')),
      containsAll([
        'idx_track_content_identity',
        'idx_track_embedding_track_id',
        'idx_listening_event_track_id',
        'idx_listening_event_occurred_at',
        'idx_listening_event_session_id',
      ]),
    );
  });

  test('partially applied v11 migration resumes idempotently', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'openmusic_partial_v12_migration_',
    );
    addTearDown(() => tempDir.delete(recursive: true));
    final databaseFile = File('${tempDir.path}/migration.sqlite');

    final partial = AppDatabase(NativeDatabase(databaseFile));
    await partial.customSelect('SELECT 1').get();
    await partial.customStatement('''
INSERT INTO track_table (
  id, title, source_type, source_uri, content_identity
) VALUES (
  'partial-track', 'Partial', 'localFile', '/partial.mp3',
  'local:sha256:existing'
)
''');
    await _dropV14ResearchTables(partial);
    await partial.customStatement('DROP TABLE listening_event_table');
    // Simulate an interrupted upgrade: the column and first v12 table were
    // created, but user_version and the remaining schema were not committed.
    await partial.customStatement('PRAGMA user_version = 11');
    await partial.close();

    final migrated = AppDatabase(NativeDatabase(databaseFile));
    addTearDown(migrated.close);
    await migrated.customSelect('SELECT 1').get();

    final track = await migrated.select(migrated.trackTable).getSingle();
    final trackColumns = await migrated
        .customSelect('PRAGMA table_info(track_table)')
        .get();
    final tables = await migrated
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    final version = await migrated
        .customSelect('PRAGMA user_version')
        .getSingle();

    expect(track.contentIdentity, 'local:sha256:existing');
    expect(
      trackColumns.where(
        (row) => row.read<String>('name') == 'content_identity',
      ),
      hasLength(1),
    );
    expect(
      tables.map((row) => row.read<String>('name')),
      containsAll([
        'track_embedding_table',
        'listening_event_table',
        'track_temporal_embedding_table',
        'track_temporal_embedding_segment_table',
        'music_analysis_task_table',
        'similarity_evaluation_table',
        'listening_summary_table',
      ]),
    );
    expect(
      tables.map((row) => row.read<String>('name')),
      isNot(contains('play_record_table')),
    );
    expect(version.read<int>('user_version'), 18);
  });

  test('schema v12 marks existing embedding revision as unknown', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'openmusic_schema_v13_migration_',
    );
    addTearDown(() => tempDir.delete(recursive: true));
    final databaseFile = File('${tempDir.path}/migration.sqlite');

    final legacy = AppDatabase(NativeDatabase(databaseFile));
    await legacy.customSelect('SELECT 1').get();
    await legacy.customStatement('''
INSERT INTO track_table (id, title, source_type, source_uri)
VALUES ('track-v12', 'Track v12', 'localFile', '/track-v12.mp3')
''');
    await legacy.customStatement('''
INSERT INTO track_embedding_table (
  track_id, modality, model_id, model_version, provider,
  audio_revision, dimensions, vector, created_at
) VALUES (
  'track-v12', 'audio', 'legacy-model', '1', 'server',
  7, 1, X'0000803F', 1700000000
)
''');
    await legacy.customStatement(
      'ALTER TABLE track_embedding_table DROP COLUMN audio_revision',
    );
    await _dropV14ResearchTables(legacy);
    await legacy.customStatement('PRAGMA user_version = 12');
    await legacy.close();

    final migrated = AppDatabase(NativeDatabase(databaseFile));
    addTearDown(migrated.close);
    await migrated.customSelect('SELECT 1').get();

    final embedding = await migrated
        .select(migrated.trackEmbeddingTable)
        .getSingle();
    final columns = await migrated
        .customSelect('PRAGMA table_info(track_embedding_table)')
        .get();

    expect(embedding.trackId, 'track-v12');
    expect(embedding.audioRevision, isNull);
    expect(
      columns.map((row) => row.read<String>('name')),
      contains('audio_revision'),
    );
  });

  test(
    'schema v13 adds versioned research storage without data loss',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'openmusic_schema_v14_migration_',
      );
      addTearDown(() => tempDir.delete(recursive: true));
      final databaseFile = File('${tempDir.path}/migration.sqlite');

      final legacy = AppDatabase(NativeDatabase(databaseFile));
      await legacy.customSelect('SELECT 1').get();
      await legacy.customStatement('''
INSERT INTO track_table (id, title, source_type, source_uri)
VALUES ('track-v13', 'Track v13', 'localFile', '/track-v13.mp3')
''');
      await legacy.customStatement(
        'ALTER TABLE track_embedding_table RENAME TO embedding_v14',
      );
      await legacy.customStatement('''
CREATE TABLE track_embedding_table (
  track_id TEXT NOT NULL REFERENCES track_table(id) ON DELETE CASCADE,
  modality TEXT NOT NULL,
  model_id TEXT NOT NULL,
  model_version TEXT NOT NULL,
  provider TEXT NOT NULL,
  audio_revision INTEGER NULL,
  dimensions INTEGER NOT NULL,
  vector BLOB NOT NULL,
  created_at INTEGER NOT NULL,
  PRIMARY KEY (track_id, modality, model_id, model_version, provider)
)
''');
      await legacy.customStatement('''
INSERT INTO track_embedding_table (
  track_id, modality, model_id, model_version, provider,
  audio_revision, dimensions, vector, created_at
) VALUES (
  'track-v13', 'audio', 'legacy-model', '1', 'server',
  3, 1, X'0000803F', 1700000000
)
''');
      await legacy.customStatement('DROP TABLE embedding_v14');
      await _dropV14ResearchTables(legacy);
      await legacy.customStatement('PRAGMA user_version = 13');
      await legacy.close();

      final migrated = AppDatabase(NativeDatabase(databaseFile));
      addTearDown(migrated.close);
      await migrated.customSelect('SELECT 1').get();

      final embedding = await migrated
          .select(migrated.trackEmbeddingTable)
          .getSingle();
      final tables = await migrated
          .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
          .get();
      expect(embedding.trackId, 'track-v13');
      expect(embedding.audioRevision, 3);
      expect(embedding.preprocessingVersion, 'legacy-unknown');
      expect(embedding.dtype, 'float32');
      expect(embedding.normalized, isNull);
      expect(
        tables.map((row) => row.read<String>('name')),
        containsAll([
          'track_temporal_embedding_table',
          'track_temporal_embedding_segment_table',
          'music_analysis_task_table',
          'similarity_evaluation_table',
        ]),
      );
    },
  );

  test('schema v14 removes only legacy embedding storage', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'openmusic_schema_v15_migration_',
    );
    addTearDown(() => tempDir.delete(recursive: true));
    final databaseFile = File('${tempDir.path}/migration.sqlite');
    final legacy = AppDatabase(NativeDatabase(databaseFile));
    await legacy.customSelect('SELECT 1').get();
    await legacy.customStatement('''
INSERT INTO track_table (
  id, title, source_type, source_uri, path_to_file,
  audio_revision, metadata_revision
) VALUES
  ('seed', 'Seed', 'localFile', '/seed.mp3', '/seed.mp3', 2, 1),
  ('candidate', 'Candidate', 'localFile', '/candidate.mp3',
   '/candidate.mp3', 3, 1)
''');
    await legacy.customStatement('''
INSERT INTO playlist_table (id, name, created_at, revision)
VALUES ('playlist', 'Playlist', 1700000000, 1)
''');
    await legacy.customStatement('''
INSERT INTO playlist_track_table (playlist_id, track_id, position)
VALUES ('playlist', 'seed', 0)
''');
    await legacy.customStatement('''
INSERT INTO listening_event_table (
  id, track_id, type, occurred_at, position_ms
) VALUES ('event', 'seed', 'playStarted', 1700000000, 0)
''');
    await legacy.customStatement('''
INSERT INTO track_embedding_table (
  track_id, modality, model_id, model_version, preprocessing_version,
  provider, audio_revision, dtype, normalized, dimensions, vector, created_at
) VALUES (
  'seed', 'audio', 'global-model', '1', 'prep-1', 'server',
  2, 'float32', 1, 2, X'0000803F00000000', 1700000000
)
''');
    await legacy.customStatement('''
INSERT INTO track_temporal_embedding_table (
  id, track_id, representation, model_id, model_version,
  preprocessing_version, provider, audio_revision, dimension, dtype,
  normalized, created_at, number_of_segments, mean_adjacent_distance,
  max_adjacent_distance, trajectory_variance, largest_transition_index
) VALUES (
  'temporal', 'seed', 'audio.temporal', 'temporal-model', '1',
  'prep-1', 'server', 2, 2, 'float32', 1, 1700000000,
  1, 0.0, 0.0, 0.0, NULL
)
''');
    await legacy.customStatement('''
INSERT INTO track_temporal_embedding_segment_table (
  temporal_embedding_id, segment_index, start_ms, end_ms,
  dimensions, vector
) VALUES ('temporal', 0, 0, 1000, 2, X'0000803F00000000')
''');
    await legacy.customStatement('''
INSERT INTO music_analysis_task_table (
  id, track_id, requested_representations, audio_revision, status,
  attempt_count, created_at, updated_at
) VALUES (
  'analysis', 'candidate', 'audio.global,audio.temporal', 3,
  'queued', 0, 1700000000, 1700000000
)
''');
    await legacy.customStatement('''
INSERT INTO similarity_evaluation_table (
  id, seed_track_id, candidate_track_id, method_version,
  source_representation_model_id, source_representation_model_version,
  source_preprocessing_version, score_shown, created_at, updated_at
) VALUES (
  'evaluation', 'seed', 'candidate', 'audio_global_cosine_v1',
  'global-model', '1', 'prep-1', 0.8, 1700000000, 1700000000
)
''');
    await legacy.customStatement(
      'ALTER TABLE track_table ADD COLUMN embedding TEXT NULL',
    );
    await legacy.customStatement(
      "UPDATE track_table SET embedding = '[0.1,0.2]' WHERE id = 'seed'",
    );
    await _createLegacyEmbeddingTaskTable(legacy);
    await legacy.customStatement('DROP TABLE music_analysis_settings_table');
    await legacy.customStatement('PRAGMA user_version = 14');
    await legacy.close();

    final migrated = AppDatabase(NativeDatabase(databaseFile));
    addTearDown(migrated.close);
    await migrated.customSelect('SELECT 1').get();
    final tables = await migrated
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    final trackColumns = await migrated
        .customSelect('PRAGMA table_info(track_table)')
        .get();

    expect(await migrated.select(migrated.trackTable).get(), hasLength(2));
    expect(await migrated.select(migrated.playlistTable).get(), hasLength(1));
    expect(
      await migrated.select(migrated.listeningEventTable).get(),
      hasLength(1),
    );
    expect(
      await migrated.select(migrated.trackEmbeddingTable).get(),
      hasLength(1),
    );
    expect(
      await migrated.select(migrated.trackTemporalEmbeddingTable).get(),
      hasLength(1),
    );
    expect(
      await migrated.select(migrated.similarityEvaluationTable).get(),
      hasLength(1),
    );
    expect(
      await migrated.select(migrated.musicAnalysisTaskTable).get(),
      hasLength(1),
    );
    expect(
      trackColumns.map((row) => row.read<String>('name')),
      isNot(contains('embedding')),
    );
    expect(
      tables.map((row) => row.read<String>('name')),
      isNot(contains('embedding_task_table')),
    );
    expect(
      tables.map((row) => row.read<String>('name')),
      contains('music_analysis_settings_table'),
    );
  });

  test(
    'schema v16 upgrades lyrics tables and preserves current embeddings',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'openmusic_schema_v17_lyrics_migration_',
      );
      addTearDown(() => tempDir.delete(recursive: true));
      final databaseFile = File('${tempDir.path}/migration.sqlite');

      final legacy = AppDatabase(NativeDatabase(databaseFile));
      await legacy.customSelect('SELECT 1').get();
      await legacy.customStatement('''
INSERT INTO track_table (
  id, title, path_to_file, source_type, source_uri, audio_revision
) VALUES ('legacy-lyrics-track', 'Legacy', 'legacy.mp3', 'localFile',
  '/legacy.mp3', 4)
''');
      await legacy.customStatement('''
INSERT INTO track_embedding_table (
  track_id, modality, model_id, model_version, preprocessing_version,
  provider, audio_revision, content_revision, dtype, normalized, dimensions,
  vector, created_at
) VALUES ('legacy-lyrics-track', 'audio', 'audio-model', 'v1', 'prep',
  'server', 4, 'audio:4', 'float32', 1, 1, X'00000000', 0)
''');
      await legacy.customStatement('''
INSERT INTO music_analysis_task_table (
  id, track_id, requested_representations, audio_revision, status,
  attempt_count, created_at, updated_at
) VALUES ('analysis-task', 'legacy-lyrics-track', 'audio.global', 4,
  'completed', 1, 0, 0)
''');
      await legacy.customStatement('DROP TABLE track_lyrics_table');
      await legacy.customStatement('DROP TABLE lyrics_resolution_state_table');
      await legacy.customStatement('DROP TABLE lyrics_resolution_task_table');
      await legacy.customStatement(
        'ALTER TABLE track_embedding_table DROP COLUMN content_revision',
      );
      await legacy.customStatement('PRAGMA user_version = 16');
      await legacy.close();

      final migrated = AppDatabase(NativeDatabase(databaseFile));
      addTearDown(migrated.close);
      final embedding = await migrated
          .select(migrated.trackEmbeddingTable)
          .getSingle();
      expect(embedding.audioRevision, 4);
      expect(embedding.contentRevision, 'audio:4');
      expect(await migrated.select(migrated.trackLyricsTable).get(), isEmpty);
      expect(
        await migrated.select(migrated.lyricsResolutionStateTable).get(),
        isEmpty,
      );
      expect(
        await migrated.select(migrated.musicAnalysisTaskTable).get(),
        hasLength(1),
      );
      expect(
        await migrated.select(migrated.trackEmotionAnalysisTable).get(),
        isEmpty,
      );
      expect(
        await migrated.select(migrated.trackEmotionSegmentTable).get(),
        isEmpty,
      );
      expect(
        await migrated.select(migrated.personalMoodAdjustmentTable).get(),
        isEmpty,
      );

      await migrated
          .into(migrated.trackLyricsTable)
          .insert(
            TrackLyricsTableCompanion.insert(
              trackId: 'legacy-lyrics-track',
              source: 'sidecarLrc',
              plainText: 'lyrics',
              contentHash:
                  'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
              fetchedAt: DateTime.utc(2026),
              updatedAt: DateTime.utc(2026),
            ),
          );
      await (migrated.delete(
        migrated.trackTable,
      )..where((table) => table.id.equals('legacy-lyrics-track'))).go();
      expect(await migrated.select(migrated.trackLyricsTable).get(), isEmpty);
    },
  );
}

Future<void> _restoreLegacyBaseTables(
  AppDatabase database, {
  String addedAtType = 'INTEGER',
}) async {
  await _dropV12Schema(database);
  await database.customStatement(
    'DROP TABLE IF EXISTS file_cleanup_task_table',
  );
  await database.customStatement(
    'DROP TABLE IF EXISTS listening_checkpoint_table',
  );
  await database.customStatement(
    'DROP INDEX IF EXISTS idx_download_task_claim',
  );
  await database.customStatement(
    'DROP INDEX IF EXISTS idx_embedding_task_claim',
  );
  await _dropDownloadFailureColumns(database);
  await _createLegacyEmbeddingTaskTable(database);
  final embeddingTaskColumns = await database
      .customSelect('PRAGMA table_info(embedding_task_table)')
      .get();
  if (embeddingTaskColumns.any(
    (row) => row.read<String>('name') == 'audio_revision',
  )) {
    await database.customStatement(
      'ALTER TABLE embedding_task_table DROP COLUMN audio_revision',
    );
  }
  await database.customStatement('DROP TABLE IF EXISTS playlist_track_table');
  await database.customStatement('DROP TABLE IF EXISTS track_artist_table');
  await database.customStatement('DROP TABLE IF EXISTS artist_table');
  await database.customStatement('DROP INDEX IF EXISTS idx_track_added_at');
  await database.customStatement('DROP TABLE track_table');
  await database.customStatement('''
CREATE TABLE track_table (
  id TEXT NOT NULL PRIMARY KEY,
  title TEXT NOT NULL,
  path_to_file TEXT NULL,
  artist_ids TEXT NOT NULL,
  artist_names TEXT NOT NULL,
  duration_ms INTEGER NULL,
  source_type TEXT NOT NULL,
  source_uri TEXT NOT NULL,
  added_at $addedAtType NULL,
  album TEXT NULL,
  image_url TEXT NULL,
  track_descriptor_json TEXT NULL,
  embedding TEXT NULL
)
''');
  await database.customStatement('DROP TABLE playlist_table');
  await database.customStatement('''
CREATE TABLE playlist_table (
  id TEXT NOT NULL PRIMARY KEY,
  name TEXT NOT NULL,
  track_ids TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  description TEXT NULL,
  image_url TEXT NULL
)
''');
  await database.customStatement(
    'DROP INDEX IF EXISTS idx_listening_summary_played_at',
  );
  await database.customStatement(
    'DROP INDEX IF EXISTS idx_listening_summary_track_played',
  );
  if (await _hasTable(database, 'listening_summary_table') &&
      !await _hasTable(database, 'play_record_table')) {
    await database.customStatement(
      'ALTER TABLE listening_summary_table RENAME TO play_record_table',
    );
  }
  final listeningSummaryColumns = await database
      .customSelect('PRAGMA table_info(play_record_table)')
      .get();
  if (listeningSummaryColumns.any(
    (row) => row.read<String>('name') == 'listened_duration_milliseconds',
  )) {
    await database.customStatement(
      'ALTER TABLE play_record_table RENAME COLUMN'
      ' listened_duration_milliseconds TO listened_duration_milisecond',
    );
  }
}

Future<bool> _hasTable(AppDatabase database, String tableName) async {
  final row = await database
      .customSelect(
        "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ? "
        'LIMIT 1',
        variables: [Variable<String>(tableName)],
      )
      .getSingleOrNull();
  return row != null;
}

Future<void> _dropV12Schema(AppDatabase database) async {
  await _dropV14ResearchTables(database);
  await database.customStatement('DROP TABLE IF EXISTS track_embedding_table');
  await database.customStatement('DROP TABLE IF EXISTS listening_event_table');
  await database.customStatement(
    'DROP INDEX IF EXISTS idx_track_content_identity',
  );
  final columns = await database
      .customSelect('PRAGMA table_info(track_table)')
      .get();
  if (columns.any((row) => row.read<String>('name') == 'content_identity')) {
    await database.customStatement(
      'ALTER TABLE track_table DROP COLUMN content_identity',
    );
  }
}

Future<void> _dropV14ResearchTables(AppDatabase database) async {
  await database.customStatement(
    'DROP TABLE IF EXISTS track_temporal_embedding_segment_table',
  );
  await database.customStatement(
    'DROP TABLE IF EXISTS track_temporal_embedding_table',
  );
  await database.customStatement(
    'DROP TABLE IF EXISTS music_analysis_task_table',
  );
  await database.customStatement(
    'DROP TABLE IF EXISTS similarity_evaluation_table',
  );
  await database.customStatement(
    'DROP TABLE IF EXISTS music_analysis_settings_table',
  );
}

Future<void> _createLegacyEmbeddingTaskTable(AppDatabase database) async {
  await database.customStatement('DROP TABLE IF EXISTS embedding_task_table');
  await database.customStatement('''
CREATE TABLE embedding_task_table (
  id TEXT NOT NULL,
  track_id TEXT NOT NULL PRIMARY KEY,
  status TEXT NOT NULL,
  file_path TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  lease_owner TEXT NULL,
  lease_until INTEGER NULL,
  audio_revision INTEGER NOT NULL DEFAULT 0
)
''');
}

Future<void> _dropDownloadFailureColumns(AppDatabase database) async {
  final columns = await database
      .customSelect('PRAGMA table_info(download_task_table)')
      .get();
  final existingNames = columns.map((row) => row.read<String>('name')).toSet();
  for (final column in [
    'failure_code',
    'failure_message',
    'failure_details',
    'failed_at',
  ]) {
    if (existingNames.contains(column)) {
      await database.customStatement(
        'ALTER TABLE download_task_table DROP COLUMN $column',
      );
    }
  }
}
