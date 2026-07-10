import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:openmusic/layers/domain/entities/track.dart';

class WaveConfig {
  final List<String> seeds;
  final List<Track> tracks;
  final String mood;
  final int queueSize;

  const WaveConfig({
    required this.seeds,
    required this.tracks,
    required this.mood,
    this.queueSize = 50,
  });

  WaveConfig copyWith({
    List<String>? seeds,
    List<Track>? tracks,
    String? mood,
    int? queueSize,
  }) {
    return WaveConfig(
      seeds: seeds ?? this.seeds,
      tracks: tracks ?? this.tracks,
      mood: mood ?? this.mood,
      queueSize: queueSize ?? this.queueSize,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'seeds': seeds,
      'tracks': tracks.map((x) => x.toJson()).toList(),
      'mood': mood,
      'queueSize': queueSize,
    };
  }

  factory WaveConfig.fromMap(Map<String, dynamic> map) {
    return WaveConfig(
      seeds: List<String>.from(map['seeds'] as List),
      tracks: List<Track>.from(
        (map['tracks'] as List).map<Track>(
          (x) => Track.fromJson(x as Map<String, dynamic>),
        ),
      ),
      mood: map['mood'] as String,
      queueSize: map['queueSize'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory WaveConfig.fromJson(String source) =>
      WaveConfig.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'WaveConfig(seeds: $seeds, tracks: $tracks, mood: $mood, queueSize: $queueSize)';
  }

  @override
  bool operator ==(covariant WaveConfig other) {
    if (identical(this, other)) return true;

    return listEquals(other.seeds, seeds) &&
        listEquals(other.tracks, tracks) &&
        other.mood == mood &&
        other.queueSize == queueSize;
  }

  @override
  int get hashCode {
    return seeds.hashCode ^
        tracks.hashCode ^
        mood.hashCode ^
        queueSize.hashCode;
  }
}
