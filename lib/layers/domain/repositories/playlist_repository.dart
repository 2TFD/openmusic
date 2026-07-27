import '../entities/playlist.dart';

abstract class PlaylistRepository {
  Future<Playlist?> getPlaylistById(String id);
  Future<void> createPlaylist(Playlist playlist);
  Future<void> deletePlaylist(String playlistId);
  Future<void> addTrackToPlaylist(String playlistId, String trackId);
  Future<void> removeTrackFromPlaylist(
    String playlistId,
    String trackId, {
    required int expectedRevision,
  });
  Future<void> reorderTracks(
    String playlistId,
    List<String> trackIds, {
    required int expectedRevision,
  });
  Future<void> updateMetadata(Playlist playlist);
  Stream<List<PlaylistSummary>> watchPlaylistSummaries();
  Stream<Playlist?> watchPlaylistById(String id);
}
