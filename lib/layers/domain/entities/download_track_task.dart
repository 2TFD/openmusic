import 'dart:convert';
import 'package:openmusic/layers/domain/entities/track_preview.dart';

enum DownloadStatus { queued, downloading, completed, failed, cancelled }

class DownloadTrackTask {
  final String trackId;
  final String urlFile;

  final double progress;
  final DownloadStatus status;
  DownloadTrackTask({
    required this.trackId,
    required this.urlFile,
    this.progress = 0,
    this.status = DownloadStatus.queued,
  });

  DownloadTrackTask copyWith({
    String? trackId,
    String? urlFile,
    double? progress,
    DownloadStatus? status,
  }) {
    return DownloadTrackTask(
      trackId: trackId ?? this.trackId,
      urlFile: urlFile ?? this.urlFile,
      progress: progress ?? this.progress,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'trackId': trackId,
      'urlFile': urlFile,
      'progress': progress,
      'status': status.name,
    };
  }

  factory DownloadTrackTask.fromMap(Map<String, dynamic> map) {
    return DownloadTrackTask(
      trackId: map['trackId'] as String,
      urlFile: map['urlFile'] as String,
      progress: map['progress'] as double,
      status: DownloadStatus.values.byName(map['status']),
    );
  }

  String toJson() => json.encode(toMap());

  factory DownloadTrackTask.fromJson(String source) =>
      DownloadTrackTask.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'DownloadTrackTask(trackId: $trackId, urlFile: $urlFile, progress: $progress, status: $status)';
  }

  @override
  bool operator ==(covariant DownloadTrackTask other) {
    if (identical(this, other)) return true;

    return other.trackId == trackId &&
        other.urlFile == urlFile &&
        other.progress == progress &&
        other.status == status;
  }

  factory DownloadTrackTask.fromPreview(TrackPreview track) {
    return DownloadTrackTask(trackId: track.id, urlFile: track.urlFile);
  }

  @override
  int get hashCode {
    return trackId.hashCode ^
        urlFile.hashCode ^
        progress.hashCode ^
        status.hashCode;
  }
}
