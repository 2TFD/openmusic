import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/core/errors/failures/failure.dart';

dynamic _lookup(Map<String, dynamic> json, String key) {
  dynamic node = json;
  for (final part in key.split('.')) {
    node = (node as Map<String, dynamic>)[part];
  }
  return node;
}

void main() {
  final en =
      jsonDecode(File('assets/translations/en.json').readAsStringSync())
          as Map<String, dynamic>;
  final ru =
      jsonDecode(File('assets/translations/ru.json').readAsStringSync())
          as Map<String, dynamic>;

  final failures = <Failure>[
    const UnsupportedSourceFailure('x'),
    const UnsupportedMediaFailure('x'),
    const ParseFailure(),
    const NotFoundFailure('track', 'id'),
    const EmptyResultFailure('resolve'),
    const RemoteServiceFailure('remote', statusCode: 500),
    const RemoteAccessFailure(),
    const NetworkFailure(),
  ];

  test('every failure maps to a message that exists in en and ru', () {
    for (final failure in failures) {
      final key = failure.toLocaleKey();
      expect(_lookup(en, key), isA<String>(), reason: 'en $key');
      expect(_lookup(ru, key), isA<String>(), reason: 'ru $key');
    }
  });

  test('import failures are not collapsed into "Failed to load"', () {
    final keys = [
      for (final failure in failures.take(6)) failure.toLocaleKey(),
    ];
    expect(keys, isNot(contains('snackbar.errorLoad')));
    expect(keys.toSet(), hasLength(keys.length), reason: 'one message each');
  });

  test('link errors read as specific user-facing reasons', () {
    String text(Failure f) => _lookup(en, f.toLocaleKey()) as String;
    expect(text(const UnsupportedSourceFailure('x')), 'Unsupported link');
    expect(
      text(const NotFoundFailure('track', 'id')),
      'Track unavailable or not found',
    );
    expect(
      text(const RemoteServiceFailure('remote')),
      'The music service returned an error',
    );
    expect(text(const RemoteAccessFailure()), contains('sign in again'));
    expect(text(const NetworkFailure()), 'No internet connection');
  });

  test('new desktop strings exist in both languages', () {
    Set<String> keys(Map<String, dynamic> json, [String prefix = '']) => {
      for (final e in json.entries)
        if (e.value is Map<String, dynamic>)
          ...keys(e.value as Map<String, dynamic>, '$prefix${e.key}.')
        else
          '$prefix${e.key}',
    };
    final missing = keys(en).difference(keys(ru));
    expect(
      missing.where(
        (k) =>
            k.startsWith('import.') ||
            k.startsWith('nav.') ||
            k.startsWith('context.') ||
            k.startsWith('errors.'),
      ),
      isEmpty,
    );
  });
}
