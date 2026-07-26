import 'package:drift/drift.dart';
import 'package:openmusic/layers/data/models/playlist_dto.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/playlist/playlist_local_data_source.dart';

class PlaylistDriftLocalSource implements PlaylistLocalDataSource {
  PlaylistDriftLocalSource(this.database);

  final AppDatabase database;

  @override
  Future<void> deletePlaylist(String id) async {
    await (database.delete(
      database.playlistTable,
    )..where((table) => table.id.equals(id))).go();
  }

  @override
  Future<List<PlaylistDto>> getPlaylists() async {
    return _mapRows(await _playlistQuery().get());
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
  Future<void> updatePlaylist(PlaylistDto playlist) async {
    await database.transaction(() async {
      await (database.update(database.playlistTable)
            ..where((table) => table.id.equals(playlist.id)))
          .write(_playlistCompanion(playlist));
      await _replaceTracks(playlist.id, playlist.trackIds);
    });
  }

  @override
  Future<bool> addTrack(String playlistId, String trackId) async {
    return database.transaction(() async {
      final playlistExists = await (database.select(
        database.playlistTable,
      )..where((table) => table.id.equals(playlistId))).getSingleOrNull();
      if (playlistExists == null) return false;

      final maxPosition = database.playlistTrackTable.position.max();
      final positionRow =
          await (database.selectOnly(database.playlistTrackTable)
                ..addColumns([maxPosition])
                ..where(
                  database.playlistTrackTable.playlistId.equals(playlistId),
                ))
              .getSingle();
      final nextPosition = (positionRow.read(maxPosition) ?? -1) + 1;
      await database
          .into(database.playlistTrackTable)
          .insert(
            PlaylistTrackTableCompanion.insert(
              playlistId: playlistId,
              trackId: trackId,
              position: nextPosition,
            ),
            mode: InsertMode.insertOrIgnore,
          );
      return true;
    });
  }

  @override
  Future<bool> removeTrack(String playlistId, String trackId) async {
    return database.transaction(() async {
      final playlistExists = await (database.select(
        database.playlistTable,
      )..where((table) => table.id.equals(playlistId))).getSingleOrNull();
      if (playlistExists == null) return false;

      await (database.delete(database.playlistTrackTable)..where(
            (table) =>
                table.playlistId.equals(playlistId) &
                table.trackId.equals(trackId),
          ))
          .go();
      await database.customStatement(
        '''
UPDATE playlist_track_table AS target
SET position = (
  SELECT COUNT(*) - 1
  FROM playlist_track_table AS preceding
  WHERE preceding.playlist_id = target.playlist_id
    AND preceding.position <= target.position
)
WHERE target.playlist_id = ?
''',
        [playlistId],
      );
      return true;
    });
  }

  @override
  Stream<List<PlaylistDto>> watchPlaylist() {
    return _playlistQuery().watch().map(_mapRows);
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
    );
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
