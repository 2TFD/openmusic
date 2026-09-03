import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

import '../../../domain/entities/track_lyrics.dart';
import '../../../domain/repositories/lyrics_provider.dart';
import '../../../domain/services/lrc_parser.dart';

abstract interface class SidecarLyricsFileSystem {
  Future<bool> exists(String filePath);

  Future<String> readUtf8(String filePath);
}

class IoSidecarLyricsFileSystem implements SidecarLyricsFileSystem {
  const IoSidecarLyricsFileSystem();

  @override
  Future<bool> exists(String filePath) => File(filePath).exists();

  @override
  Future<String> readUtf8(String filePath) =>
      File(filePath).readAsString(encoding: utf8);
}

class SidecarLrcLyricsProvider implements LyricsProvider {
  const SidecarLrcLyricsProvider({
    SidecarLyricsFileSystem fileSystem = const IoSidecarLyricsFileSystem(),
    LrcParser parser = const LrcParser(),
    this.appDirectory,
  }) : _fileSystem = fileSystem,
       _parser = parser;

  final SidecarLyricsFileSystem _fileSystem;
  final LrcParser _parser;
  final String? appDirectory;

  @override
  LyricsSource get source => LyricsSource.sidecarLrc;

  @override
  Future<LyricsProviderResult> resolve(LyricsRequest request) async {
    LrcParseFailure? lastParseFailure;
    Object? lastReadFailure;
    for (final candidate in _candidatePaths(request)) {
      try {
        if (!await _fileSystem.exists(candidate)) continue;
        final parsed = _parser.parse(await _fileSystem.readUtf8(candidate));
        switch (parsed) {
          case LrcParseSuccess():
            return LyricsProviderFound(
              plainText: parsed.plainText,
              syncedText: parsed.syncedText,
              language: _language(parsed.metadata),
              sourceId: path.basename(candidate),
              matchConfidence: 1,
              matchedTitle: request.title,
              matchedArtist: request.artists.join(', '),
              matchedDurationMs: request.duration?.inMilliseconds,
            );
          case LrcParseFailure():
            lastParseFailure = parsed;
        }
      } catch (error) {
        lastReadFailure = error;
      }
    }

    if (lastReadFailure != null) {
      return LyricsProviderPermanentFailure(
        code: 'sidecar_read_failed',
        details: lastReadFailure.runtimeType.toString(),
      );
    }
    if (lastParseFailure != null) {
      return LyricsProviderPermanentFailure(
        code: 'sidecar_lrc_invalid',
        details: lastParseFailure.reason,
      );
    }
    return const LyricsProviderNotFound(details: 'No adjacent LRC file');
  }

  Iterable<String> _candidatePaths(LyricsRequest request) sync* {
    final seen = <String>{};
    for (final audioPath in [
      _absoluteOriginalPath(request.originalFilePath),
      _absoluteCurrentPath(request.filePath),
    ]) {
      if (audioPath == null) continue;
      final withoutExtension = path.withoutExtension(audioPath);
      for (final extension in const ['.lrc', '.LRC']) {
        final candidate = '$withoutExtension$extension';
        if (seen.add(candidate)) yield candidate;
      }
    }
  }

  static String? _absoluteOriginalPath(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme && uri.scheme != 'file') return null;
    final filePath = uri?.scheme == 'file' ? uri!.toFilePath() : value;
    return path.isAbsolute(filePath) ? path.normalize(filePath) : null;
  }

  String? _absoluteCurrentPath(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (path.isAbsolute(value)) return path.normalize(value);
    final root = appDirectory;
    return root == null ? null : path.normalize(path.join(root, value));
  }

  static String? _language(Map<String, String> metadata) {
    for (final key in const ['language', 'lang', 'la']) {
      final value = metadata[key];
      if (value != null && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }
}
