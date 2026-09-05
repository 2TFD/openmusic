import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/core/services/music_analysis/music_analysis_model_registry.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/repositories/music_analysis_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/track_embedding_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/track_emotion_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/track_temporal_embedding_repository_impl.dart';
import 'package:openmusic/layers/domain/entities/music_analysis.dart';
import 'package:openmusic/layers/domain/entities/music_analysis_failure.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/track_embedding.dart';
import 'package:openmusic/layers/domain/repositories/music_analysis_client.dart';
import 'package:openmusic/layers/domain/repositories/track_repository.dart';

void main() {
  test(
    'emotion failure preserves core analysis and retries only emotion',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      await database.customStatement('''
INSERT INTO track_table (
  id, title, path_to_file, source_type, source_uri, audio_revision,
  content_identity
) VALUES ('track', 'Track', 'track.mp3', 'localFile', 'track.mp3', 4, 'sha:x')
''');
      final client = _PartialClient();
      final globals = TrackEmbeddingRepositoryImpl(database);
      final temporals = TrackTemporalEmbeddingRepositoryImpl(database);
      final emotions = TrackEmotionRepositoryImpl(database);
      final repository = MusicAnalysisRepositoryImpl(
        tracks: _Tracks(_track),
        globalEmbeddings: globals,
        temporalEmbeddings: temporals,
        emotions: emotions,
        client: client,
        registry: MusicAnalysisModelRegistry(client),
      );

      await expectLater(
        repository.analyzeTrack(
          trackId: 'track',
          audioRevision: 4,
          representations: QueueRepresentations.all,
        ),
        throwsA(isA<MusicAnalysisFailure>()),
      );
      expect(client.calls.first, QueueRepresentations.core);
      expect(client.calls.last, QueueRepresentations.emotion);
      expect(
        await globals.get(
          trackId: 'track',
          modality: TrackEmbeddingModality.audio,
          modelId: 'clap',
          modelVersion: '1',
          preprocessingVersion: 'core-global',
          provider: TrackEmbeddingProvider.server,
        ),
        isNotNull,
      );
      expect(
        await repository.missingRepresentations(
          trackId: 'track',
          audioRevision: 4,
          representations: QueueRepresentations.all,
        ),
        QueueRepresentations.emotion,
      );

      client.failEmotion = false;
      await repository.analyzeTrack(
        trackId: 'track',
        audioRevision: 4,
        representations: QueueRepresentations.all,
      );
      expect(client.calls.last, QueueRepresentations.emotion);
      expect(
        await emotions.getGlobal(
          trackId: 'track',
          modelId: 'music2emo',
          modelVersion: '1',
          preprocessingVersion: 'emotion-pre',
          contentRevision: 'sha:x',
          audioRevision: 4,
        ),
        isNotNull,
      );
    },
  );
}

abstract final class QueueRepresentations {
  static const core = {
    MusicAnalysisRepresentation.audioGlobal,
    MusicAnalysisRepresentation.audioTemporal,
  };
  static const emotion = {
    MusicAnalysisRepresentation.audioEmotionGlobal,
    MusicAnalysisRepresentation.audioEmotionTemporal,
  };
  static const all = {...core, ...emotion};
}

final _audioGlobal = MusicAnalysisModel(
  representation: MusicAnalysisRepresentation.audioGlobal,
  modelId: 'clap',
  modelVersion: '1',
  preprocessingVersion: 'core-global',
  dimension: 2,
  dtype: 'float32',
  normalized: true,
);
final _audioTemporal = MusicAnalysisModel(
  representation: MusicAnalysisRepresentation.audioTemporal,
  modelId: 'clap',
  modelVersion: '1',
  preprocessingVersion: 'core-temporal',
  dimension: 2,
  dtype: 'float32',
  normalized: true,
);
final _emotionGlobal = MusicAnalysisModel(
  representation: MusicAnalysisRepresentation.audioEmotionGlobal,
  modelId: 'music2emo',
  modelVersion: '1',
  preprocessingVersion: 'emotion-pre',
);
final _emotionTemporal = MusicAnalysisModel(
  representation: MusicAnalysisRepresentation.audioEmotionTemporal,
  modelId: 'music2emo',
  modelVersion: '1',
  preprocessingVersion: 'emotion-pre',
);

class _PartialClient implements MusicAnalysisClient {
  bool failEmotion = true;
  final calls = <Set<MusicAnalysisRepresentation>>[];

  @override
  String get baseUrl => 'https://analysis.test';

  @override
  Future<MusicAnalysisModels> getModels() async => MusicAnalysisModels(
    schemaVersion: '2',
    models: [_audioGlobal, _audioTemporal, _emotionGlobal, _emotionTemporal],
  );

  @override
  Future<MusicAnalysisResponse> analyze({
    required String trackId,
    required String filePath,
    String? contentIdentity,
    String? lyrics,
    required Set<MusicAnalysisRepresentation> requestedRepresentations,
  }) async {
    calls.add(Set.unmodifiable(requestedRepresentations));
    if (requestedRepresentations.any((entry) => entry.isEmotion) &&
        failEmotion) {
      throw const MusicAnalysisFailure(
        MusicAnalysisFailureKind.server,
        retryable: true,
      );
    }
    return MusicAnalysisResponse(
      schemaVersion: '2',
      trackId: trackId,
      contentIdentity: contentIdentity,
      audioGlobal:
          requestedRepresentations.contains(
            MusicAnalysisRepresentation.audioGlobal,
          )
          ? GlobalAnalysisRepresentation(
              metadata: _audioGlobal,
              vector: const [1, 0],
            )
          : null,
      audioTemporal:
          requestedRepresentations.contains(
            MusicAnalysisRepresentation.audioTemporal,
          )
          ? TemporalAnalysisRepresentation(
              metadata: _audioTemporal,
              segments: [
                TemporalAnalysisSegment(
                  index: 0,
                  startMs: 0,
                  endMs: 1000,
                  dimensions: 2,
                  vector: const [1, 0],
                ),
              ],
              summary: const TemporalAnalysisSummary(
                numberOfSegments: 1,
                meanAdjacentDistance: 0,
                maxAdjacentDistance: 0,
                trajectoryVariance: 0,
              ),
            )
          : null,
      audioEmotionGlobal:
          requestedRepresentations.contains(
            MusicAnalysisRepresentation.audioEmotionGlobal,
          )
          ? AudioEmotionGlobalResult(
              metadata: _emotionGlobal,
              valence: 0.2,
              arousal: 0.3,
              moodDistribution: MoodDistribution(const {'calm': 0.7}),
            )
          : null,
      audioEmotionTemporal:
          requestedRepresentations.contains(
            MusicAnalysisRepresentation.audioEmotionTemporal,
          )
          ? AudioEmotionTemporalResult(
              metadata: _emotionTemporal,
              segments: [
                AudioEmotionSegment(
                  index: 0,
                  startMs: 0,
                  endMs: 1000,
                  valence: 0.2,
                  arousal: 0.3,
                  moodDistribution: MoodDistribution(const {'calm': 0.7}),
                ),
              ],
              summary: AudioEmotionTemporalSummary(numberOfSegments: 1),
            )
          : null,
    );
  }
}

final _track = Track(
  id: 'track',
  contentIdentity: 'sha:x',
  title: 'Track',
  artists: const [],
  duration: const Duration(minutes: 2),
  source: const Source(type: SourceType.localFile, originalUrl: 'track.mp3'),
  addedAt: DateTime.utc(2026),
  filePath: 'track.mp3',
  audioRevision: 4,
);

class _Tracks implements TrackRepository {
  _Tracks(this.track);
  final Track track;
  @override
  Future<Track?> getTrackById(String id) async => id == track.id ? track : null;
  @override
  Future<List<Track>> getTracks() async => [track];
  @override
  Future<List<Track>> getTracksByIds(List<String> ids) async => [track];
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
