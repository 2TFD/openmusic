import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/data/datasources/remote/music_analysis/music_analysis_api_parser.dart';
import 'package:openmusic/layers/domain/entities/music_analysis.dart';
import 'package:openmusic/layers/domain/entities/music_analysis_failure.dart';

void main() {
  const parser = MusicAnalysisApiParser();

  test('parses /v1/models metadata', () {
    final result = parser.parseModels({
      'schema_version': '1',
      'models': [_metadata('audio.global')],
    });

    expect(result.schemaVersion, '1');
    expect(result.models.single.dimension, 2);
    expect(result.models.single.preprocessingVersion, 'pre-v1');
    expect(result.models.single.normalized, isTrue);
  });

  test('v2 models include Music2Emo and ignore unavailable lyrics emotion', () {
    final result = parser.parseModels({
      'schema_version': '2',
      'models': [
        _emotionMetadata('audio.emotion.global'),
        _emotionMetadata('audio.emotion.temporal'),
        {..._emotionMetadata('lyrics.emotion.global'), 'available': false},
      ],
    });

    expect(result.models.map((model) => model.representation), {
      MusicAnalysisRepresentation.audioEmotionGlobal,
      MusicAnalysisRepresentation.audioEmotionTemporal,
    });
  });

  test('parses audio.global and permits missing optional representations', () {
    final response = parser.parseAnalysis({
      'schema_version': '1',
      'track': {'track_id': 'track-1', 'content_identity': 'local:sha256:x'},
      'representations': {
        'audio.global': {
          ..._metadata('audio.global'),
          'embedding': [0.5, -0.5],
          'configuration': <String, Object?>{},
          'analysis': <String, Object?>{},
        },
      },
    });

    expect(response.trackId, 'track-1');
    expect(response.audioGlobal?.vector, [0.5, -0.5]);
    expect(response.audioTemporal, isNull);
    expect(response.lyricsGlobal, isNull);
  });

  test('parses ordered audio.temporal segments and summary', () {
    final response = parser.parseAnalysis({
      'schema_version': '1',
      'track': <String, Object?>{},
      'representations': {
        'audio.temporal': {
          ..._metadata('audio.temporal'),
          'configuration': <String, Object?>{},
          'segments': [
            {
              'start_ms': 0,
              'end_ms': 10000,
              'embedding': [1, 0],
            },
            {
              'start_ms': 10000,
              'end_ms': 20000,
              'embedding': [0, 1],
            },
          ],
          'summary': {
            'number_of_segments': 2,
            'mean_adjacent_distance': 0.5,
            'max_adjacent_distance': 0.5,
            'trajectory_variance': 0.25,
            'largest_transition_index': 0,
          },
        },
      },
    });

    expect(response.audioTemporal?.segments.map((entry) => entry.index), [
      0,
      1,
    ]);
    expect(response.audioTemporal?.summary.numberOfSegments, 2);
  });

  test('parses lyrics.global metadata and embedding', () {
    final response = parser.parseAnalysis({
      'schema_version': '1',
      'track': {'track_id': 'track-1'},
      'representations': {
        'lyrics.global': {
          ..._metadata('lyrics.global'),
          'embedding': [0.25, 0.75],
          'configuration': <String, Object?>{},
          'analysis': <String, Object?>{},
        },
      },
    });

    expect(
      response.lyricsGlobal?.metadata.representation,
      MusicAnalysisRepresentation.lyricsGlobal,
    );
    expect(response.lyricsGlobal?.vector, [0.25, 0.75]);
  });

  test('rejects unknown schema', () {
    expect(
      () => parser.parseModels({'schema_version': '3', 'models': []}),
      throwsA(
        isA<MusicAnalysisFailure>().having(
          (failure) => failure.kind,
          'kind',
          MusicAnalysisFailureKind.unsupportedSchema,
        ),
      ),
    );
  });

  test('parses schema v2 Music2Emo global and temporal results', () {
    final response = parser.parseAnalysis({
      'schema_version': '2',
      'track': {'track_id': 'track-emo', 'content_identity': 'sha256:x'},
      'representations': {
        'audio.emotion.global': {
          ..._emotionMetadata('audio.emotion.global'),
          'valence': 0.4,
          'arousal': -0.2,
          'raw_valence': 1.4,
          'raw_arousal': -0.8,
          'mood_distribution': {
            'labels': ['joyful', 'film'],
            'probabilities': [0.8, 0.6],
            'kind': 'multi_label_sigmoid',
            'vocabulary_version': 'mood-56-v1',
          },
          'emotion_embedding': null,
        },
        'audio.emotion.temporal': {
          ..._emotionMetadata('audio.emotion.temporal'),
          'segments': [
            {
              'start_ms': 0,
              'end_ms': 1000,
              'valence': -0.1,
              'arousal': 0.2,
              'raw_valence': 4.6,
              'raw_arousal': 5.8,
              'mood_distribution': {
                'labels': ['calm', 'travel'],
                'probabilities': [0.7, 0.4],
                'kind': 'multi_label_sigmoid',
                'vocabulary_version': 'mood-56-v1',
              },
            },
            {
              'start_ms': 1000,
              'end_ms': 2000,
              'valence': 0.3,
              'arousal': 0.6,
              'raw_valence': 6.2,
              'raw_arousal': 7.4,
              'mood_distribution': {
                'labels': ['calm', 'exciting'],
                'probabilities': [0.2, 0.9],
                'kind': 'multi_label_sigmoid',
                'vocabulary_version': 'mood-56-v1',
              },
            },
          ],
          'summary': {
            'number_of_segments': 2,
            'valence_mean': 0.1,
            'valence_std': 0.2,
            'valence_min': -0.1,
            'valence_max': 0.3,
            'arousal_mean': 0.4,
            'arousal_std': 0.2,
            'arousal_min': 0.2,
            'arousal_max': 0.6,
            'emotion_path_length': 0.56,
            'largest_emotion_change_index': 0,
            'start_end_emotion_distance': 0.56,
          },
        },
      },
    });

    expect(response.schemaVersion, '2');
    expect(response.audioEmotionGlobal?.valence, 0.4);
    expect(response.audioEmotionGlobal?.moodDistribution.scores['film'], 0.6);
    expect(response.audioEmotionTemporal?.segments, hasLength(2));
    expect(response.audioEmotionTemporal?.summary.arousalMean, 0.4);
    expect(response.audioGlobal, isNull);
  });

  test('schema v1 parsing remains unchanged', () {
    final response = parser.parseAnalysis({
      'schema_version': '1',
      'representations': {
        'audio.global': {
          ..._metadata('audio.global'),
          'embedding': [0.2, 0.8],
        },
      },
    });
    expect(response.audioGlobal?.vector, [0.2, 0.8]);
    expect(response.audioEmotionGlobal, isNull);
  });

  test('rejects unknown representation and dtype', () {
    expect(
      () => parser.parseModels({
        'schema_version': '1',
        'models': [_metadata('audio.future')],
      }),
      throwsA(isA<MusicAnalysisFailure>()),
    );
    expect(
      () => parser.parseModels({
        'schema_version': '1',
        'models': [
          {..._metadata('audio.global'), 'dtype': 'float16'},
        ],
      }),
      throwsA(isA<MusicAnalysisFailure>()),
    );
  });

  test('rejects invalid global dimensions', () {
    expect(
      () => parser.parseAnalysis({
        'schema_version': '1',
        'track': <String, Object?>{},
        'representations': {
          'audio.global': {
            ..._metadata('audio.global'),
            'configuration': <String, Object?>{},
            'embedding': [1],
          },
        },
      }),
      throwsA(isA<MusicAnalysisFailure>()),
    );
  });

  test('rejects malformed temporal segments', () {
    expect(
      () => parser.parseAnalysis({
        'schema_version': '1',
        'track': <String, Object?>{},
        'representations': {
          'audio.temporal': {
            ..._metadata('audio.temporal'),
            'configuration': <String, Object?>{},
            'segments': [
              {
                'start_ms': 100,
                'end_ms': 50,
                'embedding': [1, 0],
              },
            ],
            'summary': {
              'number_of_segments': 1,
              'mean_adjacent_distance': 0.0,
              'max_adjacent_distance': 0.0,
              'trajectory_variance': 0.0,
              'largest_transition_index': null,
            },
          },
        },
      }),
      throwsA(isA<MusicAnalysisFailure>()),
    );
  });
}

Map<String, Object?> _metadata(String representation) => {
  'representation': representation,
  'modality': representation,
  'model_id': 'model',
  'model_version': 'version',
  'preprocessing_version': 'pre-v1',
  'dimension': 2,
  'dtype': 'float32',
  'normalized': true,
};

Map<String, Object?> _emotionMetadata(String representation) => {
  'representation': representation,
  'modality': representation,
  'model_id': 'music2emo',
  'model_version': '1.0',
  'preprocessing_version': 'm2e-pre-1',
};
