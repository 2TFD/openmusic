import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/core/services/track_source_resolver.dart';
import 'package:openmusic/core/services/music_analysis/music_analysis_backfill_service.dart';
import 'package:openmusic/core/services/music_analysis/music_analysis_config.dart';
import 'package:openmusic/core/services/music_analysis/music_analysis_model_registry.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/track/drift/track_drift_local_source.dart';
import 'package:openmusic/layers/data/repositories/music_analysis_task_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/track_download_completion_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/track_ingestion_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/track_repository_impl.dart';
import 'package:openmusic/layers/domain/entities/download_track_task.dart';
import 'package:openmusic/layers/domain/entities/music_analysis.dart';
import 'package:openmusic/layers/domain/entities/playlist.dart';
import 'package:openmusic/layers/domain/entities/resolved_track_input.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';
import 'package:openmusic/layers/domain/repositories/music_analysis_repository.dart';
import 'package:openmusic/layers/domain/repositories/music_analysis_client.dart';
import 'package:openmusic/layers/domain/repositories/playlist_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_content_identity_service.dart';
import 'package:openmusic/layers/domain/repositories/track_source.dart';
import 'package:openmusic/layers/domain/usecases/add_track_use_case.dart';
import 'package:openmusic/layers/domain/usecases/complete_track_download_use_case.dart';
import 'package:openmusic/layers/domain/usecases/queue_music_analysis_use_case.dart';

void main() {
  late AppDatabase database;
  late TrackRepositoryImpl tracks;
  late MusicAnalysisTaskRepositoryImpl tasks;
  late _Analysis analysis;
  late QueueMusicAnalysisUseCase queue;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    tracks = TrackRepositoryImpl(
      localDataSource: TrackDriftLocalSource(database),
    );
    tasks = MusicAnalysisTaskRepositoryImpl(database);
    analysis = _Analysis();
    queue = QueueMusicAnalysisUseCase(analysis: analysis, tasks: tasks);
  });

  tearDown(() => database.close());

  test('analysis queue is enabled by default', () async {
    final track = await _insertTrack(
      database,
      'always-on',
      filePath: '/always-on.mp3',
    );

    final disposition = await queue(track);

    expect(disposition, QueueMusicAnalysisDisposition.queued);
    expect(analysis.missingCalls, 1);
    expect((await tasks.getAll()).single.trackId, 'always-on');
  });

  test('local import queues global and temporal analysis', () async {
    final source = _LocalSource();
    final useCase = AddTrackUseCase(
      trackResolver: TrackSourceResolver([source]),
      trackRepository: tracks,
      ingestionRepository: TrackIngestionRepositoryImpl(
        database: database,
        trackLocalDataSource: TrackDriftLocalSource(database),
      ),
      playlistRepository: _Playlists(),
      contentIdentityService: _Identity(),
      queueAnalysis: queue,
    );
    final preview = _preview('local-import', SourceType.localFile);

    final result = await useCase.addResolved(
      ResolvedTrackInput.single(preview),
    );
    final task = (await tasks.getAll()).single;

    expect(result.firstTrack?.filePath, '/downloaded/local-import.mp3');
    expect(task.trackId, 'local-import');
    expect(task.audioRevision, 1);
    expect(task.requestedRepresentations, {
      MusicAnalysisRepresentation.audioGlobal,
      MusicAnalysisRepresentation.audioTemporal,
    });
  });

  test(
    'SoundCloud completion queues analysis after durable download',
    () async {
      await _insertTrack(database, 'soundcloud');
      await database
          .into(database.downloadTaskTable)
          .insert(
            DownloadTaskTableCompanion.insert(
              trackId: 'soundcloud',
              originalUrl: 'https://soundcloud.com/a/b',
              status: DownloadStatus.downloading.name,
              createdAt: DateTime.now(),
              leaseOwner: const Value('owner'),
              leaseUntil: Value(DateTime.now().add(const Duration(minutes: 1))),
            ),
          );
      final complete = CompleteTrackDownloadUseCase(
        TrackDownloadCompletionRepositoryImpl(database),
        tracks: tracks,
        queueAnalysis: queue,
      );

      final completed = await complete.completeClaimed(
        trackId: 'soundcloud',
        filePath: '/downloaded/soundcloud.mp3',
        ownerId: 'owner',
      );

      expect(completed, isTrue);
      final task = (await tasks.getAll()).single;
      expect(task.trackId, 'soundcloud');
      expect(task.audioRevision, 1);
    },
  );

  test(
    'cache hit stays completed while audio revision change requeues',
    () async {
      var track = await _insertTrack(
        database,
        'revision',
        filePath: '/old.mp3',
      );
      await queue(track);
      final original = (await tasks.getAll()).single;
      await tasks.complete(original.id);
      analysis.missing = const {};

      expect(await queue(track), QueueMusicAnalysisDisposition.cached);
      expect((await tasks.getAll()).single.status.name, 'completed');

      analysis.missing = QueueMusicAnalysisUseCase.requiredRepresentations;
      await TrackDownloadCompletionRepositoryImpl(
        database,
      ).completeLocal(trackId: track.id, filePath: '/new.mp3');
      track = (await tracks.getTrackById(track.id))!;
      await queue(track);
      final requeued = (await tasks.getAll()).single;
      expect(requeued.audioRevision, 2);
      expect(requeued.status.name, 'queued');
    },
  );

  test('incremental backfill queues only the configured batch', () async {
    for (final id in ['one', 'two', 'three']) {
      await _insertTrack(database, id, filePath: '/$id.mp3');
    }
    final client = _ModelsClient();
    final backfill = MusicAnalysisBackfillService(
      tracks: tracks,
      queueAnalysis: queue,
      registry: MusicAnalysisModelRegistry(client),
      config: const MusicAnalysisQueueConfig(analysisBackfillBatchSize: 2),
    );

    expect(await backfill.enqueueNextBatch(), 2);
    expect(await tasks.getAll(), hasLength(2));
    expect(client.modelRequests, 1);
  });
}

class _Analysis implements MusicAnalysisRepository {
  Set<MusicAnalysisRepresentation> missing =
      QueueMusicAnalysisUseCase.requiredRepresentations;
  int missingCalls = 0;

  @override
  Future<Set<MusicAnalysisRepresentation>> missingRepresentations({
    required String trackId,
    required int audioRevision,
    required Set<MusicAnalysisRepresentation> representations,
  }) async {
    missingCalls++;
    return missing.intersection(representations);
  }

  @override
  Future<MusicAnalysisDisposition> analyzeTrack({
    required String trackId,
    required int audioRevision,
    required Set<MusicAnalysisRepresentation> representations,
  }) => throw UnimplementedError();
}

class _ModelsClient implements MusicAnalysisClient {
  int modelRequests = 0;
  @override
  String get baseUrl => 'https://analysis.example';
  @override
  Future<MusicAnalysisModels> getModels() async {
    modelRequests++;
    return MusicAnalysisModels(
      schemaVersion: '1',
      models: [
        MusicAnalysisModel(
          representation: MusicAnalysisRepresentation.audioGlobal,
          modelId: 'global',
          modelVersion: '1',
          preprocessingVersion: 'prep',
          dimension: 2,
          dtype: 'float32',
          normalized: true,
        ),
        MusicAnalysisModel(
          representation: MusicAnalysisRepresentation.audioTemporal,
          modelId: 'temporal',
          modelVersion: '1',
          preprocessingVersion: 'prep',
          dimension: 2,
          dtype: 'float32',
          normalized: true,
        ),
      ],
    );
  }

  @override
  Future<MusicAnalysisResponse> analyze({
    required String trackId,
    required String filePath,
    String? contentIdentity,
    String? lyrics,
    required Set<MusicAnalysisRepresentation> requestedRepresentations,
  }) => throw UnimplementedError();
}

Future<Track> _insertTrack(
  AppDatabase database,
  String id, {
  String? filePath,
}) async {
  await database
      .into(database.trackTable)
      .insert(
        TrackTableCompanion.insert(
          id: id,
          title: id,
          sourceType: 'soundcloud',
          sourceUri: 'https://soundcloud.com/a/$id',
          pathToFile: Value(filePath),
          audioRevision: Value(filePath == null ? 0 : 1),
        ),
      );
  return Track(
    id: id,
    title: id,
    artists: const [],
    duration: Duration.zero,
    source: Source(
      type: SourceType.soundcloud,
      originalUrl: 'https://soundcloud.com/a/$id',
    ),
    addedAt: DateTime.now(),
    filePath: filePath,
    audioRevision: filePath == null ? 0 : 1,
  );
}

TrackPreview _preview(String id, SourceType source) => TrackPreview(
  id: id,
  title: id,
  artist: 'Artist',
  source: source,
  originalUrl: '/source/$id.mp3',
  urlFile: '/source/$id.mp3',
);

class _LocalSource implements TrackSource {
  @override
  SourceType get sourceType => SourceType.localFile;
  @override
  bool canHandle(String input) => true;
  @override
  Future<String> download(TrackPreview track, {cancellation}) async =>
      '/downloaded/${track.id}.mp3';
  @override
  Future<ResolvedTrackInput> resolve(String input) async =>
      ResolvedTrackInput.single(_preview(input, sourceType));
}

class _Identity implements TrackContentIdentityService {
  @override
  Future<String?> createFor(TrackPreview preview) async =>
      'local:sha256:${preview.id}';
  @override
  Future<String> forLocalFile(String filePath) async => 'local:sha256:file';
  @override
  String forSoundCloudTrack(String trackId) => 'soundcloud:$trackId';
}

class _Playlists implements PlaylistRepository {
  @override
  Future<void> addTrackToPlaylist(String playlistId, String trackId) async {}
  @override
  Future<void> createPlaylist(Playlist playlist) async {}
  @override
  Future<void> deletePlaylist(String playlistId) async {}
  @override
  Future<Playlist?> getPlaylistById(String id) async => null;
  @override
  Future<void> removeTrackFromPlaylist(
    String playlistId,
    String trackId, {
    required int expectedRevision,
  }) async {}
  @override
  Future<void> reorderTracks(
    String playlistId,
    List<String> trackIds, {
    required int expectedRevision,
  }) async {}
  @override
  Future<void> updateMetadata(Playlist playlist) async {}
  @override
  Stream<Playlist?> watchPlaylistById(String id) => const Stream.empty();
  @override
  Stream<List<PlaylistSummary>> watchPlaylistSummaries() =>
      const Stream.empty();
}
