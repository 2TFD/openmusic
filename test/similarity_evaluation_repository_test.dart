import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/repositories/similarity_evaluation_repository_impl.dart';
import 'package:openmusic/layers/domain/entities/similarity_evaluation.dart';

void main() {
  late AppDatabase database;
  late SimilarityEvaluationRepositoryImpl repository;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = SimilarityEvaluationRepositoryImpl(database);
    for (final id in ['seed', 'candidate']) {
      await database
          .into(database.trackTable)
          .insert(
            TrackTableCompanion.insert(
              id: id,
              title: id,
              sourceType: 'localFile',
              sourceUri: '/$id.mp3',
            ),
          );
    }
  });

  tearDown(() => database.close());

  test('save updates the rating for the same versioned experiment', () async {
    await repository.save(_evaluation(id: 'first', sound: 1));
    await repository.save(_evaluation(id: 'second', sound: 3));

    final values = await repository.getAll();
    expect(values, hasLength(1));
    expect(values.single.id, 'first');
    expect(values.single.soundRating, 3);
  });

  test('different method and model versions coexist', () async {
    await repository.save(_evaluation(id: 'global'));
    await repository.save(
      _evaluation(id: 'dtw', method: ResearchSimilarityMethod.temporalDtw),
    );
    await repository.save(_evaluation(id: 'model-2', modelVersion: '2'));

    expect(await repository.getAll(), hasLength(3));
  });
}

SimilarityEvaluation _evaluation({
  required String id,
  int sound = 2,
  ResearchSimilarityMethod method = ResearchSimilarityMethod.audioGlobal,
  String modelVersion = '1',
}) => SimilarityEvaluation(
  id: id,
  seedTrackId: 'seed',
  candidateTrackId: 'candidate',
  method: method,
  sourceRepresentationModelId: 'model',
  sourceRepresentationModelVersion: modelVersion,
  sourcePreprocessingVersion: 'pre-1',
  scoreShown: 0.8,
  soundRating: sound,
  atmosphereRating: 2,
  trajectoryRating: 1,
  wouldListenNext: true,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026, 2),
);
