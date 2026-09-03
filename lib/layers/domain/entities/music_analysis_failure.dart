enum MusicAnalysisFailureKind {
  network,
  server,
  decode,
  unsupportedSchema,
  invalidRepresentation,
  fileNotFound,
  needsDownload,
  staleContent,
  unknown,
}

class MusicAnalysisFailure implements Exception {
  const MusicAnalysisFailure(this.kind, {this.details, this.retryable = false});

  final MusicAnalysisFailureKind kind;
  final String? details;
  final bool retryable;

  String get userMessage => switch (kind) {
    MusicAnalysisFailureKind.network => 'Network error',
    MusicAnalysisFailureKind.server => 'Server error',
    MusicAnalysisFailureKind.decode => 'Audio decode failed',
    MusicAnalysisFailureKind.unsupportedSchema => 'Unsupported API schema',
    MusicAnalysisFailureKind.invalidRepresentation => 'Invalid representation',
    MusicAnalysisFailureKind.fileNotFound => 'Audio file not found',
    MusicAnalysisFailureKind.needsDownload => 'Needs download',
    MusicAnalysisFailureKind.staleContent => 'Content changed during analysis',
    MusicAnalysisFailureKind.unknown => 'Analysis failed',
  };

  @override
  String toString() => 'MusicAnalysisFailure($kind, $details)';
}
