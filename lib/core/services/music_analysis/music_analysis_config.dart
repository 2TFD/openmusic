class MusicAnalysisConfig {
  MusicAnalysisConfig(String baseUrl) : baseUri = _validate(baseUrl);

  static const defaultBaseUrl = 'https://kxmwebwe-trackembeddingapi.hf.space';

  final Uri baseUri;
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

class MusicAnalysisQueueConfig {
  const MusicAnalysisQueueConfig({
    this.analysisBackfillBatchSize = 4,
    this.modelRegistryRefreshInterval = const Duration(minutes: 15),
    this.analysisFailureBackfillCooldown = const Duration(hours: 6),
  }) : assert(analysisBackfillBatchSize > 0);

  final int analysisBackfillBatchSize;
  final Duration modelRegistryRefreshInterval;
  final Duration analysisFailureBackfillCooldown;
}
