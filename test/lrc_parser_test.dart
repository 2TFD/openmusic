import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/domain/services/lrc_parser.dart';

void main() {
  const parser = LrcParser();

  test('parses synced lyrics and metadata while keeping original LRC', () {
    const source = '''[ar:Example Artist]
[ti:Example Song]
[al:Example Album]
[00:01.00]First line
[00:05.20]Second line''';

    final result = parser.parse(source) as LrcParseSuccess;

    expect(result.plainText, 'First line\nSecond line');
    expect(result.syncedText, source);
    expect(result.hasTimestamps, isTrue);
    expect(result.metadata, {
      'ar': 'Example Artist',
      'ti': 'Example Song',
      'al': 'Example Album',
    });
  });

  test('preserves Russian Unicode and repeated chorus lines', () {
    const source = '''[00:01.00]Привет, мир
[00:04.00]Припев
[00:08.00]Припев''';

    final result = parser.parse(source) as LrcParseSuccess;

    expect(result.plainText, 'Привет, мир\nПрипев\nПрипев');
  });

  test('does not duplicate plain text for multiple timestamps on one line', () {
    final result =
        parser.parse('[00:01.00][00:10.00]Repeated section') as LrcParseSuccess;

    expect(result.plainText, 'Repeated section');
  });

  test('tolerates malformed timestamps and keeps their lyric text', () {
    const source = '''[00:01.00]Good line
[00:broken]Still usable
[00:99.00]Invalid seconds but useful text''';

    final result = parser.parse(source) as LrcParseSuccess;

    expect(
      result.plainText,
      'Good line\nStill usable\nInvalid seconds but useful text',
    );
  });

  test('accepts an unsynced English sidecar as plain text', () {
    final result =
        parser.parse('A plain line\nAnother line') as LrcParseSuccess;

    expect(result.plainText, 'A plain line\nAnother line');
    expect(result.syncedText, isNull);
    expect(result.hasTimestamps, isFalse);
  });

  test('returns a typed failure for empty or metadata-only files', () {
    expect(parser.parse(''), isA<LrcParseFailure>());
    expect(parser.parse('[ar:Artist]\n[ti:Song]'), isA<LrcParseFailure>());
    expect(parser.parse('[00:01.00]'), isA<LrcParseFailure>());
  });
}
