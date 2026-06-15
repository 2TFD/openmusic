import 'package:drift/drift.dart';
import 'package:openmusic/core/utils/app_logger.dart';
import 'package:openmusic/layers/data/DTO/playlist_dto.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/playlist/playlist_local_data_source.dart';

class PlaylistDriftLocalSource implements PlaylistLocalDataSource {
  final AppDatabase database;
  PlaylistDriftLocalSource(this.database);

  @override
  Future<void> deletePlaylist(String id) async {
    try {
      await (database.delete(
        database.playlistTable,
      )..where((t) => t.id.equals(id))).go();
    } catch (e, st) {
      await AppLogger.log(
        '[PlaylistDriftLocalSource.deletePlaylist] Error deleting playlist $id: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Future<List<PlaylistDto>> getPlaylists() async {
    try {
      final List<PlaylistTableData> res = await database
          .select(database.playlistTable)
          .get();
      return res.map((e) => PlaylistDto.fromDataClass(e)).toList();
    } catch (e, st) {
      await AppLogger.log(
        '[PlaylistDriftLocalSource.getPlaylists] Error getting playlists: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Future<void> savePlaylist(PlaylistDto playlist) async {
    try {
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
    } catch (e, st) {
      await AppLogger.log(
        '[PlaylistDriftLocalSource.savePlaylist] Error saving playlist ${playlist.id}: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Future<PlaylistDto?> getPlaylistById(String id) async {
    try {
      return await (database.select(
        database.playlistTable,
      )..where((t) => t.id.equals(id))).getSingleOrNull().then(
        (data) => data != null ? PlaylistDto.fromDataClass(data) : null,
      );
    } catch (e, st) {
      await AppLogger.log(
        '[PlaylistDriftLocalSource.getPlaylistById] Error getting playlist $id: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Future<void> updatePlaylist(PlaylistDto playlist) async {
    try {
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
    } catch (e, st) {
      await AppLogger.log(
        '[PlaylistDriftLocalSource.updatePlaylist] Error updating playlist ${playlist.id}: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Stream<dynamic> watchPlaylist() {
    try {
      return database.select(database.playlistTable).watch();
    } catch (e, st) {
      AppLogger.log(
        '[PlaylistDriftLocalSource.watchPlaylist] Error watching playlists: $e, stackTrace: $st',
      );
      rethrow;
    }
  }
}
