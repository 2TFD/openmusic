import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/domain/entities/mood_map.dart';
import 'package:openmusic/layers/domain/entities/music_analysis.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/track_emotion_analysis.dart';
import 'package:openmusic/layers/domain/repositories/mood_map_repository.dart';
import 'package:openmusic/layers/presentation/blocs/mood_map/mood_map_cubit.dart';

void main() {
  test('personal save/reset and radius selection stay independent', () async {
    final repository = _MoodMapRepository([_point]);
    final cubit = MoodMapCubit(repository: repository);
    addTearDown(cubit.close);
    await cubit.initialize();

    expect(cubit.state.status, MoodMapStatus.ready);
    expect(cubit.state.tracks.single.valence, 0.2);

    await cubit.savePersonalPosition('track', -0.4, 0.6);
    expect(repository.saved?.valence, -0.4);
    expect(cubit.state.tracks.single.hasPersonalPosition, isTrue);

    cubit.setTarget(-0.4, 0.6);
    cubit.setRadius(0.1);
    expect(cubit.state.tracksInsideRadius, {'track'});

    await cubit.resetPersonalPosition('track');
    expect(repository.resetTrackId, 'track');
    expect(cubit.state.tracks.single.valence, 0.2);
    expect(cubit.state.tracks.single.hasPersonalPosition, isFalse);
    expect(cubit.state.tracksInsideRadius, isEmpty);
  });

  test('matching count includes only playable and available tracks', () async {
    final repository = _MoodMapRepository([
      _point,
      _pointFor(
        Track(
          id: 'unavailable',
          title: 'Unavailable',
          artists: const [],
          duration: const Duration(minutes: 3),
          source: const Source(
            type: SourceType.localFile,
            originalUrl: 'unavailable.mp3',
            isAvailable: false,
          ),
          addedAt: DateTime.utc(2026),
          filePath: 'unavailable.mp3',
        ),
      ),
      _pointFor(
        Track(
          id: 'unplayable',
          title: 'Unplayable',
          artists: const [],
          duration: const Duration(minutes: 3),
          source: const Source(
            type: SourceType.localFile,
            originalUrl: 'unplayable.mp3',
          ),
          addedAt: DateTime.utc(2026),
        ),
      ),
    ]);
    final cubit = MoodMapCubit(repository: repository);
    addTearDown(cubit.close);
    await cubit.initialize();

    cubit.setTarget(_point.valence, _point.arousal);

    expect(cubit.state.tracksInsideRadius, {_point.track.id});
  });
}

final _track = Track(
  id: 'track',
  title: 'Track',
  artists: const [],
  duration: const Duration(minutes: 3),
  source: const Source(type: SourceType.localFile, originalUrl: 'track.mp3'),
  addedAt: DateTime.utc(2026),
  filePath: 'track.mp3',
);

final _point = MoodMapTrack(
  track: _track,
  modelAnalysis: TrackEmotionAnalysis(
    id: 'analysis',
    trackId: 'track',
    representation: MusicAnalysisRepresentation.audioEmotionGlobal.apiName,
    modelId: 'music2emo',
    modelVersion: '1',
    preprocessingVersion: 'pre',
    contentRevision: 'audio:0',
    audioRevision: 0,
    valence: 0.2,
    arousal: -0.1,
    moodDistribution: MoodDistribution(const {'calm': 0.8}),
    analyzedAt: DateTime.utc(2026),
  ),
);

MoodMapTrack _pointFor(Track track) => MoodMapTrack(
  track: track,
  modelAnalysis: TrackEmotionAnalysis(
    id: 'analysis-${track.id}',
    trackId: track.id,
    representation: MusicAnalysisRepresentation.audioEmotionGlobal.apiName,
    modelId: 'music2emo',
    modelVersion: '1',
    preprocessingVersion: 'pre',
    contentRevision: 'audio:0',
    audioRevision: 0,
    valence: 0.2,
    arousal: -0.1,
    moodDistribution: MoodDistribution(const {'calm': 0.8}),
    analyzedAt: DateTime.utc(2026),
  ),
);

class _MoodMapRepository implements MoodMapRepository {
  _MoodMapRepository(this.points);
  List<MoodMapTrack> points;
  PersonalMoodAdjustment? saved;
  String? resetTrackId;

  @override
  Future<List<MoodMapTrack>> loadTracks() async => points;
  @override
  Stream<void> watchChanges() => const Stream.empty();
  @override
  Future<void> savePersonalPosition(PersonalMoodAdjustment adjustment) async {
    saved = adjustment;
  }

  @override
  Future<void> resetPersonalPosition(String trackId) async {
    resetTrackId = trackId;
  }
}
