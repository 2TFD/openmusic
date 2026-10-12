import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:fake_async/fake_async.dart'; // ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:owlsonic/core/app_router/app_router_names.dart';
import 'package:owlsonic/core/network/owlsonic/auth_session.dart';
import 'package:owlsonic/core/network/owlsonic/installation_identity.dart';
import 'package:owlsonic/core/network/owlsonic/owlsonic_api_exception.dart';
import 'package:owlsonic/core/services/cloud/device_storage_mode_store.dart';
import 'package:owlsonic/core/telemetry/analytics_tracker.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/data/repositories/owlsonic_cloud_repositories.dart';
import 'package:owlsonic/layers/domain/entities/cloud/auth_challenge.dart';
import 'package:owlsonic/layers/domain/repositories/cloud_repositories.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/auth_rules.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/cloud_account_cubit.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/password_reset_cubit.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/verify_email_cubit.dart';
import 'package:owlsonic/layers/presentation/features/account/ui/cloud_account_screen.dart';
import 'package:owlsonic/layers/presentation/features/account/ui/forgot_password_screen.dart';
import 'package:owlsonic/layers/presentation/features/account/ui/verify_email_screen.dart';

import 'support/fake_owlsonic_backend.dart';

Map<String, Object?> _pendingBody({
  String email = 'me@example.com',
  int resendIn = 60,
}) => {
  'status': 'verification_required',
  'email': email,
  'code_length': 6,
  'code_expires_in': 600,
  'resend_available_in': resendIn,
};

Map<String, Object?> _accepted({int resendIn = 60}) => {
  'status': 'accepted',
  'code_length': 6,
  'code_expires_in': 600,
  'resend_available_in': resendIn,
};

FakeReply _validation(String type, String field, {String? message}) =>
    FakeReply(422, {
      'error': {
        'code': 'INVALID_REQUEST',
        'message': 'Request validation failed',
        'retryable': false,
        'request_id': 'req-422',
        'details': [
          {
            'loc': ['body', field],
            'type': type,
            'message': ?message,
          },
        ],
      },
    });

class _MemoryMode implements DeviceStorageModeStore {
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

class _DiskAssetLoader extends AssetLoader {
  const _DiskAssetLoader();
  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async =>
      jsonDecode(File('$path/${locale.languageCode}.json').readAsStringSync())
          as Map<String, dynamic>;
}

/// Scripted auth repository for cubit tests (no HTTP, no timers).
final class _RecordingAnalytics implements AnalyticsTracker {
  final events = <String>[];
  @override
  bool get isAvailable => true;
  @override
  bool get isEnabled => true;
  @override
  Future<void> setEnabled(bool enabled) async {}
  @override
  Future<void> logEvent(String name, {Map<String, Object>? properties}) async {
    events.add(name);
  }

  @override
  Future<void> identify(
    String userId, {
    Map<String, Object>? properties,
  }) async {}
}

class _ScriptedAuth implements CloudAuthRepository {
  PendingVerification? pending;
  Object? verifyError;
  Object? resendError;
  CodeChallenge? resendResult;
  final calls = <String>[];

  @override
  Future<PendingVerification?> pendingVerification() async => pending;
  @override
  Future<void> clearPendingVerification() async => pending = null;
  @override
  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    calls.add('verify:$code');
    if (verifyError != null) throw verifyError!;
  }

  @override
  Future<CodeChallenge> resendVerification({required String email}) async {
    calls.add('resend');
    if (resendError != null) throw resendError!;
    return resendResult!;
  }

  @override
  Future<CodeChallenge> forgotPassword({required String email}) async {
    calls.add('forgot');
    if (resendError != null) throw resendError!;
    return resendResult!;
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    calls.add('reset');
    if (verifyError != null) throw verifyError!;
  }

  @override
  Future<CodeChallenge> register({
    required String email,
    required String password,
  }) => throw UnimplementedError();
  @override
  Future<void> login({required String email, required String password}) =>
      throw UnimplementedError();
  @override
  Future<void> logout() => throw UnimplementedError();
}

OwlSonicApiException _api(
  String code,
  int status, {
  Duration? retryAfter,
  List<Object?> details = const [],
}) => OwlSonicApiException(
  kind: OwlSonicApiErrorKind.server,
  code: code,
  message: 'Server said $code',
  retryable: false,
  statusCode: status,
  retryAfter: retryAfter,
  details: details,
);

CodeChallenge _challenge(DateTime now, {int resendIn = 60}) => CodeChallenge(
  codeLength: 6,
  codeExpiresAt: now.add(const Duration(seconds: 600)),
  resendAvailableAt: now.add(Duration(seconds: resendIn)),
);

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  // ───────────────────────── repository ─────────────────────────
  group('repository', () {
    late FakeCloud cloud;
    late MemoryPendingVerificationStore pending;
    late MemoryInstallationIdStorage ids;
    var clock = fakeNow;

    OwlSonicAuthRepository repo({String id = 'install-1'}) =>
        OwlSonicAuthRepository(
          client: cloud.client,
          identity: InstallationIdentity(storage: ids, generate: () => id),
          pending: pending,
          now: () => clock,
        );

    setUp(() {
      cloud = FakeCloud();
      pending = MemoryPendingVerificationStore();
      ids = MemoryInstallationIdStorage();
      clock = fakeNow;
    });

    test(
      'register returns verification_required and issues no tokens',
      () async {
        cloud.backend.on(
          'POST /v1/auth/register',
          (_) => FakeReply(201, _pendingBody(email: 'me@example.com')),
        );

        final challenge = await repo().register(
          email: ' Me@Example.com ',
          password: 'password',
        );

        expect(challenge.email, 'me@example.com');
        expect(challenge.codeLength, 6);
        expect(
          challenge.resendAvailableAt,
          fakeNow.add(const Duration(seconds: 60)),
        );
        expect(cloud.session.isSignedIn, isFalse);
        expect(cloud.store.tokens, isNull);
        expect(cloud.store.writes, 0);
        final body = cloud.backend.to('POST /v1/auth/register').single.json;
        expect(body['email'], 'Me@Example.com');
        expect(body['device']['installation_id'], 'install-1');
        // Pending info persisted, without any code.
        expect(pending.value!.email, 'me@example.com');
        expect(pending.value!.installationId, 'install-1');
        expect(jsonEncode(pending.value!.toJson()), isNot(contains('code"')));
      },
    );

    test(
      'register rejects a response that is not verification_required',
      () async {
        cloud.backend.on(
          'POST /v1/auth/register',
          (_) => FakeReply(201, credentials()),
        );
        await expectLater(
          repo().register(email: 'a@b.co', password: 'password'),
          throwsA(
            isA<OwlSonicApiException>().having(
              (e) => e.kind,
              'kind',
              OwlSonicApiErrorKind.invalidResponse,
            ),
          ),
        );
        expect(cloud.session.isSignedIn, isFalse);
        expect(pending.value, isNull);
      },
    );

    test('valid code creates the session and clears pending state', () async {
      cloud.backend
        ..on('POST /v1/auth/register', (_) => FakeReply(201, _pendingBody()))
        ..on(
          'POST /v1/auth/verify-email',
          (_) => FakeReply(200, credentials()),
        );
      await repo().register(email: 'me@example.com', password: 'password');

      await repo().verifyEmail(email: 'me@example.com', code: '123456');

      final body = cloud.backend.to('POST /v1/auth/verify-email').single.json;
      expect(body['code'], '123456');
      expect(body['email'], 'me@example.com');
      expect(cloud.backend.requests.last.bearer, isNull);
      expect(cloud.session.status, AuthStatus.signedIn);
      expect(cloud.store.tokens!.accessToken, 'access-2');
      expect(pending.value, isNull);
    });

    test(
      'verification after app restart reuses the registering installation id',
      () async {
        cloud.backend
          ..on('POST /v1/auth/register', (_) => FakeReply(201, _pendingBody()))
          ..on(
            'POST /v1/auth/verify-email',
            (_) => FakeReply(200, credentials()),
          );
        await repo(
          id: 'install-1',
        ).register(email: 'me@example.com', password: 'password');

        // "Restart": a new repository whose identity would generate a new id.
        ids.value = null;
        await repo(
          id: 'would-be-different',
        ).verifyEmail(email: 'me@example.com', code: '123456');

        expect(
          cloud.backend
              .to('POST /v1/auth/verify-email')
              .single
              .json['device']['installation_id'],
          'install-1',
        );
        expect(cloud.session.isSignedIn, isTrue);
      },
    );

    test('invalid code keeps pending state and stays signed out', () async {
      cloud.backend
        ..on('POST /v1/auth/register', (_) => FakeReply(201, _pendingBody()))
        ..on(
          'POST /v1/auth/verify-email',
          (_) => FakeReply.error(400, 'INVALID_CODE'),
        );
      await repo().register(email: 'me@example.com', password: 'password');

      await expectLater(
        repo().verifyEmail(email: 'me@example.com', code: '000000'),
        throwsA(
          isA<OwlSonicApiException>().having(
            (e) => e.code,
            'code',
            'INVALID_CODE',
          ),
        ),
      );
      expect(cloud.session.isSignedIn, isFalse);
      expect(pending.value, isNotNull);
    });

    test('resend updates the timing from the server response', () async {
      cloud.backend
        ..on('POST /v1/auth/register', (_) => FakeReply(201, _pendingBody()))
        ..on(
          'POST /v1/auth/resend-verification',
          (_) => FakeReply(202, _accepted(resendIn: 60)),
        );
      await repo().register(email: 'me@example.com', password: 'password');

      clock = fakeNow.add(const Duration(seconds: 61));
      await repo().resendVerification(email: 'me@example.com');

      expect(
        cloud.backend.to('POST /v1/auth/resend-verification').single.json,
        {'email': 'me@example.com'},
      );
      expect(
        pending.value!.resendAvailableAt,
        clock.add(const Duration(seconds: 60)),
      );
      expect(pending.value!.installationId, 'install-1');
    });

    test('resend cooldown keeps Retry-After and stores the wait', () async {
      cloud.backend
        ..on('POST /v1/auth/register', (_) => FakeReply(201, _pendingBody()))
        ..on(
          'POST /v1/auth/resend-verification',
          (_) => FakeReply.error(
            429,
            'RESEND_COOLDOWN',
            headers: {
              'retry-after': ['42'],
            },
          ),
        );
      await repo().register(email: 'me@example.com', password: 'password');

      await expectLater(
        repo().resendVerification(email: 'me@example.com'),
        throwsA(
          isA<OwlSonicApiException>()
              .having((e) => e.code, 'code', 'RESEND_COOLDOWN')
              .having(
                (e) => e.retryAfter,
                'retryAfter',
                const Duration(seconds: 42),
              ),
        ),
      );
      expect(
        pending.value!.resendAvailableAt,
        fakeNow.add(const Duration(seconds: 42)),
      );
    });

    test(
      'login with an unverified email surfaces EMAIL_NOT_VERIFIED, no session',
      () async {
        cloud.backend.on(
          'POST /v1/auth/login',
          (_) => FakeReply.error(403, 'EMAIL_NOT_VERIFIED'),
        );
        await expectLater(
          repo().login(email: 'me@example.com', password: 'password'),
          throwsA(
            isA<OwlSonicApiException>()
                .having((e) => e.code, 'code', 'EMAIL_NOT_VERIFIED')
                .having((e) => e.statusCode, 'status', 403),
          ),
        );
        expect(cloud.session.isSignedIn, isFalse);
      },
    );

    test('forgot-password returns the challenge without a session', () async {
      cloud.backend.on(
        'POST /v1/auth/forgot-password',
        (_) => FakeReply(202, _accepted()),
      );
      final challenge = await repo().forgotPassword(email: 'x@y.co');
      expect(challenge.codeLength, 6);
      expect(cloud.session.isSignedIn, isFalse);
    });

    test(
      'successful reset clears stored tokens and does not sign in',
      () async {
        cloud = FakeCloud(initialTokens: tokens());
        await cloud.session.restore();
        expect(cloud.session.isSignedIn, isTrue);
        cloud.backend.on(
          'POST /v1/auth/reset-password',
          (_) => const FakeReply(204),
        );

        await repo().resetPassword(
          email: 'me@example.com',
          code: '123456',
          newPassword: 'new-password',
        );

        expect(cloud.backend.to('POST /v1/auth/reset-password').single.json, {
          'email': 'me@example.com',
          'code': '123456',
          'new_password': 'new-password',
        });
        expect(cloud.store.tokens, isNull);
        expect(cloud.session.status, AuthStatus.signedOut);
      },
    );

    test('failed reset leaves the session untouched', () async {
      cloud = FakeCloud(initialTokens: tokens());
      await cloud.session.restore();
      cloud.backend.on(
        'POST /v1/auth/reset-password',
        (_) => FakeReply.error(400, 'INVALID_CODE'),
      );
      await expectLater(
        repo().resetPassword(
          email: 'me@example.com',
          code: '123456',
          newPassword: 'new-password',
        ),
        throwsA(isA<OwlSonicApiException>()),
      );
      expect(cloud.store.tokens, isNotNull);
    });
  });

  // ───────────────────────── rules & messages ─────────────────────────
  group('password rules', () {
    test('7 characters are too short, 8 are accepted', () {
      expect(
        AuthRules.validateNewPassword('1234567'),
        'auth.errors.passwordTooShort',
      );
      expect(AuthRules.validateNewPassword('12345678'), isNull);
    });

    test('128 characters are accepted, 129 are too long', () {
      expect(AuthRules.validateNewPassword('a' * 128), isNull);
      expect(
        AuthRules.validateNewPassword('a' * 129),
        'auth.errors.passwordTooLong',
      );
    });

    test(
      'no digit, capital or symbol is required; length counts characters',
      () {
        expect(AuthRules.validateNewPassword('alllowercase'), isNull);
        expect(AuthRules.validateNewPassword('пароль12'), isNull);
        expect(AuthRules.validateNewPassword('😀' * 8), isNull);
        expect(AuthRules.validateNewPassword('😀' * 7), isNotNull);
        expect(
          AuthRules.validateNewPassword(''),
          'auth.errors.passwordRequired',
        );
      },
    );

    test(
      'login validation is untouched, so short old passwords still work',
      () {
        expect(CloudAccountCubit.validatePassword('short'), isNull);
      },
    );

    test('confirmation must match', () {
      expect(AuthRules.validateConfirmation('abcdefgh', 'abcdefgh'), isNull);
      expect(
        AuthRules.validateConfirmation('abcdefgh', 'abcdefgx'),
        'auth.errors.passwordMismatch',
      );
    });

    test('code must be exactly six digits; paste is cleaned', () {
      expect(AuthRules.validateCode('123456'), isNull);
      expect(AuthRules.validateCode('12345'), 'auth.errors.codeFormat');
      expect(AuthRules.validateCode('12345a'), 'auth.errors.codeFormat');
      expect(AuthRules.digitsOnly('123 456'), '123456');
      expect(AuthRules.digitsOnly('12-34-56'), '123456');
    });
  });

  group('error messages', () {
    String key(OwlSonicApiException e) => authMessageFor(e).key;

    test('backend codes map to friendly messages', () {
      expect(key(_api('INVALID_CODE', 400)), 'auth.errors.invalidCode');
      expect(
        key(_api('CODE_ATTEMPTS_EXCEEDED', 429)),
        'auth.errors.codeAttempts',
      );
      expect(
        key(_api('EMAIL_NOT_VERIFIED', 403)),
        'auth.errors.emailNotVerified',
      );
      expect(
        key(_api('EMAIL_DELIVERY_FAILED', 503)),
        'auth.errors.emailDeliveryFailed',
      );
      expect(
        key(_api('EMAIL_ALREADY_REGISTERED', 409)),
        'auth.errors.emailAlreadyRegistered',
      );
      expect(
        key(_api('INVALID_CREDENTIALS', 401)),
        'auth.errors.invalidCredentials',
      );
    });

    test('cooldowns carry the wait from Retry-After', () {
      final cooldown = authMessageFor(
        _api('RESEND_COOLDOWN', 429, retryAfter: const Duration(seconds: 17)),
      );
      expect(cooldown.key, 'auth.errors.resendCooldown');
      expect(cooldown.args['seconds'], '17');
      final limited = authMessageFor(
        _api('RATE_LIMITED', 429, retryAfter: const Duration(seconds: 30)),
      );
      expect(limited.key, 'auth.errors.rateLimitedWait');
      expect(limited.args['seconds'], '30');
      expect(key(_api('RATE_LIMITED', 429)), 'auth.errors.rateLimited');
    });

    test('password_too_short is not shown as generic invalid input', () {
      final short = _api(
        'INVALID_REQUEST',
        422,
        details: [
          {
            'loc': ['body', 'password'],
            'type': 'password_too_short',
          },
        ],
      );
      final long = _api(
        'INVALID_REQUEST',
        422,
        details: [
          {
            'loc': ['body', 'new_password'],
            'type': 'password_too_long',
          },
        ],
      );
      expect(key(short), 'auth.errors.passwordTooShort');
      expect(key(long), 'auth.errors.passwordTooLong');
      expect(
        key(
          _api(
            'INVALID_REQUEST',
            422,
            details: [
              {
                'loc': ['body', 'code'],
                'type': 'invalid_code_format',
              },
            ],
          ),
        ),
        'auth.errors.codeFormat',
      );
      expect(key(_api('INVALID_REQUEST', 422)), 'auth.errors.invalidRequest');
    });

    test('network and backend outages never leak raw text', () {
      const offline = OwlSonicApiException(
        kind: OwlSonicApiErrorKind.network,
        code: 'network_unavailable',
        message: 'SocketException: boom',
        retryable: true,
      );
      expect(key(offline), 'auth.errors.network');
      expect(
        key(_api('SERVICE_UNAVAILABLE', 503)),
        'auth.errors.backendUnavailable',
      );
      expect(
        key(_api('INTERNAL_ERROR', 500)),
        'auth.errors.backendUnavailable',
      );
      expect(key(_api('SOMETHING_NEW', 418)), 'auth.errors.generic');
    });
  });

  // ───────────────────────── verify cubit ─────────────────────────
  group('VerifyEmailCubit', () {
    PendingVerification pendingAt(DateTime now, {int resendIn = 60}) =>
        PendingVerification(
          email: 'me@example.com',
          installationId: 'install-1',
          codeExpiresAt: now.add(const Duration(seconds: 600)),
          resendAvailableAt: now.add(Duration(seconds: resendIn)),
        );

    test(
      'registration analytics follows verified session creation only',
      () async {
        final now = fakeNow;
        final auth = _ScriptedAuth()..pending = pendingAt(now);
        final analytics = _RecordingAnalytics();
        final cubit = VerifyEmailCubit(
          auth: auth,
          analytics: analytics,
          now: () => now,
        );
        await cubit.initialize();
        expect(analytics.events, isEmpty);
        auth.verifyError = _api('INVALID_CODE', 400);
        await cubit.verify('000000');
        expect(analytics.events, isEmpty);
        auth.verifyError = null;
        await cubit.verify('000000');
        await pumpEventQueue();
        expect(analytics.events, ['registration_completed']);
        await cubit.close();
      },
    );

    test('resumes after restart and counts down from the stored time', () {
      fakeAsync((async) {
        var now = fakeNow;
        final auth = _ScriptedAuth()..pending = pendingAt(now, resendIn: 30);
        final cubit = VerifyEmailCubit(auth: auth, now: () => now)
          ..initialize();
        async.flushMicrotasks();

        expect(cubit.state.status, VerifyEmailStatus.ready);
        expect(cubit.state.email, 'me@example.com');
        expect(cubit.state.resendSecondsLeft, 30);
        expect(cubit.state.canResend, isFalse);

        now = now.add(const Duration(seconds: 31));
        async.elapse(const Duration(seconds: 1));
        expect(cubit.state.resendSecondsLeft, 0);
        expect(cubit.state.canResend, isTrue);
        cubit.close();
      });
    });

    test('nothing pending (reinstall) is reported as missing', () {
      fakeAsync((async) {
        final cubit = VerifyEmailCubit(auth: _ScriptedAuth());
        cubit.initialize();
        async.flushMicrotasks();
        expect(cubit.state.status, VerifyEmailStatus.missing);
        cubit.close();
      });
    });

    test('code that is not six digits never reaches the backend', () {
      fakeAsync((async) {
        final auth = _ScriptedAuth()..pending = pendingAt(fakeNow);
        final cubit = VerifyEmailCubit(auth: auth, now: () => fakeNow)
          ..initialize();
        async.flushMicrotasks();
        cubit.verify('123');
        async.flushMicrotasks();
        expect(auth.calls, isEmpty);
        expect(cubit.state.error?.key, 'auth.errors.codeFormat');
        cubit.close();
      });
    });

    test('invalid code is reported inline and can be retried', () {
      fakeAsync((async) {
        final auth = _ScriptedAuth()
          ..pending = pendingAt(fakeNow)
          ..verifyError = _api('INVALID_CODE', 400);
        final cubit = VerifyEmailCubit(auth: auth, now: () => fakeNow)
          ..initialize();
        async.flushMicrotasks();
        cubit.verify('000000');
        async.flushMicrotasks();
        expect(cubit.state.error?.key, 'auth.errors.invalidCode');
        expect(cubit.state.submitting, isFalse);
        expect(cubit.state.canSubmit, isTrue);

        auth.verifyError = null;
        cubit.verify('123456');
        async.flushMicrotasks();
        expect(cubit.state.status, VerifyEmailStatus.done);
        cubit.close();
      });
    });

    test('CODE_ATTEMPTS_EXCEEDED kills the code until a new one is sent', () {
      fakeAsync((async) {
        var now = fakeNow;
        final auth = _ScriptedAuth()
          ..pending = pendingAt(now, resendIn: 0)
          ..verifyError = _api('CODE_ATTEMPTS_EXCEEDED', 429)
          ..resendResult = _challenge(now);
        final cubit = VerifyEmailCubit(auth: auth, now: () => now)
          ..initialize();
        async.flushMicrotasks();
        cubit.verify('000000');
        async.flushMicrotasks();
        expect(cubit.state.codeDead, isTrue);
        expect(cubit.state.canSubmit, isFalse);

        cubit.resend();
        async.flushMicrotasks();
        expect(cubit.state.codeDead, isFalse);
        expect(cubit.state.canSubmit, isTrue);
        expect(cubit.state.resendSecondsLeft, 60);
        cubit.close();
      });
    });

    test('an expired code asks for a new one, and resend works afterwards', () {
      fakeAsync((async) {
        var now = fakeNow;
        final auth = _ScriptedAuth()
          ..pending = pendingAt(now, resendIn: 0)
          ..resendResult = _challenge(
            fakeNow.add(const Duration(seconds: 700)),
          );
        final cubit = VerifyEmailCubit(auth: auth, now: () => now)
          ..initialize();
        async.flushMicrotasks();

        now = now.add(const Duration(seconds: 601));
        async.elapse(const Duration(seconds: 1));
        expect(cubit.state.codeExpired, isTrue);
        expect(cubit.state.canSubmit, isFalse);
        expect(cubit.state.canResend, isTrue);

        cubit.resend();
        async.flushMicrotasks();
        expect(cubit.state.codeExpired, isFalse);
        expect(cubit.state.notice?.key, 'auth.verify.codeSent');
        cubit.close();
      });
    });

    test('resend is blocked during the cooldown and cannot be spammed', () {
      fakeAsync((async) {
        final auth = _ScriptedAuth()..pending = pendingAt(fakeNow);
        final cubit = VerifyEmailCubit(auth: auth, now: () => fakeNow)
          ..initialize();
        async.flushMicrotasks();
        cubit.resend();
        cubit.resend();
        async.flushMicrotasks();
        expect(auth.calls, isEmpty);
        cubit.close();
      });
    });

    test('RESEND_COOLDOWN restarts the countdown from Retry-After', () {
      fakeAsync((async) {
        final auth = _ScriptedAuth()
          ..pending = pendingAt(fakeNow, resendIn: 0)
          ..resendError = _api(
            'RESEND_COOLDOWN',
            429,
            retryAfter: const Duration(seconds: 25),
          );
        final cubit = VerifyEmailCubit(auth: auth, now: () => fakeNow)
          ..initialize();
        async.flushMicrotasks();
        cubit.resend();
        async.flushMicrotasks();
        expect(cubit.state.resendSecondsLeft, 25);
        expect(cubit.state.error?.key, 'auth.errors.resendCooldown');
        cubit.resend(); // still cooling down
        async.flushMicrotasks();
        expect(auth.calls, ['resend']);
        cubit.close();
      });
    });

    test('simultaneous resend taps send a single request', () {
      fakeAsync((async) {
        final auth = _ScriptedAuth()
          ..pending = pendingAt(fakeNow, resendIn: 0)
          ..resendResult = _challenge(fakeNow);
        final cubit = VerifyEmailCubit(auth: auth, now: () => fakeNow)
          ..initialize();
        async.flushMicrotasks();
        cubit.resend();
        cubit.resend();
        cubit.resend();
        async.flushMicrotasks();
        expect(auth.calls, ['resend']);
        cubit.close();
      });
    });
  });

  group('PasswordResetCubit', () {
    test('request always moves on with the neutral notice', () {
      fakeAsync((async) {
        final auth = _ScriptedAuth()..resendResult = _challenge(fakeNow);
        final cubit = PasswordResetCubit(auth: auth, now: () => fakeNow);
        cubit.requestCode(' nobody@example.com ');
        async.flushMicrotasks();
        expect(cubit.state.step, PasswordResetStep.code);
        expect(cubit.state.email, 'nobody@example.com');
        expect(cubit.state.notice, PasswordResetCubit.neutralNotice);
        cubit.close();
      });
    });

    test('a cooldown also leads to the code step with the same notice', () {
      fakeAsync((async) {
        final auth = _ScriptedAuth()
          ..resendError = _api(
            'RESEND_COOLDOWN',
            429,
            retryAfter: const Duration(seconds: 44),
          );
        final cubit = PasswordResetCubit(auth: auth, now: () => fakeNow);
        cubit.requestCode('a@b.co');
        async.flushMicrotasks();
        expect(cubit.state.step, PasswordResetStep.code);
        expect(cubit.state.notice, PasswordResetCubit.neutralNotice);
        expect(cubit.state.resendSecondsLeft, 44);
        cubit.close();
      });
    });

    test('reset success ends in done; invalid code stays on the form', () {
      fakeAsync((async) {
        final auth = _ScriptedAuth()..resendResult = _challenge(fakeNow);
        final cubit = PasswordResetCubit(auth: auth, now: () => fakeNow);
        cubit.requestCode('a@b.co');
        async.flushMicrotasks();

        auth.verifyError = _api('INVALID_CODE', 400);
        cubit.reset(code: '111111', newPassword: 'new-password');
        async.flushMicrotasks();
        expect(cubit.state.step, PasswordResetStep.code);
        expect(cubit.state.error?.key, 'auth.errors.invalidCode');

        auth.verifyError = null;
        cubit.reset(code: '222222', newPassword: 'new-password');
        async.flushMicrotasks();
        expect(cubit.state.step, PasswordResetStep.done);
        cubit.close();
      });
    });
  });

  // ───────────────────────── widgets ─────────────────────────
  group('screens', () {
    late FakeCloud cloud;
    late MemoryPendingVerificationStore pending;
    late OwlSonicAuthRepository auth;
    late CloudAccountCubit account;
    var clock = fakeNow;

    Future<void> pumpApp(
      WidgetTester tester, {
      Size size = const Size(420, 900),
      Locale locale = const Locale('en'),
      String initial = '/account',
    }) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      cloud = FakeCloud();
      pending = MemoryPendingVerificationStore();
      clock = fakeNow;
      auth = OwlSonicAuthRepository(
        client: cloud.client,
        identity: InstallationIdentity(
          storage: MemoryInstallationIdStorage(),
          generate: () => 'install-1',
        ),
        pending: pending,
        now: () => clock,
      );
      account = CloudAccountCubit(
        retryDelay: (_) async {},
        session: cloud.session,
        configured: true,
        auth: auth,
        account: OwlSonicAccountRepository(cloud.client),
        storageMode: _MemoryMode(),
      );
      addTearDown(account.close);
      // Tests may pre-seed `pending` through [seed] before pumping.
      final router = GoRouter(
        initialLocation: initial,
        routes: [
          GoRoute(
            path: '/${AppRouterNames.home}',
            name: AppRouterNames.home,
            builder: (_, _) => const Scaffold(body: Text('HOME')),
          ),
          GoRoute(
            path: '/${AppRouterNames.account}',
            name: AppRouterNames.account,
            builder: (_, state) => BlocProvider<CloudAccountCubit>.value(
              value: account..initialize(),
              child: CloudAccountScreen(
                initialRegister:
                    state.uri.queryParameters['mode'] == 'register',
              ),
            ),
          ),
          GoRoute(
            path: '/${AppRouterNames.verifyEmail}',
            name: AppRouterNames.verifyEmail,
            builder: (_, _) => BlocProvider(
              create: (_) =>
                  VerifyEmailCubit(auth: auth, now: () => clock)..initialize(),
              child: const VerifyEmailScreen(),
            ),
          ),
          GoRoute(
            path: '/${AppRouterNames.forgotPassword}',
            name: AppRouterNames.forgotPassword,
            builder: (_, state) => BlocProvider(
              create: (_) => PasswordResetCubit(auth: auth, now: () => clock),
              child: ForgotPasswordScreen(
                initialEmail: state.uri.queryParameters['email'] ?? '',
              ),
            ),
          ),
        ],
      );
      await tester.pumpWidget(
        EasyLocalization(
          assetLoader: const _DiskAssetLoader(),
          supportedLocales: const [Locale('en'), Locale('ru')],
          path: 'assets/translations',
          fallbackLocale: const Locale('en'),
          startLocale: locale,
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
      );
      await tester.pumpAndSettle();
    }

    Future<void> teardown(WidgetTester tester) async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    }

    Future<void> enter(WidgetTester tester, String key, String text) async {
      await tester.enterText(find.byKey(ValueKey(key)), text);
      await tester.pump();
    }

    Future<void> tapKey(WidgetTester tester, String key) async {
      final finder = find.byKey(ValueKey(key));
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    Future<void> register(WidgetTester tester) async {
      await tester.tap(find.text('Create account').first);
      await tester.pumpAndSettle();
      await enter(tester, 'cloud-email', 'me@example.com');
      await enter(tester, 'cloud-password', 'password');
      await tapKey(tester, 'cloud-submit');
    }

    testWidgets(
      'register form shows the 8-character hint and validates locally',
      (tester) async {
        await pumpApp(tester);
        expect(find.text('At least 8 characters'), findsNothing);
        await tester.tap(find.text('Create account').first);
        await tester.pumpAndSettle();
        expect(find.text('At least 8 characters'), findsOneWidget);

        await enter(tester, 'cloud-email', 'me@example.com');
        await enter(tester, 'cloud-password', '1234567');
        await tapKey(tester, 'cloud-submit');

        expect(
          find.text('Password must be at least 8 characters.'),
          findsOneWidget,
        );
        expect(cloud.backend.requests, isEmpty);

        // The form keeps what the user typed.
        expect(find.text('me@example.com'), findsOneWidget);
        await teardown(tester);
      },
    );

    testWidgets('exactly 8 characters are sent to the backend', (tester) async {
      await pumpApp(tester);
      cloud.backend.on(
        'POST /v1/auth/register',
        (_) => FakeReply(201, _pendingBody()),
      );
      await tester.tap(find.text('Create account').first);
      await tester.pumpAndSettle();
      await enter(tester, 'cloud-email', 'me@example.com');
      await enter(tester, 'cloud-password', '12345678');
      await tapKey(tester, 'cloud-submit');

      expect(cloud.backend.to('POST /v1/auth/register'), hasLength(1));
      await teardown(tester);
    });

    testWidgets('show/hide password toggles the field', (tester) async {
      await pumpApp(tester);
      TextField field() => tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const ValueKey('cloud-password')),
          matching: find.byType(TextField),
        ),
      );
      expect(field().obscureText, isTrue);
      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(field().obscureText, isFalse);
      expect(find.byTooltip('Hide password'), findsOneWidget);
      await teardown(tester);
    });

    testWidgets('backend password_too_short is shown, not "Invalid input"', (
      tester,
    ) async {
      await pumpApp(tester);
      cloud.backend.on(
        'POST /v1/auth/register',
        (_) => _validation(
          'password_too_short',
          'password',
          message: 'Password must be at least 8 characters.',
        ),
      );
      await register(tester);
      expect(
        find.text('Password must be at least 8 characters.'),
        findsOneWidget,
      );
      expect(find.textContaining('Server said'), findsNothing);
      await teardown(tester);
    });

    testWidgets('register opens Verify email without a signed-in state', (
      tester,
    ) async {
      await pumpApp(tester);
      cloud.backend.on(
        'POST /v1/auth/register',
        (_) => FakeReply(201, _pendingBody()),
      );
      await register(tester);

      expect(find.text('Verify your email'), findsOneWidget);
      expect(
        find.text('We sent a 6-digit code to me@example.com.'),
        findsOneWidget,
      );
      expect(cloud.session.isSignedIn, isFalse);
      expect(cloud.store.tokens, isNull);
      expect(pending.value?.email, 'me@example.com');
      await teardown(tester);
    });

    testWidgets(
      'code field: numeric keyboard, one-time-code autofill, paste cleaned',
      (tester) async {
        await pumpApp(tester);
        cloud.backend.on(
          'POST /v1/auth/register',
          (_) => FakeReply(201, _pendingBody()),
        );
        await register(tester);

        final field = tester.widget<TextField>(
          find.descendant(
            of: find.byKey(const ValueKey('verify-code')),
            matching: find.byType(TextField),
          ),
        );
        expect(field.keyboardType, TextInputType.number);
        expect(field.autofillHints, contains(AutofillHints.oneTimeCode));

        await enter(tester, 'verify-code', '123 456 789');
        expect(find.text('123456'), findsOneWidget);
        await teardown(tester);
      },
    );

    testWidgets('valid code signs in and continues into the app', (
      tester,
    ) async {
      await pumpApp(tester);
      cloud.backend
        ..on('POST /v1/auth/register', (_) => FakeReply(201, _pendingBody()))
        ..on(
          'POST /v1/auth/verify-email',
          (_) => FakeReply(200, credentials()),
        );
      await register(tester);

      await enter(tester, 'verify-code', '123456');
      await tapKey(tester, 'verify-submit');

      final body = cloud.backend.to('POST /v1/auth/verify-email').single.json;
      expect(body['device']['installation_id'], 'install-1');
      expect(cloud.session.isSignedIn, isTrue);
      expect(find.text('HOME'), findsOneWidget);
      expect(pending.value, isNull);
      await teardown(tester);
    });

    testWidgets('invalid code shows an inline message and keeps the input', (
      tester,
    ) async {
      await pumpApp(tester);
      cloud.backend
        ..on('POST /v1/auth/register', (_) => FakeReply(201, _pendingBody()))
        ..on(
          'POST /v1/auth/verify-email',
          (_) => FakeReply.error(400, 'INVALID_CODE'),
        );
      await register(tester);
      await enter(tester, 'verify-code', '000000');
      await tapKey(tester, 'verify-submit');

      expect(
        find.text(
          'That code is incorrect or has expired. Check it or request a new one.',
        ),
        findsOneWidget,
      );
      expect(find.text('000000'), findsOneWidget);
      expect(cloud.session.isSignedIn, isFalse);
      await teardown(tester);
    });

    testWidgets(
      'resend: 60s countdown, then one request, then a new countdown',
      (tester) async {
        await pumpApp(tester);
        cloud.backend
          ..on('POST /v1/auth/register', (_) => FakeReply(201, _pendingBody()))
          ..on(
            'POST /v1/auth/resend-verification',
            (_) => FakeReply(202, _accepted()),
          );
        await register(tester);

        expect(find.text('Resend code in 60s'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('verify-resend')));
        await tester.pump();
        expect(cloud.backend.to('POST /v1/auth/resend-verification'), isEmpty);

        clock = clock.add(const Duration(seconds: 61));
        await tester.pump(const Duration(seconds: 1));
        expect(find.text('Resend code'), findsOneWidget);

        await tester.tap(find.byKey(const ValueKey('verify-resend')));
        await tester.tap(find.byKey(const ValueKey('verify-resend')));
        await tester.pumpAndSettle();
        expect(
          cloud.backend.to('POST /v1/auth/resend-verification'),
          hasLength(1),
        );
        expect(find.text('We sent you a new code.'), findsOneWidget);
        expect(find.text('Resend code in 60s'), findsOneWidget);
        await teardown(tester);
      },
    );

    testWidgets(
      'resume after restart: account offers to continue, code screen opens',
      (tester) async {
        await pumpApp(tester);
        pending.value = PendingVerification(
          email: 'me@example.com',
          installationId: 'install-1',
          codeExpiresAt: fakeNow.add(const Duration(seconds: 300)),
          resendAvailableAt: fakeNow.add(const Duration(seconds: 20)),
        );
        await account.refreshPending();
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('cloud-pending-card')),
          findsOneWidget,
        );
        await tapKey(tester, 'cloud-pending-continue');
        expect(find.text('Verify your email'), findsOneWidget);
        expect(find.text('Resend code in 20s'), findsOneWidget);
        await teardown(tester);
      },
    );

    testWidgets('reinstall: nothing to verify explains how to continue', (
      tester,
    ) async {
      await pumpApp(tester, initial: '/${AppRouterNames.verifyEmail}');
      expect(find.text('Nothing to verify on this device'), findsOneWidget);
      expect(
        find.text('Create your account again to get a new code.'),
        findsOneWidget,
      );
      await teardown(tester);
    });

    testWidgets('login with EMAIL_NOT_VERIFIED offers to continue verification', (
      tester,
    ) async {
      await pumpApp(tester);
      pending.value = PendingVerification(
        email: 'me@example.com',
        installationId: 'install-1',
        codeExpiresAt: fakeNow.add(const Duration(seconds: 300)),
        resendAvailableAt: fakeNow,
      );
      await account.refreshPending();
      cloud.backend.on(
        'POST /v1/auth/login',
        (_) => FakeReply.error(403, 'EMAIL_NOT_VERIFIED'),
      );
      await enter(tester, 'cloud-email', 'me@example.com');
      await enter(tester, 'cloud-password', 'password');
      await tapKey(tester, 'cloud-submit');

      expect(find.text('Login failed'), findsNothing);
      expect(
        find.text(
          "Your email isn't verified yet. Enter the code we sent you, or request a new one.",
        ),
        findsOneWidget,
      );
      await tapKey(tester, 'cloud-continue-verification');
      expect(find.text('Verify your email'), findsOneWidget);
      await teardown(tester);
    });

    testWidgets(
      'unverified login from another device points to registering again',
      (tester) async {
        await pumpApp(tester);
        cloud.backend.on(
          'POST /v1/auth/login',
          (_) => FakeReply.error(403, 'EMAIL_NOT_VERIFIED'),
        );
        await enter(tester, 'cloud-email', 'me@example.com');
        await enter(tester, 'cloud-password', 'password');
        await tapKey(tester, 'cloud-submit');

        expect(
          find.byKey(const ValueKey('cloud-continue-verification')),
          findsNothing,
        );
        await tapKey(tester, 'cloud-create-again');
        // Register mode, email kept.
        expect(find.text('At least 8 characters'), findsOneWidget);
        expect(find.text('me@example.com'), findsOneWidget);
        await teardown(tester);
      },
    );

    testWidgets('Forgot password is visible under the login form only', (
      tester,
    ) async {
      await pumpApp(tester);
      expect(find.text('Forgot password?'), findsOneWidget);
      await tester.tap(find.text('Create account').first);
      await tester.pumpAndSettle();
      expect(find.text('Forgot password?'), findsNothing);
      await teardown(tester);
    });

    testWidgets('forgot → code → new password → back to login, no sign-in', (
      tester,
    ) async {
      await pumpApp(tester);
      cloud.store.tokens = tokens();
      cloud.backend
        ..on(
          'POST /v1/auth/forgot-password',
          (_) => FakeReply(202, _accepted()),
        )
        ..on('POST /v1/auth/reset-password', (_) => const FakeReply(204));

      await enter(tester, 'cloud-email', 'nobody@example.com');
      await tapKey(tester, 'cloud-forgot-password');
      expect(find.text('Reset password'), findsOneWidget);
      expect(
        tester
            .widget<TextFormField>(find.byKey(const ValueKey('reset-email')))
            .controller!
            .text,
        'nobody@example.com',
      );

      await tapKey(tester, 'reset-send');
      expect(
        find.text(
          "If an account exists for this email, we've sent a verification code.",
        ),
        findsOneWidget,
      );

      await enter(tester, 'reset-code', '654321');
      await enter(tester, 'reset-password', '1234567');
      await enter(tester, 'reset-confirm', '1234567');
      await tapKey(tester, 'reset-submit');
      expect(
        find.text('Password must be at least 8 characters.'),
        findsOneWidget,
      );
      expect(cloud.backend.to('POST /v1/auth/reset-password'), isEmpty);

      await enter(tester, 'reset-password', 'new-password');
      await enter(tester, 'reset-confirm', 'other-password');
      await tapKey(tester, 'reset-submit');
      expect(find.text("Passwords don't match"), findsOneWidget);

      await enter(tester, 'reset-confirm', 'new-password');
      await tapKey(tester, 'reset-submit');

      expect(cloud.backend.to('POST /v1/auth/reset-password'), hasLength(1));
      expect(find.text('Password updated'), findsOneWidget);
      expect(find.text('Forgot password?'), findsOneWidget); // login again
      expect(cloud.store.tokens, isNull);
      expect(cloud.session.isSignedIn, isFalse);
      await teardown(tester);
    });

    testWidgets('reset request UI does not reveal whether the account exists', (
      tester,
    ) async {
      Future<List<String>> texts(String email) async {
        await pumpApp(tester, initial: '/${AppRouterNames.forgotPassword}');
        cloud.backend.on(
          'POST /v1/auth/forgot-password',
          (_) => FakeReply(202, _accepted()),
        );
        await enter(tester, 'reset-email', email);
        await tapKey(tester, 'reset-send');
        final result = tester
            .widgetList<Text>(find.byType(Text))
            .map((t) => t.data ?? '')
            .where((t) => !t.contains(email))
            .toList();
        await teardown(tester);
        return result;
      }

      final known = await texts('known@example.com');
      final unknown = await texts('unknown@example.com');
      expect(known, unknown);
    });

    testWidgets('Russian localization of verify and forgot screens', (
      tester,
    ) async {
      await pumpApp(
        tester,
        locale: const Locale('ru'),
        initial: '/${AppRouterNames.forgotPassword}',
      );
      expect(find.text('Сброс пароля'), findsWidgets);
      await teardown(tester);

      await pumpApp(tester, locale: const Locale('ru'));
      expect(find.text('Забыли пароль?'), findsOneWidget);
      cloud.backend.on(
        'POST /v1/auth/register',
        (_) => FakeReply(201, _pendingBody()),
      );
      await tester.tap(find.text('Создать аккаунт').first);
      await tester.pumpAndSettle();
      expect(find.text('Не менее 8 символов'), findsOneWidget);
      await enter(tester, 'cloud-email', 'me@example.com');
      await enter(tester, 'cloud-password', 'password');
      await tapKey(tester, 'cloud-submit');
      expect(find.text('Подтвердите почту'), findsOneWidget);
      expect(
        find.text('Мы отправили 6-значный код на me@example.com.'),
        findsOneWidget,
      );
      await teardown(tester);
    });

    testWidgets('desktop: Enter in the code field submits', (tester) async {
      await pumpApp(tester, size: const Size(1280, 800));
      cloud.backend
        ..on('POST /v1/auth/register', (_) => FakeReply(201, _pendingBody()))
        ..on(
          'POST /v1/auth/verify-email',
          (_) => FakeReply(200, credentials()),
        );
      await register(tester);
      await enter(tester, 'verify-code', '123456');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(cloud.backend.to('POST /v1/auth/verify-email'), hasLength(1));
      expect(find.text('HOME'), findsOneWidget);
      await teardown(tester);
    });

    testWidgets('desktop: Enter in the password field submits registration', (
      tester,
    ) async {
      await pumpApp(tester, size: const Size(1280, 800));
      cloud.backend.on(
        'POST /v1/auth/register',
        (_) => FakeReply(201, _pendingBody()),
      );
      await tester.tap(find.text('Create account').first);
      await tester.pumpAndSettle();
      await enter(tester, 'cloud-email', 'me@example.com');
      await tester.tap(find.byKey(const ValueKey('cloud-password')));
      await enter(tester, 'cloud-password', 'password');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('Verify your email'), findsOneWidget);
      await teardown(tester);
    });

    testWidgets(
      'mobile: back from Verify returns to the form; small screen has no overflow',
      (tester) async {
        await pumpApp(tester, size: const Size(320, 568));
        cloud.backend.on(
          'POST /v1/auth/register',
          (_) => FakeReply(201, _pendingBody()),
        );
        await register(tester);
        expect(find.text('Verify your email'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('cloud-submit')), findsOneWidget);
        expect(find.text('me@example.com'), findsOneWidget);
        // The pending registration can be resumed from the form.
        expect(
          find.byKey(const ValueKey('cloud-pending-card')),
          findsOneWidget,
        );
        await teardown(tester);
      },
    );

    testWidgets('network and outage errors are friendly, never raw', (
      tester,
    ) async {
      await pumpApp(tester);
      cloud.backend.offline = true;
      await enter(tester, 'cloud-email', 'me@example.com');
      await enter(tester, 'cloud-password', 'password');
      await tapKey(tester, 'cloud-submit');
      expect(
        find.text(
          'Can\'t reach OwlSonic. Check your connection and try again.',
        ),
        findsOneWidget,
      );

      cloud.backend
        ..offline = false
        ..on(
          'POST /v1/auth/login',
          (_) => FakeReply.error(503, 'SERVICE_UNAVAILABLE', retryable: true),
        );
      await tapKey(tester, 'cloud-submit');
      expect(
        find.text(
          'OwlSonic is temporarily unavailable. Please try again in a moment.',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Server said'), findsNothing);
      await teardown(tester);
    });
  });
}
