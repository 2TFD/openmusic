import 'dart:async';

import 'package:owlsonic/core/services/recommendation/audio_wave_support.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';

/// Which tracks Wave may queue right now.
///
/// Online, every ready track is eligible ([isPlayableWaveTrack]). Offline, a
/// cloud track is eligible only when its audio is on this device (the user's
/// file, an offline copy, or a stream-cache copy): streaming it would fail and
/// the player would skip through the queue. Ranking among eligible tracks is
/// unchanged.
class WavePlayability {
  WavePlayability({
    required Future<bool> Function() isOnline,
    Stream<void>? changes,
    bool Function(String trackId)? hasCachedAudio,
    Future<void> Function()? warmUpCache,
  }) : _isOnline = isOnline,
       _hasCachedAudio = hasCachedAudio,
       _warmUpCache = warmUpCache {
    _subscription = changes?.listen(
      (_) => unawaited(refresh()),
      onError: (Object _) {},
    );
    unawaited(refresh());
  }

  final Future<bool> Function() _isOnline;
  final bool Function(String trackId)? _hasCachedAudio;
  final Future<void> Function()? _warmUpCache;
  StreamSubscription<void>? _subscription;

  /// Optimistic until the first check: the online behaviour is the default.
  bool _online = true;
  bool get online => _online;

  Future<void> refresh() async {
    try {
      _online = await _isOnline();
      if (!_online) await _warmUpCache?.call();
    } catch (_) {
      // Unknown connectivity keeps the last known state.
    }
  }

  bool isPlayable(Track track) {
    if (!isPlayableWaveTrack(track)) return false;
    if (_online || !track.isCloudTrack || track.filePath != null) return true;
    return _hasCachedAudio?.call(track.id) ?? false;
  }

  Future<void> dispose() async => _subscription?.cancel();
}
