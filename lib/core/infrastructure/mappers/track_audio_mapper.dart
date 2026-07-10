import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:openmusic/layers/domain/entities/track.dart';

extension TrackAudioMapper on Track {
  MediaItem toMediaItem() => MediaItem(
    id: id,
    title: title,
    artist: artists.map((a) => a.name).join(', '),
    album: album,
    artUri: imageUrl != null ? Uri.parse(imageUrl!) : null,
    duration: duration,
  );

  AudioSource toAudioSource(String appDir) {
    return AudioSource.file('$appDir/$filePath', tag: toMediaItem());
  }
}
