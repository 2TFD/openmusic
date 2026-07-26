import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:openmusic/layers/domain/entities/track.dart';

class WaveConfig {
  final List<String> seeds;
  final List<Track> tracks;
  final int queueSize;

  const WaveConfig({
    required this.seeds,
    required this.tracks,
    this.queueSize = 50,
  });

  WaveConfig copyWith({
    List<String>? seeds,
    List<Track>? tracks,
    int? queueSize,
  }) {
    return WaveConfig(
      seeds: seeds ?? this.seeds,
      tracks: tracks ?? this.tracks,
      queueSize: queueSize ?? this.queueSize,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'seeds': seeds,
      'tracks': tracks.map((x) => x.toJson()).toList(),
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
      queueSize: map['queueSize'] as int? ?? 50,
    );
  }

  String toJson() => json.encode(toMap());

  factory WaveConfig.fromJson(String source) =>
      WaveConfig.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'WaveConfig(seeds: $seeds, tracks: $tracks, queueSize: $queueSize)';
  }

  @override
  bool operator ==(covariant WaveConfig other) {
    if (identical(this, other)) return true;

    return listEquals(other.seeds, seeds) &&
        listEquals(other.tracks, tracks) &&
        other.queueSize == queueSize;
  }

  @override
  int get hashCode {
    return seeds.hashCode ^ tracks.hashCode ^ queueSize.hashCode;
  }
}
