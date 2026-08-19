enum DownloadStatus { queued, downloading, completed, failed }

abstract class DownloadFailureCodes {
  static const network = 'network';
  static const sourceUnavailable = 'source_unavailable';
  static const rateLimited = 'rate_limited';
  static const fileNotFound = 'file_not_found';
  static const filePermission = 'file_permission';
  static const fileSystem = 'file_system';
  static const unsupported = 'unsupported';
  static const unknown = 'unknown';

  const DownloadFailureCodes._();
}

class DownloadFailureInfo {
  final String code;
  final String message;
  final String details;
  final DateTime failedAt;

  const DownloadFailureInfo({
    required this.code,
    required this.message,
    required this.details,
    required this.failedAt,
  });

  DownloadFailureInfo copyWith({
    String? code,
    String? message,
    String? details,
    DateTime? failedAt,
  }) {
    return DownloadFailureInfo(
      code: code ?? this.code,
      message: message ?? this.message,
      details: details ?? this.details,
      failedAt: failedAt ?? this.failedAt,
    );
  }
}

class DownloadTrackTask {
  final String trackId;
  final String originalUrl;
  final DownloadStatus status;
  final DateTime createdAt;
  final DownloadFailureInfo? failure;

  const DownloadTrackTask({
    required this.trackId,
    required this.originalUrl,
    required this.createdAt,
    this.status = DownloadStatus.queued,
    this.failure,
  });

  DownloadTrackTask copyWith({
    String? trackId,
    String? originalUrl,
    DownloadStatus? status,
    DateTime? createdAt,
    Object? failure = _unset,
  }) {
    return DownloadTrackTask(
      trackId: trackId ?? this.trackId,
      originalUrl: originalUrl ?? this.originalUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      failure: identical(failure, _unset)
          ? this.failure
          : failure as DownloadFailureInfo?,
    );
  }

  @override
  String toString() =>
      'DownloadTrackTask(trackId: $trackId, originalUrl: $originalUrl, status: $status, createdAt: $createdAt, failure: $failure)';
}

const _unset = Object();
