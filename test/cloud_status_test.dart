import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:owlsonic/core/app_router/app_router_names.dart';
import 'package:owlsonic/core/network/owlsonic/auth_session.dart';
import 'package:owlsonic/core/services/cloud/cloud_sync_coordinator.dart';
import 'package:owlsonic/layers/presentation/features/cloud_status/cloud_status_cubit.dart';
import 'package:owlsonic/layers/presentation/features/cloud_status/cloud_status_line.dart';

import 'support/fake_owlsonic_backend.dart' show tokens;
import 'support/ux_harness.dart';

CloudStatusState derive({
  bool configured = true,
  AuthStatus status = AuthStatus.signedIn,
  CloudSyncStatus sync = const CloudSyncStatus(),
  int pending = 0,
}) => CloudStatusCubit.derive(
  configured: configured,
  status: status,
  sync: sync,
  pendingUploads: pending,
);

void main() {
  useTestLocalization();

  final synced = CloudSyncStatus(lastSyncedAt: DateTime.utc(2026, 1, 1));

  group('derived cloud status', () {
    test('hidden when the cloud is not configured', () {
      expect(derive(configured: false).kind, CloudStatusKind.hidden);
    });

    test('checking while the saved session is read', () {
      expect(derive(status: AuthStatus.unknown).kind, CloudStatusKind.checking);
    });

    test('signed out means this device only', () {
      final state = derive(status: AuthStatus.signedOut);
      expect(state.kind, CloudStatusKind.deviceOnly);
      expect(state.signedIn, isFalse);
    });

    test('up to date after a completed sync', () {
      final state = derive(sync: synced);
      expect(state.kind, CloudStatusKind.upToDate);
      expect(state.awaitingFirstSync, isFalse);
    });

    test('first sync of the session reads as syncing, not empty', () {
      final state = derive();
      expect(state.kind, CloudStatusKind.syncing);
      expect(state.awaitingFirstSync, isTrue);
    });

    test('a running sync after the first one is just syncing', () {
      final state = derive(
        sync: CloudSyncStatus(
          phase: CloudSyncPhase.syncing,
          lastSyncedAt: synced.lastSyncedAt,
        ),
      );
      expect(state.kind, CloudStatusKind.syncing);
      expect(state.awaitingFirstSync, isFalse);
    });

    test('uploads show the real number waiting, and only then', () {
      expect(derive(sync: synced, pending: 3).kind, CloudStatusKind.uploading);
      expect(derive(sync: synced, pending: 3).pendingUploads, 3);
      expect(derive(sync: synced).pendingUploads, 0);
    });

    test('network trouble is “offline”, other trouble is a failed sync', () {
      expect(
        derive(
          sync: const CloudSyncStatus(
            phase: CloudSyncPhase.failed,
            lastErrorCode: 'network_unavailable',
          ),
        ).kind,
        CloudStatusKind.offline,
      );
      expect(
        derive(
          sync: const CloudSyncStatus(
            phase: CloudSyncPhase.failed,
            lastErrorCode: 'server_error',
          ),
        ).kind,
        CloudStatusKind.failed,
      );
    });

    test('a failed first sync is not reported as an empty-library wait', () {
      expect(
        derive(
          sync: const CloudSyncStatus(phase: CloudSyncPhase.failed),
        ).awaitingFirstSync,
        isFalse,
      );
    });
  });

  group('cloud status cubit', () {
    testWidgets('follows sign-in and sync without extra network requests', (
      tester,
    ) async {
      final rig = await CloudStatusRig.create(signedIn: false);
      addTearDown(rig.dispose);
      expect(rig.cubit.state.kind, CloudStatusKind.deviceOnly);

      await rig.session.signIn(tokens());
      await flushMicrotasks();
      expect(rig.cubit.state.kind, CloudStatusKind.syncing);

      await rig.update(synced);
      expect(rig.cubit.state.kind, CloudStatusKind.upToDate);

      rig.pending = 2;
      await rig.update(synced);
      expect(rig.cubit.state.kind, CloudStatusKind.uploading);
      expect(rig.cubit.state.pendingUploads, 2);

      expect(rig.syncRequests, 0, reason: 'reading status never syncs');
    });

    testWidgets('retry asks the coordinator once', (tester) async {
      final rig = await CloudStatusRig.create(signedIn: true);
      addTearDown(rig.dispose);
      rig.cubit.retry();
      expect(rig.syncRequests, 1);
    });

    testWidgets('unconfigured builds stay hidden', (tester) async {
      final rig = await CloudStatusRig.create(configured: false);
      addTearDown(rig.dispose);
      expect(rig.cubit.state.kind, CloudStatusKind.hidden);
    });
  });

  group('status line', () {
    Future<CloudStatusRig> pumpLine(
      WidgetTester tester, {
      bool signedIn = true,
      CloudSyncStatus? sync,
      int pending = 0,
    }) async {
      final rig = await CloudStatusRig.create(
        signedIn: signedIn,
        sync: sync ?? synced,
        pending: pending,
      );
      addTearDown(rig.dispose);
      await pumpApp(
        tester,
        router: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => Scaffold(
                body: BlocProvider.value(
                  value: rig.cubit,
                  child: const CloudStatusLine(),
                ),
              ),
            ),
            GoRoute(
              path: '/${AppRouterNames.account}',
              name: AppRouterNames.account,
              builder: (_, _) => const Text('account page'),
            ),
          ],
        ),
        settle: false,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      return rig;
    }

    testWidgets('says where music lives when signed out', (tester) async {
      await pumpLine(tester, signedIn: false);
      expect(find.text('On this device only · Sign in'), findsOneWidget);
      // No sync promise for someone without an account.
      expect(find.textContaining('up to date'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('cloud-status-line')));
      await tester.pumpAndSettle();
      expect(find.text('account page'), findsOneWidget);
    });

    testWidgets('is calm when everything is in sync', (tester) async {
      await pumpLine(tester);
      expect(find.text('Your music is up to date'), findsOneWidget);
    });

    testWidgets('shows real upload progress', (tester) async {
      await pumpLine(tester, pending: 12);
      expect(find.text('Uploading 12 tracks…'), findsOneWidget);
    });

    testWidgets('says when the device is offline', (tester) async {
      await pumpLine(
        tester,
        sync: const CloudSyncStatus(
          phase: CloudSyncPhase.failed,
          lastErrorCode: 'network_unavailable',
        ),
      );
      expect(find.text('You’re offline'), findsOneWidget);
    });

    testWidgets('a failed sync can be retried right from the line', (
      tester,
    ) async {
      final rig = await pumpLine(
        tester,
        sync: const CloudSyncStatus(
          phase: CloudSyncPhase.failed,
          lastErrorCode: 'server_error',
        ),
      );
      expect(find.text('Couldn’t sync · Retry'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('cloud-status-line')));
      expect(rig.syncRequests, 1);
    });
  });
}
