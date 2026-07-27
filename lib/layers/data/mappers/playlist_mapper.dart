import '../../domain/entities/playlist.dart';
import '../models/playlist_dto.dart';

class PlaylistMapper {
  static Playlist toEntity(PlaylistDto model) {
    return Playlist(
      id: model.id,
      name: model.name,
      trackIds: model.trackIds,
      createdAt: model.createdAt,
      description: model.description,
      imageUrl: model.imageUrl,
      revision: model.revision,
    );
  }

  static PlaylistSummary summaryToEntity(PlaylistSummaryDto model) {
    return PlaylistSummary(
      id: model.id,
      name: model.name,
      createdAt: model.createdAt,
      trackCount: model.trackCount,
      revision: model.revision,
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
      revision: entity.revision,
    );
  }
}
