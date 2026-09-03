import 'dart:convert';

import 'package:crypto/crypto.dart';

abstract final class LyricsContentHasher {
  static final RegExp _trailingHorizontalWhitespace = RegExp(
    r'[\t\x20\u00a0\u1680\u2000-\u200a\u202f\u205f\u3000]+$',
    unicode: true,
  );

  static String canonicalize(String plainText) {
    final lines = plainText
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n')
        .map((line) => line.replaceFirst(_trailingHorizontalWhitespace, ''))
        .toList();

    var first = 0;
    while (first < lines.length && lines[first].trim().isEmpty) {
      first++;
    }
    var last = lines.length;
    while (last > first && lines[last - 1].trim().isEmpty) {
      last--;
    }
    return lines.sublist(first, last).join('\n');
  }

  static String hash(String plainText) {
    final canonical = canonicalize(plainText);
    return sha256.convert(utf8.encode(canonical)).toString();
  }
}
