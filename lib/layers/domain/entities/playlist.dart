import 'dart:convert';

import 'package:equatable/equatable.dart';

class Playlist extends Equatable {
  final String id;
  final String name;
  final List<String> trackIds;
  final DateTime createdAt;
  final String? description;
  final String? imageUrl;
  final int revision;

  const Playlist({
    required this.id,
    required this.name,
    required this.trackIds,
    required this.createdAt,
    this.description,
    this.imageUrl,
    this.revision = 0,
  });

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'trackIds': trackIds,
      'createdAt': createdAt.toIso8601String(),
      'description': description,
      'imageUrl': imageUrl,
      'revision': revision,
    };
  }

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      name: json['name'],
      trackIds: (json['trackIds'] as List).map((id) => id as String).toList(),
      createdAt: DateTime.parse(json['createdAt']),
      description: json['description'],
      imageUrl: json['imageUrl'],
      revision: json['revision'] as int? ?? 0,
    );
  }

  String toJsonString() => json.encode(toJson());
  factory Playlist.fromJsonString(String jsonString) =>
      Playlist.fromJson(json.decode(jsonString));

  Playlist copyWith({
    String? id,
    String? name,
    List<String>? trackIds,
    DateTime? createdAt,
    String? description,
    String? imageUrl,
    int? revision,
    bool clearDescription = false,
    bool clearImageUrl = false,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      trackIds: trackIds ?? this.trackIds,
      createdAt: createdAt ?? this.createdAt,
      description: clearDescription ? null : description ?? this.description,
      imageUrl: clearImageUrl ? null : imageUrl ?? this.imageUrl,
      revision: revision ?? this.revision,
    );
  }
}

class PlaylistSummary extends Equatable {
  const PlaylistSummary({
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
