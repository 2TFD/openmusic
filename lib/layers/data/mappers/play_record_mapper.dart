import '../../domain/entities/play_record.dart';
import '../DTO/play_record_dto.dart';

class PlayRecordMapper {
  static PlayRecord toEntity(PlayRecordDto dto) {
    return PlayRecord(
      id: dto.id,
      trackId: dto.trackId,
      trackTitle: dto.trackTitle,
      artistName: dto.artistName,
      sourceType: dto.sourceType,
      listenedDuration: Duration(milliseconds: dto.listenedMs),
      playedAt: dto.playedAt,
    );
  }

  static PlayRecordDto toDto(PlayRecord entity) {
    return PlayRecordDto(
      id: entity.id,
      trackId: entity.trackId,
      trackTitle: entity.trackTitle,
      artistName: entity.artistName,
      sourceType: entity.sourceType,
      listenedMs: entity.listenedDuration.inMilliseconds,
      playedAt: entity.playedAt,
    );
  }
}
