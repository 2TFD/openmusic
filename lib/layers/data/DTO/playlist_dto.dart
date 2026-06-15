import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:openmusic/layers/data/database/app_database.dart';

class PlaylistDto extends Equatable {
  final String id;
  final String name;
  final List<String> trackIds;
  final DateTime createdAt;
  final String? description;
  final String? imageUrl;

  const PlaylistDto({
    required this.id,
    required this.name,
    required this.trackIds,
    required this.createdAt,
    this.description,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'trackIds': trackIds,
      'createdAt': createdAt.toIso8601String(),
      'description': description,
      'imageUrl': imageUrl,
    };
  }

  factory PlaylistDto.fromJson(Map<String, dynamic> json) {
    return PlaylistDto(
      id: json['id'],
      name: json['name'],
      trackIds: (json['trackIds'] as List).map((id) => id as String).toList(),
      createdAt: DateTime.parse(json['createdAt']),
      description: json['description'],
      imageUrl: json['imageUrl'],
    );
  }

  String toJsonString() => json.encode(toJson());
  factory PlaylistDto.fromJsonString(String jsonString) =>
      PlaylistDto.fromJson(json.decode(jsonString));

  PlaylistDto copyWith({
    String? id,
    String? name,
    List<String>? trackIds,
    DateTime? createdAt,
    String? description,
    String? imageUrl,
  }) {
    return PlaylistDto(
      id: id ?? this.id,
      name: name ?? this.name,
      trackIds: trackIds ?? this.trackIds,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object> get props {
    return [id, name, trackIds, createdAt, description ?? '', imageUrl ?? ''];
  }

  factory PlaylistDto.fromDataClass(PlaylistTableData data) {
    return PlaylistDto(
      id: data.id,
      name: data.name,
      trackIds: data.trackIds.split(','),
      createdAt: data.createdAt,
      description: data.description,
      imageUrl: data.imageUrl,
    );
  }
}
