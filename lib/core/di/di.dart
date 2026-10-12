import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:owlsonic/core/errors/failures/failure.dart';
import 'package:owlsonic/core/services/download/download_worker.dart';
import 'package:owlsonic/core/services/music_analysis/music_analysis_model_registry.dart';
import 'package:owlsonic/core/services/lyrics/lyrics_backfill_service.dart';
import 'package:owlsonic/core/services/lyrics/lyrics_config.dart';
import 'package:owlsonic/core/services/lyrics/lyrics_resolution_worker.dart';
import 'package:owlsonic/core/services/lyrics/lyrics_resolver.dart';
import 'package:owlsonic/core/services/research/lyrics_semantic_research_service.dart';
import 'package:owlsonic/core/services/recommendation/mood_wave_config.dart';
import 'package:owlsonic/core/services/recommendation/mood_wave_engine.dart';
import 'package:owlsonic/core/services/recommendation/wave_playability.dart';
import 'package:owlsonic/core/services/recommendation/track_wave_config.dart';
import 'package:owlsonic/core/services/recommendation/track_wave_engine.dart';
import 'package:owlsonic/core/services/recommendation/artist_wave_config.dart';
import 'package:owlsonic/core/services/recommendation/artist_wave_engine.dart';
import 'package:owlsonic/core/services/recommendation/wave_recommendation_config.dart';
import 'package:owlsonic/core/services/recommendation/wave_recommendation_engine.dart';
import 'package:owlsonic/core/services/track_identity/sha256_track_content_identity_service.dart';
import 'package:owlsonic/core/services/track_external_actions_service.dart';
import 'package:owlsonic/layers/data/database/app_database.dart';
import 'package:owlsonic/layers/data/datasources/local/artist/artist_local_data_source.dart';
import 'package:owlsonic/layers/data/datasources/local/artist/drift/artist_drift_local_source.dart';
import 'package:owlsonic/layers/data/datasources/local/download_task/download_task_local_data_source.dart';
import 'package:owlsonic/layers/data/datasources/local/download_task/drift/download_task_drift_local_source.dart';
import 'package:owlsonic/layers/data/datasources/local/playlist/drift/playlist_drift_local_source.dart';
import 'package:owlsonic/layers/data/datasources/local/playlist/playlist_local_data_source.dart';
import 'package:owlsonic/layers/data/datasources/local/track/drift/track_drift_local_source.dart';
import 'package:owlsonic/layers/data/datasources/local/track/track_local_data_source.dart';
import 'package:owlsonic/core/services/audio_player/audio_player_service.dart';
import 'package:owlsonic/core/services/audio_player/playback_command_bus_impl.dart';
import 'package:owlsonic/layers/domain/repositories/playback_command_bus.dart';
import 'package:owlsonic/layers/data/datasources/local/listening_summary/drift/listening_summary_drift_local_source.dart';
import 'package:owlsonic/layers/data/datasources/local/listening_summary/listening_summary_local_data_source.dart';
import 'package:owlsonic/layers/data/datasources/remote/local_file_track_source.dart';
import 'package:owlsonic/layers/data/datasources/lyrics/embedded_lyrics_metadata_reader.dart';
import 'package:owlsonic/layers/data/datasources/lyrics/embedded_lyrics_provider.dart';
import 'package:owlsonic/layers/data/datasources/lyrics/lrclib_lyrics_provider.dart';
import 'package:owlsonic/layers/data/datasources/lyrics/sidecar_lrc_lyrics_provider.dart';
import 'package:owlsonic/layers/data/datasources/remote/soundcloud_track_source.dart';
import 'package:owlsonic/layers/data/datasources/remote/spotify_track_source.dart';
import 'package:owlsonic/layers/data/datasources/remote/youtube_track_source.dart';
import 'package:owlsonic/layers/data/repositories/download_repository_impl.dart';
import 'package:owlsonic/layers/data/repositories/artist_repository_impl.dart';
import 'package:owlsonic/layers/data/repositories/listening_summary_repository_impl.dart';
import 'package:owlsonic/layers/data/repositories/playlist_repository_impl.dart';
import 'package:owlsonic/layers/data/repositories/search_source_impl.dart';
import 'package:owlsonic/layers/data/repositories/track_repository_impl.dart';
import 'package:owlsonic/layers/data/repositories/track_embedding_repository_impl.dart';
import 'package:owlsonic/layers/data/repositories/listening_event_repository_impl.dart';
import 'package:owlsonic/layers/data/repositories/music_analysis_task_repository_impl.dart';
import 'package:owlsonic/layers/data/repositories/lyrics_resolution_task_repository_impl.dart';
import 'package:owlsonic/layers/data/repositories/track_lyrics_repository_impl.dart';
import 'package:owlsonic/layers/data/repositories/similarity_evaluation_repository_impl.dart';
import 'package:owlsonic/layers/data/repositories/track_removal_repository_impl.dart';
import 'package:owlsonic/layers/data/repositories/listening_checkpoint_repository_impl.dart';
import 'package:owlsonic/layers/data/repositories/playback_session_repository_impl.dart';
import 'package:owlsonic/layers/data/repositories/track_duplicate_lookup_impl.dart';
import 'package:owlsonic/layers/data/repositories/track_ingestion_repository_impl.dart';
import 'package:owlsonic/layers/data/repositories/track_temporal_embedding_repository_impl.dart';
import 'package:owlsonic/layers/data/repositories/track_download_completion_repository_impl.dart';
import 'package:owlsonic/layers/data/repositories/track_emotion_repository_impl.dart';
import 'package:owlsonic/layers/data/repositories/mood_map_repository_impl.dart';
import 'package:owlsonic/layers/domain/repositories/download_task_repository.dart';
import 'package:owlsonic/layers/domain/repositories/artist_repository.dart';
import 'package:owlsonic/layers/domain/repositories/audio_player_port.dart';
import 'package:owlsonic/layers/domain/repositories/local_track_picker.dart';
import 'package:owlsonic/layers/domain/repositories/listening_summary_repository.dart';
import 'package:owlsonic/layers/domain/repositories/playlist_repository.dart';
import 'package:owlsonic/layers/domain/repositories/search_source.dart';
import 'package:owlsonic/layers/domain/repositories/track_repository.dart';
import 'package:owlsonic/layers/domain/repositories/track_content_identity_service.dart';
import 'package:owlsonic/layers/domain/repositories/track_embedding_repository.dart';
import 'package:owlsonic/layers/domain/repositories/track_temporal_embedding_repository.dart';
import 'package:owlsonic/layers/domain/repositories/listening_event_repository.dart';
import 'package:owlsonic/layers/domain/repositories/music_analysis_task_repository.dart';
import 'package:owlsonic/layers/domain/repositories/lyrics_resolution_task_repository.dart';
import 'package:owlsonic/layers/domain/repositories/track_lyrics_repository.dart';
import 'package:owlsonic/layers/domain/repositories/similarity_evaluation_repository.dart';
import 'package:owlsonic/layers/domain/repositories/track_removal_repository.dart';
import 'package:owlsonic/layers/domain/repositories/listening_checkpoint_repository.dart';
import 'package:owlsonic/layers/domain/repositories/playback_session_repository.dart';
import 'package:owlsonic/layers/domain/repositories/track_ingestion_repository.dart';
import 'package:owlsonic/layers/domain/repositories/track_download_completion_repository.dart';
import 'package:owlsonic/layers/domain/repositories/track_emotion_repository.dart';
import 'package:owlsonic/layers/domain/repositories/mood_map_repository.dart';
import 'package:owlsonic/layers/domain/repositories/track_external_actions.dart';
import 'package:owlsonic/core/services/track_source_resolver.dart';
import 'package:owlsonic/layers/domain/usecases/add_track_use_case.dart';
import 'package:owlsonic/layers/domain/usecases/add_track_to_playlist_use_case.dart';
import 'package:owlsonic/layers/domain/usecases/complete_track_download_use_case.dart';
import 'package:owlsonic/layers/domain/usecases/delete_playlist_use_case.dart';
import 'package:owlsonic/layers/domain/usecases/get_playlist_with_tracks_use_case.dart';
import 'package:owlsonic/layers/domain/usecases/get_artist_tracks_use_case.dart';
import 'package:owlsonic/layers/domain/repositories/local_file_scanner.dart';
import 'package:owlsonic/layers/domain/repositories/track_duplicate_lookup.dart';
import 'package:owlsonic/layers/domain/usecases/import_local_track_item_use_case.dart';
import 'package:owlsonic/layers/domain/usecases/import_local_tracks_use_case.dart';
import 'package:owlsonic/layers/domain/usecases/scan_local_import_use_case.dart';
import 'package:owlsonic/layers/domain/usecases/pick_local_tracks_use_case.dart';
import 'package:owlsonic/layers/domain/usecases/update_playlist_use_case.dart';
import 'package:owlsonic/layers/domain/usecases/watch_playlist_use_case.dart';
import 'package:owlsonic/layers/domain/usecases/watch_artist_use_case.dart';
import 'package:owlsonic/layers/domain/usecases/recover_listening_checkpoint_use_case.dart';
import 'package:owlsonic/layers/domain/usecases/restore_playback_session_use_case.dart';
import 'package:owlsonic/layers/domain/usecases/save_listening_summary_use_case.dart';
import 'package:owlsonic/layers/domain/usecases/save_listening_event_use_case.dart';
import 'package:owlsonic/layers/domain/services/listening_tracker.dart';
import 'package:owlsonic/layers/domain/usecases/queue_lyrics_resolution_use_case.dart';
import 'package:owlsonic/layers/presentation/features/cloud_status/cloud_status_cubit.dart';
import 'package:owlsonic/layers/presentation/features/wave/bloc/wave_readiness_cubit.dart';
import 'package:owlsonic/layers/presentation/shared/blocs/music_analysis_status/music_analysis_status_cubit.dart';
import 'package:owlsonic/layers/presentation/features/artist/bloc/artist_detail/artist_detail_bloc.dart';
import 'package:owlsonic/layers/presentation/features/import_music/bloc/import_music/import_music_cubit.dart';
import 'package:owlsonic/layers/presentation/features/import_music/bloc/import_workspace/import_workspace_cubit.dart';
import 'package:owlsonic/layers/presentation/features/playlist/bloc/playlist_detail/playlist_detail_bloc.dart';
import 'package:owlsonic/layers/presentation/features/mood_map/bloc/mood_map/mood_map_cubit.dart';
import 'package:owlsonic/core/telemetry/crash_reporter.dart';
import 'package:owlsonic/core/telemetry/analytics_tracker.dart';
import 'package:owlsonic/core/telemetry/telemetry_consent_store.dart';
import 'package:owlsonic/layers/presentation/features/telemetry/bloc/telemetry/telemetry_cubit.dart';
import 'package:owlsonic/layers/presentation/features/onboarding/onboarding_store.dart';
import 'package:owlsonic/layers/presentation/features/onboarding/bloc/onboarding_cubit.dart';

import 'package:owlsonic/core/config/owlsonic_api_config.dart';
import 'package:owlsonic/core/network/owlsonic/auth_session.dart';
import 'package:owlsonic/core/network/owlsonic/auth_token_store.dart';
import 'package:owlsonic/core/network/owlsonic/installation_identity.dart';
import 'package:owlsonic/core/network/owlsonic/pending_verification_store.dart';
import 'package:owlsonic/core/network/owlsonic/owlsonic_api_client.dart';
import 'package:owlsonic/core/services/cloud/auto_sync_service.dart';
import 'package:owlsonic/core/services/cloud/auto_sync_settings.dart';
import 'package:owlsonic/core/services/cloud/cloud_playlist_sync.dart';
import 'package:owlsonic/core/services/cloud/cloud_playback_source.dart';
import 'package:owlsonic/core/services/cloud/cloud_audio_cache.dart';
import 'package:owlsonic/core/services/cloud/cloud_offline_library.dart';
import 'package:owlsonic/core/services/cloud/device_storage_mode_store.dart';
import 'package:owlsonic/core/services/storage/free_space_probe.dart';
import 'package:owlsonic/core/services/cloud/play_event_queue.dart';
import 'package:owlsonic/core/services/cloud/signed_url_cache.dart';
import 'package:owlsonic/core/services/cloud/sync_engine.dart';
import 'package:owlsonic/layers/data/repositories/owlsonic_cloud_repositories.dart';
import 'package:owlsonic/layers/data/repositories/cloud_aware_repositories.dart';
import 'package:owlsonic/layers/data/repositories/cloud_local_store.dart';
import 'package:owlsonic/layers/data/repositories/cloud_upload_store.dart';
import 'package:owlsonic/core/services/cloud/cloud_import_service.dart';
import 'package:owlsonic/core/services/cloud/local_library_migration.dart';
import 'package:owlsonic/core/services/cloud/discover_service.dart';
import 'package:owlsonic/core/services/cloud/cloud_sync_coordinator.dart';
import 'package:owlsonic/layers/data/repositories/owlsonic_track_upload_repository.dart';
import 'package:owlsonic/layers/domain/repositories/cloud_repositories.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/cloud_account_cubit.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/password_reset_cubit.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/verify_email_cubit.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/cloud_session_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies({
  required String appDir,
  AppDatabase? database,
  CrashReporter crashReporter = const NoopCrashReporter(),
  AnalyticsTracker analyticsTracker = const NoopAnalyticsTracker(),
  TelemetryConsentStore? telemetryConsentStore,
  bool initialTelemetryConsent = false,
  bool initialAnalyticsConsent = false,
}) async {
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);
  // primitive
  getIt.registerSingleton<String>(appDir);
  getIt.registerSingleton<CrashReporter>(crashReporter);
  getIt.registerSingleton<AnalyticsTracker>(analyticsTracker);
  getIt.registerSingleton<TelemetryConsentStore>(
    telemetryConsentStore ?? SharedPreferencesTelemetryConsentStore(),
  );
  getIt.registerSingleton<bool>(
    initialTelemetryConsent,
    instanceName: 'initialTelemetryConsent',
  );
  getIt.registerSingleton<bool>(
    initialAnalyticsConsent,
    instanceName: 'initialAnalyticsConsent',
  );

  // datasource
  getIt.registerSingleton<AppDatabase>(database ?? AppDatabase());

  getIt.registerLazySingleton<LocalFileTrackSource>(LocalFileTrackSource.new);
  getIt.registerLazySingleton<SoundcloudTrackSource>(SoundcloudTrackSource.new);
  getIt.registerLazySingleton<YoutubeTrackSource>(YoutubeTrackSource.new);
  getIt.registerLazySingleton(
    () => SpotifyTrackSource(
      youtube: getIt(),
      soundcloud: getIt<SoundcloudTrackSource>(),
      soundcloudSearch: (query) => getIt<SearchSource>().searchExternal(query),
    ),
  );
  getIt.registerLazySingleton<LocalTrackPicker>(
    () => getIt<LocalFileTrackSource>(),
  );
  getIt.registerLazySingleton<LocalFileScanner>(
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

  // OwlSonic cloud. The client never talks to the ML worker; all requests go
  // through OwlSonicApiClient to the configured OWLSONIC_API_BASE_URL.
  getIt.registerLazySingleton(OwlSonicApiConfig.fromEnvironment);
  getIt.registerLazySingleton<AuthTokenStore>(SecureAuthTokenStore.new);
  getIt.registerLazySingleton(() => AuthSession(store: getIt()));
  getIt.registerLazySingleton(InstallationIdentity.new);
  getIt.registerLazySingleton<PendingVerificationStore>(
    SharedPreferencesPendingVerificationStore.new,
  );
  getIt.registerLazySingleton(
    () => OwlSonicApiClient(config: getIt(), session: getIt()),
  );
  getIt.registerLazySingleton<CloudAuthRepository>(
    () => OwlSonicAuthRepository(
      client: getIt(),
      identity: getIt(),
      pending: getIt(),
    ),
  );
  getIt.registerLazySingleton<CloudAccountRepository>(
    () => OwlSonicAccountRepository(getIt()),
  );
  getIt.registerLazySingleton<CloudLibraryRepository>(
    () => OwlSonicLibraryRepository(getIt()),
  );
  getIt.registerLazySingleton<CloudPlaylistRepository>(
    () => OwlSonicPlaylistRepository(getIt()),
  );
  getIt.registerLazySingleton<CloudHistoryRepository>(
    () => OwlSonicHistoryRepository(getIt()),
  );
  getIt.registerLazySingleton<CloudDiscoverRepository>(
    () => OwlSonicDiscoverRepository(getIt()),
  );
  getIt.registerLazySingleton<CloudSyncRepository>(
    () => OwlSonicSyncRepository(getIt()),
  );
  getIt.registerLazySingleton<CloudTrackUploadRepository>(
    () => OwlSonicTrackUploadRepository(getIt()),
  );
  getIt.registerLazySingleton(
    () => PlayEventQueue(
      store: SharedPreferencesPlayEventStore(),
      history: getIt(),
      session: getIt(),
      accountId: () => getIt<CloudSyncCoordinator>().currentAccountId,
    ),
  );
  getIt.registerLazySingleton(
    () => SignedUrlCache(
      fetch: (trackId) => getIt<CloudLibraryRepository>().playbackUrl(trackId),
    ),
    instanceName: 'cloudPlaybackUrls',
  );
  getIt.registerLazySingleton(
    () => CloudAudioCache(
      directory: () async => Directory(
        p.join((await getApplicationCacheDirectory()).path, 'cloud_audio'),
      ),
      playbackUrl: (trackId) async => (await getIt<SignedUrlCache>(
        instanceName: 'cloudPlaybackUrls',
      ).get(trackId)).url,
      space: const PlatformFreeSpaceProbe(),
    ),
  );
  getIt.registerLazySingleton(
    () => CloudPlaybackSourceSelector(
      playbackUrls: getIt<SignedUrlCache>(instanceName: 'cloudPlaybackUrls'),
      audioCache: getIt<CloudAudioCache>(),
      // Offline mode downloads the whole library itself.
      cacheStreamed: () =>
          getIt<DeviceStorageModeStore>().effective == DeviceStorageMode.stream,
    ),
  );
  getIt.registerLazySingleton(
    () => SignedUrlCache(
      fetch: (trackId) => getIt<CloudLibraryRepository>().artworkUrl(trackId),
    ),
    instanceName: 'cloudArtworkUrls',
  );
  getIt.registerLazySingleton(() => CloudLocalStore(getIt<AppDatabase>()));
  getIt.registerLazySingleton(() => CloudUploadStore(getIt<AppDatabase>()));
  bool cloudEnabled() =>
      getIt<OwlSonicApiConfig>().isConfigured &&
      getIt<AuthSession>().isSignedIn;
  getIt.registerLazySingleton(
    () => CloudMutationContext(
      store: getIt(),
      isEnabled: cloudEnabled,
      requestSync: () => unawaited(getIt<CloudSyncCoordinator>().requestSync()),
      autoSyncEnabled: () => getIt<AutoSyncSettings>().current.value.enabled,
    ),
  );
  getIt.registerLazySingleton(
    () => CloudSyncCoordinator(
      session: getIt(),
      analytics: getIt(),
      configured: getIt<OwlSonicApiConfig>().isConfigured,
      account: getIt(),
      remote: getIt(),
      local: getIt(),
      owner: SharedPreferencesCloudAccountOwnerStore(),
      cursorsFor: (accountId) =>
          SharedPreferencesSyncCursorStore(accountId: accountId),
      afterSync: [
        () => getIt<PlayEventQueue>().flush(),
        () async => unawaited(getIt<CloudImportService>().resumePending()),
        () async => unawaited(getIt<CloudOfflineLibrary>().run()),
        () async => unawaited(getIt<AutoSyncService>().run()),
      ],
      afterPurge: [
        () => getIt<CloudOfflineLibrary>().onSignedOut(),
        () => getIt<CloudAudioCache>().clear(),
        () => getIt<PlayEventQueue>().clear(),
      ],
    ),
  );
  getIt.registerLazySingleton(
    () => CloudImportService(
      session: getIt(),
      configured: getIt<OwlSonicApiConfig>().isConfigured,
      uploader: getIt(),
      uploads: getIt(),
      local: getIt(),
      policy: getIt<AutoSyncPolicy>(),
      onLibraryChanged: () =>
          unawaited(getIt<CloudSyncCoordinator>().requestSync()),
    ),
  );
  getIt.registerLazySingleton(AutoSyncSettings.new);
  getIt.registerLazySingleton<NetworkProbe>(ConnectivityNetworkProbe.new);
  getIt.registerLazySingleton(
    () => AutoSyncPolicy(
      settings: getIt<AutoSyncSettings>(),
      network: getIt<NetworkProbe>(),
    ),
  );
  getIt.registerLazySingleton(
    () => CloudPlaylistSync(store: getIt(), remote: getIt()),
  );
  getIt.registerLazySingleton(
    () => AutoSyncService(
      session: getIt(),
      policy: getIt<AutoSyncPolicy>(),
      tracks: getIt<LocalLibraryMigration>(),
      playlists: getIt<CloudPlaylistSync>(),
      configured: getIt<OwlSonicApiConfig>().isConfigured,
    ),
  );

  // repositories

  getIt.registerLazySingleton<TrackRepository>(
    () => CloudAwareTrackRepository(
      local: TrackRepositoryImpl(
        localDataSource: getIt<TrackLocalDataSource>(),
      ),
      remote: getIt(),
      cloud: getIt(),
    ),
  );

  getIt.registerLazySingleton<TrackEmbeddingRepository>(
    () => TrackEmbeddingRepositoryImpl(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<TrackTemporalEmbeddingRepository>(
    () => TrackTemporalEmbeddingRepositoryImpl(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<TrackEmotionRepository>(
    () => TrackEmotionRepositoryImpl(getIt<AppDatabase>()),
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
    () => CloudAwareTrackRemovalRepository(
      local: TrackRemovalRepositoryImpl(
        database: getIt<AppDatabase>(),
        appDir: getIt<String>(),
      ),
      remote: getIt(),
      cloud: getIt(),
    ),
  );

  getIt.registerLazySingleton<ListeningCheckpointRepository>(
    () => ListeningCheckpointRepositoryImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<PlaybackSessionRepository>(
    () => PlaybackSessionRepositoryImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<PlaylistRepository>(
    () => CloudAwarePlaylistRepository(
      local: PlaylistRepositoryImpl(localDataSource: getIt()),
      remote: getIt(),
      cloud: getIt(),
    ),
  );

  getIt.registerLazySingleton<ListeningSummaryRepository>(
    () => CloudAwareListeningSummaryRepository(
      local: ListeningSummaryRepositoryImpl(localDataSource: getIt()),
      queue: getIt(),
      isEnabled: cloudEnabled,
    ),
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

  getIt.registerLazySingleton<TrackDuplicateLookup>(
    () => TrackDuplicateLookupImpl(
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

  getIt.registerLazySingleton(() => LyricsConfig());
  getIt.registerLazySingleton(
    () => MusicAnalysisModelRegistry(
      prefs: getIt<SharedPreferences>(),
      cloudModels: getIt<CloudLocalStore>().cloudModels,
    ),
  );
  getIt.registerLazySingleton<MoodMapRepository>(
    () => CloudAwareMoodMapRepository(
      local: MoodMapRepositoryImpl(
        database: getIt(),
        tracks: getIt(),
        emotions: getIt(),
        registry: getIt(),
      ),
      remote: getIt(),
      cloud: getIt(),
    ),
  );
  getIt.registerLazySingleton<TrackContentIdentityService>(
    Sha256TrackContentIdentityService.new,
  );

  getIt.registerLazySingleton(
    () => TrackSourceResolver([
      getIt<LocalFileTrackSource>(),
      getIt<SoundcloudTrackSource>(),
      getIt<YoutubeTrackSource>(),
      getIt<SpotifyTrackSource>(),
    ]),
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

  getIt.registerLazySingleton(
    () => DownloadWorker(
      downloadRepository: getIt<DownloadTaskRepository>(),
      trackResolver: getIt<TrackSourceResolver>(),
      completeDownload: getIt<CompleteTrackDownloadUseCase>(),
      analytics: getIt(),
      trackRepository: getIt<TrackRepository>(),
    ),
  );

  getIt.registerLazySingleton<AudioPlayerService>(
    () => AudioPlayerService(
      appDir: getIt<String>(),
      cloudPlayback: getIt<CloudPlaybackSourceSelector>(),
    ),
  );
  getIt.registerLazySingleton<AudioPlayerPort>(
    () => getIt<AudioPlayerService>(),
  );
  getIt.registerLazySingleton<PlaybackCommandBus>(
    () => PlaybackCommandBusImpl(),
  );
  getIt.registerLazySingleton<TrackExternalActions>(
    () => TrackExternalActionsService(appDirectory: getIt<String>()),
  );

  getIt.registerLazySingleton<MoodWaveConfig>(() => const MoodWaveConfig());
  getIt.registerLazySingleton(
    () => WavePlayability(
      isOnline: () async => (await Connectivity().checkConnectivity()).any(
        (result) => result != ConnectivityResult.none,
      ),
      changes: Connectivity().onConnectivityChanged.map((_) {}),
      hasCachedAudio: (trackId) => getIt<CloudAudioCache>().hasCached(trackId),
      warmUpCache: () => getIt<CloudAudioCache>().warmUp(),
    ),
  );
  getIt.registerLazySingleton<MoodWaveEngine>(
    () => MoodWaveEngine(
      isPlayable: getIt<WavePlayability>().isPlayable,
      moods: getIt<MoodMapRepository>(),
      globalEmbeddings: getIt<TrackEmbeddingRepository>(),
      temporalEmbeddings: getIt<TrackTemporalEmbeddingRepository>(),
      registry: getIt<MusicAnalysisModelRegistry>(),
      config: getIt<MoodWaveConfig>(),
    ),
  );
  getIt.registerLazySingleton<TrackWaveConfig>(() => const TrackWaveConfig());
  getIt.registerLazySingleton<TrackWaveEngine>(
    () => TrackWaveEngine(
      isPlayable: getIt<WavePlayability>().isPlayable,
      tracks: getIt<TrackRepository>(),
      globalEmbeddings: getIt<TrackEmbeddingRepository>(),
      temporalEmbeddings: getIt<TrackTemporalEmbeddingRepository>(),
      registry: getIt<MusicAnalysisModelRegistry>(),
      config: getIt<TrackWaveConfig>(),
    ),
  );
  getIt.registerLazySingleton<ArtistWaveConfig>(() => const ArtistWaveConfig());
  getIt.registerLazySingleton<ArtistWaveEngine>(
    () => ArtistWaveEngine(
      isPlayable: getIt<WavePlayability>().isPlayable,
      tracks: getIt<TrackRepository>(),
      globalEmbeddings: getIt<TrackEmbeddingRepository>(),
      temporalEmbeddings: getIt<TrackTemporalEmbeddingRepository>(),
      registry: getIt<MusicAnalysisModelRegistry>(),
      config: getIt<ArtistWaveConfig>(),
    ),
  );
  getIt.registerLazySingleton<WaveContinuationConfig>(
    () => const WaveContinuationConfig(),
  );
  getIt.registerLazySingleton<WaveRecommendationEngine>(
    () => WaveRecommendationEngine(
      mood: getIt<MoodWaveEngine>(),
      track: getIt<TrackWaveEngine>(),
      artist: getIt<ArtistWaveEngine>(),
      continuationConfig: getIt<WaveContinuationConfig>(),
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
      analytics: getIt(),
      queueLyrics: getIt(),
      duplicateLookup: getIt(),
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
      queueLyrics: getIt(),
      onDownloaded: getIt<LocalLibraryMigration>().uploadDownloaded,
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

  getIt.registerFactory(
    () => ScanLocalImportUseCase(
      scanner: getIt(),
      identity: getIt(),
      duplicates: getIt(),
      tracks: getIt(),
    ),
  );
  getIt.registerFactory(
    () => ImportLocalTrackItemUseCase(getIt<AddTrackUseCase>().addResolved),
  );

  // Route-scoped presentation objects. The router owns their lifecycle.
  getIt.registerFactory(
    () => ImportMusicCubit(
      pickLocalTracks: getIt(),
      importLocalTracks: getIt(),
      cloudImport: getIt(),
      identity: getIt(),
    ),
  );
  getIt.registerFactory(
    () => ImportWorkspaceCubit(
      scan: getIt(),
      importItem: getIt(),
      cloudImport: getIt(),
    ),
  );
  getIt.registerFactory(
    () => MusicAnalysisStatusCubit(
      tasks: getIt(),
      emotions: getIt(),
      cloudStatuses: getIt<CloudLocalStore>().watchAnalysisStatuses(),
    ),
  );
  getIt.registerFactory(
    () => MoodMapCubit(repository: getIt(), analytics: getIt()),
  );
  getIt.registerFactory(
    () => TelemetryCubit(
      reporter: getIt(),
      analytics: getIt(),
      consentStore: getIt(),
      initialConsent: getIt(instanceName: 'initialTelemetryConsent'),
      initialAnalyticsConsent: getIt(instanceName: 'initialAnalyticsConsent'),
    ),
  );
  getIt.registerLazySingleton(DeviceStorageModeStore.new);
  getIt.registerFactory(
    () => CloudSessionCubit(
      session: getIt(),
      configured: getIt<OwlSonicApiConfig>().isConfigured,
    ),
  );
  getIt.registerFactory(
    () => CloudStatusCubit(
      configured: getIt<OwlSonicApiConfig>().isConfigured,
      session: getIt(),
      currentSync: () => getIt<CloudSyncCoordinator>().status,
      syncChanges: getIt<CloudSyncCoordinator>().statusChanges,
      pendingUploads: () async =>
          (await getIt<CloudUploadStore>().pending()).length,
      requestSync: () => unawaited(getIt<CloudSyncCoordinator>().requestSync()),
    ),
  );
  getIt.registerFactory(
    () => WaveReadinessCubit(repository: getIt<MoodMapRepository>()),
  );
  getIt.registerFactory(
    () => VerifyEmailCubit(auth: getIt(), analytics: getIt()),
  );
  getIt.registerFactory(() => PasswordResetCubit(auth: getIt()));
  getIt.registerFactory(
    () => CloudAccountCubit(
      session: getIt(),
      configured: getIt<OwlSonicApiConfig>().isConfigured,
      auth: getIt(),
      account: getIt(),
      storageMode: getIt(),
      migration: getIt(),
      sync: getIt(),
      offline: getIt(),
    ),
  );
  getIt.registerLazySingleton(
    () => CloudOfflineLibrary(
      store: getIt<CloudLocalStore>(),
      tracks: getIt(),
      mode: getIt<DeviceStorageModeStore>(),
      isEnabled: cloudEnabled,
      playbackUrl: (trackId) async => (await getIt<SignedUrlCache>(
        instanceName: 'cloudPlaybackUrls',
      ).get(trackId)).url,
      artworkUrl: (trackId) async => (await getIt<SignedUrlCache>(
        instanceName: 'cloudArtworkUrls',
      ).get(trackId)).url,
      cache: getIt<CloudAudioCache>(),
      appDir: getIt<String>(),
    ),
  );
  getIt.registerLazySingleton(
    () => DiscoverService(
      remote: getIt(),
      local: getIt(),
      requestSync: () => unawaited(getIt<CloudSyncCoordinator>().requestSync()),
    ),
  );
  getIt.registerLazySingleton(
    () => LocalLibraryMigration(
      tracks: getIt(),
      uploads: getIt(),
      importer: getIt(),
      appDir: getIt<String>(),
    ),
  );
  getIt.registerLazySingleton<OnboardingStore>(
    () => SharedPreferencesOnboardingStore(),
  );
  getIt.registerFactory(() => OnboardingCubit(getIt()));
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
