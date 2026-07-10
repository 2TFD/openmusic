enum DownloadStatus { queued, downloading, completed, failed }

class DownloadTrackTask {
  final String trackId;
  final String originalUrl;
  final DownloadStatus status;
  final DateTime createdAt;

  const DownloadTrackTask({
    required this.trackId,
    required this.originalUrl,
    required this.createdAt,
    this.status = DownloadStatus.queued,
  });

  DownloadTrackTask copyWith({
    String? trackId,
    String? originalUrl,
    DownloadStatus? status,
    DateTime? createdAt,
  }) {
    return DownloadTrackTask(
      trackId: trackId ?? this.trackId,
      originalUrl: originalUrl ?? this.originalUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'DownloadTrackTask(trackId: $trackId, originalUrl: $originalUrl, status: $status, createdAt: $createdAt)';
}
