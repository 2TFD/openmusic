import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audio_service/audio_service.dart';
import 'package:owlsonic/core/app_router/app_router.dart';
import 'package:owlsonic/core/bootstrap/app_bootstrap.dart';
import 'package:owlsonic/core/bootstrap/app_initializer.dart';
import 'package:owlsonic/core/bootstrap/app_lifecycle_scope.dart';
import 'package:owlsonic/core/bootstrap/bootstrap_host.dart';
import 'package:owlsonic/core/config/owlsonic_api_config.dart';
import 'package:owlsonic/core/di/bloc_scope.dart';
import 'package:owlsonic/core/di/di.dart';
import 'package:owlsonic/core/services/cloud/auto_sync_settings.dart';
import 'package:owlsonic/core/services/cloud/device_storage_mode_store.dart';
import 'package:owlsonic/core/services/audio_player/audio_player_service.dart';
import 'package:owlsonic/core/services/audio_player/owlsonic_audio_handler.dart';
import 'package:owlsonic/core/telemetry/sentry_crash_reporter.dart';
import 'package:owlsonic/core/telemetry/posthog_analytics_tracker.dart';
import 'package:owlsonic/core/telemetry/telemetry_consent_store.dart';
import 'package:owlsonic/core/network/owlsonic/auth_session.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/domain/repositories/playback_command_bus.dart';
import 'package:owlsonic/core/utils/app_bloc_observer.dart';
import 'package:owlsonic/core/utils/app_logger.dart';
import 'package:owlsonic/layers/presentation/features/onboarding/bloc/onboarding_cubit.dart';
import 'package:owlsonic/layers/presentation/features/onboarding/ui/welcome_screen.dart';
import 'package:owlsonic/layers/presentation/features/startup/ui/startup_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux) {
    JustAudioMediaKit.ensureInitialized();
  }

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    AppLogger.warning(
      'Flutter framework error',
      operation: 'flutter.framework',
    );
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.warning(
      'Unhandled asynchronous error',
      operation: 'flutter.platform_dispatcher',
    );
    return true;
  };
  Bloc.observer = const AppBlocObserver();

  final consentStore = SharedPreferencesTelemetryConsentStore();
  final crashReporter = SentryCrashReporter();
  final analyticsTracker = PostHogAnalyticsTracker();
  var consentEnabled = false;
  var analyticsEnabled = false;
  AppLogger.configure(crashReporter);

  String? appDir;
  AppBootstrap? bootstrap;
  final initializer = AppInitializer([
    BootstrapStep(BootstrapPhase.telemetryConsent, () async {
      try {
        consentEnabled = await consentStore.load();
        analyticsEnabled = await consentStore.loadAnalytics();
      } catch (error, stackTrace) {
        await AppLogger.captureException(
          error,
          stackTrace,
          operation: 'telemetry.load_consent',
        );
      }
    }),
    const BootstrapStep(
      BootstrapPhase.localization,
      EasyLocalization.ensureInitialized,
    ),
    BootstrapStep(BootstrapPhase.appDirectory, () async {
      appDir = (await getApplicationDocumentsDirectory()).path;
    }),
    BootstrapStep(BootstrapPhase.dependencies, () async {
      // A misconfigured release build stops here, on the startup error
      // screen, instead of shipping a cloud mode that can never connect.
      OwlSonicApiConfig.fromEnvironment().ensureReleaseReady(
        releaseMode: kReleaseMode,
      );
      if (getIt.isRegistered<String>()) await getIt.reset();
      await configureDependencies(
        appDir: appDir!,
        crashReporter: crashReporter,
        analyticsTracker: analyticsTracker,
        telemetryConsentStore: consentStore,
        initialTelemetryConsent: consentEnabled,
        initialAnalyticsConsent: analyticsEnabled,
      );
      // Playback reads the device storage mode on every request; the old
      // first-launch question no longer loads it.
      var lastEpoch = getIt<AuthSession>().epoch;
      getIt<AuthSession>().changes.listen((_) {
        final epoch = getIt<AuthSession>().epoch;
        if (epoch != lastEpoch) {
          lastEpoch = epoch;
          unawaited(analyticsTracker.resetIdentity());
        }
      });
      await getIt<DeviceStorageModeStore>().load();
      await getIt<AutoSyncSettings>().load();
    }),
    BootstrapStep(BootstrapPhase.recovery, () async {
      bootstrap ??= AppBootstrap(getIt);
      await bootstrap!.run();
    }),
    BootstrapStep(BootstrapPhase.audio, () async {
      await AudioService.init(
        builder: () => OwlsonicAudioHandler(
          player: getIt<AudioPlayerService>(),
          commands: getIt<PlaybackCommandBus>(),
        ),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.ttfd.owlsonic.audio',
          androidNotificationChannelName: 'Audio playback',
          androidNotificationOngoing: true,
        ),
      );
    }),
  ]);

  runApp(
    BootstrapHost(
      initializer: initializer,
      appBuilder: (_) => MainApp(
        onFirstFrame: () async {
          unawaited(bootstrap!.startDeferred());
          final stopwatch = Stopwatch()..start();
          if (consentEnabled) unawaited(crashReporter.setEnabled(true));
          if (analyticsEnabled) unawaited(analyticsTracker.setEnabled(true));
          stopwatch.stop();
          await AppLogger.info(
            'Deferred telemetry: ${stopwatch.elapsedMilliseconds} ms',
            operation: 'startup.deferred.telemetry',
          );
        },
      ),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, this.onFirstFrame});

  final Future<void> Function()? onFirstFrame;

  @override
  Widget build(BuildContext context) {
    return BlocScope(
      child: AppLifecycleScope(
        onFirstFrame: onFirstFrame,
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
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, onboardingState) {
        if (!onboardingState.isReady) return const StartupScreen();
        if (!onboardingState.isCompleted) return const WelcomeScreen();
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
