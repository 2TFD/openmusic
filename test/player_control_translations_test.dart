import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'desktop playback controls have user-facing labels in both locales',
    () async {
      const expected = <String, Map<String, String>>{
        'en': {
          'previous': 'Previous track',
          'play': 'Play',
          'pause': 'Pause',
          'next': 'Next track',
        },
        'ru': {
          'previous': 'Предыдущий трек',
          'play': 'Воспроизвести',
          'pause': 'Пауза',
          'next': 'Следующий трек',
        },
      };

      for (final locale in expected.keys) {
        final asset = await rootBundle.loadString(
          'assets/translations/$locale.json',
        );
        final translations = jsonDecode(asset) as Map<String, dynamic>;
        final player = translations['player'] as Map<String, dynamic>;

        for (final entry in expected[locale]!.entries) {
          expect(
            player[entry.key],
            entry.value,
            reason: '$locale player.${entry.key}',
          );
        }
      }
    },
  );
}
