import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/layers/data/datasources/local/playlist/playlist_local_data_source.dart';
import 'package:openmusic/layers/data/mappers/playlist_mapper.dart';
import 'package:openmusic/layers/domain/entities/playlist.dart';
import 'package:openmusic/layers/domain/repositories/playlist_repository.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  final PlaylistLocalDataSource localDataSource;

  PlaylistRepositoryImpl({required this.localDataSource});

  @override
  Future<void> addTrackToPlaylist(String playlistId, String trackId) async {
    final exists = await localDataSource.addTrack(playlistId, trackId);
    if (!exists) {
      throw NotFoundFailure('playlist', playlistId);
    }
  }

  @override
  Future<void> createPlaylist(Playlist playlist) async {
    final model = PlaylistMapper.toDto(playlist);
    await localDataSource.savePlaylist(model);
  }

  @override
  Future<void> deletePlaylist(String playlistId) async {
    final deleted = await localDataSource.deletePlaylist(playlistId);
    if (!deleted) throw NotFoundFailure('playlist', playlistId);
  }

  @override
  Future<Playlist?> getPlaylistById(String id) async {
    final model = await localDataSource.getPlaylistById(id);
    return model == null ? null : PlaylistMapper.toEntity(model);
  }

  @override
  Future<void> removeTrackFromPlaylist(
    String playlistId,
    String trackId, {
    required int expectedRevision,
  }) async {
    final result = await localDataSource.removeTrack(
      playlistId,
      trackId,
      expectedRevision: expectedRevision,
    );
    _throwForMutation(result, playlistId);
  }

  @override
  Future<void> reorderTracks(
    String playlistId,
    List<String> trackIds, {
    required int expectedRevision,
  }) async {
    final result = await localDataSource.reorderTracks(
      playlistId,
      trackIds,
      expectedRevision: expectedRevision,
    );
    _throwForMutation(result, playlistId);
  }

  @override
  Future<void> updateMetadata(Playlist playlist) async {
    final model = PlaylistMapper.toDto(playlist);
    final result = await localDataSource.updateMetadata(model);
    _throwForMutation(result, playlist.id);
  }

  @override
  Stream<List<PlaylistSummary>> watchPlaylistSummaries() {
    return localDataSource.watchPlaylistSummaries().map(
      (dtos) => dtos.map(PlaylistMapper.summaryToEntity).toList(),
    );
  }

  @override
  Stream<Playlist?> watchPlaylistById(String id) {
    return localDataSource
        .watchPlaylistById(id)
        .map((dto) => dto == null ? null : PlaylistMapper.toEntity(dto));
  }

  void _throwForMutation(PlaylistMutationResult result, String playlistId) {
    switch (result) {
      case PlaylistMutationResult.applied:
        return;
      case PlaylistMutationResult.notFound:
        throw NotFoundFailure('playlist', playlistId);
      case PlaylistMutationResult.conflict:
        throw ConflictFailure('playlist', playlistId);
    }
  }
}
