import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:openmusic/layers/data/models/playlist_dto.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/playlist/playlist_local_data_source.dart';

class PlaylistDriftLocalSource implements PlaylistLocalDataSource {
  PlaylistDriftLocalSource(this.database);

  final AppDatabase database;

  @override
  Future<bool> deletePlaylist(String id) async {
    final affected = await (database.delete(
      database.playlistTable,
    )..where((table) => table.id.equals(id))).go();
    return affected == 1;
  }

  @override
  Future<void> savePlaylist(PlaylistDto playlist) async {
    await database.transaction(() async {
      await database
          .into(database.playlistTable)
          .insert(_playlistCompanion(playlist, includeId: true));
      await _replaceTracks(playlist.id, playlist.trackIds);
    });
  }

  @override
  Future<PlaylistDto?> getPlaylistById(String id) async {
    final query = _playlistQuery()..where(database.playlistTable.id.equals(id));
    final playlists = _mapRows(await query.get());
    return playlists.firstOrNull;
  }

  @override
  Future<PlaylistMutationResult> updateMetadata(PlaylistDto playlist) async {
    return database.transaction(() async {
      final affected =
          await (database.update(database.playlistTable)..where(
                (table) =>
                    table.id.equals(playlist.id) &
                    table.revision.equals(playlist.revision),
              ))
              .write(
                PlaylistTableCompanion(
                  name: Value(playlist.name),
                  description: Value(playlist.description),
                  imageUrl: Value(playlist.imageUrl),
                  revision: Value(playlist.revision + 1),
                ),
              );
      if (affected == 1) return PlaylistMutationResult.applied;
      return _missingOrConflict(playlist.id);
    });
  }

  @override
  Future<bool> addTrack(String playlistId, String trackId) async {
    return database.transaction(() async {
      final inserted = await database.customUpdate(
        '''
INSERT OR IGNORE INTO playlist_track_table (playlist_id, track_id, position)
SELECT ?, ?, COALESCE((
  SELECT MAX(position)
  FROM playlist_track_table
  WHERE playlist_id = ?
), -1) + 1
WHERE EXISTS (SELECT 1 FROM playlist_table WHERE id = ?)
''',
        variables: [
          Variable<String>(playlistId),
          Variable<String>(trackId),
          Variable<String>(playlistId),
          Variable<String>(playlistId),
        ],
        updates: {database.playlistTrackTable},
      );
      if (inserted == 1) {
        await database.customUpdate(
          'UPDATE playlist_table SET revision = revision + 1 WHERE id = ?',
          variables: [Variable<String>(playlistId)],
          updates: {database.playlistTable},
        );
        return true;
      }

      final playlistExists = await _playlistExists(playlistId);
      if (!playlistExists) return false;
      return true;
    });
  }

  @override
  Future<PlaylistMutationResult> removeTrack(
    String playlistId,
    String trackId, {
    required int expectedRevision,
  }) async {
    return database.transaction(() async {
      final claimed = await _claimTrackRevision(
        playlistId,
        trackId,
        expectedRevision,
      );
      if (claimed != PlaylistMutationResult.applied) return claimed;

      final relation =
          await (database.select(database.playlistTrackTable)..where(
                (table) =>
                    table.playlistId.equals(playlistId) &
                    table.trackId.equals(trackId),
              ))
              .getSingle();
      await (database.delete(database.playlistTrackTable)..where(
            (table) =>
                table.playlistId.equals(playlistId) &
                table.trackId.equals(trackId),
          ))
          .go();
      await database.customUpdate(
        '''
UPDATE playlist_track_table
SET position = -position - 1
WHERE playlist_id = ? AND position > ?
''',
        variables: [
          Variable<String>(playlistId),
          Variable<int>(relation.position),
        ],
        updates: {database.playlistTrackTable},
      );
      await database.customUpdate(
        '''
UPDATE playlist_track_table
SET position = -position - 2
WHERE playlist_id = ? AND position < 0
''',
        variables: [Variable<String>(playlistId)],
        updates: {database.playlistTrackTable},
      );
      return PlaylistMutationResult.applied;
    });
  }

  @override
  Future<PlaylistMutationResult> reorderTracks(
    String playlistId,
    List<String> trackIds, {
    required int expectedRevision,
  }) async {
    return database.transaction(() async {
      if (trackIds.toSet().length != trackIds.length) {
        return _missingOrConflict(playlistId);
      }
      final claimed = await _claimExactTrackSetRevision(
        playlistId,
        trackIds,
        expectedRevision,
      );
      if (claimed != PlaylistMutationResult.applied) return claimed;
      await _replaceTracks(playlistId, trackIds);
      return PlaylistMutationResult.applied;
    });
  }

  @override
  Stream<List<PlaylistSummaryDto>> watchPlaylistSummaries() {
    return database
        .customSelect(
          '''
SELECT
  playlist.id,
  playlist.name,
  playlist.created_at,
  playlist.description,
  playlist.image_url,
  playlist.revision,
  COUNT(relation.track_id) AS track_count
FROM playlist_table AS playlist
LEFT JOIN playlist_track_table AS relation
  ON relation.playlist_id = playlist.id
GROUP BY playlist.id
ORDER BY playlist.created_at DESC, playlist.id ASC
''',
          readsFrom: {database.playlistTable, database.playlistTrackTable},
        )
        .watch()
        .map(
          (rows) => rows
              .map(
                (row) => PlaylistSummaryDto(
                  id: row.read<String>('id'),
                  name: row.read<String>('name'),
                  createdAt: DateTime.fromMillisecondsSinceEpoch(
                    row.read<int>('created_at') * 1000,
                  ),
                  description: row.readNullable<String>('description'),
                  imageUrl: row.readNullable<String>('image_url'),
                  revision: row.read<int>('revision'),
                  trackCount: row.read<int>('track_count'),
                ),
              )
              .toList(),
        );
  }

  @override
  Stream<PlaylistDto?> watchPlaylistById(String id) {
    final query = _playlistQuery()..where(database.playlistTable.id.equals(id));
    return query.watch().map((rows) => _mapRows(rows).firstOrNull);
  }

  JoinedSelectStatement<HasResultSet, dynamic> _playlistQuery() {
    return database.select(database.playlistTable).join([
      leftOuterJoin(
        database.playlistTrackTable,
        database.playlistTrackTable.playlistId.equalsExp(
          database.playlistTable.id,
        ),
      ),
    ])..orderBy([
      OrderingTerm.desc(database.playlistTable.createdAt),
      OrderingTerm.asc(database.playlistTable.id),
      OrderingTerm.asc(database.playlistTrackTable.position),
    ]);
  }

  List<PlaylistDto> _mapRows(List<TypedResult> rows) {
    final playlists = <String, PlaylistTableData>{};
    final tracks = <String, List<(int, String)>>{};

    for (final row in rows) {
      final playlist = row.readTable(database.playlistTable);
      playlists[playlist.id] = playlist;
      final relation = row.readTableOrNull(database.playlistTrackTable);
      if (relation != null) {
        tracks.putIfAbsent(playlist.id, () => []).add((
          relation.position,
          relation.trackId,
        ));
      }
    }

    return playlists.values.map((playlist) {
      final orderedTracks = tracks[playlist.id] ?? [];
      orderedTracks.sort((a, b) => a.$1.compareTo(b.$1));
      return PlaylistDto.fromDataClass(
        playlist,
        trackIds: orderedTracks.map((item) => item.$2).toList(),
      );
    }).toList();
  }

  PlaylistTableCompanion _playlistCompanion(
    PlaylistDto playlist, {
    bool includeId = false,
  }) {
    return PlaylistTableCompanion(
      id: includeId ? Value(playlist.id) : const Value.absent(),
      name: Value(playlist.name),
      description: Value(playlist.description),
      createdAt: Value(playlist.createdAt),
      imageUrl: Value(playlist.imageUrl),
      revision: Value(playlist.revision),
    );
  }

  Future<PlaylistMutationResult> _claimTrackRevision(
    String playlistId,
    String trackId,
    int expectedRevision,
  ) async {
    final affected = await database.customUpdate(
      '''
UPDATE playlist_table
SET revision = revision + 1
WHERE id = ? AND revision = ?
  AND EXISTS (
    SELECT 1
    FROM playlist_track_table
    WHERE playlist_id = ? AND track_id = ?
  )
''',
      variables: [
        Variable<String>(playlistId),
        Variable<int>(expectedRevision),
        Variable<String>(playlistId),
        Variable<String>(trackId),
      ],
      updates: {database.playlistTable},
    );
    if (affected == 1) return PlaylistMutationResult.applied;
    return _missingOrConflict(playlistId);
  }

  Future<PlaylistMutationResult> _claimExactTrackSetRevision(
    String playlistId,
    List<String> trackIds,
    int expectedRevision,
  ) async {
    final membershipCheck = trackIds.isEmpty
        ? ''
        : '''
  AND NOT EXISTS (
    SELECT 1
    FROM playlist_track_table
    WHERE playlist_id = ?
      AND track_id NOT IN (
        SELECT CAST(value AS TEXT) FROM json_each(?)
      )
  )
''';
    final affected = await database.customUpdate(
      '''
UPDATE playlist_table
SET revision = revision + 1
WHERE id = ? AND revision = ?
  AND (
    SELECT COUNT(*)
    FROM playlist_track_table
    WHERE playlist_id = ?
  ) = ?
$membershipCheck
''',
      variables: [
        Variable<String>(playlistId),
        Variable<int>(expectedRevision),
        Variable<String>(playlistId),
        Variable<int>(trackIds.length),
        if (trackIds.isNotEmpty) Variable<String>(playlistId),
        if (trackIds.isNotEmpty) Variable<String>(jsonEncode(trackIds)),
      ],
      updates: {database.playlistTable},
    );
    if (affected == 1) return PlaylistMutationResult.applied;
    return _missingOrConflict(playlistId);
  }

  Future<PlaylistMutationResult> _missingOrConflict(String playlistId) async {
    return await _playlistExists(playlistId)
        ? PlaylistMutationResult.conflict
        : PlaylistMutationResult.notFound;
  }

  Future<bool> _playlistExists(String playlistId) async {
    final row =
        await (database.selectOnly(database.playlistTable)
              ..addColumns([database.playlistTable.id])
              ..where(database.playlistTable.id.equals(playlistId)))
            .getSingleOrNull();
    return row != null;
  }

  Future<void> _replaceTracks(String playlistId, List<String> trackIds) async {
    await (database.delete(
      database.playlistTrackTable,
    )..where((table) => table.playlistId.equals(playlistId))).go();

    final uniqueIds = <String>{};
    final companions = <PlaylistTrackTableCompanion>[];
    for (final trackId in trackIds) {
      if (!uniqueIds.add(trackId)) continue;
      companions.add(
        PlaylistTrackTableCompanion.insert(
          playlistId: playlistId,
          trackId: trackId,
          position: companions.length,
        ),
      );
    }
    if (companions.isNotEmpty) {
      await database.batch(
        (batch) => batch.insertAll(database.playlistTrackTable, companions),
      );
    }
  }
}
