import 'dart:convert';

import 'package:openmusic/layers/domain/entities/artist.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';

class TrackPreview {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String? artworkUrl;
  final Duration? duration;
  final SourceType source;
  final String originalUrl;
  final int? year;
  final String urlFile;

  const TrackPreview({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.artworkUrl,
    this.duration,
    required this.source,
    required this.originalUrl,
    this.year,
    required this.urlFile,
  });

  Track toTrack(
    String? pathToFile, {
    TrackDescriptor? trackDescriptor,
    List<double>? embedding,
  }) => Track(
    trackDescriptor: trackDescriptor,
    embedding: embedding,
    duration: duration ?? Duration.zero,
    addedAt: DateTime.now(),
    id: id,
    title: title,
    artists: [Artist(id: id, name: artist)],
    album: album,
    imageUrl: artworkUrl,
    pathToFile: pathToFile,
    source: Source(type: source, originalUrl: originalUrl),
  );

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'artworkUrl': artworkUrl,
      'duration': duration?.inMicroseconds.toString(),
      'source': source.name,
      'originalUrl': originalUrl,
      'year': year,
      'urlFile': urlFile,
    };
  }

  factory TrackPreview.fromMap(Map<String, dynamic> map) {
    return TrackPreview(
      id: map['id'] as String,
      title: map['title'] as String,
      artist: map['artist'] as String,
      album: map['album'] != null ? map['album'] as String : null,
      artworkUrl: map['artworkUrl'] != null
          ? map['artworkUrl'] as String
          : null,
      duration: map['duration'] != null
          ? Duration(microseconds: int.parse(map['duration'] as String))
          : null,
      source: SourceType.values.firstWhere((e) => e.name == map['source']),
      originalUrl: map['originalUrl'] as String,
      year: map['year'] != null ? map['year'] as int : null,
      urlFile: map['urlFile'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory TrackPreview.fromJson(String source) =>
      TrackPreview.fromMap(json.decode(source) as Map<String, dynamic>);

  TrackPreview copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? artworkUrl,
    Duration? duration,
    SourceType? source,
    String? originalUrl,
    int? year,
    String? urlFile,
  }) {
    return TrackPreview(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      duration: duration ?? this.duration,
      source: source ?? this.source,
      originalUrl: originalUrl ?? this.originalUrl,
      year: year ?? this.year,
      urlFile: urlFile ?? this.urlFile,
    );
  }
}
