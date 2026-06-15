import 'package:openmusic/layers/data/DTO/playlist_dto.dart';

abstract class PlaylistLocalDataSource {
  Future<List<PlaylistDto>> getPlaylists();
  Future<PlaylistDto?> getPlaylistById(String id);
  Future<void> savePlaylist(PlaylistDto playlist);
  Future<void> deletePlaylist(String id);
  Future<void> updatePlaylist(PlaylistDto playlist);
  Stream<dynamic> watchPlaylist();
}
