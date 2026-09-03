import 'dart:io';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';
import 'package:openmusic/layers/domain/repositories/track_content_identity_service.dart';

class Sha256TrackContentIdentityService implements TrackContentIdentityService {
  const Sha256TrackContentIdentityService();

  @override
  Future<String?> createFor(TrackPreview preview) => switch (preview.source) {
    SourceType.localFile => forLocalFile(preview.originalUrl),
    SourceType.soundcloud => Future.value(forSoundCloudTrack(preview.id)),
    SourceType.unknown => Future.value(),
  };

  @override
  Future<String> forLocalFile(String filePath) {
    return Isolate.run(() => _hashLocalFile(filePath));
  }

  static Future<String> _hashLocalFile(String filePath) async {
    final digest = await sha256.bind(File(filePath).openRead()).first;
    return 'local:sha256:$digest';
  }

  @override
  String forSoundCloudTrack(String trackId) => 'soundcloud:$trackId';
}
