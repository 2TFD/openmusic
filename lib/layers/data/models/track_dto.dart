import 'package:equatable/equatable.dart';

class ArtistDto extends Equatable {
  const ArtistDto({required this.id, required this.name});

  final String id;
  final String name;

  factory ArtistDto.fromJson(Map<String, dynamic> json) {
    return ArtistDto(id: json['id'] as String, name: json['name'] as String);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  List<Object> get props => [id, name];
}

class TrackDto extends Equatable {
  const TrackDto({
    required this.id,
    required this.title,
    required this.filePath,
    required this.artists,
    this.durationMs,
    required this.sourceType,
    required this.originalUrl,
    this.addedAt,
    this.album,
    this.imageUrl,
    this.trackDescriptorJson,
    this.embedding,
    this.metadataRevision = 0,
  });

  final String id;
  final String title;
  final String? filePath;
  final List<ArtistDto> artists;
  final int? durationMs;
  final String sourceType;
  final String originalUrl;
  final DateTime? addedAt;
  final String? album;
  final String? imageUrl;
  final String? trackDescriptorJson;
  final List<double>? embedding;
  final int metadataRevision;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'filePath': filePath,
    'artists': artists.map((artist) => artist.toJson()).toList(),
    'durationMs': durationMs,
    'sourceType': sourceType,
    'originalUrl': originalUrl,
    'addedAt': addedAt?.toIso8601String(),
    'album': album,
    'imageUrl': imageUrl,
    'trackDescriptorJson': trackDescriptorJson,
    'embedding': embedding,
    'metadataRevision': metadataRevision,
  };

  factory TrackDto.fromJson(Map<String, dynamic> json) {
    final artists = switch (json['artists']) {
      final List<dynamic> values =>
        values
            .whereType<Map<String, dynamic>>()
            .map(ArtistDto.fromJson)
            .toList(),
      _ => _legacyArtists(json),
    };
    return TrackDto(
      id: json['id'] as String,
      title: json['title'] as String,
      filePath: json['filePath'] as String?,
      artists: artists,
      durationMs: json['durationMs'] as int?,
      sourceType: json['sourceType'] as String,
      originalUrl: json['originalUrl'] as String,
      addedAt: switch (json['addedAt']) {
        final String value => DateTime.tryParse(value),
        final int value => DateTime.fromMillisecondsSinceEpoch(value),
        _ => null,
      },
      album: json['album'] as String?,
      imageUrl: json['imageUrl'] as String?,
      trackDescriptorJson: json['trackDescriptorJson'] as String?,
      embedding: json['embedding'] != null
          ? List<double>.from(json['embedding'] as List)
          : null,
      metadataRevision: json['metadataRevision'] as int? ?? 0,
    );
  }

  static List<ArtistDto> _legacyArtists(Map<String, dynamic> json) {
    final ids = List<String>.from(json['artistIds'] as List? ?? const []);
    final names = List<String>.from(json['artistNames'] as List? ?? const []);
    return [
      for (var index = 0; index < ids.length; index++)
        ArtistDto(
          id: ids[index],
          name: index < names.length ? names[index] : 'Unknown Artist',
        ),
    ];
  }

  @override
  List<Object?> get props => [
    id,
    title,
    filePath,
    artists,
    durationMs,
    sourceType,
    originalUrl,
    addedAt,
    album,
    imageUrl,
    trackDescriptorJson,
    embedding,
    metadataRevision,
  ];
}
