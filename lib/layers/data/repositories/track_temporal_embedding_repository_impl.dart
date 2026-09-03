import 'package:drift/drift.dart';

import '../../domain/entities/music_analysis.dart';
import '../../domain/entities/track_embedding.dart';
import '../../domain/entities/track_temporal_embedding.dart';
import '../../domain/repositories/track_temporal_embedding_repository.dart';
import '../converters/float32_vector_codec.dart';
import '../database/app_database.dart';

class TrackTemporalEmbeddingRepositoryImpl
    implements TrackTemporalEmbeddingRepository {
  TrackTemporalEmbeddingRepositoryImpl(this.database);

  final AppDatabase database;

  @override
  Future<bool> save(TrackTemporalEmbedding embedding) {
    return database.transaction(() async {
      final pipelineRows =
          await (database.select(database.trackTemporalEmbeddingTable)..where(
                (table) =>
                    table.trackId.equals(embedding.trackId) &
                    table.representation.equals(embedding.representation) &
                    table.modelId.equals(embedding.modelId) &
                    table.modelVersion.equals(embedding.modelVersion) &
                    table.preprocessingVersion.equals(
                      embedding.preprocessingVersion,
                    ) &
                    table.provider.equals(embedding.provider.name),
              ))
              .get();
      final newestRevision = pipelineRows.fold<int?>(null, (current, row) {
        return current == null || row.audioRevision > current
            ? row.audioRevision
            : current;
      });
      if (newestRevision != null && newestRevision > embedding.audioRevision) {
        return false;
      }

      for (final row in pipelineRows) {
        if (row.audioRevision < embedding.audioRevision) {
          await (database.delete(
            database.trackTemporalEmbeddingTable,
          )..where((table) => table.id.equals(row.id))).go();
        }
      }

      final existing = pipelineRows
          .where((row) => row.audioRevision == embedding.audioRevision)
          .firstOrNull;
      final persistedId = existing?.id ?? embedding.id;
      await database
          .into(database.trackTemporalEmbeddingTable)
          .insertOnConflictUpdate(
            TrackTemporalEmbeddingTableCompanion.insert(
              id: persistedId,
              trackId: embedding.trackId,
              representation: embedding.representation,
              modelId: embedding.modelId,
              modelVersion: embedding.modelVersion,
              preprocessingVersion: embedding.preprocessingVersion,
              provider: embedding.provider.name,
              audioRevision: embedding.audioRevision,
              dimension: embedding.dimension,
              dtype: embedding.dtype,
              normalized: embedding.normalized,
              createdAt: embedding.createdAt,
              numberOfSegments: embedding.summary.numberOfSegments,
              meanAdjacentDistance: embedding.summary.meanAdjacentDistance,
              maxAdjacentDistance: embedding.summary.maxAdjacentDistance,
              trajectoryVariance: embedding.summary.trajectoryVariance,
              largestTransitionIndex: Value(
                embedding.summary.largestTransitionIndex,
              ),
            ),
          );
      await (database.delete(
        database.trackTemporalEmbeddingSegmentTable,
      )..where((table) => table.temporalEmbeddingId.equals(persistedId))).go();
      await database.batch((batch) {
        batch.insertAll(
          database.trackTemporalEmbeddingSegmentTable,
          embedding.segments
              .map(
                (segment) => TrackTemporalEmbeddingSegmentTableCompanion.insert(
                  temporalEmbeddingId: persistedId,
                  segmentIndex: segment.index,
                  startMs: segment.startMs,
                  endMs: segment.endMs,
                  dimensions: segment.dimensions,
                  vector: Float32VectorCodec.encode(segment.vector),
                ),
              )
              .toList(growable: false),
        );
      });
      return true;
    });
  }

  @override
  Future<TrackTemporalEmbedding?> get({
    required String trackId,
    required String representation,
    required String modelId,
    required String modelVersion,
    required String preprocessingVersion,
    required TrackEmbeddingProvider provider,
    required int audioRevision,
  }) async {
    final row =
        await (database.select(database.trackTemporalEmbeddingTable)..where(
              (table) =>
                  table.trackId.equals(trackId) &
                  table.representation.equals(representation) &
                  table.modelId.equals(modelId) &
                  table.modelVersion.equals(modelVersion) &
                  table.preprocessingVersion.equals(preprocessingVersion) &
                  table.provider.equals(provider.name) &
                  table.audioRevision.equals(audioRevision),
            ))
            .getSingleOrNull();
    return row == null ? null : _load(row);
  }

  @override
  Future<List<TrackTemporalEmbedding>> getBySpace({
    required String representation,
    required String modelId,
    required String modelVersion,
    required String preprocessingVersion,
    required TrackEmbeddingProvider provider,
  }) async {
    final rows =
        await (database.select(database.trackTemporalEmbeddingTable)..where(
              (table) =>
                  table.representation.equals(representation) &
                  table.modelId.equals(modelId) &
                  table.modelVersion.equals(modelVersion) &
                  table.preprocessingVersion.equals(preprocessingVersion) &
                  table.provider.equals(provider.name),
            ))
            .get();
    final result = <TrackTemporalEmbedding>[];
    for (final row in rows) {
      result.add(await _load(row));
    }
    return result;
  }

  Future<TrackTemporalEmbedding> _load(
    TrackTemporalEmbeddingTableData row,
  ) async {
    final segmentRows =
        await (database.select(database.trackTemporalEmbeddingSegmentTable)
              ..where((table) => table.temporalEmbeddingId.equals(row.id))
              ..orderBy([(table) => OrderingTerm.asc(table.segmentIndex)]))
            .get();
    return TrackTemporalEmbedding(
      id: row.id,
      trackId: row.trackId,
      representation: row.representation,
      modelId: row.modelId,
      modelVersion: row.modelVersion,
      preprocessingVersion: row.preprocessingVersion,
      provider: TrackEmbeddingProvider.values.byName(row.provider),
      audioRevision: row.audioRevision,
      dimension: row.dimension,
      dtype: row.dtype,
      normalized: row.normalized,
      createdAt: row.createdAt,
      summary: TemporalAnalysisSummary(
        numberOfSegments: row.numberOfSegments,
        meanAdjacentDistance: row.meanAdjacentDistance,
        maxAdjacentDistance: row.maxAdjacentDistance,
        trajectoryVariance: row.trajectoryVariance,
        largestTransitionIndex: row.largestTransitionIndex,
      ),
      segments: segmentRows
          .map(
            (segment) => TemporalAnalysisSegment(
              index: segment.segmentIndex,
              startMs: segment.startMs,
              endMs: segment.endMs,
              dimensions: segment.dimensions,
              vector: Float32VectorCodec.decode(
                segment.vector,
                dimensions: segment.dimensions,
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}
