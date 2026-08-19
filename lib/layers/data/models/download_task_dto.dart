import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/domain/entities/download_track_task.dart';

class DownloadTaskDto {
  final String trackId;
  final String originalUrl;
  final DownloadStatus status;
  final DateTime createdAt;
  final DownloadFailureInfo? failure;

  DownloadTaskDto({
    required this.trackId,
    required this.originalUrl,
    required this.status,
    required this.createdAt,
    this.failure,
  });

  DownloadTaskDto copyWith({
    String? trackId,
    String? originalUrl,
    DownloadStatus? status,
    DateTime? createdAt,
    Object? failure = _unset,
  }) {
    return DownloadTaskDto(
      trackId: trackId ?? this.trackId,
      originalUrl: originalUrl ?? this.originalUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      failure: identical(failure, _unset)
          ? this.failure
          : failure as DownloadFailureInfo?,
    );
  }

  factory DownloadTaskDto.fromDataClass(DownloadTaskTableData data) {
    return DownloadTaskDto(
      trackId: data.trackId,
      originalUrl: data.originalUrl,
      status: DownloadStatus.values.byName(data.status),
      createdAt: data.createdAt,
      failure: _failureFromColumns(
        code: data.failureCode,
        message: data.failureMessage,
        details: data.failureDetails,
        failedAt: data.failedAt,
      ),
    );
  }

  static DownloadFailureInfo? _failureFromColumns({
    required String? code,
    required String? message,
    required String? details,
    required DateTime? failedAt,
  }) {
    if (code == null &&
        message == null &&
        details == null &&
        failedAt == null) {
      return null;
    }
    return DownloadFailureInfo(
      code: code ?? DownloadFailureCodes.unknown,
      message: message ?? '',
      details: details ?? '',
      failedAt: failedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

const _unset = Object();
