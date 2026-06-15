import 'dart:convert';

import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/domain/entities/embedding_task.dart';

class EmbeddingTaskDto {
  final String id;

  final String trackId;

  final EmbeddingStatus status;

  final String filePath;

  final DateTime createdAt;
  EmbeddingTaskDto({
    required this.id,
    required this.trackId,
    required this.status,
    required this.filePath,
    required this.createdAt,
  });

  EmbeddingTaskDto copyWith({
    String? id,
    String? trackId,
    EmbeddingStatus? status,
    String? filePath,
    DateTime? createdAt,
  }) {
    return EmbeddingTaskDto(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      status: status ?? this.status,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'trackId': trackId,
      'status': status.name,
      'filePath': filePath,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory EmbeddingTaskDto.fromMap(Map<String, dynamic> map) {
    return EmbeddingTaskDto(
      id: map['id'] as String,
      trackId: map['trackId'] as String,
      status: EmbeddingStatus.values.byName(map['status']),
      filePath: map['filePath'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory EmbeddingTaskDto.fromJson(String source) =>
      EmbeddingTaskDto.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'EmbeddingTaskDto(id: $id, trackId: $trackId, status: $status, filePath: $filePath, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant EmbeddingTaskDto other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.trackId == trackId &&
        other.status == status &&
        other.filePath == filePath &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        trackId.hashCode ^
        status.hashCode ^
        filePath.hashCode ^
        createdAt.hashCode;
  }

  factory EmbeddingTaskDto.fromDataClass(EmbeddingTaskTableData data) {
    return EmbeddingTaskDto(
      id: data.id,
      trackId: data.trackId,
      status: EmbeddingStatus.values.byName(data.status),
      filePath: data.filePath,
      createdAt: data.createdAt,
    );
  }
}
