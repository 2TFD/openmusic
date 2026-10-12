import 'dart:convert';

const _maxNameBytes = 180;

/// File name (without extension) for audio kept on the device:
/// "Artist - Title - source - 1a2b3c4d". Readable in file managers and other
/// players; the short id keeps same-named tracks apart and makes the name
/// deterministic per track, so an existing file is recognised and reused.
String audioFileBase({
  required String? artist,
  required String? title,
  required String source,
  required String id,
}) {
  String clean(String? value) => (value ?? '')
      .replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F]'), '_')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  var name = [
    for (final part in [clean(artist), clean(title)])
      if (part.isNotEmpty) part,
  ].join(' - ');
  // Byte-budgeted, rune-safe cut: file systems allow 255 bytes per name, and
  // the source, id, extension and ".part" suffix still follow.
  if (utf8.encode(name).length > _maxNameBytes) {
    final cut = StringBuffer();
    var bytes = 0;
    for (final rune in name.runes) {
      final char = String.fromCharCode(rune);
      bytes += utf8.encode(char).length;
      if (bytes > _maxNameBytes) break;
      cut.write(char);
    }
    name = cut.toString().trim();
  }
  name = name.replaceFirst(RegExp(r'^\.+'), '');
  final compactId = id.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
  final shortId = compactId.length > 8
      ? compactId.substring(compactId.length - 8)
      : compactId;
  return [if (name.isNotEmpty) name, source, shortId].join(' - ');
}
