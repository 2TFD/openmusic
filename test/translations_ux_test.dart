import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, String> _flatten(
  Map<String, dynamic> source, [
  String prefix = '',
]) {
  final out = <String, String>{};
  source.forEach((key, value) {
    if (value is Map<String, dynamic>) {
      out.addAll(_flatten(value, '$prefix$key.'));
    } else {
      out['$prefix$key'] = value as String;
    }
  });
  return out;
}

Map<String, String> _load(String language) => _flatten(
  jsonDecode(File('assets/translations/$language.json').readAsStringSync())
      as Map<String, dynamic>,
);

void main() {
  final en = _load('en');
  final ru = _load('ru');

  test('English and Russian define the same strings', () {
    expect(ru.keys.toSet().difference(en.keys.toSet()), isEmpty);
    expect(en.keys.toSet().difference(ru.keys.toSet()), isEmpty);
  });

  test('placeholders match between languages', () {
    final placeholder = RegExp(r'\{(\w+)\}');
    for (final key in en.keys) {
      final english = placeholder.allMatches(en[key]!).map((m) => m[1]).toSet();
      final russian = placeholder.allMatches(ru[key]!).map((m) => m[1]).toSet();
      expect(russian, english, reason: key);
    }
  });

  test('no developer vocabulary in visible strings', () {
    final technical = RegExp(
      r'valence|arousal|embedding|uuid|\bML\b|neural|cursor|idempot|snippet',
      caseSensitive: false,
    );
    for (final entry in en.entries) {
      expect(technical.hasMatch(entry.value), isFalse, reason: entry.key);
    }
  });

  test('product vocabulary is consistent', () {
    expect(en['home.addMusic'], 'Add music');
    expect(en['import.title'], 'Add music');
    expect(en['library.empty.import'], 'Add music');
    expect(en['wave.start'], 'Start Wave');
    expect(en['home.startWave'], 'Start Wave');
    expect(en['waveSession.startWave'], 'Start Wave');
    expect(en['wave.chooseMood'], 'Choose a mood');
    expect(en['moodMap.title'], 'Choose a mood');
    expect(en['cloud.migrationTitle'], 'Add this device’s music to OwlSonic');
    expect(en['waveSession.ready'], 'Wave is playing');
    expect(en['cloud.analyzing'], 'Getting ready for Wave');
    expect(
      en.values.where((v) => v.contains('Mood Wave')),
      isEmpty,
      reason: 'one name for the feature: Wave',
    );
  });

  test('privacy copy makes only claims the app and API can keep', () {
    final disclosures = [
      en['cloud.uploadNotice']!,
      en['welcome.accountNote']!,
      en['cloud.deleteAccountConfirm']!,
    ].join(' ');
    for (final claim in [
      'immediately deleted',
      'Nothing is saved',
      'never stored',
      'end-to-end',
      'encrypted',
      'never shared',
      'temporarily',
    ]) {
      expect(disclosures.contains(claim), isFalse, reason: claim);
    }
    // Verified against the client and docs/openapi.json: uploads need an
    // account, audio is stored and analyzed server-side, originals are left
    // alone, and deleting an account keeps shared content without an owner.
    expect(en['cloud.uploadNotice'], contains('uploads the music you add'));
    expect(en['cloud.uploadNotice'], contains('stored and analyzed'));
    expect(en['cloud.uploadNotice'], contains('original files stay'));
    expect(en['cloud.deleteAccountConfirm'], contains('without any link'));
    expect(
      en.keys.where((k) => k.startsWith('privacy.')),
      isEmpty,
      reason: 'the consent step was removed',
    );
  });
}
