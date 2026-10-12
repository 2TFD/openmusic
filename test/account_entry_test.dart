import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:owlsonic/core/app_router/app_router_names.dart';
import 'package:owlsonic/core/config/app_links.dart';
import 'package:owlsonic/core/config/owlsonic_api_config.dart';
import 'package:owlsonic/core/di/di.dart';
import 'package:owlsonic/core/network/owlsonic/auth_session.dart';
import 'package:owlsonic/core/services/cloud/auto_sync_settings.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/domain/entities/playlist.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/cloud_account_cubit.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/cloud_session_cubit.dart';
import 'package:owlsonic/layers/presentation/features/account/ui/account_entry_button.dart';
import 'package:owlsonic/layers/presentation/features/account/ui/cloud_account_screen.dart';
import 'package:owlsonic/layers/presentation/features/desktop_shell/ui/desktop_sidebar.dart';
import 'package:owlsonic/layers/presentation/features/playlist/bloc/playlist/playlist_bloc.dart';
import 'package:owlsonic/layers/presentation/features/settings/ui/settings_screen.dart';
import 'package:owlsonic/layers/presentation/features/statistic/bloc/statistic/statistic_bloc.dart';
import 'package:owlsonic/layers/presentation/features/telemetry/bloc/telemetry/telemetry_cubit.dart';
import 'package:owlsonic/layers/presentation/features/track/bloc/track/track_bloc.dart';
import 'package:owlsonic/layers/presentation/shared/blocs/music_analysis_status/music_analysis_status_cubit.dart';

import 'support/fake_owlsonic_backend.dart';

const _unconfigured = CloudSessionState(configured: false, signedIn: false);
const _signedOut = CloudSessionState(configured: true, signedIn: false);
const _signedIn = CloudSessionState(configured: true, signedIn: true);

void main() {
  const preferencesChannel = MethodChannel(
    'plugins.flutter.io/shared_preferences',
  );

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(preferencesChannel, (_) async => {});
    await EasyLocalization.ensureInitialized();
  });
  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(preferencesChannel, null);
  });
  tearDown(() async => getIt.reset());

  group('config', () {
    test('configured backend is distinct from signed-out', () async {
      final session = AuthSession(store: MemoryTokenStore());
      await session.restore();

      final configured = CloudSessionCubit(session: session, configured: true);
      addTearDown(configured.close);
      await Future<void>.delayed(Duration.zero);
      expect(configured.state, _signedOut);

      final unconfigured = CloudSessionCubit(
        session: session,
        configured: false,
      );
      addTearDown(unconfigured.close);
      expect(unconfigured.state, _unconfigured);
      expect(unconfigured.state, isNot(configured.state));
    });

    test('session cubit follows sign-in and sign-out', () async {
      final session = AuthSession(store: MemoryTokenStore());
      await session.restore();
      final cubit = CloudSessionCubit(session: session, configured: true);
      addTearDown(cubit.close);

      await session.signIn(tokens());
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state, _signedIn);

      await session.signOut();
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state, _signedOut);
    });

    test('API base URL decides isConfigured', () {
      expect(
        OwlSonicApiConfig(
          environment: OwlSonicEnvironment.development,
          baseUrl: 'https://api.owlsonic.stream',
        ).isConfigured,
        isTrue,
      );
      expect(
        OwlSonicApiConfig(
          environment: OwlSonicEnvironment.development,
        ).isConfigured,
        isFalse,
      );
    });

    test('.env.example documents the OwlSonic API base URL', () {
      expect(
        File('.env.example').readAsStringSync(),
        contains('OWLSONIC_API_BASE_URL=https://api.owlsonic.stream'),
      );
    });
  });

  group('mobile Home account button', () {
    testWidgets('signed out: outline icon, no dot; opens Account screen', (
      tester,
    ) async {
      await _pump(tester, const AccountEntryButton(), session: _signedOut);
      expect(find.byKey(const ValueKey('home-account-button')), findsOne);
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
      expect(find.byKey(const ValueKey('account-signed-in-dot')), findsNothing);

      await tester.tap(find.byKey(const ValueKey('home-account-button')));
      await tester.pumpAndSettle();
      expect(find.byType(CloudAccountScreen), findsOneWidget);
      expect(find.byKey(const ValueKey('cloud-submit')), findsOneWidget);
    });

    testWidgets('signed in: subtle dot on the same button', (tester) async {
      await _pump(tester, const AccountEntryButton(), session: _signedIn);
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
      expect(
        find.byKey(const ValueKey('account-signed-in-dot')),
        findsOneWidget,
      );
    });
  });

  group('desktop sidebar account entry', () {
    testWidgets('expanded sidebar opens the Account screen', (tester) async {
      await _pump(
        tester,
        const DesktopSidebar(compact: false),
        session: _signedOut,
        size: const Size(1280, 800),
      );
      expect(find.byKey(const ValueKey('sidebar-account')), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('sidebar-account')));
      await tester.pumpAndSettle();
      expect(find.byType(CloudAccountScreen), findsOneWidget);
    });

    testWidgets('compact rail keeps an icon entry with a tooltip', (
      tester,
    ) async {
      await _pump(
        tester,
        const DesktopSidebar(compact: true),
        session: _signedIn,
        size: const Size(800, 700),
      );
      expect(find.text('Account'), findsNothing);
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
      expect(find.byTooltip('Account'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('account-signed-in-dot')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('sidebar-account')));
      await tester.pumpAndSettle();
      expect(find.byType(CloudAccountScreen), findsOneWidget);
    });
  });

  group('Settings account row', () {
    Future<void> pumpSettings(
      WidgetTester tester,
      CloudSessionState session,
    ) async {
      await _pump(
        tester,
        const SettingsScreen(),
        session: session,
        size: const Size(800, 4000),
        extraProviders: [
          BlocProvider<StatisticBloc>.value(value: _FakeStatistic()),
          BlocProvider<MusicAnalysisStatusCubit>.value(value: _FakeAnalysis()),
          BlocProvider<TelemetryCubit>.value(value: _FakeTelemetry()),
        ],
      );
    }

    testWidgets('auto-sync switches change the setting; Wi-Fi only shows only '
        'while auto-sync is on', (tester) async {
      final settings = _MemoryAutoSync();
      getIt.registerSingleton<AutoSyncSettings>(settings);
      await pumpSettings(tester, _signedOut);

      final auto = find.byKey(const ValueKey('settings-auto-sync'));
      final wifi = find.byKey(const ValueKey('settings-wifi-only'));
      expect(find.text('Sync music automatically'), findsOneWidget);
      expect(
        tester.widget<Switch>(auto).value,
        isTrue,
        reason: 'on by default',
      );
      expect(wifi, findsOneWidget);
      expect(tester.widget<Switch>(wifi).value, isFalse);

      await tester.tap(wifi);
      await tester.pump();
      expect(settings.current.value.wifiOnly, isTrue);

      await tester.tap(auto);
      await tester.pump();
      expect(settings.current.value.enabled, isFalse);
      expect(wifi, findsNothing, reason: 'nothing to restrict when off');
    });

    testWidgets('auto-sync switches are hidden in builds without a cloud', (
      tester,
    ) async {
      getIt.registerSingleton<AutoSyncSettings>(_MemoryAutoSync());
      await pumpSettings(tester, _unconfigured);
      expect(find.byKey(const ValueKey('settings-auto-sync')), findsNothing);
    });

    testWidgets('signed out shows the sign-in hint', (tester) async {
      await pumpSettings(tester, _signedOut);
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Sign in to sync your library'), findsOneWidget);
    });

    testWidgets('signed in shows the signed-in state', (tester) async {
      await pumpSettings(tester, _signedIn);
      expect(find.text('Signed in'), findsOneWidget);
      expect(find.text('Sign in to sync your library'), findsNothing);
    });

    testWidgets('unconfigured is not presented as signed out', (tester) async {
      await pumpSettings(tester, _unconfigured);
      expect(find.text('Not available in this build'), findsOneWidget);
      expect(find.text('Sign in to sync your library'), findsNothing);
    });

    testWidgets('shows the installed version and build, not a fixed one', (
      tester,
    ) async {
      PackageInfo.setMockInitialValues(
        appName: 'OwlSonic',
        packageName: 'com.ttfd.owlsonic',
        version: '0.4.2',
        buildNumber: '17',
        buildSignature: '',
      );
      await pumpSettings(tester, _signedOut);
      await tester.tap(find.byKey(const ValueKey('settings-about')));
      await tester.pumpAndSettle();
      expect(find.text('0.4.2 (17)'), findsOneWidget);
      expect(find.text('0.1.0'), findsNothing);
    });

    testWidgets('privacy, terms, account deletion and support open the '
        'website while signed out', (tester) async {
      final opened = <Uri>[];
      final previous = AppLinks.opener;
      AppLinks.opener = (uri) async {
        opened.add(uri);
        return true;
      };
      addTearDown(() => AppLinks.opener = previous);
      await pumpSettings(tester, _signedOut);

      for (final key in [
        'settings-privacy',
        'settings-terms',
        'settings-account-deletion',
        'settings-support',
      ]) {
        await tester.tap(find.byKey(ValueKey(key)));
        await tester.pump();
      }
      expect(opened.map((uri) => '$uri'), [
        'https://owlsonic.stream/privacy',
        'https://owlsonic.stream/terms',
        'https://owlsonic.stream/account-deletion',
        'https://owlsonic.stream/support',
      ]);
      expect(find.byKey(const ValueKey('settings-about')), findsOneWidget);
      expect(find.byKey(const ValueKey('about-licenses')), findsNothing);
    });

    testWidgets('About app contains the version and opens licenses', (
      tester,
    ) async {
      await pumpSettings(tester, _signedOut);

      await tester.tap(find.byKey(const ValueKey('settings-about')));
      await tester.pumpAndSettle();
      expect(find.byType(AboutAppScreen), findsOneWidget);
      expect(find.text('About app'), findsOneWidget);
      expect(find.text('Version'), findsOneWidget);
      expect(find.byKey(const ValueKey('about-licenses')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('about-licenses')));
      await tester.pumpAndSettle();
      expect(find.byType(LicensePage), findsOneWidget);
    });

    testWidgets('a link that cannot open tells the user', (tester) async {
      final previous = AppLinks.opener;
      AppLinks.opener = (_) async => false;
      addTearDown(() => AppLinks.opener = previous);
      await pumpSettings(tester, _signedOut);

      await tester.tap(find.byKey(const ValueKey('settings-privacy')));
      await tester.pump();
      expect(
        find.text('Could not open https://owlsonic.stream/privacy'),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 5));
    });
  });
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  required CloudSessionState session,
  Size size = const Size(420, 900),
  List<BlocProvider> extraProviders = const [],
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(body: child),
      ),
      GoRoute(
        path: '/${AppRouterNames.account}',
        name: AppRouterNames.account,
        builder: (context, state) => BlocProvider<CloudAccountCubit>.value(
          value: _FakeAccount(),
          child: const CloudAccountScreen(),
        ),
      ),
      GoRoute(
        path: '/${AppRouterNames.settings}',
        name: AppRouterNames.settings,
        builder: (context, state) => const SizedBox(),
      ),
      GoRoute(
        path: '/${AppRouterNames.about}',
        name: AppRouterNames.about,
        builder: (context, state) => const AboutAppScreen(),
      ),
    ],
  );
  await tester.pumpWidget(
    EasyLocalization(
      assetLoader: const _DiskAssetLoader(),
      supportedLocales: const [Locale('en'), Locale('ru')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<CloudSessionCubit>.value(value: _FakeSession(session)),
          BlocProvider<PlaylistBloc>.value(value: _FakePlaylists()),
          BlocProvider<TrackBloc>.value(value: _FakeTracks()),
          ...extraProviders,
        ],
        child: Builder(
          builder: (context) => MaterialApp.router(
            theme: AppTheme.dark,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            routerConfig: router,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _DiskAssetLoader extends AssetLoader {
  const _DiskAssetLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async =>
      jsonDecode(File('$path/${locale.languageCode}.json').readAsStringSync())
          as Map<String, dynamic>;
}

class _FakeSession extends Fake implements CloudSessionCubit {
  _FakeSession(this._state);
  final CloudSessionState _state;
  @override
  CloudSessionState get state => _state;
  @override
  Stream<CloudSessionState> get stream => const Stream.empty();
  @override
  Future<void> close() async {}
}

class _FakeAccount extends Fake implements CloudAccountCubit {
  @override
  CloudAccountState get state =>
      const CloudAccountState(status: CloudAccountStatus.signedOut);
  @override
  Stream<CloudAccountState> get stream => const Stream.empty();
  @override
  Future<void> close() async {}
}

class _FakePlaylists extends Fake implements PlaylistBloc {
  @override
  PlaylistState get state => const PlaylistLoaded(<PlaylistSummary>[]);
  @override
  Stream<PlaylistState> get stream => const Stream.empty();
  @override
  Future<void> close() async {}
}

class _FakeTracks extends Fake implements TrackBloc {
  @override
  TrackState get state => const TrackLoaded([]);
  @override
  Stream<TrackState> get stream => const Stream.empty();
  @override
  Future<void> close() async {}
}

class _FakeStatistic extends Fake implements StatisticBloc {
  @override
  StatisticState get state => StatisticInitial();
  @override
  Stream<StatisticState> get stream => const Stream.empty();
  @override
  Future<void> close() async {}
}

class _FakeAnalysis extends Fake implements MusicAnalysisStatusCubit {
  @override
  MusicAnalysisStatusState get state => const MusicAnalysisStatusState();
  @override
  Stream<MusicAnalysisStatusState> get stream => const Stream.empty();
  @override
  Future<void> close() async {}
}

class _FakeTelemetry extends Fake implements TelemetryCubit {
  @override
  TelemetryState get state =>
      const TelemetryState(consentEnabled: false, available: false);
  @override
  Stream<TelemetryState> get stream => const Stream.empty();
  @override
  Future<void> close() async {}
}

class _MemoryAutoSync extends AutoSyncSettings {
  @override
  Future<void> setEnabled(bool value) async =>
      current.value = current.value.copyWith(enabled: value);

  @override
  Future<void> setWifiOnly(bool value) async =>
      current.value = current.value.copyWith(wifiOnly: value);
}
