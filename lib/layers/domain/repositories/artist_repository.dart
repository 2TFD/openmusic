import 'package:owlsonic/layers/domain/entities/artist.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';

abstract class ArtistRepository {
  Stream<List<ArtistSummary>> watchArtistSummaries();
  Stream<ArtistSummary?> watchArtistById(String id);
  Future<List<Track>> getTracksByArtist(String artistId);
}
