import 'dart:async';

import 'package:owlsonic/layers/domain/entities/cloud/cloud_models.dart';

/// In-memory cache of short-lived signed URLs (playback / artwork).
///
/// URLs are never written to disk. Concurrent requests for the same key share
/// one backend call; an expired or [invalidate]d entry is re-requested.
class SignedUrlCache {
  SignedUrlCache({
    required Future<SignedUrl> Function(String key) fetch,
    DateTime Function()? now,
    this.margin = const Duration(seconds: 30),
  }) : _fetch = fetch,
       _now = now ?? (() => DateTime.now().toUtc());

  final Future<SignedUrl> Function(String key) _fetch;
  final DateTime Function() _now;
  final Duration margin;
  final _entries = <String, SignedUrl>{};
  final _inflight = <String, Future<SignedUrl>>{};

  Future<SignedUrl> get(String key) {
    final cached = _entries[key];
    if (cached != null && cached.isUsableAt(_now(), margin: margin)) {
      return Future.value(cached);
    }
    _entries.remove(key);
    return _inflight[key] ??= _fetch(key)
        .then((url) {
          _entries[key] = url;
          return url;
        })
        .whenComplete(() {
          // Block body: returning the removed future would await itself.
          _inflight.remove(key);
        });
  }

  /// Call when a player/image request using the URL was rejected (e.g. 403).
  void invalidate(String key) => _entries.remove(key);

  void clear() => _entries.clear();
}
