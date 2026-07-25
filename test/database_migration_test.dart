import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/data/database/app_database.dart';

void main() {
  test('schema v3 migrates both task tables to lease columns', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'openmusic_schema_migration_',
    );
    addTearDown(() => tempDir.delete(recursive: true));
    final databaseFile = File('${tempDir.path}/migration.sqlite');

    final v4 = AppDatabase(NativeDatabase(databaseFile));
    await v4.customSelect('SELECT 1').get();
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
    await current.customStatement('DROP INDEX IF EXISTS idx_track_added_at');
    await current.customStatement('DROP TABLE track_table');
    await current.customStatement('''
CREATE TABLE track_table (
  id TEXT NOT NULL PRIMARY KEY,
  title TEXT NOT NULL,
  path_to_file TEXT NULL,
  artist_ids TEXT NOT NULL,
  artist_names TEXT NOT NULL,
  duration_ms INTEGER NULL,
  source_type TEXT NOT NULL,
  source_uri TEXT NOT NULL,
  added_at TEXT NULL,
  album TEXT NULL,
  image_url TEXT NULL,
  track_descriptor_json TEXT NULL,
  embedding TEXT NULL
)
''');
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
}
