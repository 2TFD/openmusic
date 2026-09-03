import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/core/services/music_analysis/music_analysis_config.dart';
import 'package:openmusic/layers/data/datasources/remote/music_analysis/dio_music_analysis_client.dart';
import 'package:openmusic/layers/domain/entities/music_analysis.dart';
import 'package:openmusic/layers/domain/entities/music_analysis_failure.dart';

void main() {
  test(
    'lyrics.global multipart includes audio, lyrics and representation',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'openmusic_analysis_client_',
      );
      addTearDown(() => directory.delete(recursive: true));
      final audio = File('${directory.path}/track.mp3');
      await audio.writeAsBytes([1, 2, 3]);
      FormData? captured;
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            captured = options.data as FormData;
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'schema_version': '1',
                  'track': {'track_id': 'track-1'},
                  'representations': {
                    'lyrics.global': {
                      'representation': 'lyrics.global',
                      'modality': 'lyrics.global',
                      'model_id': 'lyrics-model',
                      'model_version': '1',
                      'preprocessing_version': 'lyrics-pre',
                      'dimension': 2,
                      'dtype': 'float32',
                      'normalized': true,
                      'embedding': [1, 0],
                    },
                  },
                },
              ),
            );
          },
        ),
      );
      final client = DioMusicAnalysisClient(
        config: MusicAnalysisConfig('https://analysis.test'),
        appDirectory: directory.path,
        dio: dio,
      );

      final response = await client.analyze(
        trackId: 'track-1',
        filePath: audio.path,
        lyrics: 'Text for analysis',
        requestedRepresentations: const {
          MusicAnalysisRepresentation.lyricsGlobal,
        },
      );

      expect(response.lyricsGlobal?.vector, [1, 0]);
      expect(captured?.files.single.key, 'audio');
      expect(
        captured?.fields.any(
          (field) =>
              field.key == 'lyrics' && field.value == 'Text for analysis',
        ),
        isTrue,
      );
      expect(
        captured?.fields.any(
          (field) =>
              field.key == 'requested_representations' &&
              field.value == 'lyrics.global',
        ),
        isTrue,
      );
    },
  );

  test('lyrics.global rejects a request without lyrics before HTTP', () async {
    final directory = await Directory.systemTemp.createTemp(
      'openmusic_analysis_client_empty_',
    );
    addTearDown(() => directory.delete(recursive: true));
    final audio = File('${directory.path}/track.mp3');
    await audio.writeAsBytes([1]);
    final client = DioMusicAnalysisClient(
      config: MusicAnalysisConfig('https://analysis.test'),
      appDirectory: directory.path,
      dio: Dio(),
    );

    await expectLater(
      client.analyze(
        trackId: 'track-1',
        filePath: audio.path,
        requestedRepresentations: const {
          MusicAnalysisRepresentation.lyricsGlobal,
        },
      ),
      throwsA(
        isA<MusicAnalysisFailure>().having(
          (failure) => failure.kind,
          'kind',
          MusicAnalysisFailureKind.invalidRepresentation,
        ),
      ),
    );
  });
}
