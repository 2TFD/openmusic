import 'package:get_it/get_it.dart';
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
import 'package:openmusic/layers/domain/repositories/download_task_repository.dart';
import 'package:openmusic/layers/domain/repositories/embedding_task_repository.dart';
import 'package:openmusic/layers/domain/repositories/play_record_repository.dart';
import 'package:openmusic/layers/domain/repositories/playlist_repository.dart';
import 'package:openmusic/layers/domain/repositories/search_source.dart';
import 'package:openmusic/layers/domain/repositories/track_repository.dart';
import 'package:openmusic/core/services/track_source_resolver.dart';
import 'package:openmusic/core/services/wave/wave_engine.dart';
import 'package:openmusic/layers/domain/usecases/add_track_use_case.dart';
import 'package:openmusic/layers/domain/usecases/complete_track_download_use_case.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies({required String appDir}) async {
  // primitive
  getIt.registerSingleton<String>(appDir);

  // datasource
  getIt.registerSingleton<AppDatabase>(appDatabase);

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
    DownloadTaskRepositoryImpl(localDataSource: getIt<DownloadTaskLocalDataSource>()),
  );

  getIt.registerLazySingleton<SearchSource>(
    () => SearchSourceImpl(trackRepository: getIt()),
  );

  // services

  getIt.registerLazySingleton(() => EmbeddingEngine());

  getIt.registerLazySingleton(
    () =>
        TrackSourceResolver([LocalFileTrackSource(), SoundcloudTrackSource()]),
  );
  getIt.registerLazySingleton(
    () => EmbeddingWorker(
      repo: getIt<EmbeddingTaskRepository>(),
      engine: getIt<EmbeddingEngine>(),
      trackRepository: getIt<TrackRepository>(),
    ),
  );

  getIt.registerLazySingleton(
    () => DownloadWorker(
      downloadRepository: getIt<DownloadTaskRepository>(),
      trackResolver: getIt<TrackSourceResolver>(),
      completeDownload: CompleteTrackDownloadUseCase(getIt(), getIt()),
    ),
  );

  getIt.registerLazySingleton(() => AudioPlayerService());

  getIt.registerLazySingleton(() => WaveEngine());

  // usecases

  getIt.registerFactory(
    () => AddTrackUseCase(
      playlistRepository: getIt(),
      downloadRepository: getIt(),
      completeDownload: CompleteTrackDownloadUseCase(getIt(), getIt()),
      trackResolver: getIt(),
      trackRepository: getIt(),
    ),
  );

  getIt.registerFactory(() => CompleteTrackDownloadUseCase(getIt(), getIt()));
}
