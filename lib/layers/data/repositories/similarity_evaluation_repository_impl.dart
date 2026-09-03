import 'package:drift/drift.dart';

import '../../domain/entities/similarity_evaluation.dart';
import '../../domain/repositories/similarity_evaluation_repository.dart';
import '../database/app_database.dart';

class SimilarityEvaluationRepositoryImpl
    implements SimilarityEvaluationRepository {
  SimilarityEvaluationRepositoryImpl(this.database);

  final AppDatabase database;

  @override
  Future<void> save(SimilarityEvaluation evaluation) {
    return database.transaction(() async {
      final existing =
          await (database.select(database.similarityEvaluationTable)..where(
                (table) =>
                    table.seedTrackId.equals(evaluation.seedTrackId) &
                    table.candidateTrackId.equals(evaluation.candidateTrackId) &
                    table.methodVersion.equals(evaluation.method.version) &
                    table.sourceRepresentationModelId.equals(
                      evaluation.sourceRepresentationModelId,
                    ) &
                    table.sourceRepresentationModelVersion.equals(
                      evaluation.sourceRepresentationModelVersion,
                    ) &
                    table.sourcePreprocessingVersion.equals(
                      evaluation.sourcePreprocessingVersion,
                    ),
              ))
              .getSingleOrNull();
      await database
          .into(database.similarityEvaluationTable)
          .insertOnConflictUpdate(
            SimilarityEvaluationTableCompanion.insert(
              id: existing?.id ?? evaluation.id,
              seedTrackId: evaluation.seedTrackId,
              candidateTrackId: evaluation.candidateTrackId,
              methodVersion: evaluation.method.version,
              sourceRepresentationModelId:
                  evaluation.sourceRepresentationModelId,
              sourceRepresentationModelVersion:
                  evaluation.sourceRepresentationModelVersion,
              sourcePreprocessingVersion: evaluation.sourcePreprocessingVersion,
              scoreShown: evaluation.scoreShown,
              rawDistance: Value(evaluation.rawDistance),
              soundRating: Value(evaluation.soundRating),
              atmosphereRating: Value(evaluation.atmosphereRating),
              trajectoryRating: Value(evaluation.trajectoryRating),
              wouldListenNext: Value(evaluation.wouldListenNext),
              createdAt: existing?.createdAt ?? evaluation.createdAt,
              updatedAt: evaluation.updatedAt,
            ),
          );
    });
  }

  @override
  Future<List<SimilarityEvaluation>> getAll() async {
    final rows = await (database.select(
      database.similarityEvaluationTable,
    )..orderBy([(table) => OrderingTerm.asc(table.createdAt)])).get();
    return rows
        .map(
          (row) => SimilarityEvaluation(
            id: row.id,
            seedTrackId: row.seedTrackId,
            candidateTrackId: row.candidateTrackId,
            method: ResearchSimilarityMethod.values.firstWhere(
              (method) => method.version == row.methodVersion,
            ),
            sourceRepresentationModelId: row.sourceRepresentationModelId,
            sourceRepresentationModelVersion:
                row.sourceRepresentationModelVersion,
            sourcePreprocessingVersion: row.sourcePreprocessingVersion,
            scoreShown: row.scoreShown,
            rawDistance: row.rawDistance,
            soundRating: row.soundRating,
            atmosphereRating: row.atmosphereRating,
            trajectoryRating: row.trajectoryRating,
            wouldListenNext: row.wouldListenNext,
            createdAt: row.createdAt,
            updatedAt: row.updatedAt,
          ),
        )
        .toList(growable: false);
  }
}
