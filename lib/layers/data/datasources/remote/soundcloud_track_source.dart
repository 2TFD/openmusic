import 'dart:io';
import 'package:dio/dio.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/core/network/retry_policy.dart';
import 'package:openmusic/core/utils/app_logger.dart';
import 'package:openmusic/layers/domain/entities/operation_cancellation.dart';
import 'package:openmusic/layers/domain/entities/resolved_track_input.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';
import 'package:openmusic/layers/domain/repositories/track_source.dart';
import 'package:path_provider/path_provider.dart';

class SoundcloudTrackSource implements TrackSource {
  SoundcloudTrackSource({Dio? dio, Dio? redirectDio, RetryPolicy? retryPolicy})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 30),
              sendTimeout: const Duration(seconds: 10),
            ),
          ),
      _redirectDio =
          redirectDio ??
          Dio(
            BaseOptions(
              followRedirects: false,
              validateStatus: (status) => status != null && status < 400,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          ),
      _retryPolicy = retryPolicy ?? RetryPolicy();

  final Dio _dio;
  final Dio _redirectDio;
  final RetryPolicy _retryPolicy;

  @override
  SourceType get sourceType => SourceType.soundcloud;

  Future<Response<dynamic>> _get(
    String url, {
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _retryPolicy.execute(
      () => _dio.get(url, options: options, cancelToken: cancelToken),
    );
  }

  // Publicly visible in SoundCloud's JS bundles — not a secret.
  // Cached after first successful parse from soundcloud.com.
  static const _fallbackClientId = 'mQqpsaUSNZxyik7mV9y4D6dunaNX3mrQ';
  static String? _cachedClientId;

  @override
  bool canHandle(String input) {
    if (input.contains('soundcloud.com/')) {
      return true;
    }
    return false;
  }

  Future<bool> _isLikes(String input) async {
    if (input.contains('soundcloud.com/') && input.contains('/likes')) {
      return true;
    }
    return false;
  }

  Future<bool> _isPlaylist(String input) async {
    if (input.contains('soundcloud.com/') && input.contains('/sets/')) {
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>> _getTrackData(
    String trackId,
    String clientId,
  ) async {
    final response = await _get(
      "https://api-v2.soundcloud.com/tracks/$trackId?client_id=$clientId",
    );
    if (response.statusCode != 200) {
      throw const RemoteServiceFailure('SoundCloud track data');
    }
    final trackData = response.data;
    _validateProgressiveStream(trackData);
    return trackData;
  }

  void _validateProgressiveStream(Map<String, dynamic> trackData) {
    final transcodings = trackData['media']['transcodings'] as List;
    final progressive = transcodings.firstWhere(
      (t) => t['format']['protocol'] == 'progressive',
      orElse: () => null,
    );
    if (progressive == null) {
      throw const UnsupportedMediaFailure('SoundCloud HLS-only track');
    }
  }

  Future<ResolvedTrackInput> _parseTrackPreviewFromPlaylist(
    String playlistUrl,
  ) async {
    try {
      List<TrackPreview> previews = [];
      final clientId = await getClientId();
      final expandedUrl = await resolveShortSoundCloudUrl(playlistUrl);
      final resolvePlaylistDataUrl =
          'https://api-v2.soundcloud.com/resolve?url=$expandedUrl&client_id=$clientId';
      final res = await _get(resolvePlaylistDataUrl);
      if (res.statusCode != 200) {
        throw const RemoteServiceFailure('SoundCloud resolve');
      }
      final jsonPlaylistData = res.data;
      final listTrackData = jsonPlaylistData['tracks'] as List;
      for (var trackIdData in listTrackData) {
        try {
          await Future.delayed(const Duration(milliseconds: 200));

          final trackData = await _getTrackData(
            trackIdData['id'].toString(),
            clientId,
          );
          final transcodings = trackData['media']['transcodings'] as List;
          final progressive = transcodings.firstWhere(
            (t) => t['format']['protocol'] == 'progressive',
            orElse: () => null,
          );
          if (progressive == null) {
            continue;
          }

          final streamUrl = await getStreamUrl(progressive['url'], clientId);
          previews.add(
            TrackPreview(
              urlFile: streamUrl,
              artworkUrl:
                  (trackData["artwork_url"] as String? ??
                          trackData["calculated_artwork_url"] as String?)
                      ?.replaceAll('large', 't500x500'),
              id: trackData['id'].toString(),
              title: trackData['title'],
              source: SourceType.soundcloud,
              originalUrl: trackData['permalink_url'],
              album: trackData["album"],
              duration: Duration(milliseconds: trackData["duration"]),
              artist: trackData["user"]["username"],
              artistId: 'soundcloud:artist:${trackData["user"]["id"]}',
            ),
          );
        } catch (e, st) {
          await AppLogger.log(
            '[SoundCloudTrackSource._parseTrackPreviewFromPlaylist] Error processing track ${trackIdData['id']}: $e, \nst: $st',
          );
          continue;
        }
      }

      if (previews.isEmpty) {
        throw const EmptyResultFailure('resolve SoundCloud playlist');
      }
      return ResolvedTrackInput(
        input: playlistUrl,
        sourceType: SourceType.soundcloud,
        tracks: previews,
        collection: ResolvedTrackCollection(
          id: 'soundcloud:playlist:${jsonPlaylistData['id']}',
          name: jsonPlaylistData['title'] as String? ?? 'New Playlist',
          description: jsonPlaylistData['description'] as String?,
          imageUrl:
              (jsonPlaylistData['artwork_url'] as String? ??
                      jsonPlaylistData['calculated_artwork_url'] as String?)
                  ?.replaceAll('large', 't500x500'),
        ),
      );
    } catch (e, st) {
      await AppLogger.log(
        '[SoundCloudTrackSource._parseTrackPreviewFromPlaylist] ERROR: URL: $playlistUrl, Error: $e, StackTrace: \n$st',
      );
      rethrow;
    }
  }

  Future<ResolvedTrackInput> _parseTracksFromLikes(String profileUrl) async {
    try {
      final clientId = await getClientId();
      final userJson = await _resolveUserJson(profileUrl, clientId);
      final userId = userJson['id'].toString();

      const limit = 200;
      final likesUrl =
          'https://api-v2.soundcloud.com/users/$userId/likes?client_id=$clientId&limit=$limit';
      final res = await _get(likesUrl);
      if (res.statusCode != 200) {
        throw const RemoteServiceFailure('SoundCloud likes');
      }

      final collection = res.data['collection'] as List<dynamic>;
      List<TrackPreview> previews = [];

      for (final item in collection) {
        try {
          await Future.delayed(const Duration(milliseconds: 200));

          final trackData = item['track'];
          if (trackData == null) {
            continue;
          }

          final transcodings = trackData['media']['transcodings'] as List;
          final progressive = transcodings.firstWhere(
            (t) => t['format']['protocol'] == 'progressive',
            orElse: () => null,
          );
          if (progressive == null) {
            continue;
          }

          final streamUrl = await getStreamUrl(progressive['url'], clientId);
          previews.add(
            TrackPreview(
              urlFile: streamUrl,
              artworkUrl:
                  (trackData["artwork_url"] ??
                          trackData["calculated_artwork_url"])
                      ?.replaceAll('large', 't500x500'),
              id: trackData['id'].toString(),
              title: trackData['title'],
              source: SourceType.soundcloud,
              originalUrl: trackData['permalink_url'],
              album: trackData["album"],
              duration: Duration(milliseconds: trackData["duration"]),
              artist: trackData["user"]["username"],
              artistId: 'soundcloud:artist:${trackData["user"]["id"]}',
            ),
          );
        } catch (e, st) {
          await AppLogger.log(
            '[SoundCloudTrackSource._parseTracksFromLikes] Error processing track: $e, \nst:$st',
          );
          continue;
        }
      }

      if (previews.isEmpty) {
        throw const EmptyResultFailure('resolve SoundCloud likes');
      }

      return ResolvedTrackInput(
        input: profileUrl,
        sourceType: SourceType.soundcloud,
        tracks: previews,
        collection: ResolvedTrackCollection(
          id: 'soundcloud:likes:$userId',
          name:
              'soundcloud - ${userJson['permalink'] ?? userJson['username'] ?? ''}',
          description: userJson['description'] as String?,
          imageUrl: (userJson['avatar_url'] as String?)?.replaceAll(
            'large',
            't500x500',
          ),
        ),
      );
    } catch (e, st) {
      await AppLogger.log(
        '[SoundCloudTrackSource._parseTracksFromLikes] ERROR: URL: $profileUrl, Error: $e, StackTrace: \n$st',
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _resolveUserJson(
    String profileUrl,
    String clientId,
  ) async {
    final resolveUrl =
        'https://api-v2.soundcloud.com/resolve?url=$profileUrl&client_id=$clientId';
    final res = await _get(resolveUrl);
    if (res.statusCode != 200) {
      throw const RemoteServiceFailure('SoundCloud user resolve');
    }
    return res.data as Map<String, dynamic>;
  }

  Future<TrackPreview> fetchPreview(String input) async {
    try {
      final clientId = await getClientId();
      final expandedUrl = await resolveShortSoundCloudUrl(input);
      final jsonTrackData = await fetchTrackJson(expandedUrl, clientId);
      final trackData = await _getTrackData(
        jsonTrackData['id'].toString(),
        clientId,
      );
      final transcodings = trackData['media']['transcodings'] as List;
      final progressive = transcodings.firstWhere(
        (t) => t['format']['protocol'] == 'progressive',
        orElse: () => null,
      );
      if (progressive == null) {
        throw const UnsupportedMediaFailure('SoundCloud HLS-only track');
      }
      final streamUrl = await getStreamUrl(progressive['url'], clientId);
      final preview = TrackPreview(
        urlFile: streamUrl,
        id: (jsonTrackData['id'] ?? DateTime.now().millisecondsSinceEpoch)
            .toString(),
        title: jsonTrackData['title'] ?? 'Unknown Title',
        artist: jsonTrackData['user']['username'] ?? 'Unknown Artist',
        artistId: jsonTrackData['user']['id'] == null
            ? null
            : 'soundcloud:artist:${jsonTrackData['user']['id']}',
        source: SourceType.soundcloud,
        originalUrl: input,
        artworkUrl:
            (jsonTrackData["artwork_url"] as String? ??
                    jsonTrackData["calculated_artwork_url"] as String?)
                ?.replaceAll('large', 't500x500'),
        duration: Duration(
          milliseconds:
              jsonTrackData["duration"] ?? Duration.zero.inMilliseconds,
        ),
        album: jsonTrackData["album"],
        year:
            int.tryParse(
              jsonTrackData["created_at"].toString().split('-').first,
            ) ??
            DateTime.now().year,
      );
      return preview;
    } catch (e, st) {
      await AppLogger.log(
        '[SoundCloudTrackSource.fetchPreview] Error fetching preview from URL: $input, Error: $e, StackTrace: \n$st',
      );
      rethrow;
    }
  }

  @override
  Future<ResolvedTrackInput> resolve(String input) async {
    try {
      final url = await resolveShortSoundCloudUrl(input);

      if (await _isPlaylist(url)) {
        return _parseTrackPreviewFromPlaylist(url);
      } else if (await _isLikes(url)) {
        return _parseTracksFromLikes(url);
      } else {
        final preview = await fetchPreview(url);
        return ResolvedTrackInput.single(preview);
      }
    } catch (e, st) {
      await AppLogger.log(
        '[SoundCloudTrackSource.resolve] Error resolving URL: $input, Error: $e, StackTrace: \n$st',
      );
      rethrow;
    }
  }

  Future<String> getClientId({bool forceRefresh = false}) async {
    if (forceRefresh) _cachedClientId = null;
    if (_cachedClientId != null) return _cachedClientId!;

    try {
      final homeRes = await _get(
        'https://soundcloud.com',
        options: Options(responseType: ResponseType.plain),
      );
      final scriptUrls = RegExp(
        r'<script[^>]+src="(https://a-v2\.sndcdn\.com/assets/[^"]+\.js)"',
      ).allMatches(homeRes.data as String).map((m) => m.group(1)!).toList();

      for (final url in scriptUrls.reversed) {
        final jsRes = await _get(
          url,
          options: Options(responseType: ResponseType.plain),
        );
        final match = RegExp(
          r'client_id:"([a-zA-Z0-9]+)"',
        ).firstMatch(jsRes.data as String);
        if (match != null) {
          _cachedClientId = match.group(1)!;
          return _cachedClientId!;
        }
      }
    } catch (_) {}

    // Fallback to bundled value if parsing fails
    return _cachedClientId = _fallbackClientId;
  }

  void invalidateClientId() => _cachedClientId = null;

  Future<Map<String, dynamic>> fetchTrackJson(
    String url,
    String clientId,
  ) async {
    try {
      final resolveUrl =
          'https://api-v2.soundcloud.com/resolve?url=$url&client_id=$clientId';

      final res = await _get(resolveUrl);

      if (res.statusCode != 200) {
        throw RemoteServiceFailure(
          'SoundCloud resolve',
          statusCode: res.statusCode,
        );
      }
      return res.data;
    } on DioException catch (e, st) {
      await AppLogger.log(
        '[SoundcloudTrackSource.fetchTrackJson] DioException for URL: $url, Error: ${e.message}, statusCode: ${e.response?.statusCode}, stackTrace: \n$st',
      );
      rethrow;
    } catch (e, st) {
      await AppLogger.log(
        '[SoundcloudTrackSource.fetchTrackJson] Error resolving URL: $url, Error: $e, stackTrace: \n$st',
      );
      rethrow;
    }
  }

  Future<String> getStreamUrl(String transcodingUrl, String clientId) async {
    final url = '$transcodingUrl?client_id=$clientId';

    try {
      final res = await _get(url);
      return res.data['url'];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        await AppLogger.log(
          '[SoundCloudTrackSource.getStreamUrl] 404 error - stream URL may have expired: $transcodingUrl',
        );
      } else {
        await AppLogger.log(
          '[SoundCloudTrackSource.getStreamUrl] Error fetching stream URL: ${e.response?.statusCode} - $e',
        );
      }
      rethrow;
    }
  }

  Future<String> downloadFile(
    String url,
    String filename, {
    OperationCancellation? cancellation,
  }) async {
    File? partialFile;
    try {
      cancellation?.throwIfCancelled();
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$filename');
      if (await file.exists()) return filename;

      final downloadFile = File('${file.path}.part');
      partialFile = downloadFile;
      final cancelToken = CancelToken();
      cancellation?.whenCancelled.then((_) {
        if (!cancelToken.isCancelled) cancelToken.cancel();
      });

      await _retryPolicy.execute(() async {
        if (await downloadFile.exists()) await downloadFile.delete();
        await _dio.download(
          url,
          downloadFile.path,
          cancelToken: cancelToken,
          deleteOnError: true,
        );
      });
      cancellation?.throwIfCancelled();
      await downloadFile.rename(file.path);
      return filename;
    } catch (e, st) {
      if (partialFile != null && await partialFile.exists()) {
        await partialFile.delete();
      }
      await AppLogger.log(
        '[SoundCloudTrackSource.downloadFile] ERROR downloading from URL: $url, Filename: $filename, Error: $e, StackTrace: \n$st',
      );
      rethrow;
    }
  }

  Future<String> resolveShortSoundCloudUrl(String shortUrl) async {
    try {
      var currentUrl = shortUrl;
      final visited = <String>{};

      for (var redirectCount = 0; redirectCount < 8; redirectCount++) {
        if (!visited.add(currentUrl)) {
          throw const RemoteServiceFailure('SoundCloud redirect cycle');
        }

        final response = await _retryPolicy.execute(
          () => _redirectDio.get(currentUrl),
        );

        if (response.statusCode == 301 ||
            response.statusCode == 302 ||
            response.statusCode == 307 ||
            response.statusCode == 308) {
          final location = response.headers.value('location');
          if (location == null || location.isEmpty) {
            throw const ParseFailure();
          }
          currentUrl = Uri.parse(currentUrl).resolve(location).toString();
        } else {
          final uri = Uri.parse(currentUrl);
          return uri.replace(query: '').toString();
        }
      }

      throw const RemoteServiceFailure('SoundCloud redirect limit');
    } catch (e, st) {
      await AppLogger.log(
        '[SoundCloudTrackSource.resolveShortSoundCloudUrl] ERROR resolving URL: $shortUrl, Error: $e, StackTrace: \n$st',
      );
      rethrow;
    }
  }

  Future<String> downloadSoundCloudTrack(
    String trackUrl,
    String filename, {
    OperationCancellation? cancellation,
  }) async {
    try {
      final clientId = await getClientId();

      final expandedUrl = await resolveShortSoundCloudUrl(trackUrl);

      final jsonTrackData = await fetchTrackJson(expandedUrl, clientId);
      _validateProgressiveStream(jsonTrackData);

      final transcodings = jsonTrackData['media']['transcodings'] as List;
      final progressive = transcodings.firstWhere(
        (t) => t['format']['protocol'] == 'progressive',
        orElse: () => null,
      );

      final transcodingUrl = progressive['url'];

      final streamUrl = await getStreamUrl(transcodingUrl, clientId);

      final filePath = await downloadFile(
        streamUrl,
        "$filename.mp3",
        cancellation: cancellation,
      );

      return filePath;
    } catch (e, st) {
      await AppLogger.log(
        '[SoundCloudTrackSource.downloadSoundCloudTrack] ERROR: URL: $trackUrl, Filename: $filename, Error: $e, StackTrace: \n$st',
      );
      rethrow;
    }
  }

  @override
  Future<String> download(
    TrackPreview track, {
    OperationCancellation? cancellation,
  }) async {
    final filename = downloadFilename(track);
    return downloadSoundCloudTrack(
      track.originalUrl,
      filename,
      cancellation: cancellation,
    );
  }

  static String downloadFilename(TrackPreview track) =>
      _safeFilename('soundcloud_${track.id}');

  static String _safeFilename(String value) {
    final sanitized = value
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (sanitized.isEmpty) return 'soundcloud_track';
    return sanitized.length > 120 ? sanitized.substring(0, 120) : sanitized;
  }
}
