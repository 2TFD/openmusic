class LyricsConfig {
  LyricsConfig({
    String baseUrl = defaultBaseUrl,
    this.userAgent = defaultUserAgent,
    this.requestDelay = const Duration(milliseconds: 350),
    this.backfillBatchSize = 10,
    this.maxAttempts = 3,
    this.defaultRetryDelay = const Duration(minutes: 5),
  }) : baseUri = _validate(baseUrl) {
    if (userAgent.trim().isEmpty) {
      throw ArgumentError.value(userAgent, 'userAgent');
    }
    if (requestDelay.isNegative ||
        backfillBatchSize <= 0 ||
        maxAttempts <= 0 ||
        defaultRetryDelay.isNegative) {
      throw ArgumentError('Invalid lyrics queue configuration');
    }
  }

  static const defaultBaseUrl = 'https://lrclib.net';
  static const defaultUserAgent =
      'OpenMusic/0.1.0 (https://github.com/openmusic-app/openmusic)';

  final Uri baseUri;
  final String userAgent;
  final Duration requestDelay;
  final int backfillBatchSize;
  final int maxAttempts;
  final Duration defaultRetryDelay;

  String get baseUrl => baseUri.toString().replaceFirst(RegExp(r'/$'), '');

  static Uri _validate(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null ||
        !uri.hasAuthority ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      throw ArgumentError.value(value, 'baseUrl', 'Expected HTTP(S) URL');
    }
    return uri;
  }
}
