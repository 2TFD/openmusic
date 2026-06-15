import '../../domain/entities/playlist.dart';
import '../DTO/playlist_dto.dart';

class PlaylistMapper {
  static Playlist toEntity(PlaylistDto model) {
    return Playlist(
      id: model.id,
      name: model.name,
      trackIds: model.trackIds,
      createdAt: model.createdAt,
      description: model.description,
      imageUrl: model.imageUrl,
    );
  }

  static PlaylistDto toDto(Playlist entity) {
    return PlaylistDto(
      id: entity.id,
      name: entity.name,
      trackIds: entity.trackIds,
      createdAt: entity.createdAt,
      description: entity.description,
      imageUrl: entity.imageUrl,
    );
  }
}
