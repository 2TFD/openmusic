import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:openmusic/layers/data/database/app_database.dart';

class PlaylistDto extends Equatable {
  const PlaylistDto({
    required this.id,
    required this.name,
    required this.trackIds,
    required this.createdAt,
    this.description,
    this.imageUrl,
    this.revision = 0,
  });

  final String id;
  final String name;
  final List<String> trackIds;
  final DateTime createdAt;
  final String? description;
  final String? imageUrl;
  final int revision;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'trackIds': trackIds,
    'createdAt': createdAt.toIso8601String(),
    'description': description,
    'imageUrl': imageUrl,
    'revision': revision,
  };

  factory PlaylistDto.fromJson(Map<String, dynamic> json) {
    return PlaylistDto(
      id: json['id'] as String,
      name: json['name'] as String,
      trackIds: List<String>.from(json['trackIds'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      revision: json['revision'] as int? ?? 0,
    );
  }

  String toJsonString() => json.encode(toJson());

  factory PlaylistDto.fromJsonString(String source) =>
      PlaylistDto.fromJson(json.decode(source) as Map<String, dynamic>);

  PlaylistDto copyWith({
    String? id,
    String? name,
    List<String>? trackIds,
    DateTime? createdAt,
    String? description,
    String? imageUrl,
    int? revision,
  }) {
    return PlaylistDto(
      id: id ?? this.id,
      name: name ?? this.name,
      trackIds: trackIds ?? this.trackIds,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      revision: revision ?? this.revision,
    );
  }

  factory PlaylistDto.fromDataClass(
    PlaylistTableData data, {
    required List<String> trackIds,
  }) {
    return PlaylistDto(
      id: data.id,
      name: data.name,
      trackIds: trackIds,
      createdAt: data.createdAt,
      description: data.description,
      imageUrl: data.imageUrl,
      revision: data.revision,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    trackIds,
    createdAt,
    description,
    imageUrl,
    revision,
  ];
}

class PlaylistSummaryDto extends Equatable {
  const PlaylistSummaryDto({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.trackCount,
    required this.revision,
    this.description,
    this.imageUrl,
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final int trackCount;
  final int revision;
  final String? description;
  final String? imageUrl;

  @override
  List<Object?> get props => [
    id,
    name,
    createdAt,
    trackCount,
    revision,
    description,
    imageUrl,
  ];
}
