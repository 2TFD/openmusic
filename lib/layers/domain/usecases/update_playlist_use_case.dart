import 'package:openmusic/layers/domain/entities/playlist.dart';
import 'package:openmusic/layers/domain/repositories/playlist_repository.dart';
import 'package:openmusic/layers/domain/usecases/playlist_metadata_validation.dart';

class UpdatePlaylistUseCase {
  final PlaylistRepository _repository;

  UpdatePlaylistUseCase(this._repository);

  Future<Playlist> removeTrack(Playlist playlist, String trackId) async {
    await _repository.removeTrackFromPlaylist(
      playlist.id,
      trackId,
      expectedRevision: playlist.revision,
    );
    return playlist.copyWith(
      trackIds: playlist.trackIds.where((id) => id != trackId).toList(),
      revision: playlist.revision + 1,
    );
  }

  Future<Playlist> reorderTracks(
    Playlist playlist,
    int oldIndex,
    int newIndex,
  ) async {
    if (newIndex > oldIndex) newIndex--;
    final ids = List<String>.from(playlist.trackIds);
    ids.insert(newIndex, ids.removeAt(oldIndex));
    await _repository.reorderTracks(
      playlist.id,
      ids,
      expectedRevision: playlist.revision,
    );
    return playlist.copyWith(trackIds: ids, revision: playlist.revision + 1);
  }

  Future<Playlist> updateMetadata(
    Playlist playlist, {
    required String name,
    String? description,
    String? imageUrl,
    bool clearDescription = false,
    bool clearImageUrl = false,
  }) async {
    final metadata = validatePlaylistMetadata(
      name: name,
      description: description,
      imageUrl: imageUrl,
    );
    final updated = playlist.copyWith(
      name: metadata.name,
      description: metadata.description,
      imageUrl: metadata.imageUrl,
      clearDescription: clearDescription,
      clearImageUrl: clearImageUrl,
    );
    await _repository.updateMetadata(updated);
    return updated.copyWith(revision: playlist.revision + 1);
  }
}
