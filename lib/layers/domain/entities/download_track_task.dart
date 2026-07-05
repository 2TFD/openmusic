enum DownloadStatus { queued, downloading, completed, failed }

class DownloadTrackTask {
  final String trackId;
  final String originalUrl;
  final DownloadStatus status;

  const DownloadTrackTask({
    required this.trackId,
    required this.originalUrl,
    this.status = DownloadStatus.queued,
  });

  DownloadTrackTask copyWith({
    String? trackId,
    String? originalUrl,
    DownloadStatus? status,
  }) {
    return DownloadTrackTask(
      trackId: trackId ?? this.trackId,
      originalUrl: originalUrl ?? this.originalUrl,
      status: status ?? this.status,
    );
  }

  @override
  String toString() =>
      'DownloadTrackTask(trackId: $trackId, originalUrl: $originalUrl, status: $status)';
}
