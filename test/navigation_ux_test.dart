import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:owlsonic/core/app_router/app_router.dart';
import 'package:owlsonic/core/app_router/app_router_names.dart';
import 'package:owlsonic/core/services/cloud/cloud_offline_library.dart';
import 'package:owlsonic/core/services/cloud/device_storage_mode_store.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/cloud_account_cubit.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/cloud_session_cubit.dart';
import 'package:owlsonic/layers/presentation/features/account/ui/cloud_account_screen.dart';
import 'package:owlsonic/layers/presentation/features/desktop_shell/ui/desktop_sidebar.dart';
import 'package:owlsonic/layers/presentation/features/playlist/bloc/playlist/playlist_bloc.dart';
import 'package:owlsonic/layers/presentation/features/track/bloc/track/track_bloc.dart';

import 'support/ux_harness.dart';

class _FakeAccountCubit extends Fake implements CloudAccountCubit {
  _FakeAccountCubit(this._state);
  final CloudAccountState _state;
  @override
  CloudAccountState get state => _state;
  @override
  Stream<CloudAccountState> get stream => const Stream.empty();
  @override
  ValueListenable<OfflineProgress>? get offlineProgress => null;
  @override
  Future<void> close() async {}
}

void main() {
  useTestLocalization();

  final visited = <String>[];
  setUp(visited.clear);

  List<GoRoute> stubRoutes(Iterable<String> names) => [
    for (final name in names)
      GoRoute(
        path: '/$name',
        name: name,
        builder: (_, _) {
          visited.add(name);
          return Scaffold(appBar: AppBar(), body: Text('page:$name'));
        },
      ),
  ];

  group('desktop navigation', () {
    Future<void> pumpSidebar(
      WidgetTester tester, {
      required bool compact,
      String location = '/',
    }) async {
      await pumpApp(
        tester,
        size: const Size(1280, 800),
        router: GoRouter(
          initialLocation: location,
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) =>
                  Scaffold(body: DesktopSidebar(compact: compact)),
            ),
            GoRoute(
              path: '/${AppRouterNames.moodMap}',
              name: AppRouterNames.moodMap,
              builder: (_, _) =>
                  Scaffold(body: DesktopSidebar(compact: compact)),
            ),
            ...stubRoutes([AppRouterNames.wave, AppRouterNames.importMusic]),
          ],
        ),
        providers: [
          BlocProvider<CloudSessionCubit>.value(value: FakeSessionCubit()),
          BlocProvider<PlaylistBloc>.value(value: FakePlaylistBloc()),
          BlocProvider<TrackBloc>.value(value: FakeTrackBloc(const [])),
        ],
      );
    }

    testWidgets('Wave is primary navigation and Mood Map is not', (
      tester,
    ) async {
      await pumpSidebar(tester, compact: false);
      expect(find.byKey(const ValueKey('sidebar-wave')), findsOneWidget);
      expect(find.text('Wave'), findsOneWidget);
      expect(find.text('Mood Map'), findsNothing);
      expect(find.text('Choose a mood'), findsNothing);
      expect(find.text('Library'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
    });

    testWidgets('Add music stays one click away', (tester) async {
      await pumpSidebar(tester, compact: false);
      expect(find.byKey(const ValueKey('sidebar-add-music')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('sidebar-add-music')));
      await tester.pumpAndSettle();
      expect(visited, [AppRouterNames.importMusic]);
    });

    testWidgets('tapping Wave opens the Wave destination', (tester) async {
      await pumpSidebar(tester, compact: false);
      await tester.tap(find.byKey(const ValueKey('sidebar-wave')));
      await tester.pumpAndSettle();
      expect(visited, [AppRouterNames.wave]);
    });

    testWidgets('the collapsed rail keeps Wave and Add music with tooltips', (
      tester,
    ) async {
      await pumpSidebar(tester, compact: true);
      expect(find.text('Wave'), findsNothing, reason: 'icons only');
      expect(find.byTooltip('Wave'), findsOneWidget);
      expect(find.byTooltip('Add music'), findsOneWidget);
      expect(find.byTooltip('Mood Map'), findsNothing);
    });

    testWidgets('Wave stays highlighted while choosing a mood inside it', (
      tester,
    ) async {
      await pumpSidebar(tester, compact: false);
      expect(
        tester
            .widget<SidebarNavItem>(find.byKey(const ValueKey('sidebar-wave')))
            .selected,
        isFalse,
      );

      await pumpSidebar(
        tester,
        compact: false,
        location: '/${AppRouterNames.moodMap}',
      );
      expect(
        tester
            .widget<SidebarNavItem>(find.byKey(const ValueKey('sidebar-wave')))
            .selected,
        isTrue,
      );
    });
  });

  group('routes', () {
    test('Wave is a route and the Mood Map route still resolves', () {
      final router = AppRouter.router;
      expect(router.namedLocation(AppRouterNames.wave), '/wave');
      expect(router.namedLocation(AppRouterNames.moodMap), '/mood_map');
    });

    test('Account accepts the first-run mode without a new route', () {
      final router = AppRouter.router;
      expect(
        router.namedLocation(
          AppRouterNames.account,
          queryParameters: const {'mode': 'register'},
        ),
        '/account?mode=register',
      );
    });
  });

  group('Account', () {
    Future<void> pumpAccount(
      WidgetTester tester,
      CloudAccountState state, {
      bool initialRegister = false,
    }) async {
      await pumpApp(
        tester,
        size: const Size(420, 1800),
        router: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => BlocProvider<CloudAccountCubit>.value(
                value: _FakeAccountCubit(state),
                child: CloudAccountScreen(initialRegister: initialRegister),
              ),
            ),
            ...stubRoutes([AppRouterNames.settings]),
          ],
        ),
      );
    }

    testWidgets('signed out: Settings is reachable and the form explains '
        'what an account does', (tester) async {
      await pumpAccount(
        tester,
        const CloudAccountState(status: CloudAccountStatus.signedOut),
      );
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Your music, on every device'), findsOneWidget);
      expect(
        find.textContaining('Without an account, your music stays on this'),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('cloud-upload-notice')), findsOne);

      await tester.tap(find.byKey(const ValueKey('account-settings-entry')));
      await tester.pumpAndSettle();
      expect(visited, [AppRouterNames.settings]);
    });

    testWidgets('signed out: first-run Get started opens on Create account', (
      tester,
    ) async {
      await pumpAccount(
        tester,
        const CloudAccountState(status: CloudAccountStatus.signedOut),
        initialRegister: true,
      );
      final submit = find.byKey(const ValueKey('cloud-submit'));
      expect(
        find.descendant(of: submit, matching: find.text('Create account')),
        findsOneWidget,
      );
    });

    testWidgets('signed in: Settings is reachable from Account too', (
      tester,
    ) async {
      await pumpAccount(
        tester,
        const CloudAccountState(status: CloudAccountStatus.signedIn),
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('account-settings-entry')),
      );
      await tester.tap(find.byKey(const ValueKey('account-settings-entry')));
      await tester.pumpAndSettle();
      expect(visited, [AppRouterNames.settings]);
    });

    testWidgets('device storage choice is honest about what it does', (
      tester,
    ) async {
      await pumpAccount(
        tester,
        const CloudAccountState(
          status: CloudAccountStatus.signedIn,
          storageMode: DeviceStorageMode.stream,
        ),
      );
      expect(find.text('On this device'), findsOneWidget);
      expect(find.text('Play from OwlSonic (recommended)'), findsOneWidget);
      expect(find.text('Keep a copy on this device (beta)'), findsOneWidget);
      expect(
        find.textContaining('Needs space for the whole library'),
        findsOneWidget,
      );
      expect(find.text('Download for offline'), findsNothing);
    });
  });

  test('music streams by default without asking the listener first', () {
    expect(DeviceStorageModeStore().effective, DeviceStorageMode.stream);
    expect(DeviceStorageModeStore.fallback, DeviceStorageMode.stream);
  });
}
