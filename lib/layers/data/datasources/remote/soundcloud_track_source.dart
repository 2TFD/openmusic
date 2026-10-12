import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ffmpeg_kit_flutter_new_audio/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_audio/return_code.dart';
import 'package:owlsonic/core/errors/failures/failure.dart';
import 'package:owlsonic/core/network/retry_policy.dart';
import 'package:owlsonic/core/utils/app_logger.dart';
import 'package:owlsonic/core/utils/audio_file_name.dart';
import 'package:owlsonic/layers/domain/entities/operation_cancellation.dart';
import 'package:owlsonic/layers/domain/entities/resolved_track_input.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/entities/track_preview.dart';
import 'package:owlsonic/layers/domain/repositories/track_source.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

enum _LinkKind { track, playlist, likes, unsupported }

/// The transcoding chosen for download. SoundCloud is phasing out progressive
/// MP3, so HLS (AAC, MP3 or Opus) is a first-class option, not a failure.
class _SoundCloudStream {
  const _SoundCloudStream({
    required this.url,
    required this.isHls,
    required this.mimeType,
  });

  final String url;
  final bool isHls;
  final String mimeType;

  bool get isMp3 => !isHls || mimeType.contains('mpeg');
  bool get isAac => mimeType.contains('mp4');
  String get extension => isMp3 ? 'mp3' : 'm4a';
}

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

  /// The bundled fallback goes stale; it is used for a short while only, so a
  /// single failed scrape (e.g. offline at startup) does not pin it forever.
  static DateTime? _fallbackUntil;
  static const _fallbackTtl = Duration(minutes: 5);

  static const _hosts = {
    'soundcloud.com',
    'm.soundcloud.com',
    'on.soundcloud.com',
    'snd.sc',
  };

  /// Short links that have to be expanded over the network.
  static const _shortHosts = {'on.soundcloud.com', 'snd.sc'};

  /// First path segments that are SoundCloud pages, not user names, and second
  /// segments that are profile tabs, not track slugs.
  static const _reservedPaths = {
    'albums',
    'comments',
    'discover',
    'feed',
    'followers',
    'following',
    'likes',
    'popular-tracks',
    'reposts',
    'search',
    'sets',
    'spotlight',
    'stations',
    'stream',
    'tracks',
    'upload',
    'you',
  };

  static Uri? _parse(String input) {
    final value = input.trim();
    return Uri.tryParse(value.contains('://') ? value : 'https://$value');
  }

  static String _host(Uri uri) =>
      uri.host.toLowerCase().replaceFirst('www.', '');

  @override
  bool canHandle(String input) {
    final uri = _parse(input);
    return uri != null && _hosts.contains(_host(uri));
  }

  /// Classifies by path segments: a substring test treated a track named
  /// `likes-you` as a likes page and profiles as tracks.
  static _LinkKind _kindOf(String url) {
    final segments = Uri.parse(
      url,
    ).pathSegments.where((s) => s.isNotEmpty).toList();
    // `discover/sets/…` are generated system playlists, not user sets.
    if (segments.isEmpty || _reservedPaths.contains(segments[0])) {
      return _LinkKind.unsupported;
    }
    if (segments.length >= 3 && segments[1] == 'sets') {
      return _LinkKind.playlist;
    }
    if (segments.length == 2 && segments[1] == 'likes') return _LinkKind.likes;
    if (segments.length >= 2 &&
        !_reservedPaths.contains(segments[0]) &&
        !_reservedPaths.contains(segments[1])) {
      return _LinkKind.track;
    }
    return _LinkKind.unsupported;
  }

  static String _resolveUrl(String url, String clientId) => Uri.https(
    'api-v2.soundcloud.com',
    '/resolve',
    {'url': url, 'client_id': clientId},
  ).toString();

  /// A rotated client id makes every call fail with 401/403 until it is
  /// scraped again; retry the whole operation once with a fresh one.
  Future<T> _withFreshClientIdOnAuthError<T>(
    Future<T> Function() operation,
  ) async {
    try {
      return await operation();
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status != 401 && status != 403) rethrow;
      await getClientId(forceRefresh: true);
      return operation();
    }
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
    final trackData = response.data as Map<String, dynamic>;
    _requireStream(trackData);
    return trackData;
  }

  /// Picks a downloadable full-length transcoding. Go+ previews (`snipped`,
  /// policy `SNIP`) are 30-second clips and DRM-encrypted HLS cannot be
  /// decoded, so neither counts.
  static _SoundCloudStream? _selectStream(Map<String, dynamic> trackData) {
    final policy = trackData['policy'];
    if (policy == 'SNIP' || policy == 'BLOCK') return null;
    final transcodings = (trackData['media'] as Map?)?['transcodings'];
    if (transcodings is! List) return null;

    int rank(Map<dynamic, dynamic> t) {
      final format = t['format'] as Map;
      final mime = '${format['mime_type'] ?? ''}';
      return switch (format['protocol']) {
        'progressive' => 0,
        'hls' when mime.contains('mp4') => 1,
        'hls' when mime.contains('mpeg') => 2,
        'hls' => 3,
        _ => 99,
      };
    }

    Map<dynamic, dynamic>? best;
    for (final t in transcodings) {
      if (t is! Map || t['snipped'] == true) continue;
      if (t['url'] is! String || t['format'] is! Map) continue;
      if (rank(t) == 99) continue;
      if (best == null || rank(t) < rank(best)) best = t;
    }
    if (best == null) return null;
    final format = best['format'] as Map;
    return _SoundCloudStream(
      url: best['url'] as String,
      isHls: format['protocol'] == 'hls',
      mimeType: '${format['mime_type'] ?? ''}',
    );
  }

  static _SoundCloudStream _requireStream(Map<String, dynamic> trackData) {
    final stream = _selectStream(trackData);
    if (stream != null) return stream;
    if (trackData['policy'] == 'SNIP') {
      throw const UnsupportedMediaFailure('SoundCloud Go+ preview only');
    }
    throw const UnsupportedMediaFailure('SoundCloud stream');
  }

  /// Максимум идентификаторов на один запрос `/tracks?ids=`.
  static const _trackBatchSize = 50;

  /// `/resolve` отдаёт первые несколько треков плейлиста целиком, а остальные —
  /// заглушками `{id: N}`. Догружаем недостающие пачками вместо запроса на
  /// каждый трек: 200 треков — это 4 запроса вместо 200.
  Future<List<Map<String, dynamic>>> _hydratePlaylistTracks(
    List<dynamic> rawTracks,
    String clientId,
  ) async {
    final missingIds = <String>[];
    for (final raw in rawTracks) {
      if (raw is! Map) continue;
      if (raw['media'] == null) missingIds.add(raw['id'].toString());
    }

    final fetched = <String, Map<String, dynamic>>{};
    for (var start = 0; start < missingIds.length; start += _trackBatchSize) {
      final batch = missingIds.skip(start).take(_trackBatchSize).join(',');
      try {
        final res = await _get(
          'https://api-v2.soundcloud.com/tracks?ids=$batch&client_id=$clientId',
        );
        if (res.statusCode != 200) continue;
        for (final item in res.data as List) {
          if (item is Map) {
            fetched[item['id'].toString()] = item.cast<String, dynamic>();
          }
        }
      } on DioException catch (e) {
        // Протухший client_id валит все пачки: пусть resolve повторит
        // операцию со свежим, а не пометит треки недоступными.
        final status = e.response?.statusCode;
        if (status == 401 || status == 403) rethrow;
        await AppLogger.log(
          '[SoundCloudTrackSource._hydratePlaylistTracks] batch failed: $e',
        );
      } catch (e, st) {
        // Пачка могла упасть целиком — остальные всё равно грузим.
        await AppLogger.log(
          '[SoundCloudTrackSource._hydratePlaylistTracks] batch failed: '
          '$e, \nst: $st',
        );
      }
    }

    // Порядок плейлиста важнее порядка ответа: ответ по ids его не сохраняет.
    final result = <Map<String, dynamic>>[];
    for (final raw in rawTracks) {
      if (raw is! Map) continue;
      if (raw['media'] != null) {
        result.add(raw.cast<String, dynamic>());
        continue;
      }
      final hydrated = fetched[raw['id'].toString()];
      // Приватные, удалённые и недоступные в регионе треки в ответ не приходят.
      if (hydrated != null) result.add(hydrated);
    }
    return result;
  }

  static String? _artwork(Map<String, dynamic> data) =>
      (data['artwork_url'] as String? ??
              data['calculated_artwork_url'] as String? ??
              data['avatar_url'] as String?)
          ?.replaceFirst('-large.', '-t500x500.');

  static int? _year(Map<String, dynamic> trackData) {
    for (final key in ['release_date', 'display_date', 'created_at']) {
      final value = trackData[key];
      if (value is! String || value.isEmpty) continue;
      final year = int.tryParse(value.split('-').first);
      if (year != null) return year;
    }
    return null;
  }

  /// Стрим-ссылка здесь намеренно не резолвится: она живёт минуты, а
  /// [downloadSoundCloudTrack] всё равно получает свежую по `originalUrl`.
  /// Один лишний запрос на трек в экране подтверждения того не стоит.
  TrackPreview? _previewFromTrackData(Map<String, dynamic> trackData) {
    try {
      // Нужен только факт наличия пригодного потока; сама ссылка не берётся.
      if (_selectStream(trackData) == null) return null;

      final permalinkUrl = trackData['permalink_url'] as String?;
      final title = trackData['title'] as String?;
      final id = trackData['id'];
      if (permalinkUrl == null || title == null || id == null) return null;

      final duration = trackData['duration'];
      return TrackPreview(
        urlFile: '',
        artworkUrl: _artwork(trackData),
        id: id.toString(),
        title: title,
        source: SourceType.soundcloud,
        originalUrl: permalinkUrl,
        album: trackData['album'] as String?,
        duration: duration is int ? Duration(milliseconds: duration) : null,
        artist: trackData['user']?['username'] as String? ?? 'Unknown Artist',
        artistId: trackData['user']?['id'] == null
            ? null
            : 'soundcloud:artist:${trackData['user']['id']}',
        year: _year(trackData),
      );
    } catch (e, st) {
      AppLogger.log(
        '[SoundCloudTrackSource._previewFromTrackData] '
        'skipped track ${trackData['id']}: $e, \nst: $st',
      );
      return null;
    }
  }

  /// Tracks that cannot be imported are reported, not silently dropped.
  static TrackResolutionIssue _issueFor(Map<dynamic, dynamic> trackData) =>
      TrackResolutionIssue(
        label:
            trackData['title'] as String? ?? 'SoundCloud #${trackData['id']}',
        reason: TrackResolutionIssueReason.unavailable,
      );

  Future<ResolvedTrackInput> _parseTrackPreviewFromPlaylist(
    String playlistUrl,
  ) async {
    try {
      List<TrackPreview> previews = [];
      final issues = <TrackResolutionIssue>[];
      final clientId = await getClientId();
      final expandedUrl = await resolveShortSoundCloudUrl(playlistUrl);
      final res = await _get(_resolveUrl(expandedUrl, clientId));
      if (res.statusCode != 200) {
        throw const RemoteServiceFailure('SoundCloud resolve');
      }
      final jsonPlaylistData = res.data;
      final listTrackData = jsonPlaylistData['tracks'] as List;
      final hydrated = await _hydratePlaylistTracks(listTrackData, clientId);
      final hydratedIds = {for (final t in hydrated) t['id'].toString()};
      for (final raw in listTrackData) {
        if (raw is Map && !hydratedIds.contains(raw['id'].toString())) {
          issues.add(_issueFor(raw));
        }
      }
      for (final trackData in hydrated) {
        final preview = _previewFromTrackData(trackData);
        if (preview != null) {
          previews.add(preview);
        } else {
          issues.add(_issueFor(trackData));
        }
      }

      if (previews.isEmpty) {
        throw const EmptyResultFailure('resolve SoundCloud playlist');
      }
      return ResolvedTrackInput(
        input: playlistUrl,
        sourceType: SourceType.soundcloud,
        tracks: previews,
        issues: issues,
        collection: ResolvedTrackCollection(
          id: 'soundcloud:playlist:${jsonPlaylistData['id']}',
          name: jsonPlaylistData['title'] as String? ?? 'New Playlist',
          description: jsonPlaylistData['description'] as String?,
          imageUrl: _artwork(jsonPlaylistData as Map<String, dynamic>),
        ),
      );
    } catch (e, st) {
      await AppLogger.log(
        '[SoundCloudTrackSource._parseTrackPreviewFromPlaylist] ERROR: URL: $playlistUrl, Error: $e, StackTrace: \n$st',
      );
      rethrow;
    }
  }

  /// Лайки отдаются страницами по [_likesPageSize]; идём по `next_href`, пока
  /// он есть, поэтому потолка на количество лайков нет. Единственная защита —
  /// от зацикливания, если API вернёт уже пройденную ссылку.
  static const _likesPageSize = 200;

  Future<List<Map<String, dynamic>>> _fetchAllLikes(
    String userId,
    String clientId,
  ) async {
    final items = <Map<String, dynamic>>[];
    final visited = <String>{};
    String? url =
        'https://api-v2.soundcloud.com/users/$userId/likes'
        '?client_id=$clientId&limit=$_likesPageSize';

    while (url != null && visited.add(url)) {
      final res = await _get(url);
      if (res.statusCode != 200) {
        // Первая страница обязательна, оборванный хвост — уже не повод падать.
        if (items.isEmpty) throw const RemoteServiceFailure('SoundCloud likes');
        break;
      }
      for (final item in res.data['collection'] as List<dynamic>) {
        if (item is Map) items.add(item.cast<String, dynamic>());
      }

      final next = res.data['next_href'] as String?;
      url = next == null
          ? null
          : next.contains('client_id=')
          ? next
          : '$next&client_id=$clientId';
    }
    return items;
  }

  Future<ResolvedTrackInput> _parseTracksFromLikes(String likesUrl) async {
    try {
      final clientId = await getClientId();
      final user = Uri.parse(likesUrl).pathSegments.first;
      final userJson = await _resolveUserJson(
        'https://soundcloud.com/$user',
        clientId,
      );
      final userId = userJson['id'].toString();

      final previews = <TrackPreview>[];
      final issues = <TrackResolutionIssue>[];
      for (final item in await _fetchAllLikes(userId, clientId)) {
        final trackData = item['track'];
        if (trackData is! Map) continue;
        final preview = _previewFromTrackData(
          trackData.cast<String, dynamic>(),
        );
        if (preview != null) {
          previews.add(preview);
        } else {
          issues.add(_issueFor(trackData));
        }
      }

      if (previews.isEmpty) {
        throw const EmptyResultFailure('resolve SoundCloud likes');
      }

      return ResolvedTrackInput(
        input: likesUrl,
        sourceType: SourceType.soundcloud,
        tracks: previews,
        issues: issues,
        collection: ResolvedTrackCollection(
          id: 'soundcloud:likes:$userId',
          name:
              'soundcloud - ${userJson['permalink'] ?? userJson['username'] ?? ''}',
          description: userJson['description'] as String?,
          imageUrl: (userJson['avatar_url'] as String?)?.replaceFirst(
            '-large.',
            '-t500x500.',
          ),
        ),
      );
    } catch (e, st) {
      await AppLogger.log(
        '[SoundCloudTrackSource._parseTracksFromLikes] ERROR: URL: $likesUrl, Error: $e, StackTrace: \n$st',
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _resolveUserJson(
    String profileUrl,
    String clientId,
  ) async {
    final res = await _get(_resolveUrl(profileUrl, clientId));
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
      final kind = jsonTrackData['kind'];
      if (kind != null && kind != 'track') {
        throw UnsupportedSourceFailure(input);
      }
      final id = jsonTrackData['id'];
      if (id == null) throw const ParseFailure();
      final trackData = await _getTrackData(id.toString(), clientId);
      final preview = _previewFromTrackData(trackData);
      if (preview == null) throw const ParseFailure();
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
      return await _withFreshClientIdOnAuthError(() async {
        final url = await resolveShortSoundCloudUrl(input);

        return switch (_kindOf(url)) {
          _LinkKind.playlist => await _parseTrackPreviewFromPlaylist(url),
          _LinkKind.likes => await _parseTracksFromLikes(url),
          _LinkKind.track => ResolvedTrackInput.single(await fetchPreview(url)),
          _LinkKind.unsupported => throw UnsupportedSourceFailure(input),
        };
      });
    } catch (e, st) {
      await AppLogger.log(
        '[SoundCloudTrackSource.resolve] Error resolving URL: $input, Error: $e, StackTrace: \n$st',
      );
      rethrow;
    }
  }

  Future<String> getClientId({bool forceRefresh = false}) async {
    if (forceRefresh) {
      _cachedClientId = null;
      _fallbackUntil = null;
    }
    if (_cachedClientId != null) return _cachedClientId!;
    final fallbackUntil = _fallbackUntil;
    if (fallbackUntil != null && DateTime.now().isBefore(fallbackUntil)) {
      return _fallbackClientId;
    }

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
          _fallbackUntil = null;
          return _cachedClientId!;
        }
      }
    } catch (error, stackTrace) {
      await AppLogger.warning(
        'Using the bundled SoundCloud client fallback.',
        operation: 'soundcloud.resolve_client_id',
        error: error,
        stackTrace: stackTrace,
      );
    }

    // Fallback to bundled value if parsing fails; try scraping again later.
    _fallbackUntil = DateTime.now().add(_fallbackTtl);
    return _fallbackClientId;
  }

  void invalidateClientId() {
    _cachedClientId = null;
    _fallbackUntil = null;
  }

  Future<Map<String, dynamic>> fetchTrackJson(
    String url,
    String clientId,
  ) async {
    try {
      final res = await _get(_resolveUrl(url, clientId));

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

  /// [trackAuthorization] comes from the track JSON; many tracks answer the
  /// stream request with 401/403 without it.
  Future<String> getStreamUrl(
    String transcodingUrl,
    String clientId, {
    String? trackAuthorization,
  }) async {
    final transcoding = Uri.parse(transcodingUrl);
    final url = transcoding
        .replace(
          queryParameters: {
            ...transcoding.queryParameters,
            'client_id': clientId,
            'track_authorization': ?trackAuthorization,
          },
        )
        .toString();

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
      final file = File(p.join(dir.path, filename));
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

  /// Downloads an HLS stream segment by segment over Dio (retry, cancel),
  /// then remuxes locally: concatenated fMP4/Opus segments lack a proper
  /// header and duration, MP3 segments concatenate into a valid file.
  Future<String> _downloadHls(
    String playlistUrl,
    String filename,
    _SoundCloudStream stream, {
    OperationCancellation? cancellation,
  }) async {
    cancellation?.throwIfCancelled();
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, filename));
    if (await file.exists()) return filename;

    final cancelToken = CancelToken();
    cancellation?.whenCancelled.then((_) {
      if (!cancelToken.isCancelled) cancelToken.cancel();
    });

    final playlist = await _get(
      playlistUrl,
      options: Options(responseType: ResponseType.plain),
      cancelToken: cancelToken,
    );
    final base = Uri.parse(playlistUrl);
    final parts = <Uri>[];
    for (final raw in (playlist.data as String).split('\n')) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      if (line.startsWith('#EXT-X-KEY') && !line.contains('METHOD=NONE')) {
        throw const UnsupportedMediaFailure('SoundCloud encrypted HLS');
      }
      if (line.startsWith('#EXT-X-MAP')) {
        final uri = RegExp(r'URI="([^"]+)"').firstMatch(line)?.group(1);
        if (uri != null) parts.add(base.resolve(uri));
        continue;
      }
      if (line.startsWith('#')) continue;
      parts.add(base.resolve(line));
    }
    if (parts.isEmpty) throw const ParseFailure();

    final partial = File('${file.path}.part');
    try {
      final sink = partial.openWrite();
      try {
        for (final part in parts) {
          cancellation?.throwIfCancelled();
          final res = await _retryPolicy.execute(
            () => _dio.getUri<List<int>>(
              part,
              options: Options(responseType: ResponseType.bytes),
              cancelToken: cancelToken,
            ),
          );
          sink.add(res.data ?? const []);
        }
        await sink.flush();
      } finally {
        await sink.close();
      }
      cancellation?.throwIfCancelled();

      if (stream.isMp3) {
        await partial.rename(file.path);
        return filename;
      }
      final session = await FFmpegKit.executeWithArguments([
        '-y',
        '-i',
        partial.path,
        '-vn',
        if (stream.isAac) ...[
          '-c:a',
          'copy',
        ] else ...[
          '-c:a',
          'aac',
          '-b:a',
          '192k',
        ],
        '-f',
        'mp4',
        file.path,
      ]);
      final code = await session.getReturnCode();
      if (!ReturnCode.isSuccess(code) || !await file.exists()) {
        throw const UnsupportedMediaFailure('SoundCloud HLS remux');
      }
      await partial.delete();
      return filename;
    } catch (e, st) {
      if (await partial.exists()) await partial.delete();
      if (await file.exists()) await file.delete();
      await AppLogger.log(
        '[SoundCloudTrackSource._downloadHls] ERROR: $playlistUrl, Filename: $filename, Error: $e, StackTrace: \n$st',
      );
      rethrow;
    }
  }

  /// Canonical `https://soundcloud.com/<path>` without query or fragment.
  /// Only short links (on.soundcloud.com, snd.sc) need network redirects.
  Future<String> resolveShortSoundCloudUrl(String shortUrl) async {
    try {
      var current = _parse(shortUrl);
      if (current == null) throw UnsupportedSourceFailure(shortUrl);
      final visited = <Uri>{};

      for (var redirectCount = 0; redirectCount < 8; redirectCount++) {
        if (!_shortHosts.contains(_host(current!))) {
          if (!_hosts.contains(_host(current))) {
            throw UnsupportedSourceFailure(shortUrl);
          }
          return Uri(
            scheme: 'https',
            host: 'soundcloud.com',
            path: current.path,
          ).toString();
        }
        if (!visited.add(current)) {
          throw const RemoteServiceFailure('SoundCloud redirect cycle');
        }

        final response = await _retryPolicy.execute(
          () => _redirectDio.getUri(current!),
        );
        final location = response.headers.value('location');
        if (location == null || location.isEmpty) {
          throw const ParseFailure();
        }
        current = current.resolve(location);
      }

      throw const RemoteServiceFailure('SoundCloud redirect limit');
    } catch (e, st) {
      await AppLogger.log(
        '[SoundCloudTrackSource.resolveShortSoundCloudUrl] ERROR resolving URL: $shortUrl, Error: $e, StackTrace: \n$st',
      );
      rethrow;
    }
  }

  /// Earlier versions always saved `.mp3`; HLS AAC/Opus is saved as `.m4a`.
  Future<String?> _existingDownload(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    for (final extension in ['mp3', 'm4a']) {
      final name = '$filename.$extension';
      if (await File(p.join(dir.path, name)).exists()) return name;
    }
    return null;
  }

  Future<String> downloadSoundCloudTrack(
    String trackUrl,
    String filename, {
    OperationCancellation? cancellation,
  }) async {
    try {
      final existing = await _existingDownload(filename);
      if (existing != null) return existing;

      return await _withFreshClientIdOnAuthError(() async {
        final clientId = await getClientId();
        final expandedUrl = await resolveShortSoundCloudUrl(trackUrl);
        final jsonTrackData = await fetchTrackJson(expandedUrl, clientId);
        final stream = _requireStream(jsonTrackData);
        final streamUrl = await getStreamUrl(
          stream.url,
          clientId,
          trackAuthorization: jsonTrackData['track_authorization'] as String?,
        );

        if (!stream.isHls) {
          return downloadFile(
            streamUrl,
            '$filename.mp3',
            cancellation: cancellation,
          );
        }
        return _downloadHls(
          streamUrl,
          '$filename.${stream.extension}',
          stream,
          cancellation: cancellation,
        );
      });
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

  static String downloadFilename(TrackPreview track) => audioFileBase(
    artist: track.artist,
    title: track.title,
    source: 'soundcloud',
    id: track.id,
  );
}
