import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:owlsonic/core/services/audio_player/cloud_stream_audio_source.dart';
import 'package:owlsonic/core/services/cloud/cloud_playback_source.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';

extension TrackAudioMapper on Track {
  MediaItem toMediaItem() => MediaItem(
    id: id,
    title: title,
    artist: artists.map((a) => a.name).join(', '),
    album: album,
    artUri: _artUri,
    duration: duration,
  );

  /// Only real files/URLs reach the OS media session; cloud artwork
  /// placeholders resolve to short-lived signed URLs inside the app only.
  Uri? get _artUri {
    final value = imageUrl;
    if (value == null) return null;
    final uri = Uri.tryParse(value);
    if (uri == null) return null;
    const passThrough = {'http', 'https', 'file'};
    if (uri.hasScheme && !passThrough.contains(uri.scheme)) return null;
    return uri;
  }

  AudioSource toAudioSource(
    String appDir, {
    CloudPlaybackSourceSelector? cloud,
  }) {
    final path = filePath == null ? null : p.join(appDir, filePath);
    if (isCloudTrack && cloud != null) {
      return CloudStreamAudioSource(
        trackId: id,
        localPath: path,
        selector: cloud,
        tag: toMediaItem(),
      );
    }
    return AudioSource.file(path!, tag: toMediaItem());
  }
}
