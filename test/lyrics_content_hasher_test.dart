import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/domain/services/lyrics_content_hasher.dart';

void main() {
  test('uses the standard lowercase SHA-256 representation', () {
    expect(
      LyricsContentHasher.hash('hello'),
      '2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824',
    );
  });

  test('normalizes line endings and trailing horizontal whitespace', () {
    final canonical = LyricsContentHasher.hash('First line\nSecond line');

    expect(
      LyricsContentHasher.hash('\r\nFirst line  \r\nSecond line\t\r\n\r\n'),
      canonical,
    );
  });

  test('preserves internal blank lines and repeated chorus lines', () {
    const lyrics = 'Verse\n\nChorus\nChorus';

    expect(LyricsContentHasher.canonicalize('\n$lyrics\n'), lyrics);
    expect(
      LyricsContentHasher.hash(lyrics),
      isNot(LyricsContentHasher.hash('Verse\nChorus')),
    );
  });

  test('does not normalize meaningful Unicode or leading whitespace', () {
    expect(LyricsContentHasher.canonicalize('  Привет\nмир'), '  Привет\nмир');
  });
}
