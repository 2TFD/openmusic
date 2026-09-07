import 'package:equatable/equatable.dart';

import 'track.dart';

enum MoodWaveMode { stay, explore, lift, calm }

enum WaveSourceType { mood, track, artist }

class MoodPoint extends Equatable {
  factory MoodPoint({required double valence, required double arousal}) {
    if (!_isMoodCoordinate(valence) || !_isMoodCoordinate(arousal)) {
      throw ArgumentError('Mood coordinates must be finite and inside [-1, 1]');
    }
    return MoodPoint._(valence: valence, arousal: arousal);
  }

  const MoodPoint._({required this.valence, required this.arousal});

  final double valence;
  final double arousal;

  static bool _isMoodCoordinate(double value) =>
      value.isFinite && value >= -1 && value <= 1;

  @override
  List<Object> get props => [valence, arousal];
}

sealed class WaveSource extends Equatable {
  const WaveSource();

  WaveSourceType get type;
  String? get displayTitle;
  String? get imageUrl;
}

class MoodWaveSource extends WaveSource {
  MoodWaveSource({
    required this.userTarget,
    MoodPoint? effectiveTarget,
    required double radius,
    required this.mode,
  }) : effectiveTarget = effectiveTarget ?? userTarget,
       radius = _checkedRadius(radius);

  final MoodPoint userTarget;
  final MoodPoint effectiveTarget;
  final double radius;
  final MoodWaveMode mode;

  @override
  WaveSourceType get type => WaveSourceType.mood;

  @override
  String? get displayTitle => null;

  @override
  String? get imageUrl => null;

  MoodWaveSource copyWith({
    MoodPoint? userTarget,
    MoodPoint? effectiveTarget,
    double? radius,
    MoodWaveMode? mode,
  }) => MoodWaveSource(
    userTarget: userTarget ?? this.userTarget,
    effectiveTarget: effectiveTarget ?? this.effectiveTarget,
    radius: radius ?? this.radius,
    mode: mode ?? this.mode,
  );

  static double _checkedRadius(double radius) {
    if (!radius.isFinite || radius <= 0) {
      throw ArgumentError.value(radius, 'radius', 'must be positive');
    }
    return radius;
  }

  @override
  List<Object> get props => [userTarget, effectiveTarget, radius, mode];
}

class TrackWaveSource extends WaveSource {
  const TrackWaveSource({
    required this.trackId,
    this.trackTitle,
    this.imageUrl,
    this.seedAudioRevision,
  });

  final String trackId;
  final String? trackTitle;
  @override
  final String? imageUrl;
  final int? seedAudioRevision;

  @override
  WaveSourceType get type => WaveSourceType.track;

  @override
  String? get displayTitle => trackTitle;

  @override
  List<Object?> get props => [trackId, trackTitle, imageUrl, seedAudioRevision];
}

class ArtistWaveSource extends WaveSource {
  ArtistWaveSource({
    required this.artistId,
    this.artistName,
    this.imageUrl,
    List<String> globalProfileTrackIds = const [],
    List<String> representativeTrackIds = const [],
  }) : globalProfileTrackIds = List.unmodifiable(
         _unique(globalProfileTrackIds),
       ),
       representativeTrackIds = List.unmodifiable(
         _unique(representativeTrackIds),
       );

  final String artistId;
  final String? artistName;
  @override
  final String? imageUrl;
  final List<String> globalProfileTrackIds;
  final List<String> representativeTrackIds;

  @override
  WaveSourceType get type => WaveSourceType.artist;

  @override
  String? get displayTitle => artistName;

  ArtistWaveSource copyWith({
    List<String>? globalProfileTrackIds,
    List<String>? representativeTrackIds,
  }) => ArtistWaveSource(
    artistId: artistId,
    artistName: artistName,
    imageUrl: imageUrl,
    globalProfileTrackIds: globalProfileTrackIds ?? this.globalProfileTrackIds,
    representativeTrackIds:
        representativeTrackIds ?? this.representativeTrackIds,
  );

  @override
  List<Object?> get props => [
    artistId,
    artistName,
    imageUrl,
    globalProfileTrackIds,
    representativeTrackIds,
  ];
}

class WaveSession extends Equatable {
  factory WaveSession({
    required double targetValence,
    required double targetArousal,
    required double radius,
    required MoodWaveMode mode,
    required DateTime startedAt,
    String? seedTrackId,
    int? seedAudioRevision,
    List<String> recentTrackIds = const [],
  }) => WaveSession.startMood(
    targetValence: targetValence,
    targetArousal: targetArousal,
    radius: radius,
    mode: mode,
    startedAt: startedAt,
    seedTrackId: seedTrackId,
    seedAudioRevision: seedAudioRevision,
    recentTrackIds: recentTrackIds,
  );

  factory WaveSession.start({
    required double targetValence,
    required double targetArousal,
    required double radius,
    required MoodWaveMode mode,
    DateTime? startedAt,
    String? seedTrackId,
    int? seedAudioRevision,
    List<String> recentTrackIds = const [],
  }) => WaveSession.startMood(
    targetValence: targetValence,
    targetArousal: targetArousal,
    radius: radius,
    mode: mode,
    startedAt: startedAt,
    seedTrackId: seedTrackId,
    seedAudioRevision: seedAudioRevision,
    recentTrackIds: recentTrackIds,
  );

  factory WaveSession.startMood({
    required double targetValence,
    required double targetArousal,
    required double radius,
    required MoodWaveMode mode,
    DateTime? startedAt,
    String? seedTrackId,
    int? seedAudioRevision,
    List<String> recentTrackIds = const [],
    String? id,
  }) {
    _validateRevision(seedAudioRevision);
    final target = MoodPoint(valence: targetValence, arousal: targetArousal);
    final start = startedAt ?? DateTime.now();
    final recent = _unique(recentTrackIds);
    return WaveSession._(
      id: id ?? _newId(WaveSourceType.mood, start),
      source: MoodWaveSource(userTarget: target, radius: radius, mode: mode),
      startedAt: start,
      seedTrackId: seedTrackId,
      seedAudioRevision: seedAudioRevision,
      recentTrackIds: recent,
      profileTrackIds: recent,
      cycleTrackIds: const {},
      generationCount: 0,
    );
  }

  factory WaveSession.startTrack({
    required String trackId,
    String? trackTitle,
    String? imageUrl,
    int? seedAudioRevision,
    DateTime? startedAt,
    String? id,
  }) {
    if (trackId.trim().isEmpty) throw ArgumentError.value(trackId, 'trackId');
    _validateRevision(seedAudioRevision);
    final start = startedAt ?? DateTime.now();
    return WaveSession._(
      id: id ?? _newId(WaveSourceType.track, start),
      source: TrackWaveSource(
        trackId: trackId,
        trackTitle: trackTitle,
        imageUrl: imageUrl,
        seedAudioRevision: seedAudioRevision,
      ),
      startedAt: start,
      seedTrackId: trackId,
      seedAudioRevision: seedAudioRevision,
      recentTrackIds: const [],
      profileTrackIds: const [],
      cycleTrackIds: const {},
      generationCount: 0,
    );
  }

  factory WaveSession.startArtist({
    required String artistId,
    String? artistName,
    String? imageUrl,
    DateTime? startedAt,
    String? id,
  }) {
    if (artistId.trim().isEmpty) {
      throw ArgumentError.value(artistId, 'artistId');
    }
    final start = startedAt ?? DateTime.now();
    return WaveSession._(
      id: id ?? _newId(WaveSourceType.artist, start),
      source: ArtistWaveSource(
        artistId: artistId,
        artistName: artistName,
        imageUrl: imageUrl,
      ),
      startedAt: start,
      seedTrackId: null,
      seedAudioRevision: null,
      recentTrackIds: const [],
      profileTrackIds: const [],
      cycleTrackIds: const {},
      generationCount: 0,
    );
  }

  WaveSession._({
    required this.id,
    required this.source,
    required this.startedAt,
    required this.seedTrackId,
    required this.seedAudioRevision,
    required List<String> recentTrackIds,
    required List<String> profileTrackIds,
    required Set<String> cycleTrackIds,
    required this.generationCount,
  }) : recentTrackIds = List.unmodifiable(recentTrackIds),
       profileTrackIds = List.unmodifiable(profileTrackIds),
       cycleTrackIds = Set.unmodifiable(cycleTrackIds);

  final String id;
  final WaveSource source;
  final DateTime startedAt;
  final String? seedTrackId;
  final int? seedAudioRevision;
  final List<String> recentTrackIds;
  final List<String> profileTrackIds;

  /// Tracks already selected in the current library cycle.
  ///
  /// Unlike the former lifetime generated set, this is cleared when the
  /// recommendation pool is exhausted so a Wave can continue indefinitely.
  final Set<String> cycleTrackIds;

  @Deprecated('Use cycleTrackIds; generated tracks are no longer permanent')
  Set<String> get generatedTrackIds => cycleTrackIds;
  final int generationCount;

  MoodWaveSource get moodSource {
    final value = source;
    if (value is! MoodWaveSource) {
      throw StateError('The active Wave source is not Mood');
    }
    return value;
  }

  MoodPoint get userTarget => moodSource.userTarget;
  MoodPoint get effectiveTarget => moodSource.effectiveTarget;
  double get radius => moodSource.radius;
  MoodWaveMode get mode => moodSource.mode;
  double get targetValence => userTarget.valence;
  double get targetArousal => userTarget.arousal;

  WaveSession recordPlayed(
    String trackId, {
    bool skipped = false,
    int contextSize = 3,
    int? cooldownSize,
  }) {
    final recentLimit = cooldownSize ?? contextSize;
    if (trackId.isEmpty || contextSize <= 0 || recentLimit <= 0) return this;
    final recent = _appendRecent(recentTrackIds, trackId, recentLimit);
    final profile = skipped
        ? profileTrackIds.where((id) => id != trackId).toList(growable: false)
        : _appendRecent(profileTrackIds, trackId, contextSize);
    return copyWith(recentTrackIds: recent, profileTrackIds: profile);
  }

  WaveSession withSource(WaveSource source) => copyWith(source: source);

  WaveSession updateMoodSettings({
    MoodPoint? userTarget,
    double? radius,
    MoodWaveMode? mode,
  }) {
    final mood = moodSource;
    return withSource(
      mood.copyWith(
        userTarget: userTarget,
        effectiveTarget: userTarget,
        radius: radius,
        mode: mode,
      ),
    );
  }

  WaveSession copyWith({
    WaveSource? source,
    MoodPoint? userTarget,
    MoodPoint? effectiveTarget,
    double? radius,
    MoodWaveMode? mode,
    List<String>? recentTrackIds,
    List<String>? profileTrackIds,
    Set<String>? cycleTrackIds,
    int? generationCount,
  }) {
    var nextSource = source ?? this.source;
    if (userTarget != null ||
        effectiveTarget != null ||
        radius != null ||
        mode != null) {
      if (nextSource is! MoodWaveSource) {
        throw StateError('Mood settings require a Mood Wave source');
      }
      nextSource = nextSource.copyWith(
        userTarget: userTarget,
        effectiveTarget: effectiveTarget,
        radius: radius,
        mode: mode,
      );
    }
    return WaveSession._(
      id: id,
      source: nextSource,
      startedAt: startedAt,
      seedTrackId: seedTrackId,
      seedAudioRevision: seedAudioRevision,
      recentTrackIds: recentTrackIds ?? this.recentTrackIds,
      profileTrackIds: profileTrackIds ?? this.profileTrackIds,
      cycleTrackIds: cycleTrackIds ?? this.cycleTrackIds,
      generationCount: generationCount ?? this.generationCount,
    );
  }

  WaveSession withGeneratedTracks(
    Iterable<String> trackIds, {
    MoodPoint? effectiveTarget,
  }) {
    final ids = trackIds.where((id) => id.isNotEmpty).toSet();
    final nextSource = switch ((source, effectiveTarget)) {
      (final MoodWaveSource mood, final MoodPoint target) => mood.copyWith(
        effectiveTarget: target,
      ),
      _ => source,
    };
    return copyWith(
      source: nextSource,
      cycleTrackIds: {...cycleTrackIds, ...ids},
      generationCount: ids.isEmpty ? generationCount : generationCount + 1,
    );
  }

  WaveSession beginNewCycle() => copyWith(cycleTrackIds: const {});

  static List<String> _appendRecent(
    List<String> values,
    String trackId,
    int limit,
  ) {
    final updated = [...values.where((id) => id != trackId), trackId];
    return updated.length <= limit
        ? updated
        : updated.sublist(updated.length - limit);
  }

  static void _validateRevision(int? revision) {
    if (revision != null && revision < 0) {
      throw ArgumentError.value(
        revision,
        'seedAudioRevision',
        'must not be negative',
      );
    }
  }

  static String _newId(WaveSourceType type, DateTime startedAt) =>
      'wave-${type.name}-${startedAt.microsecondsSinceEpoch}';

  @override
  List<Object?> get props => [
    id,
    source,
    startedAt,
    seedTrackId,
    seedAudioRevision,
    recentTrackIds,
    profileTrackIds,
    cycleTrackIds,
    generationCount,
  ];
}

typedef MoodWaveSession = WaveSession;

class WaveCandidate extends Equatable {
  const WaveCandidate({
    required this.track,
    required this.finalScore,
    this.globalCosineSimilarity,
    this.globalSimilarity,
    this.temporalSimilarity,
    required this.availableWeight,
  });

  final Track track;
  final double finalScore;
  final double? globalCosineSimilarity;
  final double? globalSimilarity;
  final double? temporalSimilarity;
  final double availableWeight;

  @override
  List<Object?> get props => [
    track,
    finalScore,
    globalCosineSimilarity,
    globalSimilarity,
    temporalSimilarity,
    availableWeight,
  ];
}

class MoodWaveCandidate extends WaveCandidate {
  const MoodWaveCandidate({
    required super.track,
    required this.position,
    required this.distance,
    required this.moodProximity,
    required super.globalCosineSimilarity,
    required super.globalSimilarity,
    required super.temporalSimilarity,
    required super.finalScore,
    required super.availableWeight,
    required this.withinRequestedRadius,
  });

  final MoodPoint position;
  final double distance;
  final double moodProximity;
  final bool withinRequestedRadius;

  @override
  List<Object?> get props => [
    ...super.props,
    position,
    distance,
    moodProximity,
    withinRequestedRadius,
  ];
}

class WaveRecommendationBatch extends Equatable {
  WaveRecommendationBatch({
    required List<WaveCandidate> candidates,
    required this.session,
  }) : candidates = List.unmodifiable(candidates);

  final List<WaveCandidate> candidates;
  final WaveSession session;

  List<Track> get tracks =>
      candidates.map((candidate) => candidate.track).toList(growable: false);

  bool get isEmpty => candidates.isEmpty;

  @override
  List<Object> get props => [candidates, session];
}

class MoodWaveBatch extends WaveRecommendationBatch {
  MoodWaveBatch({
    required List<MoodWaveCandidate> candidates,
    required super.session,
    required this.effectiveRadius,
    required this.eligibleTrackCount,
  }) : super(candidates: candidates);

  @override
  List<MoodWaveCandidate> get candidates =>
      super.candidates.cast<MoodWaveCandidate>();

  final double effectiveRadius;
  final int eligibleTrackCount;

  @override
  List<Object> get props => [
    ...super.props,
    effectiveRadius,
    eligibleTrackCount,
  ];
}

List<String> _unique(Iterable<String> values) {
  final result = <String>[];
  for (final value in values) {
    if (value.isNotEmpty && !result.contains(value)) result.add(value);
  }
  return result;
}
