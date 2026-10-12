import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/core/network/owlsonic/auth_session.dart';
import 'package:owlsonic/core/network/owlsonic/auth_token_store.dart';
import 'package:owlsonic/core/network/owlsonic/owlsonic_api_exception.dart';
import 'package:owlsonic/layers/data/repositories/owlsonic_cloud_repositories.dart';

import 'support/fake_owlsonic_backend.dart';

/// A refresh, retry or bound job of account A must never write credentials
/// into, or send requests with the token of, account B (or a later A).
void main() {
  const usage = FakeReply(200, {
    'storage': {
      'used_bytes': 10,
      'limit_bytes': 100,
      'remaining_bytes': 90,
      'unlimited': false,
      'over_limit': false,
    },
  });

  AuthTokens accountB() => tokens(access: 'access-B', refresh: 'refresh-B');

  test('a stale successful refresh never overwrites a newer sign-in', () async {
    final cloud = FakeCloud(initialTokens: tokens());
    final gate = Completer<void>();
    cloud.backend.on('POST /v1/auth/refresh', (_) async {
      await gate.future;
      return FakeReply(200, credentials(access: 'access-A2'));
    });
    cloud.backend.on(
      'GET /v1/me/usage',
      (request) => request.bearer == 'access-1'
          ? FakeReply.error(401, 'token_expired')
          : usage,
    );

    final call = OwlSonicAccountRepository(cloud.client).usage();
    await pumpEventQueue();
    await cloud.session.signOut();
    await cloud.session.signIn(accountB());
    gate.complete();

    await expectLater(call, throwsA(isA<OwlSonicApiException>()));
    expect(cloud.session.status, AuthStatus.signedIn);
    expect(cloud.store.tokens!.accessToken, 'access-B');
    expect(await cloud.session.accessToken(), 'access-B');
    // A's request was never retried with B's token.
    expect(cloud.backend.to('GET /v1/me/usage').map((r) => r.bearer), [
      'access-1',
    ]);
  });

  test('a stale rejected refresh does not sign the new account out', () async {
    final cloud = FakeCloud(initialTokens: tokens());
    final gate = Completer<void>();
    cloud.backend.on('POST /v1/auth/refresh', (_) async {
      await gate.future;
      return FakeReply.error(401, 'refresh_revoked');
    });
    cloud.backend.on(
      'GET /v1/me/usage',
      (_) => FakeReply.error(401, 'token_expired'),
    );

    final call = OwlSonicAccountRepository(cloud.client).usage();
    await pumpEventQueue();
    await cloud.session.signIn(accountB());
    gate.complete();

    await expectLater(call, throwsA(isA<OwlSonicApiException>()));
    expect(cloud.session.status, AuthStatus.signedIn);
    expect(cloud.store.tokens!.accessToken, 'access-B');
  });

  test('sign-out during a refresh stays signed out', () async {
    final cloud = FakeCloud(initialTokens: tokens());
    final gate = Completer<void>();
    cloud.backend.on('POST /v1/auth/refresh', (_) async {
      await gate.future;
      return FakeReply(200, credentials());
    });
    cloud.backend.on(
      'GET /v1/me/usage',
      (_) => FakeReply.error(401, 'token_expired'),
    );

    final call = OwlSonicAccountRepository(cloud.client).usage();
    await pumpEventQueue();
    await cloud.session.signOut();
    gate.complete();

    await expectLater(call, throwsA(isA<OwlSonicApiException>()));
    expect(cloud.session.status, AuthStatus.signedOut);
    expect(cloud.store.tokens, isNull);
  });

  test('a newer session does not join an older in-flight refresh', () async {
    final cloud = FakeCloud(
      initialTokens: tokens(
        accessExpiresAt: fakeNow.subtract(const Duration(minutes: 1)),
      ),
    );
    final gates = <Completer<void>>[];
    cloud.backend.on('POST /v1/auth/refresh', (request) async {
      final gate = Completer<void>();
      gates.add(gate);
      await gate.future;
      final refresh = request.json['refresh_token'] as String;
      return FakeReply(200, credentials(access: 'from-$refresh'));
    });

    final stale = cloud.session.accessToken();
    await pumpEventQueue();
    await cloud.session.signIn(
      tokens(
        access: 'access-B',
        refresh: 'refresh-B',
        accessExpiresAt: fakeNow.subtract(const Duration(minutes: 1)),
      ),
    );
    final fresh = cloud.session.accessToken();
    await pumpEventQueue();
    expect(gates, hasLength(2));
    for (final gate in gates) {
      gate.complete();
    }

    expect(await stale, isNull);
    expect(await fresh, 'from-refresh-B');
    expect(cloud.store.tokens!.accessToken, 'from-refresh-B');
  });

  test('A → B → A: the first A refresh never lands in the second A', () async {
    final cloud = FakeCloud(initialTokens: tokens());
    final gate = Completer<void>();
    cloud.backend.on('POST /v1/auth/refresh', (_) async {
      await gate.future;
      return FakeReply(200, credentials(access: 'stale-A'));
    });
    cloud.backend.on(
      'GET /v1/me/usage',
      (request) => request.bearer == 'access-1'
          ? FakeReply.error(401, 'token_expired')
          : usage,
    );

    final call = OwlSonicAccountRepository(cloud.client).usage();
    await pumpEventQueue();
    await cloud.session.signOut();
    await cloud.session.signIn(accountB());
    await cloud.session.signOut();
    await cloud.session.signIn(tokens(access: 'access-A2'));
    gate.complete();

    await expectLater(call, throwsA(isA<OwlSonicApiException>()));
    expect(cloud.store.tokens!.accessToken, 'access-A2');
  });

  test('a job bound to a session fails fast after the session ends', () async {
    final cloud = FakeCloud(initialTokens: tokens());
    cloud.backend.on('GET /v1/me/usage', (_) => usage);
    final account = OwlSonicAccountRepository(cloud.client);
    await cloud.session.restore();
    final epoch = cloud.session.epoch;

    final ok = await cloud.session.bind(epoch, account.usage);
    expect(ok.usedBytes, 10);

    await cloud.session.signOut();
    await cloud.session.signIn(accountB());
    await expectLater(
      cloud.session.bind(epoch, account.usage),
      throwsA(
        isA<OwlSonicApiException>().having(
          (e) => e.code,
          'code',
          'session_changed',
        ),
      ),
    );
    expect(cloud.backend.to('GET /v1/me/usage'), hasLength(1));
  });

  test('a response arriving after an account switch is discarded', () async {
    final cloud = FakeCloud(initialTokens: tokens());
    final gate = Completer<void>();
    cloud.backend.on('GET /v1/me/usage', (_) async {
      await gate.future;
      return usage;
    });

    final call = OwlSonicAccountRepository(cloud.client).usage();
    await pumpEventQueue();
    await cloud.session.signIn(accountB());
    gate.complete();

    await expectLater(
      call,
      throwsA(
        isA<OwlSonicApiException>().having(
          (e) => e.code,
          'code',
          'session_changed',
        ),
      ),
    );
  });
}
