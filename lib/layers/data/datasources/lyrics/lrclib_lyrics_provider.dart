import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../../domain/entities/track_lyrics.dart';
import '../../../domain/repositories/lyrics_provider.dart';
import '../../../domain/services/lrc_parser.dart';
import '../../../domain/services/lyrics_track_matcher.dart';

typedef LyricsProviderDelay = Future<void> Function(Duration duration);
typedef LyricsProviderClock = DateTime Function();

class LrclibLyricsProvider implements LyricsProvider {
  LrclibLyricsProvider({
    Dio? dio,
    LyricsTrackMatcher matcher = const LyricsTrackMatcher(),
    LrcParser lrcParser = const LrcParser(),
    this.baseUrl = 'https://lrclib.net',
    this.minimumRequestInterval = const Duration(milliseconds: 350),
    this.requestTimeout = const Duration(seconds: 15),
    LyricsProviderDelay? delay,
    LyricsProviderClock? clock,
  }) : assert(!minimumRequestInterval.isNegative),
       assert(!requestTimeout.isNegative && requestTimeout != Duration.zero),
       _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: requestTimeout,
               receiveTimeout: requestTimeout,
               sendTimeout: requestTimeout,
             ),
           ),
       _matcher = matcher,
       _lrcParser = lrcParser,
       _delay = delay ?? Future<void>.delayed,
       _clock = clock ?? DateTime.now;

  static const userAgent =
      'OpenMusic/0.1.0 (https://github.com/openmusic-app/openmusic)';

  final Dio _dio;
  final LyricsTrackMatcher _matcher;
  final LrcParser _lrcParser;
  final LyricsProviderDelay _delay;
  final LyricsProviderClock _clock;
  final String baseUrl;
  final Duration minimumRequestInterval;
  final Duration requestTimeout;

  Future<void> _requestTail = Future<void>.value();
  DateTime? _lastRequestCompletedAt;

  @override
  LyricsSource get source => LyricsSource.lrclib;

  @override
  Future<LyricsProviderResult> resolve(LyricsRequest request) {
    final operation = _requestTail.then((_) => _resolveSequentially(request));
    _requestTail = operation.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );
    return operation;
  }

  Future<LyricsProviderResult> _resolveSequentially(
    LyricsRequest request,
  ) async {
    final search = _matcher.buildSearchCandidate(request);
    if (search.title.isEmpty || search.artist.isEmpty) {
      return const LyricsProviderNotFound(
        details: 'Title and artist are required for a conservative match',
      );
    }

    LyricsTrackMatch? directAmbiguous;
    try {
      final direct = await _get(
        '/api/get',
        _queryFor(request, search, includeDuration: true),
      );
      if (direct.statusCode == 200) {
        final record = _LrclibRecord.fromJson(_jsonMap(direct.data));
        final match = _matcher.match(request, [record.candidate]);
        if (match.disposition == LyricsMatchDisposition.accepted) {
          return _matchedResult(record, match);
        }
        if (match.disposition == LyricsMatchDisposition.ambiguous) {
          directAmbiguous = match;
        }
      } else if (direct.statusCode != 404) {
        return _httpFailure(direct);
      }

      final fallback = await _get(
        '/api/search',
        _queryFor(request, search, includeDuration: false),
      );
      if (fallback.statusCode == 404) {
        return directAmbiguous == null
            ? const LyricsProviderNotFound()
            : _ambiguousResult(directAmbiguous);
      }
      if (fallback.statusCode != 200) return _httpFailure(fallback);

      final records = _jsonList(fallback.data)
          .map((value) => _LrclibRecord.fromJson(_jsonMap(value)))
          .toList(growable: false);
      if (records.isEmpty) {
        return directAmbiguous == null
            ? const LyricsProviderNotFound()
            : _ambiguousResult(directAmbiguous);
      }

      final match = _matcher.match(
        request,
        records.map((record) => record.candidate),
      );
      switch (match.disposition) {
        case LyricsMatchDisposition.accepted:
          final record = records.firstWhere(
            (record) => record.sourceId == match.candidate!.sourceId,
          );
          return _matchedResult(record, match);
        case LyricsMatchDisposition.ambiguous:
          return _ambiguousResult(match);
        case LyricsMatchDisposition.noMatch:
          return directAmbiguous == null
              ? const LyricsProviderNotFound(
                  details: 'Search returned no safe metadata match',
                )
              : _ambiguousResult(directAmbiguous);
      }
    } on DioException catch (error) {
      final response = error.response;
      if (response != null) return _httpFailure(response);
      return switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.connectionError ||
        DioExceptionType.cancel => LyricsProviderTemporaryFailure(
          code: 'lrclib_network',
          details: error.type.name,
        ),
        _ => LyricsProviderPermanentFailure(
          code: 'lrclib_request_failed',
          details: error.type.name,
        ),
      };
    } on FormatException catch (error) {
      return LyricsProviderPermanentFailure(
        code: 'lrclib_malformed_response',
        details: error.message,
      );
    } catch (error) {
      return LyricsProviderPermanentFailure(
        code: 'lrclib_unexpected',
        details: error.runtimeType.toString(),
      );
    }
  }

  Future<Response<dynamic>> _get(
    String endpoint,
    Map<String, dynamic> query,
  ) async {
    final lastRequest = _lastRequestCompletedAt;
    if (lastRequest != null) {
      final elapsed = _clock().difference(lastRequest);
      final remaining = minimumRequestInterval - elapsed;
      if (remaining > Duration.zero) await _delay(remaining);
    }

    try {
      return await _dio.get<dynamic>(
        '${baseUrl.replaceFirst(RegExp(r'/$'), '')}$endpoint',
        queryParameters: query,
        options: Options(
          headers: const {'User-Agent': userAgent},
          sendTimeout: requestTimeout,
          receiveTimeout: requestTimeout,
          responseType: ResponseType.json,
          validateStatus: (_) => true,
        ),
      );
    } finally {
      _lastRequestCompletedAt = _clock();
    }
  }

  Map<String, dynamic> _queryFor(
    LyricsRequest request,
    LyricsSearchCandidate search, {
    required bool includeDuration,
  }) {
    final duration = request.duration;
    final usableDuration =
        duration != null &&
        duration >= const Duration(seconds: 1) &&
        duration <= const Duration(hours: 1);
    final query = <String, dynamic>{
      'track_name': search.title,
      'artist_name': search.artist,
      if (includeDuration && usableDuration) 'duration': duration.inSeconds,
    };
    final album = _nonEmpty(request.album);
    if (album != null) query['album_name'] = album;
    return query;
  }

  LyricsProviderResult _matchedResult(
    _LrclibRecord record,
    LyricsTrackMatch match,
  ) {
    final durationMs = record.duration.inMilliseconds;
    if (record.instrumental) {
      return LyricsProviderInstrumental(
        sourceId: record.sourceId,
        matchConfidence: match.confidence,
        matchedTitle: record.title,
        matchedArtist: record.artist,
        matchedDurationMs: durationMs,
      );
    }

    var plainText = _nonEmpty(record.plainLyrics);
    final syncedText = _nonEmpty(record.syncedLyrics);
    if (plainText == null && syncedText != null) {
      final parsed = _lrcParser.parse(syncedText);
      if (parsed case LrcParseSuccess(:final plainText)) {
        return LyricsProviderFound(
          plainText: plainText,
          syncedText: syncedText,
          sourceId: record.sourceId,
          matchConfidence: match.confidence,
          matchedTitle: record.title,
          matchedArtist: record.artist,
          matchedDurationMs: durationMs,
        );
      }
      return LyricsProviderPermanentFailure(
        code: 'lrclib_malformed_response',
        details: (parsed as LrcParseFailure).reason,
      );
    }
    if (plainText == null) {
      return const LyricsProviderPermanentFailure(
        code: 'lrclib_malformed_response',
        details: 'Non-instrumental record has no lyrics',
      );
    }
    return LyricsProviderFound(
      plainText: plainText,
      syncedText: syncedText,
      sourceId: record.sourceId,
      matchConfidence: match.confidence,
      matchedTitle: record.title,
      matchedArtist: record.artist,
      matchedDurationMs: durationMs,
    );
  }

  static LyricsProviderAmbiguous _ambiguousResult(LyricsTrackMatch match) {
    final candidate = match.candidate;
    return LyricsProviderAmbiguous(
      bestConfidence: match.confidence,
      matchedTitle: candidate?.title,
      matchedArtist: candidate?.artist,
      matchedDurationMs: candidate?.duration?.inMilliseconds,
      details: 'LRCLIB metadata did not meet auto-accept thresholds',
    );
  }

  LyricsProviderResult _httpFailure(Response<dynamic> response) {
    final statusCode = response.statusCode ?? 0;
    if (statusCode == 429) {
      return LyricsProviderTemporaryFailure(
        code: 'lrclib_rate_limited',
        details: 'HTTP 429',
        retryAfter: _retryAfter(response.headers.value('retry-after')),
      );
    }
    if (statusCode >= 500) {
      return LyricsProviderTemporaryFailure(
        code: 'lrclib_server',
        details: 'HTTP $statusCode',
      );
    }
    return LyricsProviderPermanentFailure(
      code: 'lrclib_http',
      details: 'HTTP $statusCode',
    );
  }

  Duration? _retryAfter(String? value) {
    if (value == null) return null;
    final seconds = int.tryParse(value.trim());
    if (seconds != null && seconds >= 0) return Duration(seconds: seconds);
    try {
      final target = HttpDate.parse(value);
      final duration = target.difference(_clock().toUtc());
      return duration.isNegative ? Duration.zero : duration;
    } on FormatException {
      return null;
    }
  }

  static Map<String, dynamic> _jsonMap(dynamic value) {
    if (value is! Map) throw const FormatException('Expected JSON object');
    return value.map((key, value) => MapEntry(key.toString(), value));
  }

  static List<dynamic> _jsonList(dynamic value) {
    if (value is! List) throw const FormatException('Expected JSON array');
    return value;
  }

  static String? _nonEmpty(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return value;
  }
}

class _LrclibRecord {
  const _LrclibRecord({
    required this.sourceId,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.instrumental,
    required this.plainLyrics,
    required this.syncedLyrics,
  });

  factory _LrclibRecord.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final sourceId = switch (rawId) {
      int() => rawId.toString(),
      String() when rawId.trim().isNotEmpty => rawId,
      _ => throw const FormatException('Invalid LRCLIB id'),
    };
    final title = _requiredString(
      json['trackName'] ?? json['name'],
      'trackName',
    );
    final artist = _requiredString(json['artistName'], 'artistName');
    final album = _optionalString(json['albumName'], 'albumName');
    final rawDuration = json['duration'];
    if (rawDuration is! num || !rawDuration.isFinite || rawDuration <= 0) {
      throw const FormatException('Invalid LRCLIB duration');
    }
    final instrumental = json['instrumental'];
    if (instrumental is! bool) {
      throw const FormatException('Invalid LRCLIB instrumental flag');
    }
    return _LrclibRecord(
      sourceId: sourceId,
      title: title,
      artist: artist,
      album: album,
      duration: Duration(milliseconds: (rawDuration * 1000).round()),
      instrumental: instrumental,
      plainLyrics: _optionalString(json['plainLyrics'], 'plainLyrics'),
      syncedLyrics: _optionalString(json['syncedLyrics'], 'syncedLyrics'),
    );
  }

  final String sourceId;
  final String title;
  final String artist;
  final String? album;
  final Duration duration;
  final bool instrumental;
  final String? plainLyrics;
  final String? syncedLyrics;

  LyricsTrackCandidate get candidate => LyricsTrackCandidate(
    sourceId: sourceId,
    title: title,
    artist: artist,
    album: album,
    duration: duration,
  );

  static String _requiredString(dynamic value, String field) {
    final parsed = _optionalString(value, field);
    if (parsed == null || parsed.trim().isEmpty) {
      throw FormatException('Invalid LRCLIB $field');
    }
    return parsed;
  }

  static String? _optionalString(dynamic value, String field) {
    if (value == null) return null;
    if (value is! String) throw FormatException('Invalid LRCLIB $field');
    return value;
  }
}
