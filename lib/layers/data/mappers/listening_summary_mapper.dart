import '../../domain/entities/listening_summary.dart';
import '../models/listening_summary_dto.dart';

class ListeningSummaryMapper {
  static ListeningSummary toEntity(ListeningSummaryDto dto) {
    return ListeningSummary(
      id: dto.id,
      trackId: dto.trackId,
      trackTitle: dto.trackTitle,
      artistName: dto.artistName,
      sourceType: dto.sourceType,
      listenedDuration: Duration(milliseconds: dto.listenedMs),
      playedAt: dto.playedAt,
    );
  }

  static ListeningSummaryDto toDto(ListeningSummary entity) {
    return ListeningSummaryDto(
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
