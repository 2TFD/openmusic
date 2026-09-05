import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/core/services/music_analysis/music_analysis_model_registry.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/repositories/mood_map_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/track_emotion_repository_impl.dart';
import 'package:openmusic/layers/domain/entities/music_analysis.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/track_emotion_analysis.dart';
import 'package:openmusic/layers/domain/repositories/music_analysis_client.dart';
import 'package:openmusic/layers/domain/repositories/track_repository.dart';

void main() {
  late AppDatabase database;
  late TrackEmotionRepositoryImpl emotions;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    emotions = TrackEmotionRepositoryImpl(database);
    await database.customStatement('''
INSERT INTO track_table (
  id, title, path_to_file, source_type, source_uri, audio_revision,
  content_identity
) VALUES ('track-1', 'Track', 'track.mp3', 'localFile', 'track.mp3', 2,
  'sha256:track')
''');
  });

  tearDown(() => database.close());

  test('persists global and temporal emotion data independently', () async {
    await emotions.saveGlobal(_global());
    await emotions.saveTemporal(_temporal());

    final global = await emotions.getGlobal(
      trackId: 'track-1',
      modelId: 'music2emo',
      modelVersion: '1',
      preprocessingVersion: 'pre-1',
      contentRevision: 'sha256:track',
      audioRevision: 2,
    );
    final temporal = await emotions.getTemporal(
      trackId: 'track-1',
      modelId: 'music2emo',
      modelVersion: '1',
      preprocessingVersion: 'pre-1',
      contentRevision: 'sha256:track',
      audioRevision: 2,
    );

    expect(global?.valence, 0.25);
    expect(global?.moodDistribution.scores['bright'], 0.8);
    expect(temporal?.segments.single.arousal, 0.4);
    expect(temporal?.summary.numberOfSegments, 1);
  });

  test('cache lookup requires exact revision, content and pipeline', () async {
    await emotions.saveGlobal(_global());

    Future<Object?> lookup({
      int revision = 2,
      String content = 'sha256:track',
      String version = '1',
      String preprocessing = 'pre-1',
    }) => emotions.getGlobal(
      trackId: 'track-1',
      modelId: 'music2emo',
      modelVersion: version,
      preprocessingVersion: preprocessing,
      contentRevision: content,
      audioRevision: revision,
    );

    expect(await lookup(), isNotNull);
    expect(await lookup(revision: 3), isNull);
    expect(await lookup(content: 'sha256:other'), isNull);
    expect(await lookup(version: '2'), isNull);
    expect(await lookup(preprocessing: 'pre-2'), isNull);
  });

  test('personal position overrides model and reset restores it', () async {
    await emotions.saveGlobal(_global());
    final moodMap = MoodMapRepositoryImpl(
      database: database,
      tracks: _Tracks(_track),
      emotions: emotions,
      registry: MusicAnalysisModelRegistry(_ModelsClient()),
    );

    await moodMap.savePersonalPosition(
      PersonalMoodAdjustment(
        trackId: 'track-1',
        valence: -0.8,
        arousal: 0.7,
        updatedAt: DateTime.utc(2026),
      ),
    );
    var point = (await moodMap.loadTracks()).single;
    expect((point.valence, point.arousal), (-0.8, 0.7));
    expect(point.hasPersonalPosition, isTrue);

    await moodMap.resetPersonalPosition('track-1');
    point = (await moodMap.loadTracks()).single;
    expect((point.valence, point.arousal), (0.25, -0.5));
    expect(point.hasPersonalPosition, isFalse);
  });
}

final _model = MusicAnalysisModel(
  representation: MusicAnalysisRepresentation.audioEmotionGlobal,
  modelId: 'music2emo',
  modelVersion: '1',
  preprocessingVersion: 'pre-1',
);

final _track = Track(
  id: 'track-1',
  contentIdentity: 'sha256:track',
  title: 'Track',
  artists: const [],
  duration: const Duration(minutes: 3),
  source: const Source(type: SourceType.localFile, originalUrl: 'track.mp3'),
  addedAt: DateTime.utc(2026),
  filePath: 'track.mp3',
  audioRevision: 2,
);

TrackEmotionAnalysis _global() => TrackEmotionAnalysis(
  id: 'global',
  trackId: 'track-1',
  representation: MusicAnalysisRepresentation.audioEmotionGlobal.apiName,
  modelId: 'music2emo',
  modelVersion: '1',
  preprocessingVersion: 'pre-1',
  contentRevision: 'sha256:track',
  audioRevision: 2,
  valence: 0.25,
  arousal: -0.5,
  rawValence: 0.5,
  rawArousal: -1,
  moodDistribution: MoodDistribution(const {'bright': 0.8, 'film': 0.7}),
  analyzedAt: DateTime.utc(2026),
);

TrackEmotionTemporalAnalysis _temporal() => TrackEmotionTemporalAnalysis(
  id: 'temporal',
  trackId: 'track-1',
  representation: MusicAnalysisRepresentation.audioEmotionTemporal.apiName,
  modelId: 'music2emo',
  modelVersion: '1',
  preprocessingVersion: 'pre-1',
  contentRevision: 'sha256:track',
  audioRevision: 2,
  summary: AudioEmotionTemporalSummary(numberOfSegments: 1),
  segments: [
    TrackEmotionSegment(
      analysisId: 'temporal',
      index: 0,
      startMs: 0,
      endMs: 1000,
      valence: 0.1,
      arousal: 0.4,
      moodDistribution: MoodDistribution(const {'intense': 0.6}),
    ),
  ],
  analyzedAt: DateTime.utc(2026),
);

class _ModelsClient implements MusicAnalysisClient {
  @override
  String get baseUrl => 'https://analysis.test';

  @override
  Future<MusicAnalysisModels> getModels() async =>
      MusicAnalysisModels(schemaVersion: '2', models: [_model]);

  @override
  Future<MusicAnalysisResponse> analyze({
    required String trackId,
    required String filePath,
    String? contentIdentity,
    String? lyrics,
    required Set<MusicAnalysisRepresentation> requestedRepresentations,
  }) => throw UnimplementedError();
}

class _Tracks implements TrackRepository {
  _Tracks(this.track);
  final Track track;

  @override
  Future<Track?> getTrackById(String id) async => id == track.id ? track : null;
  @override
  Future<List<Track>> getTracks() async => [track];
  @override
  Future<List<Track>> getTracksByIds(List<String> ids) async =>
      ids.contains(track.id) ? [track] : [];
  @override
  Future<List<Track>> searchTracks(
    String query, {
    required int limit,
    required int offset,
  }) async => [track];
  @override
  Future<void> updateMetadata(Track track) async {}
  @override
  Stream<void> watchChanges() => const Stream.empty();
}
