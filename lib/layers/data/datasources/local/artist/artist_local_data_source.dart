import 'package:openmusic/layers/data/models/artist_summary_dto.dart';

abstract class ArtistLocalDataSource {
  Stream<List<ArtistSummaryDto>> watchArtistSummaries();
  Stream<ArtistSummaryDto?> watchArtistById(String id);
  Future<List<String>> getTrackIdsByArtist(String artistId);
}
