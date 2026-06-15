import 'package:dio/dio.dart';
import 'package:openmusic/core/utils/app_logger.dart';
import 'package:openmusic/layers/data/datasources/remote/soundcloud_track_source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/repositories/search_source.dart';
import 'package:openmusic/layers/domain/repositories/track_repository.dart';

class SearchSourceImpl implements SearchSource {
  final TrackRepository trackRepository;

  SearchSourceImpl({required this.trackRepository});

  @override
  Future<List<Track>> searchLocal(String query) async {
    return await trackRepository.searchTracks(query);
  }

  @override
  Future<List<TrackPreview>> searchExternal(
    String query, {
    int offset = 0,
  }) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://api-v2.soundcloud.com/search/tracks',
        queryParameters: {
          'q': query,
          'client_id': await _getClientId(),
          'limit': 30,
          'offset': offset,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('SoundCloud search failed: ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        return [];
      }

      final collection = (data['collection'] as List<dynamic>?) ?? [];
      return collection
          .whereType<Map<String, dynamic>>()
          .map((item) => _mapSoundCloudTrackPreview(item, query))
          .toList();
    } on DioException catch (e, st) {
      await AppLogger.log(
        '[SearchSourceImpl.searchExternal] DioException for query: $query, Error: ${e.message}, statusCode: ${e.response?.statusCode}, stackTrace: $st',
      );
      rethrow;
    } catch (e, st) {
      await AppLogger.log(
        '[SearchSourceImpl.searchExternal] Error searching for: $query, Error: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  TrackPreview _mapSoundCloudTrackPreview(
    Map<String, dynamic> json,
    String query,
  ) {
    try {
      final user = json['user'] as Map<String, dynamic>?;
      final temp = (json['artwork_url'] ?? user?['avatar_url'])?.toString();
      final artworkUrl = temp?.replaceAll('large', 't500x500');
      final permalinkUrl = json['permalink_url'] as String?;
      final createdAt = json['created_at'] as String?;
      final year = createdAt != null
          ? int.tryParse(createdAt.split('-').first)
          : null;

      return TrackPreview(
        urlFile: '',
        id:
            json['id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: json['title'] as String? ?? 'Unknown track',
        artist: user?['username'] as String? ?? 'Unknown artist',
        album: json['genre'] as String?,
        artworkUrl: artworkUrl,
        duration: Duration(milliseconds: json['duration'] as int? ?? 0),
        source: SourceType.soundcloud,
        originalUrl: permalinkUrl ?? query,
        year: year,
      );
    } catch (e, st) {
      AppLogger.log(
        '[SearchSourceImpl._mapSoundCloudTrackPreview] Error mapping JSON: Error: $e, stackTrace: $st',
      );
      return TrackPreview(
        urlFile: '',
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: json['title'] as String? ?? 'Unknown track',
        artist: 'Unknown artist',
        album: null,
        artworkUrl: null,
        duration: Duration.zero,
        source: SourceType.soundcloud,
        originalUrl: query,
        year: DateTime.now().year,
      );
    }
  }

  Future<String> _getClientId() async {
    // TODO
    return await SoundcloudTrackSource().getClientId();
  }
}
