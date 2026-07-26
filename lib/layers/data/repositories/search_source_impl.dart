import 'package:dio/dio.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/core/network/retry_policy.dart';
import 'package:openmusic/core/utils/app_logger.dart';
import 'package:openmusic/layers/data/datasources/remote/soundcloud_track_source.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/repositories/search_source.dart';

class SearchSourceImpl implements SearchSource {
  final SoundcloudTrackSource _soundcloudTrackSource;
  final Dio _dio;
  final RetryPolicy _retryPolicy;

  SearchSourceImpl({
    required SoundcloudTrackSource soundcloudTrackSource,
    Dio? dio,
    RetryPolicy? retryPolicy,
  }) : _soundcloudTrackSource = soundcloudTrackSource,
       _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 20),
               sendTimeout: const Duration(seconds: 10),
             ),
           ),
       _retryPolicy = retryPolicy ?? RetryPolicy();

  @override
  Future<List<TrackPreview>> searchExternal(
    String query, {
    int offset = 0,
  }) async {
    try {
      final response = await _retryPolicy.execute(
        () async => _dio.get(
          'https://api-v2.soundcloud.com/search/tracks',
          queryParameters: {
            'q': query,
            'client_id': await _soundcloudTrackSource.getClientId(),
            'limit': 30,
            'offset': offset,
          },
        ),
      );

      if (response.statusCode != 200) {
        throw RemoteServiceFailure(
          'SoundCloud search',
          statusCode: response.statusCode,
        );
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        return [];
      }

      final collection = (data['collection'] as List<dynamic>?) ?? [];
      return collection
          .whereType<Map<String, dynamic>>()
          .map(_mapSoundCloudTrackPreview)
          .whereType<TrackPreview>()
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

  TrackPreview? _mapSoundCloudTrackPreview(Map<String, dynamic> json) {
    try {
      final user = json['user'] as Map<String, dynamic>?;
      final temp = (json['artwork_url'] ?? user?['avatar_url'])?.toString();
      final artworkUrl = temp?.replaceAll('large', 't500x500');
      final permalinkUrl = json['permalink_url'] as String?;
      final id = json['id']?.toString();
      if (id == null || permalinkUrl == null || permalinkUrl.isEmpty) {
        return null;
      }
      final createdAt = json['created_at'] as String?;
      final year = createdAt != null
          ? int.tryParse(createdAt.split('-').first)
          : null;

      return TrackPreview(
        urlFile: '',
        id: id,
        title: json['title'] as String? ?? 'Unknown track',
        artist: user?['username'] as String? ?? 'Unknown artist',
        artistId: user?['id'] == null
            ? null
            : 'soundcloud:artist:${user!['id']}',
        album: json['genre'] as String?,
        artworkUrl: artworkUrl,
        duration: Duration(milliseconds: json['duration'] as int? ?? 0),
        source: SourceType.soundcloud,
        originalUrl: permalinkUrl,
        year: year,
      );
    } catch (e, st) {
      AppLogger.log(
        '[SearchSourceImpl._mapSoundCloudTrackPreview] Error mapping JSON: Error: $e, stackTrace: $st',
      );
      return null;
    }
  }
}
