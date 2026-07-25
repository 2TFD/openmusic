import 'package:openmusic/layers/data/datasources/local/playlist/playlist_local_data_source.dart';
import 'package:openmusic/layers/data/mappers/playlist_mapper.dart';
import 'package:openmusic/layers/domain/entities/playlist.dart';
import 'package:openmusic/layers/domain/repositories/playlist_repository.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  final PlaylistLocalDataSource localDataSource;

  PlaylistRepositoryImpl({required this.localDataSource});

  @override
  Future<void> addTrackToPlaylist(String playlistId, String trackId) async {
    final playlist = await getPlaylistById(playlistId);
    if (playlist == null) {
      throw Exception('Playlist with id: $playlistId not found');
    }
    final updated = playlist.copyWith(
      trackIds: [...playlist.trackIds, trackId],
    );

    await updatePlaylist(updated);
  }

  @override
  Future<void> createPlaylist(Playlist playlist) async {
    final model = PlaylistMapper.toDto(playlist);
    await localDataSource.savePlaylist(model);
  }

  @override
  Future<void> deletePlaylist(String playlistId) async {
    await localDataSource.deletePlaylist(playlistId);
  }

  @override
  Future<Playlist?> getPlaylistById(String id) async {
    final model = await localDataSource.getPlaylistById(id);
    return model == null ? null : PlaylistMapper.toEntity(model);
  }

  @override
  Future<List<Playlist>> getPlaylists() async {
    final models = await localDataSource.getPlaylists();
    return models.map(PlaylistMapper.toEntity).toList();
  }

  @override
  Future<void> removeTrackFromPlaylist(
    String playlistId,
    String trackId,
  ) async {
    final playlist = await getPlaylistById(playlistId);
    if (playlist == null) {
      throw Exception('Playlist with id: $playlistId not found');
    }

    final updated = playlist.copyWith(
      trackIds: playlist.trackIds.where((id) => id != trackId).toList(),
    );

    await updatePlaylist(updated);
  }

  @override
  Future<void> updatePlaylist(Playlist playlist) async {
    final model = PlaylistMapper.toDto(playlist);
    await localDataSource.updatePlaylist(model);
  }

  @override
  Stream<List<Playlist>> watchPlaylist() {
    return localDataSource
        .watchPlaylist()
        .map((dtos) => dtos.map(PlaylistMapper.toEntity).toList());
  }
}
