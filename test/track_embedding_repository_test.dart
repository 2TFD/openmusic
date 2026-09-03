import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/data/converters/float32_vector_codec.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/repositories/track_embedding_repository_impl.dart';
import 'package:openmusic/layers/domain/entities/track_embedding.dart';

void main() {
  late AppDatabase database;
  late TrackEmbeddingRepositoryImpl repository;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = TrackEmbeddingRepositoryImpl(database);
    await _insertTrack(database, 'track-1');
  });

  tearDown(() => database.close());

  test('Float32 BLOB round-trip uses compact values', () {
    final bytes = Float32VectorCodec.encode([0.1, -2.5, 3.25]);
    final decoded = Float32VectorCodec.decode(bytes, dimensions: 3);

    expect(bytes.length, 3 * 4);
    expect(decoded[0], closeTo(0.1, 0.000001));
    expect(decoded[1], -2.5);
    expect(decoded[2], 3.25);
  });

  test('invalid embeddings are rejected', () {
    expect(
      () => _embedding(vector: const [], dimensions: 0),
      throwsArgumentError,
    );
    expect(
      () => _embedding(vector: const [1], dimensions: 2),
      throwsArgumentError,
    );
    expect(
      () => _embedding(vector: const [double.nan], dimensions: 1),
      throwsArgumentError,
    );
    expect(
      () => Float32VectorCodec.encode([double.maxFinite]),
      throwsArgumentError,
    );
  });

  test('save upserts the same versioned embedding key', () async {
    await repository.save(_embedding(vector: const [1, 2]));
    await repository.save(
      _embedding(vector: const [3, 4], createdAt: DateTime.utc(2026, 2)),
    );

    final rows = await database.select(database.trackEmbeddingTable).get();
    final stored = await repository.get(
      trackId: 'track-1',
      modality: TrackEmbeddingModality.audio,
      modelId: 'model-a',
      modelVersion: '1',
      provider: TrackEmbeddingProvider.server,
    );
    expect(rows, hasLength(1));
    expect(stored?.vector, [3, 4]);
    expect(stored?.audioRevision, 2);
    expect(stored?.contentRevision, 'audio:2');
    expect(stored?.createdAt.isAtSameMomentAs(DateTime.utc(2026, 2)), isTrue);
  });

  test('older audioRevision cannot overwrite a newer embedding', () async {
    await repository.save(
      _embedding(
        vector: const [5, 6],
        audioRevision: 5,
        createdAt: DateTime.utc(2026, 5),
      ),
    );
    await repository.save(
      _embedding(
        vector: const [1, 2],
        audioRevision: 4,
        createdAt: DateTime.utc(2026, 6),
      ),
    );

    final stored = await repository.get(
      trackId: 'track-1',
      modality: TrackEmbeddingModality.audio,
      modelId: 'model-a',
      modelVersion: '1',
      provider: TrackEmbeddingProvider.server,
    );
    expect(stored?.audioRevision, 5);
    expect(stored?.vector, [5, 6]);
    expect(stored?.createdAt.isAtSameMomentAs(DateTime.utc(2026, 5)), isTrue);
  });

  test('database enforces composite uniqueness', () async {
    final companion = TrackEmbeddingTableCompanion.insert(
      trackId: 'track-1',
      modality: 'audio',
      modelId: 'model-a',
      modelVersion: '1',
      provider: 'server',
      dimensions: 1,
      vector: Float32VectorCodec.encode([1]),
      createdAt: DateTime.utc(2026),
    );
    await database.into(database.trackEmbeddingTable).insert(companion);

    await expectLater(
      database.into(database.trackEmbeddingTable).insert(companion),
      throwsA(anything),
    );
  });

  test('track delete cascades to embeddings', () async {
    await repository.save(_embedding(vector: const [1, 2]));

    await (database.delete(
      database.trackTable,
    )..where((row) => row.id.equals('track-1'))).go();

    expect(await repository.getForTrack('track-1'), isEmpty);
  });

  test('stores models, providers, and modalities independently', () async {
    await repository.save(_embedding(vector: const [1, 2]));
    await repository.save(
      _embedding(
        vector: const [2, 3],
        modelId: 'model-b',
        provider: TrackEmbeddingProvider.local,
      ),
    );
    await repository.save(
      _embedding(
        vector: const [4, 5],
        modality: TrackEmbeddingModality.lyrics,
        audioRevision: null,
        contentRevision: _lyricsHashA,
      ),
    );

    final values = await repository.getForTrack('track-1');
    expect(values, hasLength(3));
    expect(values.map((value) => value.modelId).toSet(), {
      'model-a',
      'model-b',
    });
    expect(values.map((value) => value.provider).toSet(), {
      TrackEmbeddingProvider.server,
      TrackEmbeddingProvider.local,
    });
    expect(values.map((value) => value.modality).toSet(), {
      TrackEmbeddingModality.audio,
      TrackEmbeddingModality.lyrics,
    });
  });

  test(
    'different preprocessing versions are separate embedding spaces',
    () async {
      await repository.save(
        _embedding(vector: const [1, 0], preprocessingVersion: 'pre-a'),
      );
      await repository.save(
        _embedding(vector: const [0, 1], preprocessingVersion: 'pre-b'),
      );

      final values = await repository.getForTrack('track-1');
      expect(values, hasLength(2));
      expect(values.map((value) => value.preprocessingVersion).toSet(), {
        'pre-a',
        'pre-b',
      });
    },
  );

  test(
    'lyrics embedding uses content hash and can replace current row',
    () async {
      await repository.save(
        _embedding(
          modality: TrackEmbeddingModality.lyrics,
          audioRevision: null,
          contentRevision: _lyricsHashA,
          vector: const [1, 0],
        ),
      );
      await repository.save(
        _embedding(
          modality: TrackEmbeddingModality.lyrics,
          audioRevision: null,
          contentRevision: _lyricsHashB,
          vector: const [0, 1],
        ),
      );

      expect(
        await repository.get(
          trackId: 'track-1',
          modality: TrackEmbeddingModality.lyrics,
          modelId: 'model-a',
          modelVersion: '1',
          provider: TrackEmbeddingProvider.server,
          contentRevision: _lyricsHashA,
        ),
        isNull,
      );
      final current = await repository.get(
        trackId: 'track-1',
        modality: TrackEmbeddingModality.lyrics,
        modelId: 'model-a',
        modelVersion: '1',
        provider: TrackEmbeddingProvider.server,
        contentRevision: _lyricsHashB,
      );
      expect(current?.audioRevision, isNull);
      expect(current?.contentRevision, _lyricsHashB);
      expect(current?.vector, [0, 1]);
    },
  );

  test('lyrics embedding rejects audio revision and non-hash revision', () {
    expect(
      () => _embedding(
        modality: TrackEmbeddingModality.lyrics,
        audioRevision: 1,
        contentRevision: _lyricsHashA,
        vector: const [1, 0],
      ),
      throwsArgumentError,
    );
    expect(
      () => _embedding(
        modality: TrackEmbeddingModality.lyrics,
        audioRevision: null,
        contentRevision: 'not-a-hash',
        vector: const [1, 0],
      ),
      throwsArgumentError,
    );
  });

  test('deleteForTrack deletes only the requested track embeddings', () async {
    await _insertTrack(database, 'track-2');
    await repository.save(_embedding(vector: const [1, 2]));
    await repository.save(_embedding(trackId: 'track-2', vector: const [3, 4]));

    await repository.deleteForTrack('track-1');

    expect(await repository.getForTrack('track-1'), isEmpty);
    expect(await repository.getForTrack('track-2'), hasLength(1));
  });
}

TrackEmbedding _embedding({
  String trackId = 'track-1',
  TrackEmbeddingModality modality = TrackEmbeddingModality.audio,
  String modelId = 'model-a',
  String modelVersion = '1',
  String preprocessingVersion = TrackEmbedding.legacyPreprocessingVersion,
  TrackEmbeddingProvider provider = TrackEmbeddingProvider.server,
  int? audioRevision = 2,
  String? contentRevision,
  int dimensions = 2,
  required List<double> vector,
  DateTime? createdAt,
}) {
  return TrackEmbedding(
    trackId: trackId,
    modality: modality,
    modelId: modelId,
    modelVersion: modelVersion,
    preprocessingVersion: preprocessingVersion,
    provider: provider,
    audioRevision: audioRevision,
    contentRevision: contentRevision,
    dimensions: dimensions,
    vector: vector,
    createdAt: createdAt ?? DateTime.utc(2026),
  );
}

const _lyricsHashA =
    'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
const _lyricsHashB =
    'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';

Future<void> _insertTrack(AppDatabase database, String id) {
  return database
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
