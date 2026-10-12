import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:owlsonic/core/services/storage/free_space_probe.dart';
import 'package:owlsonic/core/utils/app_logger.dart';
import 'package:path/path.dart' as p;

/// Dio for downloading cloud audio and artwork from signed URLs.
///
/// [receiveTimeout] bounds both the wait for response headers and every gap
/// between received chunks (Dio 5), so a stalled connection fails and the
/// caller retries later instead of hanging a whole download pass. There is no
/// total-duration limit: large files on slow links still complete.
Dio cloudDownloadDio({
  Duration connectTimeout = const Duration(seconds: 15),
  Duration receiveTimeout = const Duration(seconds: 30),
}) => Dio(
  BaseOptions(connectTimeout: connectTimeout, receiveTimeout: receiveTimeout),
);

/// Fails a response body that delivers no data for [stall] and cancels its
/// request. Dio arms its own chunk watchdog only after the first chunk, so a
/// body that never starts (or a socket that silently dies) would otherwise
/// hang the download forever.
Stream<Uint8List> stallGuarded(
  Stream<Uint8List> body, {
  required Duration stall,
  CancelToken? cancel,
}) => body.timeout(
  stall,
  onTimeout: (sink) {
    cancel?.cancel('stalled');
    sink
      ..addError(TimeoutException('No audio data received for $stall', stall))
      ..close();
  },
);

/// Idle limit of a download made with [dio]: its receive timeout.
Duration stallTimeoutOf(Dio dio) =>
    dio.options.receiveTimeout ?? const Duration(seconds: 30);

/// Size-limited cache of streamed cloud tracks, used by the "stream" storage
/// mode: a track played over the network is downloaded once in the background
/// and the next playback reads it from disk. Least recently played tracks are
/// evicted first when the cache grows past [maxBytes].
///
/// Files live in the platform cache directory, so the OS may also purge them;
/// a missing entry simply streams again.
class CloudAudioCache {
  CloudAudioCache({
    required Future<Directory> Function() directory,
    required Future<Uri> Function(String trackId) playbackUrl,
    Dio? dio,
    FreeSpaceProbe? space,
    this.maxBytes = defaultMaxBytes,
    this.minFreeBytes = 500 * 1024 * 1024,
  }) : _space = space,
       _directoryProvider = directory,
       _playbackUrl = playbackUrl,
       _dio = dio ?? cloudDownloadDio();

  static const defaultMaxBytes = 1024 * 1024 * 1024; // 1 GB

  final Future<Directory> Function() _directoryProvider;
  final Future<Uri> Function(String trackId) _playbackUrl;
  final Dio _dio;
  final FreeSpaceProbe? _space;
  final int maxBytes;

  /// Caching is skipped while the device has less free space than this.
  final int minFreeBytes;

  Future<Directory>? _directory;
  Map<String, String>? _index; // file key -> absolute path
  final _inflight = <String, Future<void>>{};

  /// The cached file of [trackId], marking it as recently used, or null.
  Future<String?> lookup(String trackId) async {
    final key = _key(trackId);
    final entries = await _entries();
    final path = entries[key];
    if (path == null) return null;
    final file = File(path);
    if (!await file.exists()) {
      entries.remove(key);
      return null;
    }
    try {
      await file.setLastModified(DateTime.now());
    } catch (_) {
      // Only affects eviction order.
    }
    return path;
  }

  /// Whether [trackId] is in the cache index (no I/O; false until the index
  /// was loaded, e.g. by [warmUp]).
  bool hasCached(String trackId) => _index?.containsKey(_key(trackId)) ?? false;

  /// Loads the cache index from disk.
  Future<void> warmUp() => _entries();

  /// Downloads [trackId] into the cache in the background. Concurrent and
  /// repeated calls for the same track share one download.
  Future<void> cache(String trackId) {
    final key = _key(trackId);
    final running = _inflight[key];
    if (running != null) return running;
    final future = _download(trackId, key).whenComplete(() {
      // Block body: returning the removed future would await itself.
      _inflight.remove(key);
    });
    _inflight[key] = future;
    return future;
  }

  /// Moves an existing file (e.g. an offline copy the user no longer keeps)
  /// into the cache instead of deleting it.
  Future<void> adopt(String trackId, File file) async {
    final key = _key(trackId);
    final dir = await _dir();
    final target = File(p.join(dir.path, '$key${p.extension(file.path)}'));
    await _move(file, target);
    (await _entries())[key] = target.path;
    await _evict(keep: key);
  }

  /// Moves the cached file of [trackId] into [directory] (offline mode reuses
  /// it instead of downloading again). Returns the new path, or null.
  Future<String?> take(
    String trackId,
    String directory, {
    String? fileName,
  }) async {
    final key = _key(trackId);
    final entries = await _entries();
    final path = entries.remove(key);
    if (path == null || !await File(path).exists()) return null;
    final target = File(
      p.join(directory, '${fileName ?? key}${p.extension(path)}'),
    );
    await _move(File(path), target);
    return target.path;
  }

  Future<void> clear() async {
    final entries = await _entries();
    for (final path in entries.values) {
      try {
        await File(path).delete();
      } catch (_) {}
    }
    entries.clear();
  }

  Future<void> _download(String trackId, String key) async {
    final entries = await _entries();
    if (entries.containsKey(key)) return;
    final dir = await _dir();
    final free = await _space?.freeBytes(dir.path);
    if (free != null && free < minFreeBytes) return;
    final partial = File(p.join(dir.path, '$key.part'));
    try {
      final uri = await _playbackUrl(trackId);
      final cancel = CancelToken();
      final response = await _dio.getUri<ResponseBody>(
        uri,
        options: Options(responseType: ResponseType.stream),
        cancelToken: cancel,
      );
      final sink = partial.openWrite();
      try {
        await sink.addStream(
          stallGuarded(
            response.data!.stream,
            stall: stallTimeoutOf(_dio),
            cancel: cancel,
          ),
        );
        await sink.flush();
      } finally {
        await sink.close();
      }
      final extension = audioExtensionFor(
        response.headers.value(Headers.contentTypeHeader),
        uri.path,
      );
      final target = File(p.join(dir.path, '$key.$extension'));
      await partial.rename(target.path);
      entries[key] = target.path;
      await _evict(keep: key);
    } catch (error, stackTrace) {
      if (await partial.exists()) await partial.delete();
      await AppLogger.warning(
        'Could not cache a streamed cloud track.',
        operation: 'owlsonic.audio_cache',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _evict({required String keep}) async {
    final entries = await _entries();
    final files = <({String key, File file, int size, DateTime used})>[];
    var total = 0;
    for (final entry in entries.entries) {
      final file = File(entry.value);
      try {
        final stat = await file.stat();
        if (stat.type == FileSystemEntityType.notFound) continue;
        files.add((
          key: entry.key,
          file: file,
          size: stat.size,
          used: stat.modified,
        ));
        total += stat.size;
      } catch (_) {}
    }
    if (total <= maxBytes) return;
    files.sort((a, b) => a.used.compareTo(b.used));
    for (final entry in files) {
      if (total <= maxBytes) break;
      if (entry.key == keep) continue;
      try {
        await entry.file.delete();
        entries.remove(entry.key);
        total -= entry.size;
      } catch (_) {}
    }
  }

  Future<Directory> _dir() =>
      _directory ??= _directoryProvider().then((dir) async {
        await dir.create(recursive: true);
        return dir;
      });

  Future<Map<String, String>> _entries() async {
    final existing = _index;
    if (existing != null) return existing;
    final dir = await _dir();
    final index = <String, String>{};
    await for (final entity in dir.list()) {
      if (entity is! File) continue;
      if (entity.path.endsWith('.part')) {
        // Left over from an interrupted download.
        try {
          await entity.delete();
        } catch (_) {}
        continue;
      }
      index[p.basenameWithoutExtension(entity.path)] = entity.path;
    }
    return _index = index;
  }

  static Future<void> _move(File from, File to) async {
    if (await to.exists()) await to.delete();
    try {
      await from.rename(to.path);
    } on FileSystemException {
      // Different volume: rename is not possible.
      await from.copy(to.path);
      await from.delete();
    }
  }

  static String _key(String trackId) =>
      trackId.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
}

/// File extension for downloaded audio, from the response content type, then
/// the URL path; MP3 when neither says.
String audioExtensionFor(String? contentType, String urlPath) {
  final mime = contentType?.split(';').first.trim().toLowerCase();
  final fromMime = switch (mime) {
    'audio/mpeg' || 'audio/mp3' => 'mp3',
    'audio/mp4' || 'audio/x-m4a' || 'audio/m4a' => 'm4a',
    'audio/aac' || 'audio/aacp' => 'aac',
    'audio/flac' || 'audio/x-flac' => 'flac',
    'audio/ogg' || 'audio/opus' => 'ogg',
    'audio/wav' || 'audio/x-wav' || 'audio/wave' => 'wav',
    _ => null,
  };
  if (fromMime != null) return fromMime;
  final fromPath = p.extension(urlPath).replaceFirst('.', '').toLowerCase();
  const known = {
    'mp3',
    'm4a',
    'mp4',
    'aac',
    'flac',
    'ogg',
    'oga',
    'opus',
    'wav',
  };
  return known.contains(fromPath) ? fromPath : 'mp3';
}
