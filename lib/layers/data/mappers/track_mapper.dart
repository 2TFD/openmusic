import '../../domain/entities/artist.dart';
import '../../domain/entities/source.dart';
import '../../domain/entities/track.dart';
import '../DTO/track_dto.dart';

class TrackMapper {
  static Track toEntity(TrackDto dto) {
    return Track(
      trackDescriptor: dto.trackDescriptorJson != null
          ? TrackDescriptor.fromJson(dto.trackDescriptorJson!)
          : null,
      embedding: dto.embedding,
      id: dto.id,
      title: dto.title,
      pathToFile: dto.pathToFile,
      artists: dto.artistIds.asMap().entries.map((entry) {
        final index = entry.key;
        final id = entry.value;
        return Artist(id: id, name: dto.artistNames[index]);
      }).toList(),
      duration: dto.durationMs != null
          ? Duration(milliseconds: dto.durationMs!)
          : Duration.zero,
      source: Source(
        type: SourceType.values.firstWhere(
          (e) => e.name == dto.sourceType,
          orElse: () => SourceType.localFile,
        ),
        originalUrl: dto.sourceUri,
      ),
      addedAt: dto.addedAt != null
          ? DateTime.parse(dto.addedAt!)
          : DateTime.now(),
      album: dto.album,
      imageUrl: dto.imageUrl,
    );
  }

  static TrackDto toDto(Track entity) {
    return TrackDto(
      trackDescriptorJson: entity.trackDescriptor?.toJson(),
      embedding: entity.embedding,
      id: entity.id,
      title: entity.title,
      pathToFile: entity.pathToFile,
      artistIds: entity.artists.map((artist) => artist.id).toList(),
      artistNames: entity.artists.map((artist) => artist.name).toList(),
      durationMs: entity.duration.inMilliseconds,
      sourceType: entity.source.type.name,
      sourceUri: entity.source.originalUrl,
      addedAt: entity.addedAt.toIso8601String(),
      album: entity.album,
      imageUrl: entity.imageUrl,
    );
  }
}
