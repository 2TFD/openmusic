import '../../../../domain/entities/music_analysis.dart';
import '../../../../domain/entities/music_analysis_failure.dart';

class MusicAnalysisApiParser {
  const MusicAnalysisApiParser();

  static const supportedSchemaVersions = {'1', '2'};

  MusicAnalysisModels parseModels(Object? payload) {
    final root = _map(payload);
    final schema = _schema(root);
    final rawModels = root['models'];
    if (rawModels is! List || rawModels.isEmpty) {
      throw const MusicAnalysisFailure(
        MusicAnalysisFailureKind.invalidRepresentation,
        details: 'models must be a non-empty list',
      );
    }
    final models = <MusicAnalysisModel>[];
    for (final entry in rawModels) {
      final data = _map(entry);
      // The v2 registry advertises a deliberately unavailable lyrics emotion
      // placeholder. It is outside this client's supported feature set.
      if (data['representation'] == 'lyrics.emotion.global' &&
          data['available'] == false) {
        continue;
      }
      models.add(_metadata(data));
    }
    return MusicAnalysisModels(schemaVersion: schema, models: models);
  }

  MusicAnalysisResponse parseAnalysis(Object? payload) {
    final root = _map(payload);
    final schema = _schema(root);
    final representations = _map(root['representations']);
    GlobalAnalysisRepresentation? audioGlobal;
    TemporalAnalysisRepresentation? audioTemporal;
    AudioEmotionGlobalResult? audioEmotionGlobal;
    AudioEmotionTemporalResult? audioEmotionTemporal;
    GlobalAnalysisRepresentation? lyricsGlobal;
    for (final entry in representations.entries) {
      final representation = _representation(entry.key);
      final data = _map(entry.value);
      switch (representation) {
        case MusicAnalysisRepresentation.audioGlobal:
          audioGlobal = _global(data, representation);
        case MusicAnalysisRepresentation.audioTemporal:
          audioTemporal = _temporal(data, representation);
        case MusicAnalysisRepresentation.audioEmotionGlobal:
          audioEmotionGlobal = _emotionGlobal(data, representation);
        case MusicAnalysisRepresentation.audioEmotionTemporal:
          audioEmotionTemporal = _emotionTemporal(data, representation);
        case MusicAnalysisRepresentation.lyricsGlobal:
          lyricsGlobal = _global(data, representation);
      }
    }
    final track = root['track'] == null
        ? const <String, Object?>{}
        : _map(root['track']);
    return MusicAnalysisResponse(
      schemaVersion: schema,
      trackId: track['track_id'] as String?,
      contentIdentity: track['content_identity'] as String?,
      audioGlobal: audioGlobal,
      audioTemporal: audioTemporal,
      audioEmotionGlobal: audioEmotionGlobal,
      audioEmotionTemporal: audioEmotionTemporal,
      lyricsGlobal: lyricsGlobal,
    );
  }

  AudioEmotionGlobalResult _emotionGlobal(
    Map<String, Object?> data,
    MusicAnalysisRepresentation expected,
  ) {
    final metadata = _metadata(data);
    if (metadata.representation != expected) {
      _invalid('representation mismatch');
    }
    try {
      return AudioEmotionGlobalResult(
        metadata: metadata,
        valence: _finite(data['valence'], 'valence'),
        arousal: _finite(data['arousal'], 'arousal'),
        rawValence: _nullableFinite(
          data['raw_valence'] ?? data['rawValence'],
          'raw_valence',
        ),
        rawArousal: _nullableFinite(
          data['raw_arousal'] ?? data['rawArousal'],
          'raw_arousal',
        ),
        moodDistribution: _moodDistribution(
          data['mood_distribution'] ?? data['moodDistribution'],
        ),
      );
    } on ArgumentError catch (error) {
      _invalid(error.toString());
    }
  }

  AudioEmotionTemporalResult _emotionTemporal(
    Map<String, Object?> data,
    MusicAnalysisRepresentation expected,
  ) {
    final metadata = _metadata(data);
    if (metadata.representation != expected) {
      _invalid('representation mismatch');
    }
    final rawSegments = data['segments'];
    if (rawSegments is! List || rawSegments.isEmpty) {
      _invalid('emotion temporal segments must not be empty');
    }
    final segments = <AudioEmotionSegment>[];
    for (var index = 0; index < rawSegments.length; index++) {
      final segment = _map(rawSegments[index]);
      try {
        segments.add(
          AudioEmotionSegment(
            index: segment['index'] == null
                ? index
                : _int(segment['index'], 'index'),
            startMs: _int(
              segment['start_ms'] ?? segment['startMs'],
              'start_ms',
            ),
            endMs: _int(segment['end_ms'] ?? segment['endMs'], 'end_ms'),
            valence: _finite(segment['valence'], 'valence'),
            arousal: _finite(segment['arousal'], 'arousal'),
            rawValence: _nullableFinite(segment['raw_valence'], 'raw_valence'),
            rawArousal: _nullableFinite(segment['raw_arousal'], 'raw_arousal'),
            moodDistribution: _moodDistribution(
              segment['mood_distribution'] ?? segment['moodDistribution'],
            ),
          ),
        );
      } on ArgumentError catch (error) {
        _invalid(error.toString());
      }
      if (index > 0 && segments[index].startMs < segments[index - 1].startMs) {
        _invalid('emotion temporal segments are not ordered');
      }
    }
    final summaryData = data['summary'] == null
        ? const <String, Object?>{}
        : _map(data['summary']);
    try {
      final summary = AudioEmotionTemporalSummary(
        numberOfSegments: summaryData['number_of_segments'] == null
            ? segments.length
            : _int(summaryData['number_of_segments'], 'number_of_segments'),
        valenceMean: _nullableFinite(
          summaryData['valence_mean'] ?? summaryData['mean_valence'],
          'valence_mean',
        ),
        valenceStd: _nullableFinite(summaryData['valence_std'], 'valence_std'),
        minValence: _nullableFinite(
          summaryData['valence_min'] ?? summaryData['min_valence'],
          'valence_min',
        ),
        maxValence: _nullableFinite(
          summaryData['valence_max'] ?? summaryData['max_valence'],
          'valence_max',
        ),
        arousalMean: _nullableFinite(
          summaryData['arousal_mean'] ?? summaryData['mean_arousal'],
          'arousal_mean',
        ),
        arousalStd: _nullableFinite(summaryData['arousal_std'], 'arousal_std'),
        minArousal: _nullableFinite(
          summaryData['arousal_min'] ?? summaryData['min_arousal'],
          'arousal_min',
        ),
        maxArousal: _nullableFinite(
          summaryData['arousal_max'] ?? summaryData['max_arousal'],
          'arousal_max',
        ),
        emotionPathLength: _nullableFinite(
          summaryData['emotion_path_length'],
          'emotion_path_length',
        ),
        largestEmotionChangeIndex:
            summaryData['largest_emotion_change_index'] == null
            ? null
            : _int(
                summaryData['largest_emotion_change_index'],
                'largest_emotion_change_index',
              ),
        startEndEmotionDistance: _nullableFinite(
          summaryData['start_end_emotion_distance'],
          'start_end_emotion_distance',
        ),
      );
      return AudioEmotionTemporalResult(
        metadata: metadata,
        segments: segments,
        summary: summary,
      );
    } on ArgumentError catch (error) {
      _invalid(error.toString());
    }
  }

  MoodDistribution _moodDistribution(Object? value) {
    final raw = _map(value);
    final scores = <String, double>{};
    final labels = raw['labels'];
    final probabilities = raw['probabilities'];
    if (labels is List && probabilities is List) {
      if (labels.length != probabilities.length || labels.isEmpty) {
        _invalid('mood labels/probabilities length mismatch');
      }
      for (var index = 0; index < labels.length; index++) {
        final label = labels[index];
        if (label is! String || label.trim().isEmpty) {
          _invalid('invalid mood label');
        }
        scores[label] = _finite(probabilities[index], 'mood probability');
      }
    } else {
      // Early schema-v2 fixtures used a compact label -> score object.
      for (final entry in raw.entries) {
        scores[entry.key] = _finite(entry.value, 'mood_distribution');
      }
    }
    try {
      return MoodDistribution(
        scores,
        kind: raw['kind'] as String?,
        vocabularyVersion: raw['vocabulary_version'] as String?,
      );
    } on ArgumentError catch (error) {
      _invalid(error.toString());
    }
  }

  GlobalAnalysisRepresentation _global(
    Map<String, Object?> data,
    MusicAnalysisRepresentation expected,
  ) {
    final metadata = _metadata(data);
    if (metadata.representation != expected)
      _invalid('representation mismatch');
    final vector = _vector(data['embedding'], metadata.dimension);
    return GlobalAnalysisRepresentation(metadata: metadata, vector: vector);
  }

  TemporalAnalysisRepresentation _temporal(
    Map<String, Object?> data,
    MusicAnalysisRepresentation expected,
  ) {
    final metadata = _metadata(data);
    if (metadata.representation != expected)
      _invalid('representation mismatch');
    final rawSegments = data['segments'];
    if (rawSegments is! List || rawSegments.isEmpty) {
      _invalid('temporal segments must not be empty');
    }
    final segments = <TemporalAnalysisSegment>[];
    for (var index = 0; index < rawSegments.length; index++) {
      final segment = _map(rawSegments[index]);
      final startMs = _int(segment['start_ms'], 'start_ms');
      final endMs = _int(segment['end_ms'], 'end_ms');
      try {
        segments.add(
          TemporalAnalysisSegment(
            index: index,
            startMs: startMs,
            endMs: endMs,
            dimensions: metadata.dimension,
            vector: _vector(segment['embedding'], metadata.dimension),
          ),
        );
      } on ArgumentError catch (error) {
        _invalid(error.toString());
      }
      if (index > 0 && startMs < segments[index - 1].startMs) {
        _invalid('temporal segments are not ordered');
      }
    }
    final rawSummary = _map(data['summary']);
    final summary = TemporalAnalysisSummary(
      numberOfSegments: _int(
        rawSummary['number_of_segments'],
        'number_of_segments',
      ),
      meanAdjacentDistance: _finite(
        rawSummary['mean_adjacent_distance'],
        'mean_adjacent_distance',
      ),
      maxAdjacentDistance: _finite(
        rawSummary['max_adjacent_distance'],
        'max_adjacent_distance',
      ),
      trajectoryVariance: _finite(
        rawSummary['trajectory_variance'],
        'trajectory_variance',
      ),
      largestTransitionIndex: rawSummary['largest_transition_index'] == null
          ? null
          : _int(
              rawSummary['largest_transition_index'],
              'largest_transition_index',
            ),
    );
    final largestTransitionIndex = summary.largestTransitionIndex;
    final hasInvalidLargestTransitionIndex =
        largestTransitionIndex != null &&
        (largestTransitionIndex < 0 ||
            largestTransitionIndex >= segments.length - 1);
    if (summary.numberOfSegments != segments.length ||
        hasInvalidLargestTransitionIndex) {
      _invalid(
        'invalid temporal summary: '
        'segments=${segments.length}, '
        'summary.number_of_segments=${summary.numberOfSegments}, '
        'summary.largest_transition_index=$largestTransitionIndex, '
        'valid_largest_transition_index='
        '${segments.length > 1 ? '0..${segments.length - 2}' : 'null'}',
      );
    }
    return TemporalAnalysisRepresentation(
      metadata: metadata,
      segments: segments,
      summary: summary,
    );
  }

  MusicAnalysisModel _metadata(Map<String, Object?> data) {
    try {
      final representation = _representation(_string(data, 'representation'));
      final modality = _string(data, 'modality');
      if (modality != representation.apiName) _invalid('modality mismatch');
      final isEmbedding = representation.isEmbedding;
      return MusicAnalysisModel(
        representation: representation,
        modelId: _stringEither(data, 'model_id', 'modelId'),
        modelVersion: _stringEither(data, 'model_version', 'modelVersion'),
        preprocessingVersion: _stringEither(
          data,
          'preprocessing_version',
          'preprocessingVersion',
        ),
        dimension: isEmbedding ? _int(data['dimension'], 'dimension') : 0,
        dtype: isEmbedding ? _string(data, 'dtype') : 'float32',
        normalized: isEmbedding ? data['normalized'] as bool : false,
      );
    } on MusicAnalysisFailure {
      rethrow;
    } catch (error) {
      _invalid(error.toString());
    }
  }

  Map<String, Object?> _map(Object? value) {
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    throw const MusicAnalysisFailure(
      MusicAnalysisFailureKind.invalidRepresentation,
      details: 'Expected object',
    );
  }

  String _schema(Map<String, Object?> root) {
    final schema = root['schema_version'];
    if (schema is! String || !supportedSchemaVersions.contains(schema)) {
      throw MusicAnalysisFailure(
        MusicAnalysisFailureKind.unsupportedSchema,
        details: 'schema_version=$schema',
      );
    }
    return schema;
  }

  MusicAnalysisRepresentation _representation(String value) {
    try {
      return MusicAnalysisRepresentation.parse(value);
    } on ArgumentError {
      throw MusicAnalysisFailure(
        MusicAnalysisFailureKind.invalidRepresentation,
        details: 'Unknown representation $value',
      );
    }
  }

  String _string(Map<String, Object?> data, String key) {
    final value = data[key];
    if (value is! String || value.trim().isEmpty) _invalid('invalid $key');
    return value;
  }

  String _stringEither(
    Map<String, Object?> data,
    String snakeKey,
    String camelKey,
  ) {
    final value = data[snakeKey] ?? data[camelKey];
    if (value is! String || value.trim().isEmpty) {
      _invalid('invalid $snakeKey');
    }
    return value;
  }

  int _int(Object? value, String name) {
    if (value is! int) _invalid('invalid $name');
    return value;
  }

  double _finite(Object? value, String name) {
    if (value is! num || !value.toDouble().isFinite) _invalid('invalid $name');
    return value.toDouble();
  }

  double? _nullableFinite(Object? value, String name) =>
      value == null ? null : _finite(value, name);

  List<double> _vector(Object? value, int dimension) {
    if (value is! List || value.length != dimension || value.isEmpty) {
      _invalid('invalid vector dimensions');
    }
    final result = <double>[];
    for (final item in value) {
      if (item is! num || !item.toDouble().isFinite) {
        _invalid('non-finite vector value');
      }
      result.add(item.toDouble());
    }
    return result;
  }

  Never _invalid(String details) => throw MusicAnalysisFailure(
    MusicAnalysisFailureKind.invalidRepresentation,
    details: details,
  );
}
