import 'package:drift/drift.dart';
import 'package:openmusic/layers/data/DTO/playlist_dto.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/playlist/playlist_local_data_source.dart';

class PlaylistDriftLocalSource implements PlaylistLocalDataSource {
  final AppDatabase database;
  PlaylistDriftLocalSource(this.database);

  @override
  Future<void> deletePlaylist(String id) async {
    await (database.delete(
      database.playlistTable,
    )..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<List<PlaylistDto>> getPlaylists() async {
    final List<PlaylistTableData> res = await database
        .select(database.playlistTable)
        .get();
    return res.map((e) => PlaylistDto.fromDataClass(e)).toList();
  }

  @override
  Future<void> savePlaylist(PlaylistDto playlist) async {
    await database
        .into(database.playlistTable)
        .insert(
          PlaylistTableCompanion(
            id: Value(playlist.id),
            name: Value(playlist.name),
            description: Value(playlist.description),
            trackIds: Value(playlist.trackIds.join(',')),
            createdAt: Value(playlist.createdAt),
            imageUrl: Value(playlist.imageUrl),
          ),
        );
  }

  @override
  Future<PlaylistDto?> getPlaylistById(String id) async {
    return await (database.select(
      database.playlistTable,
    )..where((t) => t.id.equals(id))).getSingleOrNull().then(
      (data) => data != null ? PlaylistDto.fromDataClass(data) : null,
    );
  }

  @override
  Future<void> updatePlaylist(PlaylistDto playlist) async {
    await (database.update(
      database.playlistTable,
    )..where((t) => t.id.equals(playlist.id))).write(
      PlaylistTableCompanion(
        name: Value(playlist.name),
        description: Value(playlist.description),
        trackIds: Value(playlist.trackIds.join(',')),
        imageUrl: Value(playlist.imageUrl),
      ),
    );
  }

  @override
  Stream<List<PlaylistDto>> watchPlaylist() {
    return database
        .select(database.playlistTable)
        .watch()
        .map((rows) => rows.map(PlaylistDto.fromDataClass).toList());
  }
}
