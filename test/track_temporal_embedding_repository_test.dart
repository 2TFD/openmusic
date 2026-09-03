import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/repositories/track_temporal_embedding_repository_impl.dart';
import 'package:openmusic/layers/domain/entities/music_analysis.dart';
import 'package:openmusic/layers/domain/entities/track_embedding.dart';
import 'package:openmusic/layers/domain/entities/track_temporal_embedding.dart';

void main() {
  late AppDatabase database;
  late TrackTemporalEmbeddingRepositoryImpl repository;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = TrackTemporalEmbeddingRepositoryImpl(database);
    await _insertTrack(database, 'track-1');
  });

  tearDown(() => database.close());

  test('Float32 BLOB roundtrip preserves segment ordering', () async {
    await repository.save(
      _embedding(
        revision: 1,
        vectors: const [
          [1, 2],
          [3, 4],
        ],
      ),
    );

    final stored = await repository.get(
      trackId: 'track-1',
      representation: 'audio.temporal',
      modelId: 'model',
      modelVersion: '1',
      preprocessingVersion: 'pre-1',
      provider: TrackEmbeddingProvider.server,
      audioRevision: 1,
    );
    final storageType = await database
        .customSelect(
          'SELECT typeof(vector) AS storage_type '
          'FROM track_temporal_embedding_segment_table LIMIT 1',
        )
        .getSingle();

    expect(stored?.segments.map((segment) => segment.index), [0, 1]);
    expect(stored?.segments[1].vector[1], closeTo(4, 1e-6));
    expect(storageType.read<String>('storage_type'), 'blob');
  });

  test('same identity atomically replaces all old segments', () async {
    await repository.save(
      _embedding(
        revision: 2,
        vectors: const [
          [1, 0],
          [0, 1],
        ],
      ),
    );
    await repository.save(
      _embedding(
        revision: 2,
        vectors: const [
          [0.5, 0.5],
        ],
      ),
    );

    final parentCount = await database
        .select(database.trackTemporalEmbeddingTable)
        .get();
    final segments = await database
        .select(database.trackTemporalEmbeddingSegmentTable)
        .get();
    expect(parentCount, hasLength(1));
    expect(segments, hasLength(1));
    expect(segments.single.segmentIndex, 0);
  });

  test('track and parent deletes cascade to temporal segments', () async {
    await repository.save(
      _embedding(
        revision: 1,
        vectors: const [
          [1, 0],
        ],
      ),
    );
    await (database.delete(
      database.trackTable,
    )..where((table) => table.id.equals('track-1'))).go();

    expect(
      await database.select(database.trackTemporalEmbeddingTable).get(),
      isEmpty,
    );
    expect(
      await database.select(database.trackTemporalEmbeddingSegmentTable).get(),
      isEmpty,
    );
  });

  test('older audioRevision cannot replace newer temporal result', () async {
    await repository.save(
      _embedding(
        revision: 5,
        vectors: const [
          [1, 0],
        ],
      ),
    );
    final saved = await repository.save(
      _embedding(
        revision: 4,
        vectors: const [
          [0, 1],
        ],
      ),
    );

    expect(saved, isFalse);
    final all = await repository.getBySpace(
      representation: 'audio.temporal',
      modelId: 'model',
      modelVersion: '1',
      preprocessingVersion: 'pre-1',
      provider: TrackEmbeddingProvider.server,
    );
    expect(all.single.audioRevision, 5);
    expect(all.single.segments.single.vector[0], closeTo(1, 1e-6));
  });
}

TrackTemporalEmbedding _embedding({
  required int revision,
  required List<List<double>> vectors,
}) => TrackTemporalEmbedding(
  id: 'temporal-$revision',
  trackId: 'track-1',
  representation: 'audio.temporal',
  modelId: 'model',
  modelVersion: '1',
  preprocessingVersion: 'pre-1',
  provider: TrackEmbeddingProvider.server,
  audioRevision: revision,
  dimension: 2,
  dtype: 'float32',
  normalized: true,
  createdAt: DateTime.utc(2026),
  summary: TemporalAnalysisSummary(
    numberOfSegments: vectors.length,
    meanAdjacentDistance: 0.1,
    maxAdjacentDistance: 0.2,
    trajectoryVariance: 0.3,
    largestTransitionIndex: vectors.length > 1 ? 0 : null,
  ),
  segments: [
    for (var index = 0; index < vectors.length; index++)
      TemporalAnalysisSegment(
        index: index,
        startMs: index * 1000,
        endMs: (index + 1) * 1000,
        dimensions: 2,
        vector: vectors[index],
      ),
  ],
);

Future<void> _insertTrack(AppDatabase database, String id) => database
    .into(database.trackTable)
    .insert(
      TrackTableCompanion.insert(
        id: id,
        title: id,
        sourceType: 'localFile',
        sourceUri: '/$id.mp3',
      ),
    );
