import 'dart:async';
import 'dart:io';

import 'package:owlsonic/core/services/cloud/cloud_audio_cache.dart';
import 'package:owlsonic/core/services/cloud/signed_url_cache.dart';
import 'package:owlsonic/core/utils/app_logger.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_models.dart';

sealed class PlaybackSource {
  const PlaybackSource();
}

class LocalPlaybackSource extends PlaybackSource {
  const LocalPlaybackSource(this.path, {required this.cached});
  final String path;

  /// True when the file is an OwlSonic cache entry rather than an
  /// offline/user file.
  final bool cached;
}

class RemotePlaybackSource extends PlaybackSource {
  const RemotePlaybackSource(this.uri);
  final Uri uri;

  @override
  String toString() => 'RemotePlaybackSource(<signed url>)';
}

class PlaybackUnavailable implements Exception {
  const PlaybackUnavailable(this.reason, [this.cause]);
  final String reason;
  final Object? cause;

  @override
  String toString() => 'PlaybackUnavailable($reason)';
}

/// Playback priority: offline/local file → cached file → backend signed URL.
/// The signed URL is requested from `POST /v1/library/{id}/playback` through
/// [SignedUrlCache]; it is never constructed locally nor persisted.
///
/// With an [audioCache], a streamed track is also downloaded into it in the
/// background while [cacheStreamed] is true (the "stream" storage mode), so the
/// next playback is local.
class CloudPlaybackSourceSelector {
  CloudPlaybackSourceSelector({
    required SignedUrlCache playbackUrls,
    Future<bool> Function(String path)? fileExists,
    CloudAudioCache? audioCache,
    bool Function()? cacheStreamed,
  }) : _playbackUrls = playbackUrls,
       _fileExists = fileExists ?? ((path) => File(path).exists()),
       _audioCache = audioCache,
       _cacheStreamed = cacheStreamed ?? (() => true);

  final SignedUrlCache _playbackUrls;
  final Future<bool> Function(String path) _fileExists;
  final CloudAudioCache? _audioCache;
  final bool Function() _cacheStreamed;

  Future<PlaybackSource> resolve({
    String? localPath,
    String? cachedPath,
    String? cloudTrackId,
  }) async {
    if (localPath != null && await _fileExists(localPath)) {
      return LocalPlaybackSource(localPath, cached: false);
    }
    final cached =
        cachedPath ??
        (cloudTrackId == null ? null : await _audioCache?.lookup(cloudTrackId));
    if (cached != null && await _fileExists(cached)) {
      return LocalPlaybackSource(cached, cached: true);
    }
    if (cloudTrackId == null) {
      throw const PlaybackUnavailable('no_local_file');
    }
    final SignedUrl signed;
    try {
      signed = await _playbackUrls.get(cloudTrackId);
    } catch (error, stackTrace) {
      unawaited(
        AppLogger.captureException(
          error,
          stackTrace,
          operation: 'cloud.playback.resolve',
        ),
      );
      throw PlaybackUnavailable('cloud_unavailable', error);
    }
    final audioCache = _audioCache;
    if (audioCache != null && _cacheStreamed()) {
      unawaited(audioCache.cache(cloudTrackId));
    }
    return RemotePlaybackSource(signed.url);
  }

  /// The player reports a rejected/expired stream; the next [resolve] fetches
  /// a fresh signed URL.
  void reportRemoteFailure(String cloudTrackId) =>
      _playbackUrls.invalidate(cloudTrackId);
}
