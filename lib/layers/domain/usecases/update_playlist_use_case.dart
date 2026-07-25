import 'package:openmusic/layers/domain/entities/playlist.dart';
import 'package:openmusic/layers/domain/repositories/playlist_repository.dart';

class UpdatePlaylistUseCase {
  final PlaylistRepository _repository;

  UpdatePlaylistUseCase(this._repository);

  Future<void> call(Playlist playlist) async {
    await _repository.updatePlaylist(playlist);
  }

  Playlist removeTrack(Playlist playlist, String trackId) {
    return playlist.copyWith(
      trackIds: playlist.trackIds.where((id) => id != trackId).toList(),
    );
  }

  Playlist reorderTracks(Playlist playlist, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final ids = List<String>.from(playlist.trackIds);
    ids.insert(newIndex, ids.removeAt(oldIndex));
    return playlist.copyWith(trackIds: ids);
  }

  Playlist rename(Playlist playlist, String name) {
    return playlist.copyWith(name: name);
  }
}
