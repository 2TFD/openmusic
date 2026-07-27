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
      embedding: dto.embedding,
      id: dto.id,
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
      ),
      addedAt:
          dto.addedAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      album: dto.album,
      imageUrl: dto.imageUrl,
      metadataRevision: dto.metadataRevision,
    );
  }

  static TrackDto toDto(Track entity) {
    return TrackDto(
      trackDescriptorJson: entity.trackDescriptor?.toJson(),
      embedding: entity.embedding,
      id: entity.id,
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
      metadataRevision: entity.metadataRevision,
    );
  }
}
