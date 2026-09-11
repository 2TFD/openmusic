import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audio_service/audio_service.dart';
import 'package:openmusic/core/app_router/app_router.dart';
import 'package:openmusic/core/bootstrap/app_bootstrap.dart';
import 'package:openmusic/core/bootstrap/app_initializer.dart';
import 'package:openmusic/core/bootstrap/app_lifecycle_scope.dart';
import 'package:openmusic/core/bootstrap/bootstrap_host.dart';
import 'package:openmusic/core/di/bloc_scope.dart';
import 'package:openmusic/core/di/di.dart';
import 'package:openmusic/core/services/audio_player/audio_player_service.dart';
import 'package:openmusic/core/services/audio_player/openmusic_audio_handler.dart';
import 'package:openmusic/core/telemetry/sentry_crash_reporter.dart';
import 'package:openmusic/core/telemetry/telemetry_consent_store.dart';
import 'package:openmusic/core/themes/app_theme.dart';
import 'package:openmusic/layers/domain/repositories/playback_command_bus.dart';
import 'package:openmusic/core/utils/app_bloc_observer.dart';
import 'package:openmusic/core/utils/app_logger.dart';
import 'package:openmusic/layers/presentation/blocs/track/track_bloc.dart';
import 'package:openmusic/layers/presentation/blocs/player/player_bloc.dart';
import 'package:openmusic/layers/presentation/screens/startup_screen.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    AppLogger.warning(
      '[FlutterError] ${details.exceptionAsString()}, '
      'stackTrace: ${details.stack}',
      operation: 'flutter.framework',
    );
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.warning(
      '[PlatformDispatcher] $error, stackTrace: $stack',
      operation: 'flutter.platform_dispatcher',
    );
    return true;
  };
  Bloc.observer = const AppBlocObserver();

  final consentStore = SharedPreferencesTelemetryConsentStore();
  final crashReporter = SentryCrashReporter();
  var consentEnabled = false;
  try {
    consentEnabled = await consentStore.load();
    await crashReporter.setEnabled(consentEnabled);
  } catch (error, stackTrace) {
    await AppLogger.captureException(
      error,
      stackTrace,
      operation: 'telemetry.initialize',
    );
  }
  AppLogger.configure(crashReporter);

  String? appDir;
  AppBootstrap? bootstrap;
  final initializer = AppInitializer([
    const BootstrapStep(
      BootstrapPhase.localization,
      EasyLocalization.ensureInitialized,
    ),
    BootstrapStep(BootstrapPhase.appDirectory, () async {
      appDir = (await getApplicationDocumentsDirectory()).path;
    }),
    BootstrapStep(BootstrapPhase.dependencies, () async {
      if (getIt.isRegistered<String>()) await getIt.reset();
      await configureDependencies(
        appDir: appDir!,
        crashReporter: crashReporter,
        telemetryConsentStore: consentStore,
        initialTelemetryConsent: consentEnabled,
      );
    }),
    BootstrapStep(BootstrapPhase.recovery, () async {
      bootstrap ??= AppBootstrap(getIt);
      await bootstrap!.run();
    }),
    BootstrapStep(
      BootstrapPhase.audio,
      () => AudioService.init(
        builder: () => OpenmusicAudioHandler(
          player: getIt<AudioPlayerService>(),
          commands: getIt<PlaybackCommandBus>(),
        ),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.ttfd.openmusic.audio',
          androidNotificationChannelName: 'Audio playback',
          androidNotificationOngoing: true,
        ),
      ),
    ),
  ]);

  runApp(
    BootstrapHost(initializer: initializer, appBuilder: (_) => const MainApp()),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocScope(
      child: AppLifecycleScope(
        child: MaterialApp.router(
          theme: AppTheme.dark,
          debugShowCheckedModeBanner: false,
          routerConfig: AppRouter.router,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          builder: (context, child) => _StartupGate(child: child),
        ),
      ),
    );
  }
}

class _StartupGate extends StatelessWidget {
  const _StartupGate({required this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackBloc, TrackState>(
      buildWhen: (previous, current) =>
          _tracksAreStarting(previous) != _tracksAreStarting(current),
      builder: (context, trackState) => BlocBuilder<PlayerBloc, PlayerState>(
        buildWhen: (previous, current) =>
            previous.isRestoring != current.isRestoring,
        builder: (context, playerState) {
          if (_tracksAreStarting(trackState) || playerState.isRestoring) {
            return const StartupScreen();
          }
          return child ?? const SizedBox.shrink();
        },
      ),
    );
  }

  static bool _tracksAreStarting(TrackState state) =>
      state is TrackInitial || state is TrackLoading;
}
