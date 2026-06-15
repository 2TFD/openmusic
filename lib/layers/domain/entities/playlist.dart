import 'dart:convert';

import 'package:equatable/equatable.dart';

class Playlist extends Equatable {
  final String id;
  final String name;
  final List<String> trackIds;
  final DateTime createdAt;
  final String? description;
  final String? imageUrl;

  const Playlist({
    required this.id,
    required this.name,
    required this.trackIds,
    required this.createdAt,
    this.description,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    trackIds,
    createdAt,
    description,
    imageUrl,
  ];

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

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      name: json['name'],
      trackIds: (json['trackIds'] as List).map((id) => id as String).toList(),
      createdAt: DateTime.parse(json['createdAt']),
      description: json['description'],
      imageUrl: json['imageUrl'],
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
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      trackIds: trackIds ?? this.trackIds,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
