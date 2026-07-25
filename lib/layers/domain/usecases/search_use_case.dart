import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';
import 'package:openmusic/layers/domain/repositories/search_source.dart';
import 'package:openmusic/layers/domain/repositories/track_repository.dart';

class LocalSearchPage {
  final List<Track> tracks;
  final bool hasMore;
  final int offset;

  const LocalSearchPage({
    required this.tracks,
    required this.hasMore,
    required this.offset,
  });
}

class SearchUseCase {
  final TrackRepository trackRepository;
  final SearchSource searchSource;

  static const int pageSize = 30;

  List<Track> _localCache = [];
  String _localCacheQuery = '';

  SearchUseCase({required this.trackRepository, required this.searchSource});

  Future<LocalSearchPage> searchLocal(String query, {int offset = 0}) async {
    if (offset == 0 || query != _localCacheQuery) {
      _localCache = await trackRepository.searchTracks(query);
      _localCacheQuery = query;
    }

    final page = _localCache.skip(offset).take(pageSize).toList();
    return LocalSearchPage(
      tracks: page,
      hasMore: offset + pageSize < _localCache.length,
      offset: offset,
    );
  }

  Future<List<TrackPreview>> searchExternal(
    String query, {
    int offset = 0,
  }) async {
    return await searchSource.searchExternal(query, offset: offset);
  }
}
