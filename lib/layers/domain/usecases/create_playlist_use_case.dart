import '../entities/playlist.dart';
import '../repositories/playlist_repository.dart';
import 'playlist_metadata_validation.dart';

class CreatePlaylistUseCase {
  final PlaylistRepository _repository;

  CreatePlaylistUseCase(this._repository);

  Future<void> call(Playlist playlist) async {
    final metadata = validatePlaylistMetadata(
      name: playlist.name,
      description: playlist.description,
      imageUrl: playlist.imageUrl,
    );
    await _repository.createPlaylist(
      playlist.copyWith(
        name: metadata.name,
        description: metadata.description,
        imageUrl: metadata.imageUrl,
        clearDescription: metadata.description == null,
        clearImageUrl: metadata.imageUrl == null,
      ),
    );
  }
}
