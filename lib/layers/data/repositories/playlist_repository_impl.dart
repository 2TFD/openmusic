import 'package:openmusic/core/utils/app_logger.dart';
import 'package:openmusic/layers/data/datasources/local/playlist/playlist_local_data_source.dart';
import 'package:openmusic/layers/data/mappers/playlist_mapper.dart';
import 'package:openmusic/layers/domain/entities/playlist.dart';
import 'package:openmusic/layers/domain/repositories/playlist_repository.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  final PlaylistLocalDataSource localDataSource;

  PlaylistRepositoryImpl({required this.localDataSource});

  @override
  Future<void> addTrackToPlaylist(String playlistId, String trackId) async {
    try {
      final playlist = await getPlaylistById(playlistId);
      if (playlist == null) {
        throw Exception('Playlist with id: $playlistId not found');
      }
      final updated = playlist.copyWith(
        trackIds: [...playlist.trackIds, trackId],
      );

      await updatePlaylist(updated);
    } catch (e, st) {
      await AppLogger.log(
        '[PlaylistRepositoryImpl.addTrackToPlaylist] Error adding track $trackId to playlist $playlistId: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Future<void> createPlaylist(Playlist playlist) async {
    try {
      final model = PlaylistMapper.toDto(playlist);
      await localDataSource.savePlaylist(model);
    } catch (e, st) {
      await AppLogger.log(
        '[PlaylistRepositoryImpl.createPlaylist] Error creating playlist ${playlist.id}: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Future<void> deletePlaylist(String playlistId) async {
    try {
      await localDataSource.deletePlaylist(playlistId);
    } catch (e, st) {
      await AppLogger.log(
        '[PlaylistRepositoryImpl.deletePlaylist] Error deleting playlist $playlistId: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Future<Playlist?> getPlaylistById(String id) async {
    try {
      final model = await localDataSource.getPlaylistById(id);
      return model == null ? null : PlaylistMapper.toEntity(model);
    } catch (e, st) {
      await AppLogger.log(
        '[PlaylistRepositoryImpl.getPlaylistById] Error getting playlist $id: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Future<List<Playlist>> getPlaylists() async {
    try {
      final models = await localDataSource.getPlaylists();
      return models.map(PlaylistMapper.toEntity).toList();
    } catch (e, st) {
      await AppLogger.log(
        '[PlaylistRepositoryImpl.getPlaylists] Error getting playlists: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Future<void> removeTrackFromPlaylist(
    String playlistId,
    String trackId,
  ) async {
    try {
      final playlist = await getPlaylistById(playlistId);
      if (playlist == null) {
        throw Exception('Playlist with id: $playlistId not found');
      }

      final updated = playlist.copyWith(
        trackIds: playlist.trackIds.where((id) => id != trackId).toList(),
      );

      await updatePlaylist(updated);
    } catch (e, st) {
      await AppLogger.log(
        '[PlaylistRepositoryImpl.removeTrackFromPlaylist] Error removing track $trackId from playlist $playlistId: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Future<void> updatePlaylist(Playlist playlist) async {
    try {
      final model = PlaylistMapper.toDto(playlist);
      await localDataSource.updatePlaylist(model);
    } catch (e, st) {
      await AppLogger.log(
        '[PlaylistRepositoryImpl.updatePlaylist] Error updating playlist ${playlist.id}: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Stream<dynamic> watchPlaylist() {
    try {
      return localDataSource.watchPlaylist();
    } catch (e, st) {
      AppLogger.log(
        '[PlaylistRepositoryImpl.watchPlaylist] Error watching playlists: $e, stackTrace: $st',
      );
      rethrow;
    }
  }
}
