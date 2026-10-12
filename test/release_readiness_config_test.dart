import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/core/config/app_links.dart';
import 'package:owlsonic/core/config/owlsonic_api_config.dart';
import 'package:owlsonic/core/telemetry/diagnostics_scrubber.dart';

OwlSonicApiConfig config(String env, String? url) => OwlSonicApiConfig(
  environment: OwlSonicEnvironment.parse(env),
  baseUrl: url,
);

void main() {
  group('release configuration', () {
    test('the committed production config points at the production API', () {
      final json =
          jsonDecode(File('config/production.json').readAsStringSync())
              as Map<String, dynamic>;
      expect(json['OWLSONIC_ENV'], 'production');
      expect(json['OWLSONIC_API_BASE_URL'], 'https://api.owlsonic.stream');
      expect(
        OwlSonicApiConfig.productionBaseUrl,
        json['OWLSONIC_API_BASE_URL'],
      );
      // Public configuration only: no credentials or API keys.
      expect(
        json.keys.where(
          (k) => RegExp('SECRET|TOKEN|KEY|PASSWORD|DSN').hasMatch(k),
        ),
        isEmpty,
      );
      config(
        'production',
        json['OWLSONIC_API_BASE_URL'] as String,
      ).ensureReleaseReady(releaseMode: true, localOnly: false);
    });

    test('the release script builds from the committed config', () {
      final script = File('tool/build_release.sh').readAsStringSync();
      expect(
        script,
        contains('--dart-define-from-file=config/production.json'),
      );
      expect(script, contains('--release'));
    });

    test('a release build without a backend fails loudly', () {
      expect(
        () => config(
          'development',
          null,
        ).ensureReleaseReady(releaseMode: true, localOnly: false),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('OWLSONIC_API_BASE_URL'),
          ),
        ),
      );
    });

    test('development, plain HTTP or a wrong production host fail', () {
      for (final bad in [
        config('development', 'https://api.owlsonic.stream'),
        config('staging', 'http://staging.example.com'),
        config('production', 'https://api.example.com'),
        config('production', 'http://api.owlsonic.stream'),
      ]) {
        expect(
          () => bad.ensureReleaseReady(releaseMode: true, localOnly: false),
          throwsStateError,
          reason: '${bad.environment} ${bad.baseUri}',
        );
      }
    });

    test('staging over HTTPS, local-only builds and debug builds pass', () {
      config(
        'staging',
        'https://staging.owlsonic.stream',
      ).ensureReleaseReady(releaseMode: true, localOnly: false);
      config(
        'development',
        null,
      ).ensureReleaseReady(releaseMode: true, localOnly: true);
      config(
        'development',
        null,
      ).ensureReleaseReady(releaseMode: false, localOnly: false);
    });
  });

  test('legal links are HTTPS pages on owlsonic.stream', () {
    for (final uri in [
      AppLinks.privacy,
      AppLinks.terms,
      AppLinks.accountDeletion,
      AppLinks.support,
    ]) {
      expect(uri.scheme, 'https');
      expect(uri.host, 'owlsonic.stream');
    }
  });

  group('diagnostics scrubbing', () {
    test('signed URLs, tokens, e-mails and file paths are removed', () {
      const raw =
          'GET https://cdn.owlsonic.stream/a/b.mp3?X-Amz-Signature=abc&exp=1 '
          'Authorization: Bearer eyJhbGciOi.eyJzdWIiOiIx.c2lnbmF0dXJl '
          'user me@example.com file /Users/alice/Music/Artist - Song.flac '
          'win C:\\Users\\bob\\Music\\Song.mp3 request_id=req-42';
      final scrubbed = scrubDiagnostics(raw);
      expect(scrubbed, isNot(contains('Signature')));
      expect(scrubbed, isNot(contains('eyJ')));
      expect(scrubbed, isNot(contains('me@example.com')));
      expect(scrubbed, isNot(contains('alice')));
      expect(scrubbed, isNot(contains('bob')));
      expect(
        scrubbed,
        contains('https://cdn.owlsonic.stream/a/b.mp3?<redacted>'),
      );
      expect(scrubbed, contains('request_id=req-42'));
      expect(scrubbed, contains('<path>'));
    });

    test('ordinary messages are unchanged', () {
      const message = 'Sync failed: timeout status=null network=true';
      expect(scrubDiagnostics(message), message);
    });
  });
}
