import 'package:equatable/equatable.dart';

enum SourceType { localFile, soundcloud, unknown }

class Source extends Equatable {
  final SourceType type;
  final String originalUrl;
  final bool isAvailable;

  const Source({
    required this.type,
    required this.originalUrl,
    this.isAvailable = true,
  });

  @override
  List<Object?> get props => [type, originalUrl, isAvailable];

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'originalUrl': originalUrl,
      'isAvailable': isAvailable,
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
    );
  }

  Source copyWith({SourceType? type, String? originalUrl, bool? isAvailable}) {
    return Source(
      type: type ?? this.type,
      originalUrl: originalUrl ?? this.originalUrl,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
