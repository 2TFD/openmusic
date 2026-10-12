import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/core/network/owlsonic/installation_identity.dart';
import 'package:owlsonic/core/services/cloud/device_storage_mode_store.dart';
import 'package:owlsonic/layers/data/repositories/owlsonic_cloud_repositories.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/cloud_account_cubit.dart';

import 'support/fake_owlsonic_backend.dart';

class _MemoryStorageMode implements DeviceStorageModeStore {
  DeviceStorageMode? mode;
  @override
  final current = ValueNotifier<DeviceStorageMode?>(null);
  @override
  DeviceStorageMode get effective => mode ?? DeviceStorageModeStore.fallback;
  @override
  Future<DeviceStorageMode?> load() async => mode;
  @override
  Future<void> save(DeviceStorageMode next) async => mode = next;
}

CloudAccountCubit _cubit(FakeCloud cloud, {bool configured = true}) =>
    CloudAccountCubit(
      retryDelay: (_) async {},
      session: cloud.session,
      configured: configured,
      auth: OwlSonicAuthRepository(
        client: cloud.client,
        identity: InstallationIdentity(
          storage: MemoryInstallationIdStorage(),
          generate: () => 'install',
        ),
        pending: MemoryPendingVerificationStore(),
        now: () => fakeNow,
      ),
      account: OwlSonicAccountRepository(cloud.client),
      storageMode: _MemoryStorageMode(),
    );

void _accountRoutes(FakeCloud cloud) {
  cloud.backend.on(
    'GET /v1/me',
    (_) => const FakeReply(200, {
      'id': 'u1',
      'email': 'me@example.com',
      'created_at': '2026-01-01T00:00:00Z',
    }),
  );
  cloud.backend.on(
    'GET /v1/me/usage',
    (_) => const FakeReply(200, {
      'storage': {
        'used_bytes': 1,
        'limit_bytes': null,
        'remaining_bytes': null,
        'unlimited': true,
        'over_limit': false,
      },
    }),
  );
  cloud.backend.on(
    'GET /v1/devices',
    (_) => const FakeReply(200, {'items': []}),
  );
}

void main() {
  test(
    'validation rejects empty/invalid input without calling the backend',
    () {
      expect(CloudAccountCubit.validateEmail(''), 'cloud.errors.emailRequired');
      expect(
        CloudAccountCubit.validateEmail('nope'),
        'cloud.errors.emailInvalid',
      );
      expect(CloudAccountCubit.validateEmail('a@b.co'), isNull);
      expect(
        CloudAccountCubit.validatePassword(''),
        'cloud.errors.passwordRequired',
      );
      expect(
        CloudAccountCubit.validatePassword('x' * 129),
        'cloud.errors.passwordTooLong',
      );
    },
  );

  test('unconfigured build never touches the network', () async {
    final cloud = FakeCloud();
    final cubit = _cubit(cloud, configured: false);
    await cubit.initialize();
    expect(cubit.state.status, CloudAccountStatus.unconfigured);
    expect(cloud.backend.requests, isEmpty);
    await cubit.close();
  });

  test('login success moves to signed-in and loads account data', () async {
    final cloud = FakeCloud();
    cloud.backend.on(
      'POST /v1/auth/login',
      (_) => FakeReply(200, credentials()),
    );
    _accountRoutes(cloud);
    final cubit = _cubit(cloud);
    await cubit.initialize();
    expect(cubit.state.status, CloudAccountStatus.signedOut);

    expect(await cubit.login('me@example.com', 'pw'), isTrue);
    await cubit.refresh();

    expect(cubit.state.status, CloudAccountStatus.signedIn);
    expect(cubit.state.user?.email, 'me@example.com');
    expect(cubit.state.usage?.unlimited, isTrue);
    await cubit.close();
  });

  Future<CloudAccountCubit> signedInCubit(FakeCloud cloud) async {
    cloud.backend.on(
      'POST /v1/auth/login',
      (_) => FakeReply(200, credentials()),
    );
    _accountRoutes(cloud);
    final cubit = _cubit(cloud);
    await cubit.initialize();
    await cubit.login('me@example.com', 'pw');
    return cubit;
  }

  FakeHandler dropFirst(int times, FakeHandler ok) {
    var calls = 0;
    return (request) {
      if (calls++ < times) {
        throw DioException.connectionError(
          requestOptions: RequestOptions(path: request.path),
          reason: 'dropped',
        );
      }
      return ok(request);
    };
  }

  test(
    'refresh retries a dropped connection instead of showing an error',
    () async {
      final cloud = FakeCloud();
      final cubit = await signedInCubit(cloud);
      cloud.backend.on(
        'GET /v1/devices',
        dropFirst(2, (_) => const FakeReply(200, {'items': []})),
      );

      await cubit.refresh();

      expect(cubit.state.error, isNull);
      expect(cubit.state.user?.email, 'me@example.com');
      // Login also triggers a background refresh, so only a lower bound holds.
      expect(
        cloud.backend.to('GET /v1/devices').length,
        greaterThanOrEqualTo(3),
      );
      await cubit.close();
    },
  );

  test('one failing request keeps the data that did load', () async {
    final cloud = FakeCloud();
    final cubit = await signedInCubit(cloud);
    cloud.backend.on(
      'GET /v1/devices',
      dropFirst(99, (_) => const FakeReply(200, {'items': []})),
    );

    await cubit.refresh();

    expect(cubit.state.error?.isNetwork, isTrue);
    expect(cubit.state.user?.email, 'me@example.com');
    expect(cubit.state.usage?.unlimited, isTrue);
    await cubit.close();
  });

  test('backend error is kept structured on the state', () async {
    final cloud = FakeCloud();
    cloud.backend.on(
      'POST /v1/auth/login',
      (_) => FakeReply.error(401, 'invalid_credentials', requestId: 'req-x'),
    );
    final cubit = _cubit(cloud);
    await cubit.initialize();

    expect(await cubit.login('me@example.com', 'bad'), isFalse);

    expect(cubit.state.status, CloudAccountStatus.signedOut);
    expect(cubit.state.submitting, isFalse);
    expect(cubit.state.error?.code, 'invalid_credentials');
    expect(cubit.state.error?.requestId, 'req-x');
    await cubit.close();
  });

  test('revoked session elsewhere transitions the UI to signed-out', () async {
    final cloud = FakeCloud(initialTokens: tokens());
    _accountRoutes(cloud);
    final cubit = _cubit(cloud);
    await cubit.initialize();
    expect(cubit.state.status, CloudAccountStatus.signedIn);

    await cloud.session.signOut();
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.status, CloudAccountStatus.signedOut);
    expect(cubit.state.user, isNull);
    await cubit.close();
  });

  test('storage mode is a device-local preference', () async {
    final cloud = FakeCloud();
    final cubit = _cubit(cloud, configured: false);
    await cubit.initialize();
    await cubit.setStorageMode(DeviceStorageMode.offline);
    expect(cubit.state.storageMode, DeviceStorageMode.offline);
    expect(cloud.backend.requests, isEmpty);
    await cubit.close();
  });
}
