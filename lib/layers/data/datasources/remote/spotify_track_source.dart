import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/core/network/retry_policy.dart';
import 'package:openmusic/core/services/spotify/spotify_auth_service.dart';
import 'package:openmusic/layers/data/datasources/remote/youtube_track_source.dart';
import 'package:openmusic/layers/domain/entities/operation_cancellation.dart';
import 'package:openmusic/layers/domain/entities/resolved_track_input.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';
import 'package:openmusic/layers/domain/repositories/track_source.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class SpotifyTrackMetadata {
  const SpotifyTrackMetadata({
    required this.id,
    required this.title,
    required this.artists,
    required this.url,
    required this.duration,
    this.album,
    this.artworkUrl,
    this.year,
  });

  final String id;
  final String title;
  final List<String> artists;
  final String url;
  final Duration duration;
  final String? album;
  final String? artworkUrl;
  final int? year;
}

class SpotifyYoutubeMatcher {
  const SpotifyYoutubeMatcher();

  static const acceptanceThreshold = 0.72;

  double score(SpotifyTrackMetadata track, Video candidate) {
    final target = _tokens('${track.artists.join(' ')} ${track.title}');
    final candidateTokens = _tokens('${candidate.author} ${candidate.title}');
    final textScore = _dice(target, candidateTokens);
    final candidateDuration = candidate.duration;
    var durationScore = 0.5;
    if (candidateDuration != null) {
      final delta = (candidateDuration - track.duration).abs().inMilliseconds;
      final maximum = math.max(
        const Duration(seconds: 15).inMilliseconds,
        (track.duration.inMilliseconds * 0.08).round(),
      );
      if (delta > maximum) return 0;
      durationScore = 1 - (delta / maximum);
    }
    var result = textScore * 0.65 + durationScore * 0.35;
    const variants = {'cover', 'karaoke', 'live', 'remix'};
    final targetVariants = target.intersection(variants);
    final unexpected = candidateTokens
        .intersection(variants)
        .difference(targetVariants);
    if (unexpected.isNotEmpty) result -= 0.25;
    return result.clamp(0, 1);
  }

  Video? best(SpotifyTrackMetadata track, Iterable<Video> candidates) {
    Video? selected;
    var selectedScore = acceptanceThreshold;
    for (final candidate in candidates) {
      final candidateScore = score(track, candidate);
      if (candidateScore < selectedScore) continue;
      if (candidateScore == selectedScore && selected != null) {
        final candidateOfficial = _isOfficial(candidate);
        final selectedOfficial = _isOfficial(selected);
        if (!candidateOfficial || selectedOfficial) continue;
      }
      selected = candidate;
      selectedScore = candidateScore;
    }
    return selected;
  }

  static bool _isOfficial(Video video) {
    final value = '${video.author} ${video.title}'.toLowerCase();
    return value.contains(' - topic') ||
        value.contains('official audio') ||
        value.contains('vevo');
  }

  static Set<String> _tokens(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'\([^)]*official[^)]*\)|\[[^]]*official[^]]*\]'), ' ')
      .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ')
      .split(RegExp(r'\s+'))
      .where((token) => token.isNotEmpty)
      .toSet();

  static double _dice(Set<String> a, Set<String> b) {
    if (a.isEmpty || b.isEmpty) return 0;
    return 2 * a.intersection(b).length / (a.length + b.length);
  }
}

class SpotifyTrackSource implements TrackSource {
  SpotifyTrackSource({
    required SpotifyAuthService auth,
    required YoutubeTrackSource youtube,
    Dio? dio,
    SpotifyYoutubeMatcher matcher = const SpotifyYoutubeMatcher(),
    RetryPolicy? retryPolicy,
  }) : _auth = auth,
       _youtube = youtube,
       _dio = dio ?? Dio(BaseOptions(baseUrl: 'https://api.spotify.com/v1')),
       _matcher = matcher,
       _retryPolicy = retryPolicy ?? RetryPolicy();

  final SpotifyAuthService _auth;
  final YoutubeTrackSource _youtube;
  final Dio _dio;
  final SpotifyYoutubeMatcher _matcher;
  final RetryPolicy _retryPolicy;

  @override
  SourceType get sourceType => SourceType.spotify;

  @override
  bool canHandle(String input) {
    if (input.startsWith('spotify:')) return true;
    final uri = Uri.tryParse(input.trim());
    if (uri == null) return false;
    final host = uri.host.toLowerCase().replaceFirst('www.', '');
    return host == 'open.spotify.com' || host == 'spotify.link';
  }

  @override
  Future<ResolvedTrackInput> resolve(String input) async {
    if (!canHandle(input)) throw UnsupportedSourceFailure(input);
    final parsed = await _parseInput(input);
    return switch (parsed.type) {
      'track' => _resolveTrack(parsed.id, parsed.url),
      'album' => _resolveAlbum(parsed.id, parsed.url),
      'playlist' => _resolvePlaylist(parsed.id, parsed.url),
      _ => throw const UnsupportedMediaFailure('Spotify entity'),
    };
  }

  Future<ResolvedTrackInput> _resolveTrack(String id, String url) async {
    final json = await _get('/tracks/$id');
    final metadata = _trackFromJson(json, fallbackUrl: url);
    final preview = await _match(metadata);
    if (preview == null) throw const EmptyResultFailure('match Spotify track');
    return ResolvedTrackInput.single(preview);
  }

  Future<ResolvedTrackInput> _resolveAlbum(String id, String url) async {
    final album = await _get('/albums/$id');
    final items = await _allPages('/albums/$id/tracks?limit=50');
    final albumName = album['name'] as String?;
    final image = _image(album['images']);
    final releaseDate = album['release_date'] as String?;
    final tracks = items
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => _trackFromJson(
            item,
            fallbackUrl: _spotifyUrl('track', item['id'].toString()),
            album: albumName,
            artworkUrl: image,
            year: releaseDate == null
                ? null
                : int.tryParse(releaseDate.split('-').first),
          ),
        )
        .toList();
    return _matchCollection(
      input: url,
      id: 'spotify:album:$id',
      name: albumName ?? 'Spotify album',
      description: null,
      imageUrl: image,
      tracks: tracks,
    );
  }

  Future<ResolvedTrackInput> _resolvePlaylist(String id, String url) async {
    final playlist = await _get('/playlists/$id');
    List<dynamic> rawItems;
    try {
      rawItems = await _allPages('/playlists/$id/items?limit=50');
    } on DioException catch (error) {
      if (error.response?.statusCode == 403) throw const RemoteAccessFailure();
      rethrow;
    }
    final tracks = <SpotifyTrackMetadata>[];
    for (final raw in rawItems.whereType<Map<String, dynamic>>()) {
      final item = raw['item'] ?? raw['track'];
      if (item is! Map<String, dynamic> || item['type'] != 'track') continue;
      if (item['is_local'] == true) continue;
      tracks.add(_trackFromJson(item));
    }
    final images = playlist['images'];
    return _matchCollection(
      input: url,
      id: 'spotify:playlist:$id',
      name: playlist['name'] as String? ?? 'Spotify playlist',
      description: playlist['description'] as String?,
      imageUrl: _image(images),
      tracks: tracks,
    );
  }

  Future<ResolvedTrackInput> _matchCollection({
    required String input,
    required String id,
    required String name,
    required String? description,
    required String? imageUrl,
    required List<SpotifyTrackMetadata> tracks,
  }) async {
    final previews = <TrackPreview>[];
    final issues = <TrackResolutionIssue>[];
    for (var start = 0; start < tracks.length; start += 3) {
      final batch = tracks.skip(start).take(3);
      final matches = await Future.wait(batch.map(_match));
      var index = 0;
      for (final track in batch) {
        final match = matches[index++];
        if (match == null) {
          issues.add(
            TrackResolutionIssue(
              label: '${track.artists.join(', ')} — ${track.title}',
              reason: TrackResolutionIssueReason.noMatch,
            ),
          );
        } else {
          previews.add(match);
        }
      }
    }
    if (previews.isEmpty) {
      throw const EmptyResultFailure('match Spotify collection');
    }
    return ResolvedTrackInput(
      input: input,
      sourceType: SourceType.spotify,
      tracks: previews,
      issues: issues,
      collection: ResolvedTrackCollection(
        id: id,
        name: name,
        description: description,
        imageUrl: imageUrl,
      ),
    );
  }

  Future<TrackPreview?> _match(SpotifyTrackMetadata track) async {
    final query = '${track.artists.join(' ')} ${track.title} audio';
    final candidates = await _youtube.search(query, limit: 10);
    final selected = _matcher.best(track, candidates);
    if (selected == null) return null;
    return TrackPreview(
      id: track.id,
      title: track.title,
      artist: track.artists.join(', '),
      artistId: track.artists.length == 1
          ? 'spotify:artist:${_slug(track.artists.first)}'
          : null,
      album: track.album,
      artworkUrl: track.artworkUrl,
      duration: track.duration,
      source: SourceType.spotify,
      originalUrl: track.url,
      year: track.year,
      urlFile: '',
      media: MediaLocator(
        type: SourceType.youtube,
        id: selected.id.value,
        url: selected.url,
      ),
    );
  }

  SpotifyTrackMetadata _trackFromJson(
    Map<String, dynamic> json, {
    String? fallbackUrl,
    String? album,
    String? artworkUrl,
    int? year,
  }) {
    final albumJson = json['album'] is Map<String, dynamic>
        ? json['album'] as Map<String, dynamic>
        : null;
    final duration = json['duration_ms'];
    final id = json['id']?.toString();
    if (id == null || json['name'] == null || duration is! int) {
      throw const ParseFailure();
    }
    final releaseDate = albumJson?['release_date'] as String?;
    return SpotifyTrackMetadata(
      id: id,
      title: json['name'] as String,
      artists: (json['artists'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((artist) => artist['name']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toList(),
      url:
          (json['external_urls'] as Map<String, dynamic>?)?['spotify']
              as String? ??
          fallbackUrl ??
          _spotifyUrl('track', id),
      duration: Duration(milliseconds: duration),
      album: albumJson?['name'] as String? ?? album,
      artworkUrl: _image(albumJson?['images']) ?? artworkUrl,
      year:
          (releaseDate == null
              ? null
              : int.tryParse(releaseDate.split('-').first)) ??
          year,
    );
  }

  Future<List<dynamic>> _allPages(String path) async {
    final items = <dynamic>[];
    String? next = path;
    while (next != null) {
      final page = await _get(next);
      items.addAll(page['items'] as List<dynamic>? ?? const []);
      next = page['next'] as String?;
    }
    return items;
  }

  Future<Map<String, dynamic>> _get(String path, {bool retried = false}) async {
    final token = await _auth.accessToken();
    try {
      final response = await _retryPolicy.execute(() async {
        try {
          return await _dio.get<Map<String, dynamic>>(
            path,
            options: Options(headers: {'Authorization': 'Bearer $token'}),
          );
        } on DioException catch (error) {
          final data = error.response?.data;
          if (error.response?.statusCode == 429 &&
              data is Map &&
              data['error'] is Map &&
              (data['error'] as Map)['reason'] == 'QUOTA_EXCEEDED') {
            throw const RateLimitFailure();
          }
          rethrow;
        }
      });
      final data = response.data;
      if (data == null) throw const ParseFailure();
      return data;
    } on DioException catch (error) {
      if (error.response?.statusCode == 401 && !retried) {
        await _auth.refreshAccessToken();
        return _get(path, retried: true);
      }
      rethrow;
    }
  }

  Future<({String type, String id, String url})> _parseInput(
    String input,
  ) async {
    var value = input.trim();
    if (value.startsWith('spotify:')) {
      final parts = value.split(':');
      if (parts.length != 3) throw const ValidationFailure('spotifyUrl');
      return (
        type: parts[1],
        id: parts[2],
        url: _spotifyUrl(parts[1], parts[2]),
      );
    }
    var uri = Uri.parse(value);
    if (uri.host.toLowerCase().replaceFirst('www.', '') == 'spotify.link') {
      final response = await Dio(
        BaseOptions(followRedirects: true),
      ).getUri<dynamic>(uri);
      uri = response.realUri;
    }
    final parts = uri.pathSegments.where((part) => part.isNotEmpty).toList();
    final offset = parts.firstOrNull?.startsWith('intl-') == true ? 1 : 0;
    if (parts.length < offset + 2) {
      throw const ValidationFailure('spotifyUrl');
    }
    final type = parts[offset];
    final id = parts[offset + 1];
    return (type: type, id: id, url: _spotifyUrl(type, id));
  }

  @override
  Future<String> download(
    TrackPreview track, {
    OperationCancellation? cancellation,
  }) {
    final media = track.media;
    if (media?.type != SourceType.youtube) {
      throw const UnsupportedMediaFailure('Spotify audio');
    }
    return _youtube.download(
      TrackPreview(
        id: media!.id,
        title: track.title,
        artist: track.artist,
        source: SourceType.youtube,
        originalUrl: media.url,
        urlFile: '',
      ),
      cancellation: cancellation,
    );
  }

  static String? _image(dynamic images) {
    if (images is! List<dynamic>) return null;
    for (final image in images.whereType<Map<String, dynamic>>()) {
      final url = image['url'] as String?;
      if (url != null) return url;
    }
    return null;
  }

  static String _spotifyUrl(String type, String id) =>
      'https://open.spotify.com/$type/$id';

  static String _slug(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-');
}
