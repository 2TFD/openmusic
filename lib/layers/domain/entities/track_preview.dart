import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:owlsonic/layers/domain/entities/artist.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';

class TrackPreview extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String? artistId;
  final String? album;
  final String? artworkUrl;
  final Duration? duration;
  final SourceType source;
  final String originalUrl;
  final int? year;
  final String urlFile;
  final MediaLocator? media;

  const TrackPreview({
    required this.id,
    required this.title,
    required this.artist,
    this.artistId,
    this.album,
    this.artworkUrl,
    this.duration,
    required this.source,
    required this.originalUrl,
    this.year,
    required this.urlFile,
    this.media,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    artist,
    artistId,
    album,
    artworkUrl,
    duration,
    source,
    originalUrl,
    year,
    urlFile,
    media,
  ];

  Track toTrack(
    String? filePath, {
    String? contentIdentity,
    TrackDescriptor? trackDescriptor,
  }) => Track(
    trackDescriptor: trackDescriptor,
    contentIdentity: contentIdentity,
    duration: duration ?? Duration.zero,
    addedAt: DateTime.now(),
    id: id,
    title: title,
    artists: [
      Artist(
        id: artistId ?? stableArtistId(source: source, artistName: artist),
        name: artist,
      ),
    ],
    album: album,
    imageUrl: artworkUrl,
    filePath: filePath,
    source: Source(type: source, originalUrl: originalUrl, media: media),
  );

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'artist': artist,
      'artistId': artistId,
      'album': album,
      'artworkUrl': artworkUrl,
      'duration': duration?.inMicroseconds.toString(),
      'source': source.name,
      'originalUrl': originalUrl,
      'year': year,
      'urlFile': urlFile,
      'media': media?.toJson(),
    };
  }

  factory TrackPreview.fromMap(Map<String, dynamic> map) {
    return TrackPreview(
      id: map['id'] as String,
      title: map['title'] as String,
      artist: map['artist'] as String,
      artistId: map['artistId'] as String?,
      album: map['album'] != null ? map['album'] as String : null,
      artworkUrl: map['artworkUrl'] != null
          ? map['artworkUrl'] as String
          : null,
      duration: map['duration'] != null
          ? Duration(microseconds: int.parse(map['duration'] as String))
          : null,
      source: SourceType.values.firstWhere(
        (e) => e.name == map['source'],
        orElse: () => SourceType.unknown,
      ),
      originalUrl: map['originalUrl'] as String,
      year: map['year'] != null ? map['year'] as int : null,
      urlFile: map['urlFile'] as String,
      media: map['media'] is Map<String, dynamic>
          ? MediaLocator.fromJson(map['media'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory TrackPreview.fromJson(String source) =>
      TrackPreview.fromMap(json.decode(source) as Map<String, dynamic>);

  TrackPreview copyWith({
    String? id,
    String? title,
    String? artist,
    String? artistId,
    String? album,
    String? artworkUrl,
    Duration? duration,
    SourceType? source,
    String? originalUrl,
    int? year,
    String? urlFile,
    MediaLocator? media,
  }) {
    return TrackPreview(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      artistId: artistId ?? this.artistId,
      album: album ?? this.album,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      duration: duration ?? this.duration,
      source: source ?? this.source,
      originalUrl: originalUrl ?? this.originalUrl,
      year: year ?? this.year,
      urlFile: urlFile ?? this.urlFile,
      media: media ?? this.media,
    );
  }
}

String stableArtistId({
  required SourceType source,
  required String artistName,
}) {
  final normalized = artistName.trim().toLowerCase().replaceAll(
    RegExp(r'\s+'),
    ' ',
  );
  return '${source.name}:artist:$normalized';
}
