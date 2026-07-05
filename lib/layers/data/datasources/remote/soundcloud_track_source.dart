import 'dart:io';
import 'package:dio/dio.dart';
import 'package:openmusic/core/utils/app_logger.dart';
import 'package:openmusic/layers/domain/entities/playlist.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';
import 'package:openmusic/layers/domain/repositories/track_source.dart';
import 'package:path_provider/path_provider.dart';

class SoundcloudTrackSource implements TrackSource {
  final _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 10),
    ),
  );

  final _redirectDio = Dio(
    BaseOptions(
      followRedirects: false,
      validateStatus: (status) => status != null && status < 400,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // Publicly visible in SoundCloud's JS bundles — not a secret.
  // Cached after first successful parse from soundcloud.com.
  static const _fallbackClientId = 'mQqpsaUSNZxyik7mV9y4D6dunaNX3mrQ';
  static String? _cachedClientId;

  @override
  Future<Playlist> createPlaylist(
    String playlistUrl,
    List<Track> tracks,
  ) async {
    try {
      if (await _isPlaylist(playlistUrl)) {
        final clientId = await getClientId();
        final expandedUrl = await resolveShortSoundCloudUrl(playlistUrl);
        final resolvePlaylistDataUrl =
            'https://api-v2.soundcloud.com/resolve?url=$expandedUrl&client_id=$clientId';
        final res = await _dio.get(resolvePlaylistDataUrl);
        if (res.statusCode != 200) {
          throw Exception('Resolve failed');
        }
        final jsonPlaylistData = res.data;
        final playlist = Playlist(
          id: jsonPlaylistData['id'].toString(),
          name: jsonPlaylistData['title'] ?? 'New Playlist',
          trackIds: tracks.map((t) => t.id).toList(),
          createdAt: DateTime.now(),
          imageUrl:
              (jsonPlaylistData["artwork_url"] ??
                      jsonPlaylistData["calculated_artwork_url"])
                  ?.replaceAll('large', 't500x500'),
          description: jsonPlaylistData["description"],
        );
        return playlist;
      } else if (await _isLikes(playlistUrl)) {
        final clientId = await getClientId();
        final userJson = await _resolveUserJson(playlistUrl, clientId);
        final playlist = Playlist(
          id: userJson['id'].toString(),
          name:
              'soundcloud - ${userJson['permalink'] ?? userJson['username'] ?? ''}',
          trackIds: tracks.map((t) => t.id).toList(),
          createdAt: DateTime.now(),
          imageUrl: userJson['avatar_url']?.replaceAll('large', 't500x500'),
          description: userJson['description'],
        );
        return playlist;
      } else {
        throw Exception('Unsupported playlist type');
      }
    } catch (e, st) {
      await AppLogger.log(
        '[SoundCloudTrackSource.createPlaylist] ERROR: URL: $playlistUrl, Error: $e, StackTrace: \n$st',
      );
      rethrow;
    }
  }

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
    final response = await _dio.get(
      "https://api-v2.soundcloud.com/tracks/$trackId?client_id=$clientId",
    );
    if (response.statusCode != 200) {
      throw Exception('Track data fetch failed');
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
      throw Exception('No progressive stream found (only HLS available)');
    }
  }

  Future<List<TrackPreview>> _parseTrackPreviewFromPlaylist(
    String playlistUrl,
  ) async {
    try {
      List<TrackPreview> previews = [];
      final clientId = await getClientId();
      final expandedUrl = await resolveShortSoundCloudUrl(playlistUrl);
      final resolvePlaylistDataUrl =
          'https://api-v2.soundcloud.com/resolve?url=$expandedUrl&client_id=$clientId';
      final res = await _dio.get(resolvePlaylistDataUrl);
      if (res.statusCode != 200) {
        throw Exception('Resolve failed');
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
        throw Exception('No valid tracks found in playlist');
      }
      return previews;
    } catch (e, st) {
      await AppLogger.log(
        '[SoundCloudTrackSource._parseTrackPreviewFromPlaylist] ERROR: URL: $playlistUrl, Error: $e, StackTrace: \n$st',
      );
      rethrow;
    }
  }

  Future<List<TrackPreview>> _parseTracksFromLikes(String profileUrl) async {
    try {
      final clientId = await getClientId();
      final userId = await _resolveUserId(profileUrl, clientId);

      const limit = 200;
      final likesUrl =
          'https://api-v2.soundcloud.com/users/$userId/likes?client_id=$clientId&limit=$limit';
      final res = await _dio.get(likesUrl);
      if (res.statusCode != 200) {
        throw Exception('Likes resolve failed');
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
        throw Exception('No valid tracks found in likes');
      }

      return previews;
    } catch (e, st) {
      await AppLogger.log(
        '[SoundCloudTrackSource._parseTracksFromLikes] ERROR: URL: $profileUrl, Error: $e, StackTrace: \n$st',
      );
      rethrow;
    }
  }

  Future<String> _resolveUserId(String profileUrl, String clientId) async {
    final userJson = await _resolveUserJson(profileUrl, clientId);
    return userJson['id'].toString();
  }

  Future<Map<String, dynamic>> _resolveUserJson(
    String profileUrl,
    String clientId,
  ) async {
    final resolveUrl =
        'https://api-v2.soundcloud.com/resolve?url=$profileUrl&client_id=$clientId';
    final res = await _dio.get(resolveUrl);
    if (res.statusCode != 200) {
      throw Exception('Resolve failed');
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
        throw Exception('No progressive stream found (only HLS available)');
      }
      final streamUrl = await getStreamUrl(progressive['url'], clientId);
      final preview = TrackPreview(
        urlFile: streamUrl,
        id: (jsonTrackData['id'] ?? DateTime.now().millisecondsSinceEpoch)
            .toString(),
        title: jsonTrackData['title'] ?? 'Unknown Title',
        artist: jsonTrackData['user']['username'] ?? 'Unknown Artist',
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
  Future<List<TrackPreview>> resolve(String input) async {
    try {
      final url = await resolveShortSoundCloudUrl(input);

      if (await _isPlaylist(url)) {
        return _parseTrackPreviewFromPlaylist(url);
      } else if (await _isLikes(url)) {
        return _parseTracksFromLikes(url);
      } else {
        final preview = await fetchPreview(url);
        return [preview];
      }
    } catch (e, st) {
      await AppLogger.log(
        '[SoundCloudTrackSource.resolve] Error resolving URL: $input, Error: $e, StackTrace: \n$st',
      );
      rethrow;
    }
  }

  Future<String> getClientId() async {
    if (_cachedClientId != null) return _cachedClientId!;

    try {
      final homeRes = await _dio.get(
        'https://soundcloud.com',
        options: Options(responseType: ResponseType.plain),
      );
      final scriptUrls = RegExp(
        r'<script[^>]+src="(https://a-v2\.sndcdn\.com/assets/[^"]+\.js)"',
      ).allMatches(homeRes.data as String).map((m) => m.group(1)!).toList();

      for (final url in scriptUrls.reversed) {
        final jsRes = await _dio.get(
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
    return _fallbackClientId;
  }

  Future<Map<String, dynamic>> fetchTrackJson(String url, String clientId) async {
    try {
      final resolveUrl =
          'https://api-v2.soundcloud.com/resolve?url=$url&client_id=$clientId';

      final res = await _dio.get(resolveUrl);

      if (res.statusCode != 200) {
        throw Exception('Resolve failed: status code ${res.statusCode}');
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
      final res = await _dio.get(url);
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

  Future<String> downloadFile(String url, String filename) async {
    try {
      final res = await _dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final dir = await getApplicationDocumentsDirectory();
      final file = await File("${dir.path}/$filename").create();
      await file.writeAsBytes(res.data);
      return filename;
    } catch (e, st) {
      await AppLogger.log(
        '[SoundCloudTrackSource.downloadFile] ERROR downloading from URL: $url, Filename: $filename, Error: $e, StackTrace: \n$st',
      );
      rethrow;
    }
  }

  Future<String> resolveShortSoundCloudUrl(String shortUrl) async {
    try {
      String currentUrl = shortUrl;

      while (true) {
        final response = await _redirectDio.get(currentUrl);

        if (response.statusCode == 301 ||
            response.statusCode == 302 ||
            response.statusCode == 307 ||
            response.statusCode == 308) {
          final location = response.headers.value('location');

          if (location == null) break;
          currentUrl = location;
        } else {
          break;
        }
      }

      final uri = Uri.parse(currentUrl);
      final finalUrl = uri.replace(query: '').toString();

      return finalUrl;
    } catch (e, st) {
      await AppLogger.log(
        '[SoundCloudTrackSource.resolveShortSoundCloudUrl] ERROR resolving URL: $shortUrl, Error: $e, StackTrace: \n$st',
      );
      rethrow;
    }
  }

  Future<String> downloadSoundCloudTrack(
    String trackUrl,
    String filename,
  ) async {
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

      final filePath = await downloadFile(streamUrl, "$filename.mp3");

      return filePath;
    } catch (e, st) {
      await AppLogger.log(
        '[SoundCloudTrackSource.downloadSoundCloudTrack] ERROR: URL: $trackUrl, Filename: $filename, Error: $e, StackTrace: \n$st',
      );
      rethrow;
    }
  }

  @override
  Future<String> download(TrackPreview track) async {
    final filename = _safeFilename(
      '${track.artist}-${track.title}_${DateTime.now().microsecondsSinceEpoch}',
    );
    return downloadSoundCloudTrack(track.originalUrl, filename);
  }

  String _safeFilename(String value) {
    final sanitized = value
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (sanitized.isEmpty) return 'soundcloud_track';
    return sanitized.length > 120 ? sanitized.substring(0, 120) : sanitized;
  }

  @override
  Future<TrackPreview> fetchTrackPreview(String input) async {
    try {
      final url = await resolveShortSoundCloudUrl(input);
      final clientId = await getClientId();
      if (await _isPlaylist(url)) {
        final resolvePlaylistDataUrl =
            'https://api-v2.soundcloud.com/resolve?url=$url&client_id=$clientId';
        final res = await _dio.get(resolvePlaylistDataUrl);
        if (res.statusCode != 200) {
          throw Exception('Resolve failed');
        }
        final jsonPlaylistData = res.data;
        final trackDataResponse = (jsonPlaylistData['tracks'] as List).first;
        await Future.delayed(const Duration(milliseconds: 200));

        final trackData = await _getTrackData(
          trackDataResponse['id'].toString(),
          clientId,
        );
        final transcodings = trackData['media']['transcodings'] as List;
        final progressive = transcodings.firstWhere(
          (t) => t['format']['protocol'] == 'progressive',
          orElse: () => null,
        );

        final streamUrl = await getStreamUrl(progressive['url'], clientId);
        return TrackPreview(
          urlFile: streamUrl,
          artworkUrl:
              (trackData["artwork_url"] as String? ??
                      trackData["calculated_artwork_url"] as String?)
                  ?.replaceAll('large', 't500x500'),
          id: trackData['id'].toString(),
          title: trackData['title'],
          source: SourceType.soundcloud,
          originalUrl: url,
          album: trackData["album"],
          duration: Duration(milliseconds: trackData["duration"]),
          artist: trackData["user"]["username"],
        );
      } else if (await _isLikes(url)) {
        final userId = await _resolveUserId(url, clientId);

        const limit = 10;
        final likesUrl =
            'https://api-v2.soundcloud.com/users/$userId/likes?client_id=$clientId&limit=$limit';
        final res = await _dio.get(likesUrl);
        if (res.statusCode != 200) {
          throw Exception('Likes resolve failed');
        }

        final item = (res.data['collection'] as List<dynamic>).first;

        final trackData = item['track'];
        if (trackData == null) {}

        final transcodings = trackData['media']['transcodings'] as List;
        final progressive = transcodings.firstWhere(
          (t) => t['format']['protocol'] == 'progressive',
          orElse: () => null,
        );

        final streamUrl = await getStreamUrl(progressive['url'], clientId);
        return TrackPreview(
          urlFile: streamUrl,
          artworkUrl:
              (trackData["artwork_url"] ?? trackData["calculated_artwork_url"])
                  ?.replaceAll('large', 't500x500'),
          id: trackData['id'].toString(),
          title: trackData['title'],
          source: SourceType.soundcloud,
          originalUrl: url,
          album: trackData["album"],
          duration: Duration(milliseconds: trackData["duration"]),
          artist: trackData["user"]["username"],
        );
      } else {
        final preview = await fetchPreview(url);
        return preview;
      }
    } catch (e, st) {
      await AppLogger.log(
        '[SoundCloudTrackSource.resolve] Error resolving URL: $input, Error: $e, StackTrace: \n$st',
      );
      rethrow;
    }
  }
}
