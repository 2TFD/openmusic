import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';

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

  TrackPreview get firstTrack => tracks.first;
}
