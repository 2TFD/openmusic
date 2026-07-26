import 'dart:convert';

import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/domain/entities/embedding_task.dart';

class EmbeddingTaskDto {
  final String id;
  final String trackId;
  final EmbeddingStatus status;
  final String filePath;
  final DateTime createdAt;
  final int audioRevision;

  EmbeddingTaskDto({
    required this.id,
    required this.trackId,
    required this.status,
    required this.filePath,
    required this.createdAt,
    this.audioRevision = 0,
  });

  EmbeddingTaskDto copyWith({
    String? id,
    String? trackId,
    EmbeddingStatus? status,
    String? filePath,
    DateTime? createdAt,
    int? audioRevision,
  }) {
    return EmbeddingTaskDto(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      status: status ?? this.status,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
      audioRevision: audioRevision ?? this.audioRevision,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'trackId': trackId,
    'status': status.name,
    'filePath': filePath,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'audioRevision': audioRevision,
  };

  factory EmbeddingTaskDto.fromMap(Map<String, dynamic> map) {
    return EmbeddingTaskDto(
      id: map['id'] as String,
      trackId: map['trackId'] as String,
      status: EmbeddingStatus.values.byName(map['status'] as String),
      filePath: map['filePath'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      audioRevision: map['audioRevision'] as int? ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory EmbeddingTaskDto.fromJson(String source) =>
      EmbeddingTaskDto.fromMap(json.decode(source) as Map<String, dynamic>);

  factory EmbeddingTaskDto.fromDataClass(EmbeddingTaskTableData data) {
    return EmbeddingTaskDto(
      id: data.id,
      trackId: data.trackId,
      status: EmbeddingStatus.values.byName(data.status),
      filePath: data.filePath,
      createdAt: data.createdAt,
      audioRevision: data.audioRevision,
    );
  }

  @override
  String toString() =>
      'EmbeddingTaskDto(id: $id, trackId: $trackId, status: $status, filePath: $filePath, createdAt: $createdAt, audioRevision: $audioRevision)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is EmbeddingTaskDto &&
            other.id == id &&
            other.trackId == trackId &&
            other.status == status &&
            other.filePath == filePath &&
            other.createdAt == createdAt &&
            other.audioRevision == audioRevision;
  }

  @override
  int get hashCode =>
      Object.hash(id, trackId, status, filePath, createdAt, audioRevision);
}
