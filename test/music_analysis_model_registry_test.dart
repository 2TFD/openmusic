import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/core/services/music_analysis/music_analysis_model_registry.dart';
import 'package:owlsonic/layers/domain/entities/music_analysis.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('serves descriptors cached by earlier app versions', () async {
    SharedPreferences.setMockInitialValues({
      'cached_analysis_models': jsonEncode({
        'schemaVersion': '1.0',
        'models': [
          {
            'representation': MusicAnalysisRepresentation.audioGlobal.apiName,
            'modelId': 'clap',
            'modelVersion': '1.1',
            'preprocessingVersion': '1.2',
            'dimension': 512,
            'dtype': 'float32',
            'normalized': true,
          },
        ],
      }),
    });
    final registry = MusicAnalysisModelRegistry(
      prefs: await SharedPreferences.getInstance(),
    );

    final models = await registry.getModels();

    expect(
      models.find(MusicAnalysisRepresentation.audioGlobal)?.modelId,
      'clap',
    );
  });

  test(
    'without a cache reports no models instead of calling a worker',
    () async {
      SharedPreferences.setMockInitialValues({});
      final registry = MusicAnalysisModelRegistry(
        prefs: await SharedPreferences.getInstance(),
      );

      final models = await registry.getModels(refresh: true);

      expect(models.models, isEmpty);
      expect(
        models.find(MusicAnalysisRepresentation.audioEmotionGlobal),
        isNull,
      );
    },
  );
}
