import 'package:equatable/equatable.dart';
import 'package:openmusic/layers/domain/entities/source.dart';

class ListeningSummary extends Equatable {
  final String id;
  final String trackId;
  final String trackTitle;
  final String artistName;
  final SourceType sourceType;
  final Duration listenedDuration;
  final DateTime playedAt;

  const ListeningSummary({
    required this.id,
    required this.trackId,
    required this.trackTitle,
    required this.artistName,
    required this.sourceType,
    required this.listenedDuration,
    required this.playedAt,
  });

  @override
  List<Object?> get props => [
    id,
    trackId,
    trackTitle,
    artistName,
    sourceType,
    listenedDuration,
    playedAt,
  ];

  Map<String, dynamic> toJson() => {
    'id': id,
    'trackId': trackId,
    'trackTitle': trackTitle,
    'artistName': artistName,
    'sourceType': sourceType.name,
    'listenedMs': listenedDuration.inMilliseconds,
    'playedAt': playedAt.toIso8601String(),
  };

  factory ListeningSummary.fromJson(Map<String, dynamic> json) =>
      ListeningSummary(
        id: json['id'],
        trackId: json['trackId'],
        trackTitle: json['trackTitle'],
        artistName: json['artistName'],
        sourceType: SourceType.values.firstWhere(
          (e) => e.name == json['sourceType'],
          orElse: () => SourceType.unknown,
        ),
        listenedDuration: Duration(milliseconds: json['listenedMs']),
        playedAt: DateTime.parse(json['playedAt']),
      );
}

class ListeningStatsSummary {
  const ListeningStatsSummary({
    required this.totalTracks,
    required this.totalTime,
    required this.uniqueArtists,
    required this.bySource,
  });

  final int totalTracks;
  final Duration totalTime;
  final int uniqueArtists;
  final Map<SourceType, int> bySource;
}

class ListeningCheckpoint {
  const ListeningCheckpoint({
    required this.id,
    required this.trackId,
    required this.trackTitle,
    required this.artistName,
    required this.sourceType,
    required this.listenedDuration,
    required this.updatedAt,
  });

  final String id;
  final String trackId;
  final String trackTitle;
  final String artistName;
  final SourceType sourceType;
  final Duration listenedDuration;
  final DateTime updatedAt;
}
