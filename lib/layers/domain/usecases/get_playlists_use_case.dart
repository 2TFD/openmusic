import '../entities/playlist.dart';
import '../repositories/playlist_repository.dart';

class GetPlaylistsUseCase {
  final PlaylistRepository _repository;

  GetPlaylistsUseCase(this._repository);

  Future<List<Playlist>> call() async => await _repository.getPlaylists();
}
