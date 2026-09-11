import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';

enum TrackResolutionIssueReason { unavailable, noMatch, unsupported }

class TrackResolutionIssue {
  const TrackResolutionIssue({required this.label, required this.reason});

  final String label;
  final TrackResolutionIssueReason reason;
}

class ResolvedTrackCollection {
  const ResolvedTrackCollection({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
}

class ResolvedTrackInput {
  const ResolvedTrackInput({
    required this.input,
    required this.sourceType,
    required this.tracks,
    this.collection,
    this.issues = const [],
  });

  factory ResolvedTrackInput.single(TrackPreview preview) => ResolvedTrackInput(
    input: preview.originalUrl,
    sourceType: preview.source,
    tracks: [preview],
  );

  final String input;
  final SourceType sourceType;
  final List<TrackPreview> tracks;
  final ResolvedTrackCollection? collection;
  final List<TrackResolutionIssue> issues;

  TrackPreview get firstTrack => tracks.first;
}
