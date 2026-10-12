// StreamAudioSource is marked experimental in just_audio 0.10 but is the
// supported way to feed lazily resolved bytes through its local proxy (all
// platforms, including media_kit on Windows/Linux).
// ignore_for_file: experimental_member_use

import 'dart:async';
import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:owlsonic/core/services/cloud/cloud_playback_source.dart';
import 'package:path/path.dart' as p;

/// Lazily resolved audio of an OwlSonic cloud track.
///
/// Every byte-range request applies the playback priority: the local file
/// (original or managed copy) when it exists, otherwise a backend signed URL
/// from `POST /v1/library/{id}/playback`. URLs live only in memory; a rejected
/// or expired one is re-acquired once per request.
class CloudStreamAudioSource extends StreamAudioSource {
  CloudStreamAudioSource({
    required this.trackId,
    required this.localPath,
    required CloudPlaybackSourceSelector selector,
    HttpClient? httpClient,
    this.responseTimeout = const Duration(seconds: 20),
    super.tag,
  }) : _selector = selector,
       _http = httpClient ?? _sharedHttp;

  /// One client for all cloud tracks: a client per source would keep its own
  /// idle sockets alive for the whole queue. The timeouts make a stalled
  /// network fail instead of hanging playback.
  static final HttpClient _sharedHttp = HttpClient()
    ..connectionTimeout = const Duration(seconds: 15)
    ..idleTimeout = const Duration(seconds: 15);

  /// Longest wait for the response headers after connecting. The body is not
  /// time-limited: the player legitimately pauses reading it.
  final Duration responseTimeout;

  final String trackId;
  final String? localPath;
  final CloudPlaybackSourceSelector _selector;
  final HttpClient _http;

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final source = await _selector.resolve(
      localPath: localPath,
      cloudTrackId: trackId,
    );
    return switch (source) {
      LocalPlaybackSource(:final path) => _file(path, start, end),
      RemotePlaybackSource() => _remote(source.uri, start, end, retry: true),
    };
  }

  Future<StreamAudioResponse> _file(String path, int? start, int? end) async {
    final file = File(path);
    final length = await file.length();
    final from = start ?? 0;
    final to = end ?? length;
    return StreamAudioResponse(
      sourceLength: start == null ? null : length,
      contentLength: to - from,
      offset: start,
      stream: file.openRead(from, to),
      contentType: _mimeFor(path),
    );
  }

  Future<StreamAudioResponse> _remote(
    Uri uri,
    int? start,
    int? end, {
    required bool retry,
  }) async {
    final request = await _http.getUrl(uri);
    if (start != null || end != null) {
      request.headers.set(
        HttpHeaders.rangeHeader,
        'bytes=${start ?? 0}-${end == null ? '' : end - 1}',
      );
    }
    final response = await request.close().timeout(
      responseTimeout,
      onTimeout: () {
        request.abort();
        throw const PlaybackUnavailable('timeout');
      },
    );
    final status = response.statusCode;
    if ((status == 401 || status == 403 || status == 404) && retry) {
      await response.drain<void>();
      // Expired or rejected signed URL: fetch a fresh one exactly once.
      _selector.reportRemoteFailure(trackId);
      final next = await _selector.resolve(cloudTrackId: trackId);
      if (next is RemotePlaybackSource) {
        return _remote(next.uri, start, end, retry: false);
      }
      throw const PlaybackUnavailable('cloud_rejected');
    }
    if (status != HttpStatus.ok && status != HttpStatus.partialContent) {
      await response.drain<void>();
      if (status == 401 || status == 403) {
        _selector.reportRemoteFailure(trackId);
      }
      throw PlaybackUnavailable('http_$status');
    }
    final partial = status == HttpStatus.partialContent;
    return StreamAudioResponse(
      rangeRequestsSupported: true,
      sourceLength: partial ? _totalFromContentRange(response) : null,
      contentLength: response.contentLength < 0 ? null : response.contentLength,
      offset: partial ? (start ?? 0) : null,
      stream: response,
      contentType: response.headers.contentType?.mimeType ?? _mimeFor(uri.path),
    );
  }

  static int? _totalFromContentRange(HttpClientResponse response) {
    final value = response.headers.value(HttpHeaders.contentRangeHeader);
    final total = value?.split('/').last;
    return total == null ? null : int.tryParse(total);
  }

  static String _mimeFor(String path) =>
      switch (p.extension(path).toLowerCase()) {
        '.flac' => 'audio/flac',
        '.m4a' || '.mp4' || '.aac' => 'audio/mp4',
        '.wav' => 'audio/wav',
        '.ogg' || '.oga' || '.opus' => 'audio/ogg',
        _ => 'audio/mpeg',
      };
}
