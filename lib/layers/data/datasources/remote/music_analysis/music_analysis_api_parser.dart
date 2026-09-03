import '../../../../domain/entities/music_analysis.dart';
import '../../../../domain/entities/music_analysis_failure.dart';

class MusicAnalysisApiParser {
  const MusicAnalysisApiParser();

  static const supportedSchemaVersion = '1';

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
    return MusicAnalysisModels(
      schemaVersion: schema,
      models: rawModels.map((entry) => _metadata(_map(entry))).toList(),
    );
  }

  MusicAnalysisResponse parseAnalysis(Object? payload) {
    final root = _map(payload);
    final schema = _schema(root);
    final representations = _map(root['representations']);
    GlobalAnalysisRepresentation? audioGlobal;
    TemporalAnalysisRepresentation? audioTemporal;
    GlobalAnalysisRepresentation? lyricsGlobal;
    for (final entry in representations.entries) {
      final representation = _representation(entry.key);
      final data = _map(entry.value);
      switch (representation) {
        case MusicAnalysisRepresentation.audioGlobal:
          audioGlobal = _global(data, representation);
        case MusicAnalysisRepresentation.audioTemporal:
          audioTemporal = _temporal(data, representation);
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
      lyricsGlobal: lyricsGlobal,
    );
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
      return MusicAnalysisModel(
        representation: representation,
        modelId: _string(data, 'model_id'),
        modelVersion: _string(data, 'model_version'),
        preprocessingVersion: _string(data, 'preprocessing_version'),
        dimension: _int(data['dimension'], 'dimension'),
        dtype: _string(data, 'dtype'),
        normalized: data['normalized'] as bool,
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
    if (schema != supportedSchemaVersion) {
      throw MusicAnalysisFailure(
        MusicAnalysisFailureKind.unsupportedSchema,
        details: 'schema_version=$schema',
      );
    }
    return schema! as String;
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

  int _int(Object? value, String name) {
    if (value is! int) _invalid('invalid $name');
    return value;
  }

  double _finite(Object? value, String name) {
    if (value is! num || !value.toDouble().isFinite) _invalid('invalid $name');
    return value.toDouble();
  }

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
