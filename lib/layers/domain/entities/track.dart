import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import 'artist.dart';
import 'source.dart';

class Track extends Equatable {
  final String id;
  final List<double>? embedding;
  final TrackDescriptor? trackDescriptor;
  final String title;
  final List<Artist> artists;
  final Duration duration;
  final Source source;
  final DateTime addedAt;
  final String? album;
  final String? imageUrl;
  final String? filePath;

  const Track({
    required this.id,
    this.embedding,
    this.trackDescriptor,
    required this.title,
    required this.artists,
    required this.duration,
    required this.source,
    required this.addedAt,
    this.filePath,
    this.album,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    artists,
    duration,
    source,
    addedAt,
    album,
    imageUrl,
    filePath,
    embedding,
    trackDescriptor,
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artists': artists.map((artist) => artist.toJson()).toList(),
      'trackDescriptor': trackDescriptor?.toJson(),
      'embedding': embedding,
      'durationMs': duration.inMilliseconds,
      'source': source.toJson(),
      'addedAt': addedAt.toIso8601String(),
      'album': album,
      'imageUrl': imageUrl,
    };
  }

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      trackDescriptor: json['trackDescriptor'] != null
          ? TrackDescriptor.fromMap(json['trackDescriptor'])
          : null,
      embedding: (json['embedding'] as List?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      id: json['id'],
      title: json['title'],
      artists: (json['artists'] as List)
          .map((artistJson) => Artist.fromJson(artistJson))
          .toList(),
      filePath: json['filePath'],
      duration: json['durationMs'] != null
          ? Duration(milliseconds: json['durationMs'])
          : Duration.zero,
      source: Source.fromJson(json['source']),
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'])
          : DateTime.now(),
      album: json['album'],
      imageUrl: json['imageUrl'],
    );
  }

  String toJsonString() => json.encode(toJson());
  factory Track.fromJsonString(String jsonString) =>
      Track.fromJson(json.decode(jsonString));

  MediaItem toMediaItem() => MediaItem(
    id: id,
    title: title,
    artist: artists.map((a) => a.name).join(', '),
    album: album,
    artUri: imageUrl != null ? Uri.parse(imageUrl!) : null,
    duration: duration,
  );

  AudioSource toAudioSource(String appDir) {
    return AudioSource.file('$appDir/$filePath', tag: toMediaItem());
  }

  Track copyWith({
    String? id,
    String? title,
    List<Artist>? artists,
    Duration? duration,
    Source? source,
    DateTime? addedAt,
    TrackDescriptor? trackDescriptor,
    List<double>? embedding,
    String? album,
    String? imageUrl,
    String? filePath,
  }) {
    return Track(
      trackDescriptor: trackDescriptor ?? this.trackDescriptor,
      embedding: embedding ?? this.embedding,
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      artists: artists ?? this.artists,
      duration: duration ?? this.duration,
      source: source ?? this.source,
      addedAt: addedAt ?? this.addedAt,
      album: album ?? this.album,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  bool get isReady => embedding != null && filePath != null;
  bool get isReadyToPlay => filePath != null;
}

class TrackDescriptor {
  final AudioFeatures audio;
  final EmotionalProfile emotion;
  final AtmosphereProfile atmosphere;
  final TextureProfile texture;
  final StructureProfile structure;
  final ContextProfile context;

  TrackDescriptor({
    required this.audio,
    required this.emotion,
    required this.atmosphere,
    required this.texture,
    required this.structure,
    required this.context,
  });

  TrackDescriptor copyWith({
    AudioFeatures? audio,
    EmotionalProfile? emotion,
    AtmosphereProfile? atmosphere,
    TextureProfile? texture,
    StructureProfile? structure,
    ContextProfile? context,
  }) {
    return TrackDescriptor(
      audio: audio ?? this.audio,
      emotion: emotion ?? this.emotion,
      atmosphere: atmosphere ?? this.atmosphere,
      texture: texture ?? this.texture,
      structure: structure ?? this.structure,
      context: context ?? this.context,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'audio': audio.toMap(),
      'emotion': emotion.toMap(),
      'atmosphere': atmosphere.toMap(),
      'texture': texture.toMap(),
      'structure': structure.toMap(),
      'context': context.toMap(),
    };
  }

  factory TrackDescriptor.fromMap(Map<String, dynamic> map) {
    return TrackDescriptor(
      audio: AudioFeatures.fromMap(map['audio'] as Map<String, dynamic>),
      emotion: EmotionalProfile.fromMap(map['emotion'] as Map<String, dynamic>),
      atmosphere: AtmosphereProfile.fromMap(
        map['atmosphere'] as Map<String, dynamic>,
      ),
      texture: TextureProfile.fromMap(map['texture'] as Map<String, dynamic>),
      structure: StructureProfile.fromMap(
        map['structure'] as Map<String, dynamic>,
      ),
      context: ContextProfile.fromMap(map['context'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory TrackDescriptor.fromJson(String source) =>
      TrackDescriptor.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TrackDescriptor(audio: $audio, emotion: $emotion, atmosphere: $atmosphere, texture: $texture, structure: $structure, context: $context)';
  }

  @override
  bool operator ==(covariant TrackDescriptor other) {
    if (identical(this, other)) return true;

    return other.audio == audio &&
        other.emotion == emotion &&
        other.atmosphere == atmosphere &&
        other.texture == texture &&
        other.structure == structure &&
        other.context == context;
  }

  @override
  int get hashCode {
    return audio.hashCode ^
        emotion.hashCode ^
        atmosphere.hashCode ^
        texture.hashCode ^
        structure.hashCode ^
        context.hashCode;
  }
}

class AudioFeatures {
  final double tempo; // BPM
  final double energy; // 0–1
  final double loudness; // dB
  final double danceability; // 0–1
  final double valence; // 0–1 (happy/sad)

  final double acousticness;
  final double instrumentalness;
  final double liveness;
  final double speechiness;

  AudioFeatures({
    required this.tempo,
    required this.energy,
    required this.loudness,
    required this.danceability,
    required this.valence,
    required this.acousticness,
    required this.instrumentalness,
    required this.liveness,
    required this.speechiness,
  });

  AudioFeatures copyWith({
    double? tempo,
    double? energy,
    double? loudness,
    double? danceability,
    double? valence,
    double? acousticness,
    double? instrumentalness,
    double? liveness,
    double? speechiness,
  }) {
    return AudioFeatures(
      tempo: tempo ?? this.tempo,
      energy: energy ?? this.energy,
      loudness: loudness ?? this.loudness,
      danceability: danceability ?? this.danceability,
      valence: valence ?? this.valence,
      acousticness: acousticness ?? this.acousticness,
      instrumentalness: instrumentalness ?? this.instrumentalness,
      liveness: liveness ?? this.liveness,
      speechiness: speechiness ?? this.speechiness,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tempo': tempo,
      'energy': energy,
      'loudness': loudness,
      'danceability': danceability,
      'valence': valence,
      'acousticness': acousticness,
      'instrumentalness': instrumentalness,
      'liveness': liveness,
      'speechiness': speechiness,
    };
  }

  factory AudioFeatures.fromMap(Map<String, dynamic> map) {
    return AudioFeatures(
      tempo: map['tempo'] as double,
      energy: map['energy'] as double,
      loudness: map['loudness'] as double,
      danceability: map['danceability'] as double,
      valence: map['valence'] as double,
      acousticness: map['acousticness'] as double,
      instrumentalness: map['instrumentalness'] as double,
      liveness: map['liveness'] as double,
      speechiness: map['speechiness'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory AudioFeatures.fromJson(String source) =>
      AudioFeatures.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AudioFeatures(tempo: $tempo, energy: $energy, loudness: $loudness, danceability: $danceability, valence: $valence, acousticness: $acousticness, instrumentalness: $instrumentalness, liveness: $liveness, speechiness: $speechiness)';
  }

  @override
  bool operator ==(covariant AudioFeatures other) {
    if (identical(this, other)) return true;

    return other.tempo == tempo &&
        other.energy == energy &&
        other.loudness == loudness &&
        other.danceability == danceability &&
        other.valence == valence &&
        other.acousticness == acousticness &&
        other.instrumentalness == instrumentalness &&
        other.liveness == liveness &&
        other.speechiness == speechiness;
  }

  @override
  int get hashCode {
    return tempo.hashCode ^
        energy.hashCode ^
        loudness.hashCode ^
        danceability.hashCode ^
        valence.hashCode ^
        acousticness.hashCode ^
        instrumentalness.hashCode ^
        liveness.hashCode ^
        speechiness.hashCode;
  }
}

class EmotionalProfile {
  final double valence; // позитив ↔ негатив
  final double arousal; // спокойствие ↔ возбуждение
  final double tension; // напряжение
  final double nostalgia; // ностальгия
  final double melancholy; // грусть
  final double euphoria; // эйфория

  EmotionalProfile({
    required this.valence,
    required this.arousal,
    required this.tension,
    required this.nostalgia,
    required this.melancholy,
    required this.euphoria,
  });

  EmotionalProfile copyWith({
    double? valence,
    double? arousal,
    double? tension,
    double? nostalgia,
    double? melancholy,
    double? euphoria,
  }) {
    return EmotionalProfile(
      valence: valence ?? this.valence,
      arousal: arousal ?? this.arousal,
      tension: tension ?? this.tension,
      nostalgia: nostalgia ?? this.nostalgia,
      melancholy: melancholy ?? this.melancholy,
      euphoria: euphoria ?? this.euphoria,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'valence': valence,
      'arousal': arousal,
      'tension': tension,
      'nostalgia': nostalgia,
      'melancholy': melancholy,
      'euphoria': euphoria,
    };
  }

  factory EmotionalProfile.fromMap(Map<String, dynamic> map) {
    return EmotionalProfile(
      valence: map['valence'] as double,
      arousal: map['arousal'] as double,
      tension: map['tension'] as double,
      nostalgia: map['nostalgia'] as double,
      melancholy: map['melancholy'] as double,
      euphoria: map['euphoria'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory EmotionalProfile.fromJson(String source) =>
      EmotionalProfile.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'EmotionalProfile(valence: $valence, arousal: $arousal, tension: $tension, nostalgia: $nostalgia, melancholy: $melancholy, euphoria: $euphoria)';
  }

  @override
  bool operator ==(covariant EmotionalProfile other) {
    if (identical(this, other)) return true;

    return other.valence == valence &&
        other.arousal == arousal &&
        other.tension == tension &&
        other.nostalgia == nostalgia &&
        other.melancholy == melancholy &&
        other.euphoria == euphoria;
  }

  @override
  int get hashCode {
    return valence.hashCode ^
        arousal.hashCode ^
        tension.hashCode ^
        nostalgia.hashCode ^
        melancholy.hashCode ^
        euphoria.hashCode;
  }
}

class AtmosphereProfile {
  final double intimacy; // интимность (в наушниках)
  final double spaciousness; // ощущение пространства
  final double darkness; // тёмность
  final double warmth; // тепло ↔ холод
  final double haziness; // туманность / размытость
  final double realism; // живое ↔ синтетическое

  AtmosphereProfile({
    required this.intimacy,
    required this.spaciousness,
    required this.darkness,
    required this.warmth,
    required this.haziness,
    required this.realism,
  });

  AtmosphereProfile copyWith({
    double? intimacy,
    double? spaciousness,
    double? darkness,
    double? warmth,
    double? haziness,
    double? realism,
  }) {
    return AtmosphereProfile(
      intimacy: intimacy ?? this.intimacy,
      spaciousness: spaciousness ?? this.spaciousness,
      darkness: darkness ?? this.darkness,
      warmth: warmth ?? this.warmth,
      haziness: haziness ?? this.haziness,
      realism: realism ?? this.realism,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'intimacy': intimacy,
      'spaciousness': spaciousness,
      'darkness': darkness,
      'warmth': warmth,
      'haziness': haziness,
      'realism': realism,
    };
  }

  factory AtmosphereProfile.fromMap(Map<String, dynamic> map) {
    return AtmosphereProfile(
      intimacy: map['intimacy'] as double,
      spaciousness: map['spaciousness'] as double,
      darkness: map['darkness'] as double,
      warmth: map['warmth'] as double,
      haziness: map['haziness'] as double,
      realism: map['realism'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory AtmosphereProfile.fromJson(String source) =>
      AtmosphereProfile.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AtmosphereProfile(intimacy: $intimacy, spaciousness: $spaciousness, darkness: $darkness, warmth: $warmth, haziness: $haziness, realism: $realism)';
  }

  @override
  bool operator ==(covariant AtmosphereProfile other) {
    if (identical(this, other)) return true;

    return other.intimacy == intimacy &&
        other.spaciousness == spaciousness &&
        other.darkness == darkness &&
        other.warmth == warmth &&
        other.haziness == haziness &&
        other.realism == realism;
  }

  @override
  int get hashCode {
    return intimacy.hashCode ^
        spaciousness.hashCode ^
        darkness.hashCode ^
        warmth.hashCode ^
        haziness.hashCode ^
        realism.hashCode;
  }
}

class TextureProfile {
  final double softness; // мягкость
  final double sharpness; // резкость
  final double roughness; // шероховатость
  final double density; // плотность
  final double brightness; // яркость (высокие частоты)
  final double saturation; // «грязь» / перегруз

  TextureProfile({
    required this.softness,
    required this.sharpness,
    required this.roughness,
    required this.density,
    required this.brightness,
    required this.saturation,
  });

  TextureProfile copyWith({
    double? softness,
    double? sharpness,
    double? roughness,
    double? density,
    double? brightness,
    double? saturation,
  }) {
    return TextureProfile(
      softness: softness ?? this.softness,
      sharpness: sharpness ?? this.sharpness,
      roughness: roughness ?? this.roughness,
      density: density ?? this.density,
      brightness: brightness ?? this.brightness,
      saturation: saturation ?? this.saturation,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'softness': softness,
      'sharpness': sharpness,
      'roughness': roughness,
      'density': density,
      'brightness': brightness,
      'saturation': saturation,
    };
  }

  factory TextureProfile.fromMap(Map<String, dynamic> map) {
    return TextureProfile(
      softness: map['softness'] as double,
      sharpness: map['sharpness'] as double,
      roughness: map['roughness'] as double,
      density: map['density'] as double,
      brightness: map['brightness'] as double,
      saturation: map['saturation'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory TextureProfile.fromJson(String source) =>
      TextureProfile.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TextureProfile(softness: $softness, sharpness: $sharpness, roughness: $roughness, density: $density, brightness: $brightness, saturation: $saturation)';
  }

  @override
  bool operator ==(covariant TextureProfile other) {
    if (identical(this, other)) return true;

    return other.softness == softness &&
        other.sharpness == sharpness &&
        other.roughness == roughness &&
        other.density == density &&
        other.brightness == brightness &&
        other.saturation == saturation;
  }

  @override
  int get hashCode {
    return softness.hashCode ^
        sharpness.hashCode ^
        roughness.hashCode ^
        density.hashCode ^
        brightness.hashCode ^
        saturation.hashCode;
  }
}

class StructureProfile {
  final double complexity; // сложность
  final double variation; // разнообразие
  final double buildup; // нарастание
  final double dropIntensity; // сила дропа
  final double repetitiveness;

  StructureProfile({
    required this.complexity,
    required this.variation,
    required this.buildup,
    required this.dropIntensity,
    required this.repetitiveness,
  });

  StructureProfile copyWith({
    double? complexity,
    double? variation,
    double? buildup,
    double? dropIntensity,
    double? repetitiveness,
  }) {
    return StructureProfile(
      complexity: complexity ?? this.complexity,
      variation: variation ?? this.variation,
      buildup: buildup ?? this.buildup,
      dropIntensity: dropIntensity ?? this.dropIntensity,
      repetitiveness: repetitiveness ?? this.repetitiveness,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'complexity': complexity,
      'variation': variation,
      'buildup': buildup,
      'dropIntensity': dropIntensity,
      'repetitiveness': repetitiveness,
    };
  }

  factory StructureProfile.fromMap(Map<String, dynamic> map) {
    return StructureProfile(
      complexity: map['complexity'] as double,
      variation: map['variation'] as double,
      buildup: map['buildup'] as double,
      dropIntensity: map['dropIntensity'] as double,
      repetitiveness: map['repetitiveness'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory StructureProfile.fromJson(String source) =>
      StructureProfile.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'StructureProfile(complexity: $complexity, variation: $variation, buildup: $buildup, dropIntensity: $dropIntensity, repetitiveness: $repetitiveness)';
  }

  @override
  bool operator ==(covariant StructureProfile other) {
    if (identical(this, other)) return true;

    return other.complexity == complexity &&
        other.variation == variation &&
        other.buildup == buildup &&
        other.dropIntensity == dropIntensity &&
        other.repetitiveness == repetitiveness;
  }

  @override
  int get hashCode {
    return complexity.hashCode ^
        variation.hashCode ^
        buildup.hashCode ^
        dropIntensity.hashCode ^
        repetitiveness.hashCode;
  }
}

class ContextProfile {
  final List<String> genres;
  final List<String> moods; // "sad", "dreamy", "dark"
  final List<String> scenarios; // "night drive", "study", "party"
  ContextProfile({
    required this.genres,
    required this.moods,
    required this.scenarios,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'genres': genres,
      'moods': moods,
      'scenarios': scenarios,
    };
  }

  factory ContextProfile.fromMap(Map<String, dynamic> map) {
    return ContextProfile(
      genres: List<String>.from((map['genres'] as List<String>)),
      moods: List<String>.from((map['moods'] as List<String>)),
      scenarios: List<String>.from((map['scenarios'] as List<String>)),
    );
  }

  String toJson() => json.encode(toMap());

  factory ContextProfile.fromJson(String source) =>
      ContextProfile.fromMap(json.decode(source) as Map<String, dynamic>);

  ContextProfile copyWith({
    List<String>? genres,
    List<String>? moods,
    List<String>? scenarios,
  }) {
    return ContextProfile(
      genres: genres ?? this.genres,
      moods: moods ?? this.moods,
      scenarios: scenarios ?? this.scenarios,
    );
  }

  @override
  String toString() =>
      'ContextProfile(genres: $genres, moods: $moods, scenarios: $scenarios)';

  @override
  bool operator ==(covariant ContextProfile other) {
    if (identical(this, other)) return true;

    return listEquals(other.genres, genres) &&
        listEquals(other.moods, moods) &&
        listEquals(other.scenarios, scenarios);
  }

  @override
  int get hashCode => genres.hashCode ^ moods.hashCode ^ scenarios.hashCode;
}
