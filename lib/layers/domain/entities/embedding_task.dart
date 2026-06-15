import 'dart:convert';

enum EmbeddingStatus { queued, processing, done, failed }

class EmbeddingTask {
  final String id;

  final String trackId;

  final EmbeddingStatus status;

  final String filePath;

  final DateTime createdAt;
  EmbeddingTask({
    required this.id,
    required this.trackId,
    required this.status,
    required this.filePath,
    required this.createdAt,
  });

  EmbeddingTask copyWith({
    String? id,
    String? trackId,
    EmbeddingStatus? status,
    String? filePath,
    DateTime? createdAt,
  }) {
    return EmbeddingTask(
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

  factory EmbeddingTask.fromMap(Map<String, dynamic> map) {
    return EmbeddingTask(
      id: map['id'] as String,
      trackId: map['trackId'] as String,
      status: EmbeddingStatus.values.byName(map['status']),
      filePath: map['filePath'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory EmbeddingTask.fromJson(String source) =>
      EmbeddingTask.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'EmbeddingTask(id: $id, trackId: $trackId, status: $status, filePath: $filePath, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant EmbeddingTask other) {
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
}
