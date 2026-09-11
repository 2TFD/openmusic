import '../../domain/entities/artist.dart';
import '../../domain/entities/source.dart';
import '../../domain/entities/track.dart';
import '../models/track_dto.dart';

class TrackMapper {
  static Track toEntity(TrackDto dto) {
    return Track(
      trackDescriptor: dto.trackDescriptorJson != null
          ? TrackDescriptor.fromJson(dto.trackDescriptorJson!)
          : null,
      id: dto.id,
      contentIdentity: dto.contentIdentity,
      title: dto.title,
      filePath: dto.filePath,
      artists: dto.artists
          .map((artist) => Artist(id: artist.id, name: artist.name))
          .toList(),
      duration: dto.durationMs != null
          ? Duration(milliseconds: dto.durationMs!)
          : Duration.zero,
      source: Source(
        type: SourceType.values.firstWhere(
          (e) => e.name == dto.sourceType,
          orElse: () => SourceType.unknown,
        ),
        originalUrl: dto.originalUrl,
        media:
            dto.mediaSourceType != null &&
                dto.mediaSourceId != null &&
                dto.mediaSourceUrl != null
            ? MediaLocator(
                type: SourceType.values.firstWhere(
                  (type) => type.name == dto.mediaSourceType,
                  orElse: () => SourceType.unknown,
                ),
                id: dto.mediaSourceId!,
                url: dto.mediaSourceUrl!,
              )
            : null,
      ),
      addedAt:
          dto.addedAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      album: dto.album,
      imageUrl: dto.imageUrl,
      audioRevision: dto.audioRevision,
      metadataRevision: dto.metadataRevision,
    );
  }

  static TrackDto toDto(Track entity) {
    return TrackDto(
      trackDescriptorJson: entity.trackDescriptor?.toJson(),
      id: entity.id,
      contentIdentity: entity.contentIdentity,
      title: entity.title,
      filePath: entity.filePath,
      artists: entity.artists
          .map((artist) => ArtistDto(id: artist.id, name: artist.name))
          .toList(),
      durationMs: entity.duration.inMilliseconds,
      sourceType: entity.source.type.name,
      originalUrl: entity.source.originalUrl,
      addedAt: entity.addedAt,
      album: entity.album,
      imageUrl: entity.imageUrl,
      audioRevision: entity.audioRevision,
      metadataRevision: entity.metadataRevision,
      mediaSourceType: entity.source.media?.type.name,
      mediaSourceId: entity.source.media?.id,
      mediaSourceUrl: entity.source.media?.url,
    );
  }
}
