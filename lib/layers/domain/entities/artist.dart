import 'package:equatable/equatable.dart';

class Artist extends Equatable {
  final String id;
  final String name;
  final List<String>? genres;
  final String? imageUrl;

  const Artist({
    required this.id,
    required this.name,
    this.genres,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, genres, imageUrl];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'genres': genres,
      'imageUrl': imageUrl,
    };
  }

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'],
      name: json['name'],
      genres: json['genres'] != null ? List<String>.from(json['genres']) : null,
      imageUrl: json['imageUrl'],
    );
  }

  Artist copyWith({
    String? id,
    String? name,
    List<String>? genres,
    String? imageUrl,
  }) {
    return Artist(
      id: id ?? this.id,
      name: name ?? this.name,
      genres: genres ?? this.genres,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}