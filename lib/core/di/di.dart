import 'package:get_it/get_it.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/core/services/download/download_worker.dart';
import 'package:openmusic/core/services/music_analysis/music_analysis_backfill_service.dart';
import 'package:openmusic/core/services/music_analysis/music_analysis_config.dart';
import 'package:openmusic/core/services/music_analysis/music_analysis_model_registry.dart';
import 'package:openmusic/core/services/music_analysis/music_analysis_worker.dart';
import 'package:openmusic/core/services/lyrics/lyrics_backfill_service.dart';
import 'package:openmusic/core/services/lyrics/lyrics_config.dart';
import 'package:openmusic/core/services/lyrics/lyrics_resolution_worker.dart';
import 'package:openmusic/core/services/lyrics/lyrics_resolver.dart';
import 'package:openmusic/core/services/research/lyrics_semantic_research_service.dart';
import 'package:openmusic/core/services/recommendation/recommendation_config.dart';
import 'package:openmusic/core/services/recommendation/recommendation_engine.dart';
import 'package:openmusic/core/services/track_identity/sha256_track_content_identity_service.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/artist/artist_local_data_source.dart';
import 'package:openmusic/layers/data/datasources/local/artist/drift/artist_drift_local_source.dart';
import 'package:openmusic/layers/data/datasources/local/download_task/download_task_local_data_source.dart';
import 'package:openmusic/layers/data/datasources/local/download_task/drift/download_task_drift_local_source.dart';
import 'package:openmusic/layers/data/datasources/local/playlist/drift/playlist_drift_local_source.dart';
import 'package:openmusic/layers/data/datasources/local/playlist/playlist_local_data_source.dart';
import 'package:openmusic/layers/data/datasources/local/track/drift/track_drift_local_source.dart';
import 'package:openmusic/layers/data/datasources/local/track/track_local_data_source.dart';
import 'package:openmusic/core/services/audio_player/audio_player_service.dart';
import 'package:openmusic/core/services/audio_player/playback_command_bus_impl.dart';
import 'package:openmusic/layers/domain/repositories/playback_command_bus.dart';
import 'package:openmusic/layers/data/datasources/local/listening_summary/drift/listening_summary_drift_local_source.dart';
import 'package:openmusic/layers/data/datasources/local/listening_summary/listening_summary_local_data_source.dart';
import 'package:openmusic/layers/data/datasources/remote/local_file_track_source.dart';
import 'package:openmusic/layers/data/datasources/lyrics/embedded_lyrics_metadata_reader.dart';
import 'package:openmusic/layers/data/datasources/lyrics/embedded_lyrics_provider.dart';
import 'package:openmusic/layers/data/datasources/lyrics/lrclib_lyrics_provider.dart';
import 'package:openmusic/layers/data/datasources/lyrics/sidecar_lrc_lyrics_provider.dart';
import 'package:openmusic/layers/data/datasources/remote/music_analysis/dio_music_analysis_client.dart';
import 'package:openmusic/layers/data/datasources/remote/soundcloud_track_source.dart';
import 'package:openmusic/layers/data/repositories/download_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/artist_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/listening_summary_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/playlist_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/search_source_impl.dart';
import 'package:openmusic/layers/data/repositories/track_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/track_embedding_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/listening_event_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/music_analysis_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/music_analysis_task_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/lyrics_resolution_task_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/track_lyrics_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/similarity_evaluation_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/track_removal_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/listening_checkpoint_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/playback_session_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/track_ingestion_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/track_temporal_embedding_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/track_download_completion_repository_impl.dart';
import 'package:openmusic/layers/domain/repositories/download_task_repository.dart';
import 'package:openmusic/layers/domain/repositories/artist_repository.dart';
import 'package:openmusic/layers/domain/repositories/audio_player_port.dart';
import 'package:openmusic/layers/domain/repositories/local_track_picker.dart';
import 'package:openmusic/layers/domain/repositories/listening_summary_repository.dart';
import 'package:openmusic/layers/domain/repositories/playlist_repository.dart';
import 'package:openmusic/layers/domain/repositories/search_source.dart';
import 'package:openmusic/layers/domain/repositories/track_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_content_identity_service.dart';
import 'package:openmusic/layers/domain/repositories/track_embedding_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_temporal_embedding_repository.dart';
import 'package:openmusic/layers/domain/repositories/listening_event_repository.dart';
import 'package:openmusic/layers/domain/repositories/music_analysis_client.dart';
import 'package:openmusic/layers/domain/repositories/music_analysis_repository.dart';
import 'package:openmusic/layers/domain/repositories/music_analysis_task_repository.dart';
import 'package:openmusic/layers/domain/repositories/lyrics_resolution_task_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_lyrics_repository.dart';
import 'package:openmusic/layers/domain/repositories/similarity_evaluation_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_removal_repository.dart';
import 'package:openmusic/layers/domain/repositories/listening_checkpoint_repository.dart';
import 'package:openmusic/layers/domain/repositories/playback_session_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_ingestion_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_download_completion_repository.dart';
import 'package:openmusic/core/services/track_source_resolver.dart';
import 'package:openmusic/layers/domain/usecases/add_track_use_case.dart';
import 'package:openmusic/layers/domain/usecases/add_track_to_playlist_use_case.dart';
import 'package:openmusic/layers/domain/usecases/complete_track_download_use_case.dart';
import 'package:openmusic/layers/domain/usecases/delete_playlist_use_case.dart';
import 'package:openmusic/layers/domain/usecases/get_playlist_with_tracks_use_case.dart';
import 'package:openmusic/layers/domain/usecases/get_artist_tracks_use_case.dart';
import 'package:openmusic/layers/domain/usecases/import_local_tracks_use_case.dart';
import 'package:openmusic/layers/domain/usecases/pick_local_tracks_use_case.dart';
import 'package:openmusic/layers/domain/usecases/update_playlist_use_case.dart';
import 'package:openmusic/layers/domain/usecases/watch_playlist_use_case.dart';
import 'package:openmusic/layers/domain/usecases/watch_artist_use_case.dart';
import 'package:openmusic/layers/domain/usecases/recover_listening_checkpoint_use_case.dart';
import 'package:openmusic/layers/domain/usecases/restore_playback_session_use_case.dart';
import 'package:openmusic/layers/domain/usecases/save_listening_summary_use_case.dart';
import 'package:openmusic/layers/domain/usecases/save_listening_event_use_case.dart';
import 'package:openmusic/layers/domain/services/listening_tracker.dart';
import 'package:openmusic/layers/domain/usecases/generate_wave_use_case.dart';
import 'package:openmusic/layers/domain/usecases/queue_music_analysis_use_case.dart';
import 'package:openmusic/layers/domain/usecases/queue_lyrics_analysis_use_case.dart';
import 'package:openmusic/layers/domain/usecases/queue_lyrics_resolution_use_case.dart';
import 'package:openmusic/layers/presentation/blocs/music_analysis_status/music_analysis_status_cubit.dart';
import 'package:openmusic/layers/presentation/blocs/artist_detail/artist_detail_bloc.dart';
import 'package:openmusic/layers/presentation/blocs/import_music/import_music_cubit.dart';
import 'package:openmusic/layers/presentation/blocs/playlist_detail/playlist_detail_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies({required String appDir}) async {
  // primitive
  getIt.registerSingleton<String>(appDir);

  // datasource
  getIt.registerSingleton<AppDatabase>(AppDatabase());

  getIt.registerLazySingleton<LocalFileTrackSource>(LocalFileTrackSource.new);
  getIt.registerLazySingleton<SoundcloudTrackSource>(SoundcloudTrackSource.new);
  getIt.registerLazySingleton<LocalTrackPicker>(
    () => getIt<LocalFileTrackSource>(),
  );

  getIt.registerSingleton<TrackLocalDataSource>(
    TrackDriftLocalSource(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<ArtistLocalDataSource>(
    () => ArtistDriftLocalSource(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<DownloadTaskLocalDataSource>(
    () => DownloadTaskDriftLocalSource(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<PlaylistLocalDataSource>(
    () => PlaylistDriftLocalSource(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<ListeningSummaryLocalDataSource>(
    () => ListeningSummaryDriftLocalSource(getIt<AppDatabase>()),
  );

  // repositories

  getIt.registerSingleton<TrackRepository>(
    TrackRepositoryImpl(localDataSource: getIt<TrackLocalDataSource>()),
  );

  getIt.registerLazySingleton<TrackEmbeddingRepository>(
    () => TrackEmbeddingRepositoryImpl(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<TrackTemporalEmbeddingRepository>(
    () => TrackTemporalEmbeddingRepositoryImpl(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<MusicAnalysisTaskRepository>(
    () => MusicAnalysisTaskRepositoryImpl(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<TrackLyricsRepository>(
    () => TrackLyricsRepositoryImpl(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<LyricsResolutionTaskRepository>(
    () => LyricsResolutionTaskRepositoryImpl(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<SimilarityEvaluationRepository>(
    () => SimilarityEvaluationRepositoryImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<ListeningEventRepository>(
    () => ListeningEventRepositoryImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<ArtistRepository>(
    () => ArtistRepositoryImpl(
      localDataSource: getIt<ArtistLocalDataSource>(),
      trackRepository: getIt<TrackRepository>(),
    ),
  );

  getIt.registerLazySingleton<TrackRemovalRepository>(
    () => TrackRemovalRepositoryImpl(
      database: getIt<AppDatabase>(),
      appDir: getIt<String>(),
    ),
  );

  getIt.registerLazySingleton<ListeningCheckpointRepository>(
    () => ListeningCheckpointRepositoryImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<PlaybackSessionRepository>(
    () => PlaybackSessionRepositoryImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<PlaylistRepository>(
    () => PlaylistRepositoryImpl(localDataSource: getIt()),
  );

  getIt.registerLazySingleton<ListeningSummaryRepository>(
    () => ListeningSummaryRepositoryImpl(localDataSource: getIt()),
  );

  getIt.registerSingleton<DownloadTaskRepository>(
    DownloadTaskRepositoryImpl(
      localDataSource: getIt<DownloadTaskLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<TrackIngestionRepository>(
    () => TrackIngestionRepositoryImpl(
      database: getIt<AppDatabase>(),
      trackLocalDataSource: getIt<TrackLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<TrackDownloadCompletionRepository>(
    () => TrackDownloadCompletionRepositoryImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<SearchSource>(
    () => SearchSourceImpl(soundcloudTrackSource: getIt()),
  );

  // services

  getIt.registerLazySingleton(
    () => MusicAnalysisConfig(MusicAnalysisConfig.defaultBaseUrl),
  );
  getIt.registerLazySingleton(() => LyricsConfig());
  getIt.registerLazySingleton(() => const MusicAnalysisQueueConfig());
  getIt.registerLazySingleton<MusicAnalysisClient>(
    () => DioMusicAnalysisClient(
      config: getIt<MusicAnalysisConfig>(),
      appDirectory: getIt<String>(),
    ),
  );
  getIt.registerLazySingleton(
    () => MusicAnalysisModelRegistry(getIt<MusicAnalysisClient>()),
  );
  getIt.registerLazySingleton<MusicAnalysisRepository>(
    () => MusicAnalysisRepositoryImpl(
      tracks: getIt(),
      globalEmbeddings: getIt(),
      temporalEmbeddings: getIt(),
      lyrics: getIt(),
      client: getIt(),
      registry: getIt(),
    ),
  );
  getIt.registerLazySingleton<TrackContentIdentityService>(
    Sha256TrackContentIdentityService.new,
  );

  getIt.registerLazySingleton(
    () => TrackSourceResolver([
      getIt<LocalFileTrackSource>(),
      getIt<SoundcloudTrackSource>(),
    ]),
  );
  getIt.registerLazySingleton(
    () => QueueMusicAnalysisUseCase(analysis: getIt(), tasks: getIt()),
  );
  getIt.registerLazySingleton(
    () => QueueLyricsAnalysisUseCase(analysis: getIt(), tasks: getIt()),
  );
  getIt.registerLazySingleton(
    () => QueueLyricsResolutionUseCase(getIt<LyricsResolutionTaskRepository>()),
  );
  getIt.registerLazySingleton<EmbeddedLyricsMetadataReader>(
    () => FfprobeEmbeddedLyricsMetadataReader(appDirectory: getIt<String>()),
  );
  getIt.registerLazySingleton<EmbeddedLyricsProvider>(
    () => EmbeddedLyricsProvider(metadataReader: getIt()),
  );
  getIt.registerLazySingleton<SidecarLrcLyricsProvider>(
    () => SidecarLrcLyricsProvider(appDirectory: getIt<String>()),
  );
  getIt.registerLazySingleton<LrclibLyricsProvider>(
    () => LrclibLyricsProvider(
      baseUrl: getIt<LyricsConfig>().baseUrl,
      minimumRequestInterval: getIt<LyricsConfig>().requestDelay,
    ),
  );
  getIt.registerLazySingleton<LyricsResolver>(
    () => LyricsResolver(
      tracks: getIt(),
      lyrics: getIt(),
      providers: [
        getIt<EmbeddedLyricsProvider>(),
        getIt<SidecarLrcLyricsProvider>(),
        getIt<LrclibLyricsProvider>(),
      ],
      queueAnalysis: getIt(),
      config: getIt(),
    ),
  );
  getIt.registerLazySingleton<LyricsBackfill>(
    () => LyricsBackfillService(
      tracks: getIt(),
      lyrics: getIt(),
      tasks: getIt(),
      config: getIt(),
    ),
  );
  getIt.registerLazySingleton(
    () => LyricsResolutionWorker(
      tasks: getIt(),
      resolver: getIt(),
      backfill: getIt(),
      config: getIt(),
    ),
  );
  getIt.registerLazySingleton(
    () => LyricsSemanticResearchService(
      tracks: getIt(),
      lyrics: getIt(),
      embeddings: getIt(),
      registry: getIt(),
    ),
  );
  getIt.registerLazySingleton<MusicAnalysisBackfill>(
    () => MusicAnalysisBackfillService(
      tracks: getIt(),
      queueAnalysis: getIt(),
      registry: getIt(),
      config: getIt(),
    ),
  );
  getIt.registerLazySingleton(
    () => MusicAnalysisWorker(
      tasks: getIt(),
      analysis: getIt(),
      backfill: getIt(),
    ),
  );

  getIt.registerLazySingleton(
    () => DownloadWorker(
      downloadRepository: getIt<DownloadTaskRepository>(),
      trackResolver: getIt<TrackSourceResolver>(),
      completeDownload: getIt<CompleteTrackDownloadUseCase>(),
    ),
  );

  getIt.registerLazySingleton<AudioPlayerService>(
    () => AudioPlayerService(appDir: getIt<String>()),
  );
  getIt.registerLazySingleton<AudioPlayerPort>(
    () => getIt<AudioPlayerService>(),
  );
  getIt.registerLazySingleton<PlaybackCommandBus>(
    () => PlaybackCommandBusImpl(),
  );

  getIt.registerLazySingleton(() => const RecommendationConfig());
  getIt.registerLazySingleton(
    () => RecommendationEngine(
      tracks: getIt(),
      globalEmbeddings: getIt(),
      temporalEmbeddings: getIt(),
      lyrics: getIt(),
      registry: getIt(),
      config: getIt(),
    ),
  );

  // usecases

  getIt.registerFactory(
    () => AddTrackUseCase(
      playlistRepository: getIt(),
      trackResolver: getIt(),
      trackRepository: getIt(),
      ingestionRepository: getIt(),
      contentIdentityService: getIt(),
      queueAnalysis: getIt(),
      queueLyrics: getIt(),
    ),
  );

  getIt.registerFactory(
    () => SaveListeningEventUseCase(getIt<ListeningEventRepository>()),
  );
  getIt.registerFactory(
    () => ListeningTracker(saveEvent: getIt<SaveListeningEventUseCase>()),
  );

  getIt.registerLazySingleton(
    () => CompleteTrackDownloadUseCase(
      getIt(),
      tracks: getIt(),
      queueAnalysis: getIt(),
      queueLyrics: getIt(),
    ),
  );
  getIt.registerFactory(
    () => GenerateWaveUseCase(
      engine: getIt(),
      tracks: getIt(),
      queueAnalysis: getIt(),
    ),
  );

  getIt.registerFactory(
    () => RecoverListeningCheckpointUseCase(
      checkpoints: getIt(),
      saveListeningSummary: SaveListeningSummaryUseCase(repo: getIt()),
    ),
  );

  getIt.registerFactory(
    () => RestorePlaybackSessionUseCase(sessions: getIt(), tracks: getIt()),
  );

  getIt.registerFactory(() => PickLocalTracksUseCase(getIt()));
  getIt.registerFactory(
    () => ImportLocalTracksUseCase((resolved) async {
      final result = await getIt<AddTrackUseCase>().addResolved(resolved);
      if (result.isEmpty) {
        throw result.failures.firstOrNull?.failure ??
            const EmptyResultFailure('import tracks');
      }
    }),
  );

  // Route-scoped presentation objects. The router owns their lifecycle.
  getIt.registerFactory(
    () =>
        ImportMusicCubit(pickLocalTracks: getIt(), importLocalTracks: getIt()),
  );
  getIt.registerFactory(() => MusicAnalysisStatusCubit(tasks: getIt()));
  getIt.registerFactory(
    () => PlaylistDetailBloc(
      getPlaylistWithTracks: GetPlaylistWithTracksUseCase(
        playlistRepository: getIt(),
        trackRepository: getIt(),
      ),
      updatePlaylist: UpdatePlaylistUseCase(getIt()),
      deletePlaylist: DeletePlaylistUseCase(getIt()),
      addTrack: AddTrackToPlaylistUseCase(getIt()),
      watchPlaylist: WatchPlaylistUseCase(getIt()),
      trackChanges: getIt<TrackRepository>().watchChanges(),
    ),
  );
  getIt.registerFactory(
    () => ArtistDetailBloc(
      watchArtist: WatchArtistUseCase(getIt<ArtistRepository>()),
      getArtistTracks: GetArtistTracksUseCase(getIt<ArtistRepository>()),
    ),
  );
}
