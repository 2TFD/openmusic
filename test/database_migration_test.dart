import 'dart:io';

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
      final taskColumns = await migrated
          .customSelect('PRAGMA table_info(embedding_task_table)')
          .get();
      final playlistColumns = await migrated
          .customSelect('PRAGMA table_info(playlist_table)')
          .get();
      final downloadIndexes = await migrated
          .customSelect('PRAGMA index_list(download_task_table)')
          .get();
      final embeddingIndexes = await migrated
          .customSelect('PRAGMA index_list(embedding_task_table)')
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
        taskColumns.map((row) => row.read<String>('name')),
        contains('audio_revision'),
      );
      expect(
        playlistColumns.map((row) => row.read<String>('name')),
        contains('revision'),
      );
      expect(
        downloadIndexes.map((row) => row.read<String>('name')),
        contains('idx_download_task_claim'),
      );
      expect(
        embeddingIndexes.map((row) => row.read<String>('name')),
        contains('idx_embedding_task_claim'),
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
    final embeddingColumns = await migrated
        .customSelect('PRAGMA table_info(embedding_task_table)')
        .get();

    expect(
      downloadColumns.map((row) => row.read<String>('name')),
      containsAll(['lease_owner', 'lease_until']),
    );
    expect(
      embeddingColumns.map((row) => row.read<String>('name')),
      containsAll(['lease_owner', 'lease_until']),
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
        .customSelect('PRAGMA table_info(play_record_table)')
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
    await legacy.customStatement('DROP TABLE playback_queue_item_table');
    await legacy.customStatement('DROP TABLE playback_session_table');
    await legacy.customStatement('DROP TABLE app_navigation_state_table');
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
}

Future<void> _restoreLegacyBaseTables(
  AppDatabase database, {
  String addedAtType = 'INTEGER',
}) async {
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
  final playRecordColumns = await database
      .customSelect('PRAGMA table_info(play_record_table)')
      .get();
  if (playRecordColumns.any(
    (row) => row.read<String>('name') == 'listened_duration_milliseconds',
  )) {
    await database.customStatement(
      'ALTER TABLE play_record_table RENAME COLUMN'
      ' listened_duration_milliseconds TO listened_duration_milisecond',
    );
  }
}
