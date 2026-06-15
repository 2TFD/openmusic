import '../repositories/playlist_repository.dart';

class AddTrackToPlaylistUseCase {
  final PlaylistRepository _repository;

  AddTrackToPlaylistUseCase(this._repository);

  Future<void> call({
    required String playlistId,
    required String trackId,
  }) async {
    await _repository.addTrackToPlaylist(playlistId, trackId);
  }
}
