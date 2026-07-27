import 'package:get_it/get_it.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/core/services/download/download_worker.dart';
import 'package:openmusic/core/services/embedding/embedding_engine.dart';
import 'package:openmusic/core/services/embedding/embedding_worker.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/download_task/download_task_local_data_source.dart';
import 'package:openmusic/layers/data/datasources/local/download_task/drift/download_task_drift_local_source.dart';
import 'package:openmusic/layers/data/datasources/local/embedding_task/drift/embedding_task_drift_local_source.dart';
import 'package:openmusic/layers/data/datasources/local/embedding_task/embedding_task_local_data_source.dart';
import 'package:openmusic/layers/data/datasources/local/playlist/drift/playlist_drift_local_source.dart';
import 'package:openmusic/layers/data/datasources/local/playlist/playlist_local_data_source.dart';
import 'package:openmusic/layers/data/datasources/local/track/drift/track_drift_local_source.dart';
import 'package:openmusic/layers/data/datasources/local/track/track_local_data_source.dart';
import 'package:openmusic/core/services/audio_player/audio_player_service.dart';
import 'package:openmusic/layers/data/datasources/local/play_record/drift/play_record_drift_local_source.dart';
import 'package:openmusic/layers/data/datasources/local/play_record/play_record_local_data_source.dart';
import 'package:openmusic/layers/data/datasources/remote/local_file_track_source.dart';
import 'package:openmusic/layers/data/datasources/remote/soundcloud_track_source.dart';
import 'package:openmusic/layers/data/repositories/download_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/embedding_task_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/play_record_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/playlist_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/search_source_impl.dart';
import 'package:openmusic/layers/data/repositories/track_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/track_removal_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/listening_checkpoint_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/playback_session_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/track_ingestion_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/track_download_completion_repository_impl.dart';
import 'package:openmusic/layers/domain/repositories/download_task_repository.dart';
import 'package:openmusic/layers/domain/repositories/audio_player_port.dart';
import 'package:openmusic/layers/domain/repositories/embedding_task_repository.dart';
import 'package:openmusic/layers/domain/repositories/local_track_picker.dart';
import 'package:openmusic/layers/domain/repositories/play_record_repository.dart';
import 'package:openmusic/layers/domain/repositories/playlist_repository.dart';
import 'package:openmusic/layers/domain/repositories/search_source.dart';
import 'package:openmusic/layers/domain/repositories/track_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_removal_repository.dart';
import 'package:openmusic/layers/domain/repositories/listening_checkpoint_repository.dart';
import 'package:openmusic/layers/domain/repositories/playback_session_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_ingestion_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_download_completion_repository.dart';
import 'package:openmusic/core/services/track_source_resolver.dart';
import 'package:openmusic/core/services/wave/wave_engine.dart';
import 'package:openmusic/layers/domain/usecases/add_track_use_case.dart';
import 'package:openmusic/layers/domain/usecases/add_track_to_playlist_use_case.dart';
import 'package:openmusic/layers/domain/usecases/complete_track_download_use_case.dart';
import 'package:openmusic/layers/domain/usecases/delete_playlist_use_case.dart';
import 'package:openmusic/layers/domain/usecases/get_playlist_with_tracks_use_case.dart';
import 'package:openmusic/layers/domain/usecases/import_local_tracks_use_case.dart';
import 'package:openmusic/layers/domain/usecases/pick_local_tracks_use_case.dart';
import 'package:openmusic/layers/domain/usecases/update_playlist_use_case.dart';
import 'package:openmusic/layers/domain/usecases/watch_playlist_use_case.dart';
import 'package:openmusic/layers/domain/usecases/recover_listening_checkpoint_use_case.dart';
import 'package:openmusic/layers/domain/usecases/restore_playback_session_use_case.dart';
import 'package:openmusic/layers/domain/usecases/save_statistic_use_case.dart';
import 'package:openmusic/layers/presentation/blocs/embedding_status/embedding_status_cubit.dart';
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

  getIt.registerLazySingleton<DownloadTaskLocalDataSource>(
    () => DownloadTaskDriftLocalSource(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<EmbeddingTaskLocalDataSource>(
    () => EmbeddingTaskDriftLocalSource(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<PlaylistLocalDataSource>(
    () => PlaylistDriftLocalSource(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<PlayRecordLocalDataSource>(
    () => PlayRecordDriftLocalSource(getIt<AppDatabase>()),
  );

  // repositories

  getIt.registerSingleton<TrackRepository>(
    TrackRepositoryImpl(localDataSource: getIt<TrackLocalDataSource>()),
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

  getIt.registerLazySingleton<EmbeddingTaskRepository>(
    () => EmbeddingTaskRepositoryImpl(localDataSource: getIt()),
  );

  getIt.registerLazySingleton<PlaylistRepository>(
    () => PlaylistRepositoryImpl(localDataSource: getIt()),
  );

  getIt.registerLazySingleton<PlayRecordRepository>(
    () => PlayRecordRepositoryImpl(localDataSource: getIt()),
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

  getIt.registerLazySingleton(() => EmbeddingEngine());

  getIt.registerLazySingleton(
    () => TrackSourceResolver([
      getIt<LocalFileTrackSource>(),
      getIt<SoundcloudTrackSource>(),
    ]),
  );
  getIt.registerLazySingleton(
    () => EmbeddingWorker(
      repo: getIt<EmbeddingTaskRepository>(),
      engine: getIt<EmbeddingEngine>(),
    ),
  );

  getIt.registerLazySingleton(
    () => DownloadWorker(
      downloadRepository: getIt<DownloadTaskRepository>(),
      trackResolver: getIt<TrackSourceResolver>(),
      completeDownload: CompleteTrackDownloadUseCase(getIt()),
    ),
  );

  getIt.registerLazySingleton<AudioPlayerPort>(
    () => AudioPlayerService(appDir: getIt<String>()),
  );

  getIt.registerLazySingleton(() => WaveEngine());

  // usecases

  getIt.registerFactory(
    () => AddTrackUseCase(
      playlistRepository: getIt(),
      trackResolver: getIt(),
      trackRepository: getIt(),
      ingestionRepository: getIt(),
    ),
  );

  getIt.registerFactory(() => CompleteTrackDownloadUseCase(getIt()));

  getIt.registerFactory(
    () => RecoverListeningCheckpointUseCase(
      checkpoints: getIt(),
      saveRecord: SaveRecordPlayUseCase(repo: getIt()),
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
  getIt.registerFactory(
    () => EmbeddingStatusCubit(
      pendingCounts: getIt<EmbeddingTaskRepository>().watchPendingCount(),
    ),
  );
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
}
