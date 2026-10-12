import 'dart:convert';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:owlsonic/core/errors/failures/failure.dart';
import 'package:owlsonic/core/network/retry_policy.dart';
import 'package:owlsonic/core/utils/app_logger.dart';
import 'package:owlsonic/layers/data/datasources/remote/youtube_track_source.dart';
import 'package:owlsonic/layers/domain/entities/operation_cancellation.dart';
import 'package:owlsonic/layers/domain/entities/resolved_track_input.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/entities/track_preview.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/domain/repositories/track_source.dart';
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

  double score(SpotifyTrackMetadata track, Video candidate) => _score(
    track,
    author: candidate.author,
    title: candidate.title,
    duration: candidate.duration,
  );

  double _score(
    SpotifyTrackMetadata track, {
    required String author,
    required String title,
    required Duration? duration,
  }) {
    final target = _tokens('${track.artists.join(' ')} ${track.title}');
    final candidateTokens = _tokens('$author $title');
    final textScore = _dice(target, candidateTokens);
    final candidateDuration = duration;
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

  /// SoundCloud fallback. A candidate without a known length is skipped:
  /// uploads there are often edits, so the length check is what keeps a
  /// remix or a cut-down version out.
  TrackPreview? bestPreview(
    SpotifyTrackMetadata track,
    Iterable<TrackPreview> candidates,
  ) {
    TrackPreview? selected;
    var selectedScore = acceptanceThreshold;
    for (final candidate in candidates) {
      final duration = candidate.duration;
      if (duration == null || duration == Duration.zero) continue;
      final candidateScore = _score(
        track,
        author: candidate.artist,
        title: candidate.title,
        duration: duration,
      );
      if (candidateScore < selectedScore ||
          (selected != null && candidateScore == selectedScore)) {
        continue;
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

/// Reads Spotify metadata from the public embed widget
/// (`open.spotify.com/embed/<type>/<id>`): no developer app, no sign-in.
/// Audio comes from the matched YouTube video, as before.
///
/// Limits of the embed: playlists list their first 100 tracks only, and
/// private playlists are not visible.
class SpotifyTrackSource implements TrackSource, TrackAudioFallback {
  SpotifyTrackSource({
    required YoutubeTrackSource youtube,
    TrackSource? soundcloud,
    Future<List<TrackPreview>> Function(String query)? soundcloudSearch,
    Dio? dio,
    SpotifyYoutubeMatcher matcher = const SpotifyYoutubeMatcher(),
    RetryPolicy? retryPolicy,
    Duration searchSpacing = const Duration(milliseconds: 400),
  }) : _youtube = youtube,
       _soundcloud = soundcloud,
       _soundcloudSearch = soundcloudSearch,
       _searchSpacing = searchSpacing,
       _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 20),
               responseType: ResponseType.plain,
               headers: {'User-Agent': _browserUserAgent},
             ),
           ),
       _matcher = matcher,
       _retryPolicy = retryPolicy ?? RetryPolicy();

  final YoutubeTrackSource _youtube;

  /// Fallback audio when YouTube has no match or refuses this network.
  final TrackSource? _soundcloud;
  final Future<List<TrackPreview>> Function(String query)? _soundcloudSearch;

  /// Minimum gap between YouTube searches: a burst of them is what trips
  /// Google's abuse check on a big playlist.
  final Duration _searchSpacing;
  DateTime _nextSearchAt = DateTime.fromMillisecondsSinceEpoch(0);
  final Dio _dio;
  final SpotifyYoutubeMatcher _matcher;
  final RetryPolicy _retryPolicy;

  /// The embed answers non-browser agents with a bare shell page.
  static const _browserUserAgent =
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 14_0) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/128.0 Safari/537.36';

  @override
  SourceType get sourceType => SourceType.spotify;

  @override
  bool canHandle(String input) {
    if (input.trim().startsWith('spotify:')) return true;
    final uri = Uri.tryParse(input.trim());
    if (uri == null) return false;
    final host = uri.host.toLowerCase().replaceFirst('www.', '');
    return host == 'open.spotify.com' || host == 'spotify.link';
  }

  @override
  Future<ResolvedTrackInput> resolve(String input) async {
    if (!canHandle(input)) throw UnsupportedSourceFailure(input);
    final parsed = await _parseInput(input);
    if (!const {'track', 'album', 'playlist'}.contains(parsed.type)) {
      throw const UnsupportedMediaFailure('Spotify entity');
    }
    final entity = await _embedEntity(parsed.type, parsed.id);
    return switch (parsed.type) {
      'track' => _resolveTrack(entity, parsed.url),
      _ => _resolveCollection(entity, parsed.type, parsed.id, parsed.url),
    };
  }

  Future<ResolvedTrackInput> _resolveTrack(
    Map<String, dynamic> entity,
    String url,
  ) async {
    final metadata = _trackFromEntity(entity, url);
    final preview = await _match(metadata);
    if (preview == null) throw const EmptyResultFailure('match Spotify track');
    return ResolvedTrackInput.single(preview);
  }

  Future<ResolvedTrackInput> _resolveCollection(
    Map<String, dynamic> entity,
    String type,
    String id,
    String url,
  ) {
    final isAlbum = type == 'album';
    final name = (entity['name'] ?? entity['title']) as String?;
    final cover = _coverArt(entity) ?? _largestImage(entity);
    final tracks = <SpotifyTrackMetadata>[];
    final issues = <TrackResolutionIssue>[];
    final rawItems = entity['trackList'];
    for (final item in rawItems is List ? rawItems : const []) {
      if (item is! Map<String, dynamic>) continue;
      // Podcast episodes can sit in playlists; they are not music.
      final entityType = item['entityType'];
      if (entityType != null && entityType != 'track') continue;
      final track = _trackFromListItem(
        item,
        album: isAlbum ? name : null,
        // Playlist items carry no per-track artwork; the album cover is
        // right for every album track.
        artworkUrl: isAlbum ? cover : null,
      );
      if (track != null) {
        tracks.add(track);
      } else {
        issues.add(
          TrackResolutionIssue(
            label: item['title']?.toString() ?? 'Spotify track',
            reason: TrackResolutionIssueReason.unavailable,
          ),
        );
      }
    }
    return _matchCollection(
      input: url,
      id: 'spotify:$type:$id',
      name: name ?? (isAlbum ? 'Spotify album' : 'Spotify playlist'),
      description: null,
      imageUrl: cover,
      tracks: tracks,
      parseIssues: issues,
    );
  }

  Future<ResolvedTrackInput> _matchCollection({
    required String input,
    required String id,
    required String name,
    required String? description,
    required String? imageUrl,
    required List<SpotifyTrackMetadata> tracks,
    List<TrackResolutionIssue> parseIssues = const [],
  }) async {
    final previews = <TrackPreview>[];
    final issues = [...parseIssues];
    for (var start = 0; start < tracks.length; start += 3) {
      final batch = tracks.skip(start).take(3);
      final matches = await Future.wait(batch.map(_matchSafely));
      var index = 0;
      for (final track in batch) {
        final match = matches[index++];
        if (match.preview == null) {
          issues.add(
            TrackResolutionIssue(
              label: '${track.artists.join(', ')} — ${track.title}',
              reason: match.failed
                  ? TrackResolutionIssueReason.unavailable
                  : TrackResolutionIssueReason.noMatch,
            ),
          );
        } else {
          previews.add(match.preview!);
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

  /// One failed YouTube search (rate limit, captcha, network) must cost one
  /// track, not the whole album or playlist. A rate-limited search is retried
  /// once after a pause.
  Future<({TrackPreview? preview, bool failed})> _matchSafely(
    SpotifyTrackMetadata track,
  ) async {
    for (var attempt = 1; ; attempt++) {
      try {
        return (preview: await _match(track), failed: false);
      } catch (error, stackTrace) {
        if (attempt < 2) {
          await Future<void>.delayed(const Duration(seconds: 5));
          continue;
        }
        await AppLogger.warning(
          'YouTube search for a Spotify track failed.',
          operation: 'spotify.match',
          error: error,
          stackTrace: stackTrace,
        );
        return (preview: null, failed: true);
      }
    }
  }

  /// YouTube first; SoundCloud when YouTube has no match or fails. A YouTube
  /// error is rethrown only when SoundCloud found nothing either, so the
  /// caller still retries and reports the track as unavailable.
  Future<TrackPreview?> _match(SpotifyTrackMetadata track) async {
    Object? youtubeError;
    StackTrace? youtubeStack;
    try {
      final youtube = await _matchYoutube(track);
      if (youtube != null) return youtube;
    } catch (error, stackTrace) {
      youtubeError = error;
      youtubeStack = stackTrace;
    }
    final soundcloud = await _matchSoundcloud(track);
    if (soundcloud != null) return soundcloud;
    if (youtubeError != null) {
      Error.throwWithStackTrace(youtubeError, youtubeStack!);
    }
    return null;
  }

  Future<TrackPreview?> _matchYoutube(SpotifyTrackMetadata track) async {
    await _paceSearch();
    final query = '${track.artists.join(' ')} ${track.title} audio';
    final candidates = await _youtube.search(query, limit: 10);
    final selected = _matcher.best(track, candidates);
    if (selected == null) return null;
    return _previewFor(
      track,
      media: MediaLocator(
        type: SourceType.youtube,
        id: selected.id.value,
        url: selected.url,
      ),
      fallbackArtwork: selected.thumbnails.highResUrl,
    );
  }

  Future<TrackPreview?> _matchSoundcloud(SpotifyTrackMetadata track) async {
    final selected = await _findSoundcloudCandidate(track);
    if (selected == null) return null;
    return _previewFor(
      track,
      media: MediaLocator(
        type: SourceType.soundcloud,
        id: selected.id,
        url: selected.originalUrl,
      ),
      fallbackArtwork: selected.artworkUrl,
    );
  }

  @override
  Future<TrackPreview?> findFallback(Track track) {
    if (track.source.type != SourceType.spotify ||
        track.source.media?.type != SourceType.youtube ||
        track.duration <= Duration.zero ||
        track.artists.isEmpty) {
      return Future.value();
    }
    return _findSoundcloudCandidate(
      SpotifyTrackMetadata(
        id: track.id,
        title: track.title,
        artists: track.artists.map((artist) => artist.name).toList(),
        url: track.source.originalUrl,
        duration: track.duration,
      ),
    );
  }

  Future<TrackPreview?> _findSoundcloudCandidate(
    SpotifyTrackMetadata track,
  ) async {
    final search = _soundcloudSearch;
    if (search == null || _soundcloud == null) return null;
    try {
      final candidates = await search(
        '${track.artists.join(' ')} ${track.title}',
      );
      final selected = _matcher.bestPreview(track, candidates);
      return selected;
    } catch (error, stackTrace) {
      await AppLogger.warning(
        'SoundCloud fallback search for a Spotify track failed.',
        operation: 'spotify.match_soundcloud',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<void> _paceSearch() async {
    final now = DateTime.now();
    final at = _nextSearchAt.isAfter(now) ? _nextSearchAt : now;
    _nextSearchAt = at.add(_searchSpacing);
    final wait = at.difference(now);
    if (wait > Duration.zero) await Future<void>.delayed(wait);
  }

  TrackPreview _previewFor(
    SpotifyTrackMetadata track, {
    required MediaLocator media,
    String? fallbackArtwork,
  }) => TrackPreview(
    id: track.id,
    title: track.title,
    artist: track.artists.join(', '),
    artistId: track.artists.length == 1
        ? 'spotify:artist:${_slug(track.artists.first)}'
        : null,
    album: track.album,
    artworkUrl: track.artworkUrl ?? fallbackArtwork,
    duration: track.duration,
    source: SourceType.spotify,
    originalUrl: track.url,
    year: track.year,
    urlFile: '',
    media: media,
  );

  static final _nextData = RegExp(
    r'<script id="__NEXT_DATA__"[^>]*>(.*?)</script>',
    dotAll: true,
  );

  Future<Map<String, dynamic>> _embedEntity(String type, String id) async {
    final response = await _retryPolicy.execute(
      () => _dio.get<String>('https://open.spotify.com/embed/$type/$id'),
    );
    return parseEmbedEntity(response.data ?? '', id);
  }

  /// The embed is a Next.js page; its data sits in `__NEXT_DATA__`. A missing
  /// entity there is either a 404 page or a changed page format.
  static Map<String, dynamic> parseEmbedEntity(String html, String id) {
    final match = _nextData.firstMatch(html);
    if (match == null) throw const ParseFailure();
    final Object? data;
    try {
      data = jsonDecode(match.group(1)!);
    } on FormatException {
      throw const ParseFailure();
    }
    final pageProps = _map(_map(data)?['props'])?['pageProps'];
    if (_map(pageProps)?['status'] == 404) {
      throw NotFoundFailure('spotify', id);
    }
    final entity = _map(_map(_map(pageProps)?['state'])?['data'])?['entity'];
    if (entity is! Map<String, dynamic>) throw const ParseFailure();
    return entity;
  }

  static Map<String, dynamic>? _map(Object? value) =>
      value is Map<String, dynamic> ? value : null;

  SpotifyTrackMetadata _trackFromEntity(
    Map<String, dynamic> entity,
    String url,
  ) {
    final id = entity['id']?.toString();
    final rawTitle = (entity['name'] ?? entity['title'])?.toString();
    final duration = entity['duration'];
    if (id == null || rawTitle == null || duration is! int || duration <= 0) {
      throw const ParseFailure();
    }
    final artists = [
      for (final artist
          in entity['artists'] is List ? entity['artists'] as List : const [])
        if (artist is Map && artist['name'] is String)
          _plainSpaces(artist['name'] as String),
    ];
    final title = _plainSpaces(rawTitle);
    final release = _map(entity['releaseDate'])?['isoString'] as String?;
    return SpotifyTrackMetadata(
      id: id,
      title: title,
      artists: artists,
      url: url,
      duration: Duration(milliseconds: duration),
      artworkUrl: _largestImage(entity),
      year: release == null ? null : int.tryParse(release.split('-').first),
    );
  }

  /// List items name their artists only as a joined `subtitle`.
  static SpotifyTrackMetadata? _trackFromListItem(
    Map<String, dynamic> item, {
    String? album,
    String? artworkUrl,
  }) {
    final uri = item['uri']?.toString() ?? '';
    final id = uri.startsWith('spotify:track:')
        ? uri.substring('spotify:track:'.length)
        : null;
    final title = item['title']?.toString();
    final duration = item['duration'];
    if (id == null || id.isEmpty || title == null || duration is! int) {
      return null;
    }
    // Spotify joins artists with a comma and a no-break space (U+00A0); left
    // in, it ends up in the YouTube query and trips Google's abuse check.
    final subtitle = _plainSpaces(item['subtitle']?.toString() ?? '');
    return SpotifyTrackMetadata(
      id: id,
      title: _plainSpaces(title),
      artists: subtitle
          .split(',')
          .map((name) => name.trim())
          .where((name) => name.isNotEmpty)
          .toList(),
      url: _spotifyUrl('track', id),
      duration: Duration(milliseconds: duration),
      album: album,
      artworkUrl: artworkUrl,
    );
  }

  static String _plainSpaces(String value) =>
      value.replaceAll(RegExp(r'[\u00A0\u2007\u202F]'), ' ');

  static String? _coverArt(Map<String, dynamic> entity) {
    final sources = _map(entity['coverArt'])?['sources'];
    if (sources is! List) return null;
    for (final source in sources) {
      if (source is Map && source['url'] is String) {
        return source['url'] as String;
      }
    }
    return null;
  }

  static String? _largestImage(Map<String, dynamic> entity) {
    final images = _map(entity['visualIdentity'])?['image'];
    if (images is! List) return null;
    String? best;
    var bestWidth = -1;
    for (final image in images) {
      if (image is! Map || image['url'] is! String) continue;
      final width = image['maxWidth'] is int ? image['maxWidth'] as int : 0;
      if (width > bestWidth) {
        best = image['url'] as String;
        bestWidth = width;
      }
    }
    return best;
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
      uri = await _expandShortLink(uri);
    }
    var parts = uri.pathSegments.where((part) => part.isNotEmpty).toList();
    if (parts.firstOrNull?.startsWith('intl-') == true)
      parts = parts.skip(1).toList();
    // An embed link pasted as-is: /embed/<type>/<id>.
    if (parts.firstOrNull == 'embed') parts = parts.skip(1).toList();
    if (parts.length < 2) throw const ValidationFailure('spotifyUrl');
    final type = parts[0];
    final id = parts[1];
    return (type: type, id: id, url: _spotifyUrl(type, id));
  }

  static final _openSpotifyUrl = RegExp(
    r'https://open\.spotify\.com/[A-Za-z0-9/_\-]+',
  );

  /// spotify.link is a Branch link: it answers with a plain redirect for some
  /// clients and with an HTML/JS page for others. Follow redirects by hand and
  /// fall back to the open.spotify.com link embedded in the page.
  Future<Uri> _expandShortLink(Uri uri) async {
    final dio = Dio(
      BaseOptions(
        followRedirects: false,
        validateStatus: (status) => status != null && status < 400,
        responseType: ResponseType.plain,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'User-Agent': 'curl/8.0'},
      ),
    );
    var current = uri;
    for (var hop = 0; hop < 6; hop++) {
      if (current.host.toLowerCase().replaceFirst('www.', '') ==
          'open.spotify.com') {
        return current;
      }
      final response = await _retryPolicy.execute(
        () => dio.getUri<String>(current),
      );
      final location = response.headers.value('location');
      if (location != null && location.isNotEmpty) {
        current = current.resolve(location);
        continue;
      }
      final embedded = _openSpotifyUrl.firstMatch(response.data ?? '');
      if (embedded != null) return Uri.parse(embedded.group(0)!);
      break;
    }
    throw const ValidationFailure('spotifyUrl');
  }

  @override
  Future<String> download(
    TrackPreview track, {
    OperationCancellation? cancellation,
  }) {
    final media = track.media;
    final source = switch (media?.type) {
      SourceType.youtube => _youtube,
      SourceType.soundcloud => _soundcloud,
      _ => null,
    };
    if (media == null || source == null) {
      throw const UnsupportedMediaFailure('Spotify audio');
    }
    return source.download(
      TrackPreview(
        id: media.id,
        title: track.title,
        artist: track.artist,
        source: media.type,
        originalUrl: media.url,
        urlFile: '',
      ),
      cancellation: cancellation,
    );
  }

  static String _spotifyUrl(String type, String id) =>
      'https://open.spotify.com/$type/$id';

  static String _slug(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-');
}
