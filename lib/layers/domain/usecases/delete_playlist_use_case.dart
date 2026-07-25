import 'package:openmusic/layers/domain/repositories/playlist_repository.dart';

class DeletePlaylistUseCase {
  final PlaylistRepository _repository;

  DeletePlaylistUseCase(this._repository);

  Future<void> call(String playlistId) async {
    await _repository.deletePlaylist(playlistId);
  }
}
