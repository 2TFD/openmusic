import 'package:equatable/equatable.dart';

enum SourceType { localFile, soundcloud, youtube, spotify, unknown }

class MediaLocator extends Equatable {
  const MediaLocator({required this.type, required this.id, required this.url});

  final SourceType type;
  final String id;
  final String url;

  @override
  List<Object?> get props => [type, id, url];

  Map<String, dynamic> toJson() => {'type': type.name, 'id': id, 'url': url};

  factory MediaLocator.fromJson(Map<String, dynamic> json) => MediaLocator(
    type: SourceType.values.firstWhere(
      (type) => type.name == json['type'],
      orElse: () => SourceType.unknown,
    ),
    id: json['id'] as String,
    url: json['url'] as String,
  );
}

class Source extends Equatable {
  final SourceType type;
  final String originalUrl;
  final bool isAvailable;
  final MediaLocator? media;

  const Source({
    required this.type,
    required this.originalUrl,
    this.isAvailable = true,
    this.media,
  });

  @override
  List<Object?> get props => [type, originalUrl, isAvailable, media];

  SourceType get effectiveMediaType => media?.type ?? type;
  String get effectiveMediaUrl => media?.url ?? originalUrl;

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'originalUrl': originalUrl,
      'isAvailable': isAvailable,
      'media': media?.toJson(),
    };
  }

  @override
  String toString() {
    return type.name.toString();
  }

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      type: SourceType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SourceType.unknown,
      ),
      originalUrl: json['originalUrl'],
      isAvailable: json['isAvailable'] ?? true,
      media: json['media'] is Map<String, dynamic>
          ? MediaLocator.fromJson(json['media'] as Map<String, dynamic>)
          : null,
    );
  }

  Source copyWith({
    SourceType? type,
    String? originalUrl,
    bool? isAvailable,
    MediaLocator? media,
  }) {
    return Source(
      type: type ?? this.type,
      originalUrl: originalUrl ?? this.originalUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      media: media ?? this.media,
    );
  }
}
