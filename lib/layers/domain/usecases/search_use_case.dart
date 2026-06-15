import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';
import 'package:openmusic/layers/domain/repositories/search_source.dart';
import 'package:openmusic/layers/domain/repositories/track_repository.dart';

class SearchUseCase {
  final TrackRepository trackRepository;
  final SearchSource searchSource;

  SearchUseCase({required this.trackRepository, required this.searchSource});

  Future<List<Track>> searchLocal(String query) async {
    return await trackRepository.searchTracks(query);
  }

  Future<List<TrackPreview>> searchExternal(
    String query, {
    int offset = 0,
  }) async {
    return await searchSource.searchExternal(query, offset: offset);
  }
}
