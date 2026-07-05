import 'dart:convert';

import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/domain/entities/source.dart';

class PlayRecordDto {
  final String id;

  final String trackId;
  final String trackTitle;

  final String artistName;

  final SourceType sourceType;

  final int listenedMs;

  final DateTime playedAt;

  PlayRecordDto({
    required this.id,
    required this.trackId,
    required this.trackTitle,
    required this.artistName,
    required this.sourceType,
    required this.listenedMs,
    required this.playedAt,
  });

  PlayRecordDto copyWith({
    String? id,
    String? trackId,
    String? trackTitle,
    String? artistName,
    SourceType? sourceType,
    int? listenedMs,
    DateTime? playedAt,
  }) {
    return PlayRecordDto(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      trackTitle: trackTitle ?? this.trackTitle,
      artistName: artistName ?? this.artistName,
      sourceType: sourceType ?? this.sourceType,
      listenedMs: listenedMs ?? this.listenedMs,
      playedAt: playedAt ?? this.playedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'trackId': trackId,
      'trackTitle': trackTitle,
      'artistName': artistName,
      'sourceType': sourceType.name,
      'listenedMs': listenedMs,
      'playedAt': playedAt.millisecondsSinceEpoch,
    };
  }

  factory PlayRecordDto.fromMap(Map<String, dynamic> map) {
    return PlayRecordDto(
      id: map['id'] as String,
      trackId: map['trackId'] as String,
      trackTitle: map['trackTitle'] as String,
      artistName: map['artistName'] as String,
      sourceType: SourceType.values.firstWhere(
        (e) => e.name == map['sourceType'],
        orElse: () => SourceType.unknown,
      ),
      listenedMs: map['listenedMs'] as int,
      playedAt: DateTime.fromMillisecondsSinceEpoch(map['playedAt'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory PlayRecordDto.fromJson(String source) =>
      PlayRecordDto.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PlayRecordDto(id: $id, trackId: $trackId, trackTitle: $trackTitle, artistName: $artistName, sourceType: $sourceType, listenedMs: $listenedMs, playedAt: $playedAt)';
  }

  @override
  bool operator ==(covariant PlayRecordDto other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.trackId == trackId &&
        other.trackTitle == trackTitle &&
        other.artistName == artistName &&
        other.sourceType == sourceType &&
        other.listenedMs == listenedMs &&
        other.playedAt == playedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        trackId.hashCode ^
        trackTitle.hashCode ^
        artistName.hashCode ^
        sourceType.hashCode ^
        listenedMs.hashCode ^
        playedAt.hashCode;
  }

  factory PlayRecordDto.fromDataClass(PlayRecordTableData data) {
    return PlayRecordDto(
      id: data.id,
      trackId: data.trackId,
      trackTitle: data.trackTitle,
      artistName: data.artistName,
      sourceType: SourceType.values.firstWhere(
        (e) => e.name == data.sourceType,
        orElse: () => SourceType.unknown,
      ),
      listenedMs: data.listenedDurationMilisecond,
      playedAt: data.playedAt,
    );
  }
}
