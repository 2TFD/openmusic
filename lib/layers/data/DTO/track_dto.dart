import 'package:equatable/equatable.dart';

class TrackDto extends Equatable {
  final String id;

  final String title;

  final String? filePath;

  final List<String> artistIds;

  final List<String> artistNames;

  final int? durationMs;

  final String sourceType;

  final String originalUrl;

  final String? addedAt;

  final String? album;

  final String? imageUrl;

  final String? trackDescriptorJson;

  final List<double>? embedding;

  const TrackDto({
    required this.id,
    required this.title,
    required this.filePath,
    required this.artistIds,
    required this.artistNames,
    this.durationMs,
    required this.sourceType,
    required this.originalUrl,
    this.addedAt,
    this.album,
    this.imageUrl,
    this.trackDescriptorJson,
    this.embedding,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    filePath,
    artistIds,
    artistNames,
    durationMs,
    sourceType,
    originalUrl,
    addedAt,
    album,
    imageUrl,
    trackDescriptorJson,
    embedding,
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artistIds': artistIds,
      'filePath': filePath,
      'artistNames': artistNames,
      'durationMs': durationMs,
      'sourceType': sourceType,
      'originalUrl': originalUrl,
      'addedAt': addedAt,
      'album': album,
      'imageUrl': imageUrl,
      'trackDescriptorJson': trackDescriptorJson,
      'embedding': embedding,
    };
  }

  factory TrackDto.fromJson(Map<String, dynamic> json) {
    return TrackDto(
      id: json['id'],
      title: json['title'],
      filePath: json['filePath'] ?? '',
      artistIds: List<String>.from(json['artistIds']),
      artistNames: List<String>.from(json['artistNames']),
      durationMs: json['durationMs'],
      sourceType: json['sourceType'],
      originalUrl: json['originalUrl'],
      addedAt: json['addedAt'],
      album: json['album'],
      imageUrl: json['imageUrl'],
      trackDescriptorJson: json['trackDescriptorJson'],
      embedding: json['embedding'] != null
          ? List<double>.from(json['embedding'])
          : null,
    );
  }
}
