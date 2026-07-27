import 'package:openmusic/layers/data/models/playlist_dto.dart';

enum PlaylistMutationResult { applied, notFound, conflict }

abstract class PlaylistLocalDataSource {
  Future<PlaylistDto?> getPlaylistById(String id);
  Future<void> savePlaylist(PlaylistDto playlist);
  Future<bool> deletePlaylist(String id);
  Future<PlaylistMutationResult> updateMetadata(PlaylistDto playlist);
  Future<bool> addTrack(String playlistId, String trackId);
  Future<PlaylistMutationResult> removeTrack(
    String playlistId,
    String trackId, {
    required int expectedRevision,
  });
  Future<PlaylistMutationResult> reorderTracks(
    String playlistId,
    List<String> trackIds, {
    required int expectedRevision,
  });
  Stream<List<PlaylistSummaryDto>> watchPlaylistSummaries();
  Stream<PlaylistDto?> watchPlaylistById(String id);
}
