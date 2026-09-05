part of 'mood_map_cubit.dart';

enum MoodMapStatus { initial, loading, ready, failure }

class MoodMapState extends Equatable {
  const MoodMapState({
    this.status = MoodMapStatus.initial,
    this.tracks = const [],
    this.targetValence,
    this.targetArousal,
    this.radius = 0.35,
    this.selectedTrackId,
    this.error,
  });

  final MoodMapStatus status;
  final List<MoodMapTrack> tracks;
  final double? targetValence;
  final double? targetArousal;
  final double radius;
  final String? selectedTrackId;
  final Object? error;

  MoodMapTrack? get selectedTrack {
    for (final track in tracks) {
      if (track.track.id == selectedTrackId) return track;
    }
    return null;
  }

  Set<String> get tracksInsideRadius {
    final targetV = targetValence;
    final targetA = targetArousal;
    if (targetV == null || targetA == null) return const {};
    return tracks
        .where(
          (track) =>
              track.track.isReadyToPlay &&
              track.track.source.isAvailable &&
              MoodMapGeometry.withinRadius(
                valence: track.valence,
                arousal: track.arousal,
                targetValence: targetV,
                targetArousal: targetA,
                radius: radius,
              ),
        )
        .map((track) => track.track.id)
        .toSet();
  }

  MoodMapState copyWith({
    MoodMapStatus? status,
    List<MoodMapTrack>? tracks,
    Object? targetValence = _unsetMoodMapValue,
    Object? targetArousal = _unsetMoodMapValue,
    double? radius,
    Object? selectedTrackId = _unsetMoodMapValue,
    Object? error = _unsetMoodMapValue,
  }) => MoodMapState(
    status: status ?? this.status,
    tracks: tracks ?? this.tracks,
    targetValence: identical(targetValence, _unsetMoodMapValue)
        ? this.targetValence
        : targetValence as double?,
    targetArousal: identical(targetArousal, _unsetMoodMapValue)
        ? this.targetArousal
        : targetArousal as double?,
    radius: radius ?? this.radius,
    selectedTrackId: identical(selectedTrackId, _unsetMoodMapValue)
        ? this.selectedTrackId
        : selectedTrackId as String?,
    error: identical(error, _unsetMoodMapValue) ? this.error : error,
  );

  @override
  List<Object?> get props => [
    status,
    tracks,
    targetValence,
    targetArousal,
    radius,
    selectedTrackId,
    error,
  ];
}

const _unsetMoodMapValue = Object();
