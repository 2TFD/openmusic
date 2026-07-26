import 'package:openmusic/layers/data/models/playlist_dto.dart';

abstract class PlaylistLocalDataSource {
  Future<List<PlaylistDto>> getPlaylists();
  Future<PlaylistDto?> getPlaylistById(String id);
  Future<void> savePlaylist(PlaylistDto playlist);
  Future<void> deletePlaylist(String id);
  Future<void> updatePlaylist(PlaylistDto playlist);
  Future<bool> addTrack(String playlistId, String trackId);
  Future<bool> removeTrack(String playlistId, String trackId);
  Stream<List<PlaylistDto>> watchPlaylist();
}
