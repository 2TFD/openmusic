import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/core/network/owlsonic/auth_session.dart';
import 'package:owlsonic/core/network/owlsonic/installation_identity.dart';
import 'package:owlsonic/core/network/owlsonic/owlsonic_api_exception.dart';
import 'package:owlsonic/layers/data/repositories/owlsonic_cloud_repositories.dart';

import 'support/fake_owlsonic_backend.dart';

void main() {
  OwlSonicAuthRepository authFor(
    FakeCloud cloud,
    MemoryInstallationIdStorage ids, {
    MemoryPendingVerificationStore? pendingStore,
  }) => OwlSonicAuthRepository(
    client: cloud.client,
    identity: InstallationIdentity(storage: ids, generate: () => 'install-1'),
    pending: pendingStore ?? MemoryPendingVerificationStore(),
    now: () => fakeNow,
  );

  test('login sends email, password and device, then stores tokens', () async {
    final cloud = FakeCloud();
    cloud.backend.on(
      'POST /v1/auth/login',
      (_) => FakeReply(200, credentials()),
    );

    await authFor(
      cloud,
      MemoryInstallationIdStorage(),
    ).login(email: ' me@example.com ', password: 'secret');

    final body = cloud.backend.to('POST /v1/auth/login').single.json;
    expect(body['email'], 'me@example.com');
    expect(body['password'], 'secret');
    expect(body['device']['installation_id'], 'install-1');
    expect(body['device']['platform'], isNotEmpty);
    expect(cloud.backend.requests.single.bearer, isNull);
    expect(cloud.session.status, AuthStatus.signedIn);
    expect(cloud.store.tokens!.accessToken, 'access-2');
    expect(cloud.store.tokens!.refreshToken, 'refresh-2');
    expect(
      cloud.store.tokens!.accessExpiresAt,
      fakeNow.add(const Duration(seconds: 900)),
    );
  });

  test(
    'register maps 409 to a structured exception and stays signed out',
    () async {
      final cloud = FakeCloud();
      cloud.backend.on(
        'POST /v1/auth/register',
        (_) => FakeReply.error(409, 'email_taken', requestId: 'req-409'),
      );

      final future = authFor(
        cloud,
        MemoryInstallationIdStorage(),
      ).register(email: 'me@example.com', password: 'secret');

      await expectLater(
        future,
        throwsA(
          isA<OwlSonicApiException>()
              .having((e) => e.code, 'code', 'email_taken')
              .having((e) => e.statusCode, 'status', 409)
              .having((e) => e.requestId, 'request_id', 'req-409'),
        ),
      );
      expect(cloud.store.tokens, isNull);
    },
  );

  test('installation id is generated once and reused', () async {
    final storage = MemoryInstallationIdStorage();
    var generated = 0;
    String gen() => 'id-${++generated}';

    final first = await InstallationIdentity(
      storage: storage,
      generate: gen,
    ).installationId();
    final second = await InstallationIdentity(
      storage: storage,
      generate: gen,
    ).installationId();

    expect(first, 'id-1');
    expect(second, 'id-1');
    expect(generated, 1);
  });

  test('persisted tokens restore a signed-in session', () async {
    final cloud = FakeCloud(initialTokens: tokens());
    await cloud.session.restore();
    expect(cloud.session.status, AuthStatus.signedIn);
  });

  test('401 triggers one refresh and the request is retried once', () async {
    final cloud = FakeCloud(initialTokens: tokens());
    cloud.backend.on(
      'POST /v1/auth/refresh',
      (_) => FakeReply(200, credentials()),
    );
    cloud.backend.on(
      'GET /v1/me',
      (request) => request.bearer == 'access-2'
          ? const FakeReply(200, {
              'id': 'u1',
              'email': 'me@example.com',
              'created_at': '2026-01-01T00:00:00Z',
            })
          : FakeReply.error(401, 'token_expired'),
    );

    final user = await OwlSonicAccountRepository(cloud.client).me();

    expect(user.email, 'me@example.com');
    expect(cloud.backend.to('GET /v1/me').map((r) => r.bearer), [
      'access-1',
      'access-2',
    ]);
    expect(
      cloud.backend.to('POST /v1/auth/refresh').single.json['refresh_token'],
      'refresh-1',
    );
    expect(cloud.store.tokens!.refreshToken, 'refresh-2');
  });

  test('concurrent 401s share a single refresh', () async {
    final cloud = FakeCloud(initialTokens: tokens());
    final gate = Completer<void>();
    cloud.backend.on('POST /v1/auth/refresh', (_) async {
      await gate.future;
      return FakeReply(200, credentials());
    });
    cloud.backend.on(
      'GET /v1/me/usage',
      (request) => request.bearer == 'access-2'
          ? const FakeReply(200, {
              'storage': {
                'used_bytes': 10,
                'limit_bytes': 100,
                'remaining_bytes': 90,
                'unlimited': false,
                'over_limit': false,
              },
            })
          : FakeReply.error(401, 'token_expired'),
    );
    final account = OwlSonicAccountRepository(cloud.client);

    final calls = [for (var i = 0; i < 5; i++) account.usage()];
    await Future<void>.delayed(Duration.zero);
    gate.complete();
    final results = await Future.wait(calls);

    expect(results.map((u) => u.usedBytes), everyElement(10));
    expect(cloud.backend.to('POST /v1/auth/refresh'), hasLength(1));
  });

  test('rejected refresh signs out and does not loop', () async {
    final cloud = FakeCloud(initialTokens: tokens());
    cloud.backend.on(
      'POST /v1/auth/refresh',
      (_) => FakeReply.error(401, 'refresh_revoked'),
    );
    cloud.backend.on(
      'GET /v1/me',
      (_) => FakeReply.error(401, 'token_expired'),
    );

    await expectLater(
      OwlSonicAccountRepository(cloud.client).me(),
      throwsA(
        isA<OwlSonicApiException>().having((e) => e.code, 'code', 'signed_out'),
      ),
    );

    expect(cloud.backend.to('GET /v1/me'), hasLength(1));
    expect(cloud.backend.to('POST /v1/auth/refresh'), hasLength(1));
    expect(cloud.session.status, AuthStatus.signedOut);
    expect(cloud.store.tokens, isNull);
  });

  test(
    'second 401 after a successful refresh is surfaced, not retried',
    () async {
      final cloud = FakeCloud(initialTokens: tokens());
      cloud.backend.on(
        'POST /v1/auth/refresh',
        (_) => FakeReply(200, credentials()),
      );
      cloud.backend.on(
        'GET /v1/me',
        (_) => FakeReply.error(401, 'token_expired'),
      );

      await expectLater(
        OwlSonicAccountRepository(cloud.client).me(),
        throwsA(
          isA<OwlSonicApiException>().having(
            (e) => e.statusCode,
            'status',
            401,
          ),
        ),
      );
      expect(cloud.backend.to('GET /v1/me'), hasLength(2));
    },
  );

  test('refresh failing offline keeps the session', () async {
    final cloud = FakeCloud(
      initialTokens: tokens(
        accessExpiresAt: fakeNow.subtract(const Duration(minutes: 1)),
      ),
    );
    cloud.backend.offline = true;

    await expectLater(
      OwlSonicAccountRepository(cloud.client).me(),
      throwsA(
        isA<OwlSonicApiException>().having(
          (e) => e.isNetwork,
          'network',
          isTrue,
        ),
      ),
    );
    expect(cloud.session.status, AuthStatus.signedIn);
    expect(cloud.store.tokens, isNotNull);
  });

  test('expiring access token is refreshed proactively', () async {
    final cloud = FakeCloud(
      initialTokens: tokens(
        accessExpiresAt: fakeNow.add(const Duration(seconds: 5)),
      ),
    );
    cloud.backend.on(
      'POST /v1/auth/refresh',
      (_) => FakeReply(200, credentials()),
    );
    cloud.backend.on(
      'GET /v1/devices',
      (_) => const FakeReply(200, {'items': []}),
    );

    await OwlSonicAccountRepository(cloud.client).devices();

    expect(cloud.backend.to('GET /v1/devices').single.bearer, 'access-2');
  });

  test(
    'logout revokes server session and clears tokens even if it fails',
    () async {
      final cloud = FakeCloud(initialTokens: tokens());
      cloud.backend.on(
        'POST /v1/auth/logout',
        (_) => FakeReply.error(500, 'boom'),
      );

      await authFor(cloud, MemoryInstallationIdStorage()).logout();

      expect(
        cloud.backend.to('POST /v1/auth/logout').single.bearer,
        'access-1',
      );
      expect(cloud.store.tokens, isNull);
      expect(cloud.session.status, AuthStatus.signedOut);
    },
  );

  test('authenticated calls without a session fail fast', () async {
    final cloud = FakeCloud();

    await expectLater(
      OwlSonicAccountRepository(cloud.client).me(),
      throwsA(
        isA<OwlSonicApiException>().having((e) => e.code, 'code', 'signed_out'),
      ),
    );
    expect(cloud.backend.requests, isEmpty);
  });

  test('token objects never print secrets', () {
    expect(tokens().toString(), isNot(contains('access-1')));
  });
}
