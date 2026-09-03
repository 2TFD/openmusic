import 'package:drift/drift.dart';

import '../../domain/entities/track_embedding.dart';
import '../../domain/repositories/track_embedding_repository.dart';
import '../converters/float32_vector_codec.dart';
import '../database/app_database.dart';

class TrackEmbeddingRepositoryImpl implements TrackEmbeddingRepository {
  TrackEmbeddingRepositoryImpl(this.database);

  final AppDatabase database;

  @override
  Future<void> save(TrackEmbedding embedding) async {
    await database.customUpdate(
      '''
INSERT INTO track_embedding_table (
  track_id, modality, model_id, model_version, preprocessing_version, provider,
  audio_revision, content_revision, dtype, normalized, dimensions, vector,
  created_at
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
ON CONFLICT(
  track_id, modality, model_id, model_version, preprocessing_version, provider
)
DO UPDATE SET
  audio_revision = excluded.audio_revision,
  content_revision = excluded.content_revision,
  dtype = excluded.dtype,
  normalized = excluded.normalized,
  dimensions = excluded.dimensions,
  vector = excluded.vector,
  created_at = excluded.created_at
WHERE (
       excluded.modality = 'lyrics'
       AND excluded.audio_revision IS NULL
       AND excluded.content_revision IS NOT NULL
      )
   OR (
       excluded.modality != 'lyrics'
       AND (
         track_embedding_table.audio_revision IS NULL
         OR (
           excluded.audio_revision IS NOT NULL
           AND excluded.audio_revision >= track_embedding_table.audio_revision
         )
       )
      )
''',
      variables: [
        Variable<String>(embedding.trackId),
        Variable<String>(embedding.modality.name),
        Variable<String>(embedding.modelId),
        Variable<String>(embedding.modelVersion),
        Variable<String>(embedding.preprocessingVersion),
        Variable<String>(embedding.provider.name),
        Variable<int>(embedding.audioRevision),
        Variable<String>(embedding.contentRevision),
        Variable<String>(embedding.dtype),
        Variable<bool>(embedding.normalized),
        Variable<int>(embedding.dimensions),
        Variable<Uint8List>(Float32VectorCodec.encode(embedding.vector)),
        Variable<DateTime>(embedding.createdAt),
      ],
      updates: {database.trackEmbeddingTable},
    );
  }

  @override
  Future<TrackEmbedding?> get({
    required String trackId,
    required TrackEmbeddingModality modality,
    required String modelId,
    required String modelVersion,
    required TrackEmbeddingProvider provider,
    String preprocessingVersion = TrackEmbedding.legacyPreprocessingVersion,
    String? contentRevision,
  }) async {
    final row =
        await (database.select(database.trackEmbeddingTable)..where(
              (table) =>
                  table.trackId.equals(trackId) &
                  table.modality.equals(modality.name) &
                  table.modelId.equals(modelId) &
                  table.modelVersion.equals(modelVersion) &
                  table.preprocessingVersion.equals(preprocessingVersion) &
                  table.provider.equals(provider.name) &
                  (contentRevision == null
                      ? const Constant(true)
                      : table.contentRevision.equals(contentRevision)),
            ))
            .getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<List<TrackEmbedding>> getBySpace({
    required TrackEmbeddingModality modality,
    required String modelId,
    required String modelVersion,
    required String preprocessingVersion,
    required TrackEmbeddingProvider provider,
  }) async {
    final rows =
        await (database.select(database.trackEmbeddingTable)..where(
              (table) =>
                  table.modality.equals(modality.name) &
                  table.modelId.equals(modelId) &
                  table.modelVersion.equals(modelVersion) &
                  table.preprocessingVersion.equals(preprocessingVersion) &
                  table.provider.equals(provider.name),
            ))
            .get();
    return rows.map(_toEntity).toList(growable: false);
  }

  @override
  Future<List<TrackEmbedding>> getForTrack(String trackId) async {
    final rows =
        await (database.select(database.trackEmbeddingTable)
              ..where((table) => table.trackId.equals(trackId))
              ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]))
            .get();
    return rows.map(_toEntity).toList(growable: false);
  }

  @override
  Future<void> deleteForTrack(String trackId) async {
    await (database.delete(
      database.trackEmbeddingTable,
    )..where((table) => table.trackId.equals(trackId))).go();
  }

  static TrackEmbedding _toEntity(TrackEmbeddingTableData row) {
    return TrackEmbedding(
      trackId: row.trackId,
      modality: TrackEmbeddingModality.values.byName(row.modality),
      modelId: row.modelId,
      modelVersion: row.modelVersion,
      preprocessingVersion: row.preprocessingVersion,
      provider: TrackEmbeddingProvider.values.byName(row.provider),
      audioRevision: row.audioRevision,
      contentRevision: row.contentRevision,
      dtype: row.dtype,
      normalized: row.normalized,
      dimensions: row.dimensions,
      vector: Float32VectorCodec.decode(row.vector, dimensions: row.dimensions),
      createdAt: row.createdAt,
    );
  }
}
