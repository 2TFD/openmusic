import 'package:owlsonic/layers/domain/entities/operation_cancellation.dart';
import 'package:owlsonic/layers/domain/entities/resolved_track_input.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/entities/track_preview.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';

abstract class TrackSource {
  SourceType get sourceType;
  bool canHandle(String input);
  Future<ResolvedTrackInput> resolve(String input);
  Future<String> download(
    TrackPreview track, {
    OperationCancellation? cancellation,
  });
}

/// A source that can download from the stored link alone. The download
/// worker skips [TrackSource.resolve] for it: re-resolving is an extra
/// request that can fail on its own (YouTube's watch page under a bot check)
/// while the audio itself is still reachable.
abstract interface class DirectDownloadSource {
  /// `null` when [originalUrl] cannot be downloaded without resolving.
  TrackPreview? previewForDownload(
    String originalUrl, {
    String? title,
    String? artist,
  });
}

/// Finds another audio upload for a track whose selected media failed.
/// The implementation must validate the candidate against track metadata.
abstract interface class TrackAudioFallback {
  Future<TrackPreview?> findFallback(Track track);
}
