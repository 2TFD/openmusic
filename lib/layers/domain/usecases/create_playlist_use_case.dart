import '../entities/playlist.dart';
import '../repositories/playlist_repository.dart';

class CreatePlaylistUseCase {
  final PlaylistRepository _repository;

  CreatePlaylistUseCase(this._repository);

  Future<void> call(Playlist playlist) async {
    await _repository.createPlaylist(playlist);
  }
}
