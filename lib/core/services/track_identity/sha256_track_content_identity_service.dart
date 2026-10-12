import 'dart:io';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/entities/track_preview.dart';
import 'package:owlsonic/layers/domain/repositories/track_content_identity_service.dart';

class Sha256TrackContentIdentityService implements TrackContentIdentityService {
  const Sha256TrackContentIdentityService();

  @override
  Future<String?> createFor(TrackPreview preview) => switch (preview.source) {
    SourceType.localFile => forLocalFile(preview.originalUrl),
    SourceType.soundcloud => Future.value(forSoundCloudTrack(preview.id)),
    SourceType.youtube => Future.value('youtube:${preview.id}'),
    SourceType.owlsonic => Future.value('owlsonic:${preview.id}'),
    SourceType.spotify => Future.value(switch (preview.media?.type) {
      SourceType.youtube => 'youtube:${preview.media!.id}',
      SourceType.soundcloud => forSoundCloudTrack(preview.media!.id),
      _ => 'spotify:${preview.id}',
    }),
    SourceType.unknown => Future.value(),
  };

  /// Scan and import both need the identity of the same file; hashing a
  /// large file twice is the slowest step of a local import. Keyed by size and
  /// mtime so an edited file is hashed again.
  static final _localCache = <String, String>{};
  static const _localCacheLimit = 2048;

  @override
  Future<String> forLocalFile(String filePath) async {
    final stat = await File(filePath).stat();
    final key =
        '$filePath|${stat.size}|${stat.modified.microsecondsSinceEpoch}';
    final cached = _localCache[key];
    if (cached != null) return cached;
    final identity = await Isolate.run(() => _hashLocalFile(filePath));
    if (_localCache.length >= _localCacheLimit) {
      _localCache.remove(_localCache.keys.first);
    }
    return _localCache[key] = identity;
  }

  static Future<String> _hashLocalFile(String filePath) async {
    final digest = await sha256.bind(File(filePath).openRead()).first;
    return 'local:sha256:$digest';
  }

  @override
  String forSoundCloudTrack(String trackId) => 'soundcloud:$trackId';
}
