import 'package:openmusic/layers/data/models/artist_summary_dto.dart';
import 'package:openmusic/layers/domain/entities/artist.dart';

class ArtistMapper {
  const ArtistMapper._();

  static ArtistSummary summaryToEntity(ArtistSummaryDto model) {
    return ArtistSummary(
      id: model.id,
      name: model.name,
      trackCount: model.trackCount,
      totalDuration: Duration(milliseconds: model.totalDurationMs),
      coverImageUrls: model.coverImageUrls,
    );
  }
}
