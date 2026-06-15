import '../entities/playlist.dart';

abstract class PlaylistRepository {
  Future<List<Playlist>> getPlaylists();
  Future<Playlist?> getPlaylistById(String id);
  Future<void> createPlaylist(Playlist playlist);
  Future<void> deletePlaylist(String playlistId);
  Future<void> addTrackToPlaylist(String playlistId, String trackId);
  Future<void> removeTrackFromPlaylist(String playlistId, String trackId);
  Future<void> updatePlaylist(Playlist playlist);
  Stream<dynamic> watchPlaylist();
}
