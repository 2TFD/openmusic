import 'package:openmusic/layers/domain/entities/playlist.dart';
import 'package:openmusic/layers/domain/repositories/playlist_repository.dart';

class WatchPlaylistUseCase {
  const WatchPlaylistUseCase(this._repository);

  final PlaylistRepository _repository;

  Stream<Playlist?> call(String playlistId) =>
      _repository.watchPlaylistById(playlistId);
}
