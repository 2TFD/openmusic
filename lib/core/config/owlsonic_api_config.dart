enum OwlSonicEnvironment {
  development,
  staging,
  production;

  static OwlSonicEnvironment parse(String value) =>
      switch (value.trim().toLowerCase()) {
        'production' || 'prod' => OwlSonicEnvironment.production,
        'staging' || 'stage' => OwlSonicEnvironment.staging,
        _ => OwlSonicEnvironment.development,
      };
}

/// Single source of truth for the OwlSonic backend location and HTTP limits.
///
/// Configured at build time:
///   --dart-define=OWLSONIC_ENV=production
///   --dart-define=OWLSONIC_API_BASE_URL=https://api.example.com
///
/// No production URL is compiled in. Without a base URL the cloud features are
/// reported as unconfigured instead of silently talking to a guessed host.
/// Release builds are checked by [ensureReleaseReady]; the reproducible
/// production build passes `--dart-define-from-file=config/production.json`
/// (see `tool/build_release.sh`).
class OwlSonicApiConfig {
  OwlSonicApiConfig({
    required this.environment,
    String? baseUrl,
    this.connectTimeout = const Duration(seconds: 10),
    this.requestTimeout = const Duration(seconds: 30),
    this.uploadTimeout = const Duration(minutes: 10),
  }) : baseUri = _parse(baseUrl);

  factory OwlSonicApiConfig.fromEnvironment() => OwlSonicApiConfig(
    environment: OwlSonicEnvironment.parse(
      const String.fromEnvironment('OWLSONIC_ENV', defaultValue: 'development'),
    ),
    baseUrl: const String.fromEnvironment('OWLSONIC_API_BASE_URL'),
  );

  final OwlSonicEnvironment environment;
  final Uri? baseUri;
  final Duration connectTimeout;
  final Duration requestTimeout;
  final Duration uploadTimeout;

  bool get isConfigured => baseUri != null;

  /// The OwlSonic production API.
  static const productionBaseUrl = 'https://api.owlsonic.stream';

  /// Fails a release build that would ship a silently broken cloud mode:
  /// no backend URL, a development configuration, plain HTTP, or a
  /// production build pointing anywhere but [productionBaseUrl]. A build
  /// meant to be local-only must say so with `OWLSONIC_LOCAL_ONLY=true`.
  /// Debug and profile builds are never blocked.
  void ensureReleaseReady({
    required bool releaseMode,
    bool localOnly = const bool.fromEnvironment('OWLSONIC_LOCAL_ONLY'),
  }) {
    if (!releaseMode || localOnly) return;
    const hint =
        'Build with --dart-define-from-file=config/production.json '
        '(tool/build_release.sh), or set OWLSONIC_LOCAL_ONLY=true for a '
        'local-only build.';
    final uri = baseUri;
    if (uri == null) {
      throw StateError('Release build without OWLSONIC_API_BASE_URL. $hint');
    }
    if (environment == OwlSonicEnvironment.development) {
      throw StateError('Release build with OWLSONIC_ENV=development. $hint');
    }
    if (uri.scheme != 'https') {
      throw StateError('Release builds must use an https:// backend. $hint');
    }
    if (environment == OwlSonicEnvironment.production &&
        baseUrl != productionBaseUrl) {
      throw StateError(
        'Production build must use $productionBaseUrl, not $baseUrl. $hint',
      );
    }
  }

  String get baseUrl {
    final uri = baseUri;
    if (uri == null) {
      throw StateError('OWLSONIC_API_BASE_URL is not configured');
    }
    return uri.toString().replaceFirst(RegExp(r'/+$'), '');
  }

  static Uri? _parse(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    final uri = Uri.tryParse(trimmed);
    if (uri == null ||
        !uri.hasAuthority ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      throw ArgumentError.value(value, 'baseUrl', 'Expected HTTP(S) URL');
    }
    return uri;
  }
}
