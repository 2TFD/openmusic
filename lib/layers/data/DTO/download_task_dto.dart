import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/domain/entities/download_track_task.dart';

class DownloadTaskDto {
  final String trackId;
  final String originalUrl;
  final DownloadStatus status;
  final DateTime createdAt;

  DownloadTaskDto({
    required this.trackId,
    required this.originalUrl,
    required this.status,
    required this.createdAt,
  });

  DownloadTaskDto copyWith({
    String? trackId,
    String? originalUrl,
    DownloadStatus? status,
    DateTime? createdAt,
  }) {
    return DownloadTaskDto(
      trackId: trackId ?? this.trackId,
      originalUrl: originalUrl ?? this.originalUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory DownloadTaskDto.fromDataClass(DownloadTaskTableData data) {
    return DownloadTaskDto(
      trackId: data.trackId,
      originalUrl: data.originalUrl,
      status: DownloadStatus.values.byName(data.status),
      createdAt: data.createdAt,
    );
  }
}
