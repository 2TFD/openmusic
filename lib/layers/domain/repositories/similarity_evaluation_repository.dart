import '../entities/similarity_evaluation.dart';

abstract interface class SimilarityEvaluationRepository {
  Future<void> save(SimilarityEvaluation evaluation);
  Future<List<SimilarityEvaluation>> getAll();
}
