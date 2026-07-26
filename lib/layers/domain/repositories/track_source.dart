import 'package:openmusic/layers/domain/entities/operation_cancellation.dart';
import 'package:openmusic/layers/domain/entities/resolved_track_input.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';

abstract class TrackSource {
  SourceType get sourceType;
  bool canHandle(String input);
  Future<ResolvedTrackInput> resolve(String input);
  Future<String> download(
    TrackPreview track, {
    OperationCancellation? cancellation,
  });
}
