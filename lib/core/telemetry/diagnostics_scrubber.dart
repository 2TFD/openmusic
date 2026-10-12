/// Removes secrets and personal data from diagnostics text before it leaves
/// the device: signed URL query strings, bearer tokens / JWTs, e-mail
/// addresses and file paths (music file names carry titles and artists).
/// Backend request ids (`request_id=...`) are kept: support needs them.
String scrubDiagnostics(String input) {
  var text = input;
  // Signed playback/artwork URLs carry their credentials in the query.
  text = text.replaceAllMapped(
    RegExp(r'''(https?://[^\s?#"'<>]+)[?#][^\s"'<>]*'''),
    (m) => '${m[1]}?<redacted>',
  );
  text = text.replaceAll(
    RegExp(r'Bearer\s+[A-Za-z0-9._~+/=-]+'),
    'Bearer <redacted>',
  );
  text = text.replaceAll(
    RegExp(r'eyJ[A-Za-z0-9_-]{5,}\.[A-Za-z0-9_-]{5,}\.[A-Za-z0-9_-]*'),
    '<jwt>',
  );
  text = text.replaceAll(
    RegExp(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+'),
    '<email>',
  );
  // Absolute POSIX paths (not URL paths) and Windows paths; the extension is
  // kept because it helps diagnose codec problems.
  String path(Match m) {
    final value = m[0]!;
    final dot = value.lastIndexOf('.');
    final slash = value.lastIndexOf(RegExp(r'[/\\]'));
    final ext = dot > slash && value.length - dot <= 6
        ? value.substring(dot)
        : '';
    return '<path>$ext';
  }

  text = text.replaceAllMapped(
    RegExp(r'''(?<![\w:/.])/(?:[^\s'"/<>]+/)+[^\s'"/<>]+'''),
    path,
  );
  text = text.replaceAllMapped(
    RegExp(r'''[A-Za-z]:\\(?:[^\s'"\\<>]+\\)*[^\s'"\\<>]+'''),
    path,
  );
  return text;
}
