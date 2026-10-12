import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:owlsonic/core/services/audio_metadata/audio_metadata_writer.dart';
import 'package:owlsonic/core/services/cloud/cloud_audio_cache.dart';
import 'package:owlsonic/core/services/cloud/device_storage_mode_store.dart';
import 'package:owlsonic/core/services/storage/free_space_probe.dart';
import 'package:owlsonic/core/utils/app_logger.dart';
import 'package:owlsonic/core/utils/audio_file_name.dart';
import 'package:owlsonic/layers/data/repositories/cloud_local_store.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/domain/repositories/track_repository.dart';
import 'package:path/path.dart' as p;

enum OfflinePhase {
  /// Stream mode, or nothing has run yet.
  idle,
  downloading,

  /// Every cloud track has audio on this device.
  complete,

  /// Stopped to keep [CloudOfflineLibrary.minFreeBytes] free on the device.
  lowSpace,

  /// Stopped after repeated failures (offline, server trouble); the next sync
  /// continues.
  interrupted,
}

@immutable
class OfflineProgress {
  const OfflineProgress({
    this.phase = OfflinePhase.idle,
    this.total = 0,
    this.onDevice = 0,
    this.freeBytes,
    this.neededBytes,
  });

  final OfflinePhase phase;

  /// Cloud tracks in the library / of them playable without a connection.
  final int total;
  final int onDevice;

  /// Set with [OfflinePhase.lowSpace] when the platform reports them.
  final int? freeBytes;
  final int? neededBytes;

  double get fraction => total == 0 ? 1 : onDevice / total;
}

class _NotEnoughSpace implements Exception {
  const _NotEnoughSpace({this.free, this.needed});
  final int? free;
  final int? needed;
}

/// The "offline" storage mode: keeps a copy of every cloud track on this
/// device, with title/artist/album/cover written into the file, so the
/// library plays without a connection.
///
/// - [run] downloads what is missing (after each sync and when the mode is
///   switched on). Tracks already in the stream cache are moved, not fetched.
/// - Switching back to "stream" moves the copies into the size-limited cache
///   instead of deleting them.
/// - Copies whose track left the library (deleted, signed out) are removed.
///
/// Work is serialized; switching modes cancels the download in flight.
class CloudOfflineLibrary {
  CloudOfflineLibrary({
    required CloudLocalStore store,
    required TrackRepository tracks,
    required DeviceStorageModeStore mode,
    required bool Function() isEnabled,
    required Future<Uri> Function(String trackId) playbackUrl,
    required Future<Uri> Function(String trackId) artworkUrl,
    required CloudAudioCache cache,
    required String appDir,
    AudioMetadataWriter metadata = const FfmpegAudioMetadataWriter(),
    FreeSpaceProbe space = const PlatformFreeSpaceProbe(),
    Dio? dio,
  }) : _store = store,
       _space = space,
       _tracks = tracks,
       _mode = mode,
       _isEnabled = isEnabled,
       _playbackUrl = playbackUrl,
       _artworkUrl = artworkUrl,
       _cache = cache,
       _appDir = appDir,
       _metadata = metadata,
       _dio = dio ?? cloudDownloadDio();

  final CloudLocalStore _store;
  final TrackRepository _tracks;
  final DeviceStorageModeStore _mode;
  final bool Function() _isEnabled;
  final Future<Uri> Function(String trackId) _playbackUrl;
  final Future<Uri> Function(String trackId) _artworkUrl;
  final CloudAudioCache _cache;
  final String _appDir;
  final AudioMetadataWriter _metadata;
  final FreeSpaceProbe _space;
  final Dio _dio;

  /// Space always left free on the device, so offline music never fills it.
  static const minFreeBytes = 500 * 1024 * 1024;

  /// What the account screen shows under the offline mode.
  final progress = ValueNotifier<OfflineProgress>(const OfflineProgress());

  /// Consecutive failures that end a pass (offline, server trouble); the next
  /// sync starts a new one.
  static const _maxConsecutiveFailures = 3;

  Future<void> _serial = Future.value();
  int _generation = 0;
  CancelToken? _cancel;

  Directory get _folder =>
      Directory(p.join(_appDir, CloudLocalStore.offlineFolder));

  /// Downloads missing cloud tracks while the mode is "offline".
  Future<void> run() => _enqueue(_download);

  /// Reacts to the user's choice: downloads for "offline", hands the copies
  /// to the cache for "stream".
  Future<void> onModeChanged(DeviceStorageMode mode) {
    _generation++;
    _cancel?.cancel();
    return mode == DeviceStorageMode.offline
        ? run()
        : _enqueue(_releaseToCache);
  }

  /// The account left this device (sign-out or another account): stops any
  /// download and deletes every managed copy, which no track references now.
  Future<void> onSignedOut() {
    _generation++;
    _cancel?.cancel();
    return _enqueue((_) async {
      await _sweep();
      await _report(OfflinePhase.idle);
    });
  }

  /// True when [track] is a cloud track whose audio is an OwlSonic-managed
  /// copy (not a local original that was uploaded).
  static bool hasManagedCopy(Track track) =>
      track.isCloudTrack &&
      (track.filePath?.startsWith('${CloudLocalStore.offlineFolder}/') ??
          false);

  /// "Download to this device" for one cloud track, in any storage mode.
  /// Throws when the download fails so the caller can tell the user.
  Future<void> downloadTrack(String trackId) {
    final done = _serial.then((_) async {
      final track = (await _tracks.getTracksByIds([trackId])).firstOrNull;
      if (track == null || !track.isCloudTrack || track.filePath != null) {
        return;
      }
      await _folder.create(recursive: true);
      final free = await _space.freeBytes(_folder.path);
      if (free != null && free < minFreeBytes) {
        throw _NotEnoughSpace(free: free, needed: minFreeBytes);
      }
      await _downloadTrack(track);
      await _report(progress.value.phase);
    });
    _serial = done.then<void>((_) {}, onError: (_) {});
    return done;
  }

  /// Deletes this device's managed copy of one cloud track. The track stays
  /// in the library and streams again. Local originals are never touched.
  Future<void> removeDownload(String trackId) {
    final done = _serial.then((_) async {
      final relative = (await _store.managedOfflineAudio())[trackId];
      if (relative == null) return;
      await _store.detachOfflineAudio(trackId);
      final file = File(p.join(_appDir, relative));
      if (await file.exists()) await file.delete();
      await _report(progress.value.phase);
    });
    _serial = done.then<void>((_) {}, onError: (_) {});
    return done;
  }

  Future<void> _enqueue(Future<void> Function(int generation) work) {
    final generation = _generation;
    final next = _serial.then((_) async {
      try {
        await work(generation);
      } catch (error, stackTrace) {
        await AppLogger.warning(
          'Offline library pass failed.',
          operation: 'owlsonic.offline',
          error: error,
          stackTrace: stackTrace,
        );
      }
    });
    _serial = next;
    return next;
  }

  bool _active(int generation) =>
      generation == _generation &&
      _isEnabled() &&
      _mode.effective == DeviceStorageMode.offline;

  Future<void> _download(int generation) async {
    if (_mode.current.value == null) await _mode.load();
    await _sweep();
    await _renameToReadable();
    if (!_active(generation)) {
      await _report(OfflinePhase.idle);
      return;
    }

    final ids = await _store.cloudTracksWithoutAudio();
    if (ids.isEmpty) {
      await _report(OfflinePhase.complete);
      return;
    }
    await _folder.create(recursive: true);
    final free = await _space.freeBytes(_folder.path);
    if (free != null && free < minFreeBytes) {
      await _report(
        OfflinePhase.lowSpace,
        freeBytes: free,
        neededBytes: minFreeBytes,
      );
      return;
    }
    await _report(OfflinePhase.downloading);

    final tracks = {
      for (final track in await _tracks.getTracksByIds(ids)) track.id: track,
    };
    var failures = 0;
    for (final id in ids) {
      if (!_active(generation)) {
        await _report(
          _mode.effective == DeviceStorageMode.offline
              ? OfflinePhase.interrupted
              : OfflinePhase.idle,
        );
        return;
      }
      final track = tracks[id];
      if (track == null) continue;
      try {
        await _downloadTrack(track);
        failures = 0;
        await _report(OfflinePhase.downloading);
      } on _NotEnoughSpace catch (space) {
        await _report(
          OfflinePhase.lowSpace,
          freeBytes: space.free,
          neededBytes: space.needed,
        );
        return;
      } catch (error, stackTrace) {
        if (error is DioException && error.type == DioExceptionType.cancel) {
          return;
        }
        if (isOutOfSpace(error)) {
          await _report(
            OfflinePhase.lowSpace,
            freeBytes: await _space.freeBytes(_folder.path),
          );
          return;
        }
        await AppLogger.warning(
          'Offline download failed for $id.',
          operation: 'owlsonic.offline.download',
          error: error,
          stackTrace: stackTrace,
        );
        if (++failures >= _maxConsecutiveFailures) {
          await _report(OfflinePhase.interrupted);
          return;
        }
      }
    }
    final counts = await _store.cloudAudioCounts();
    await _report(
      counts.onDevice >= counts.total
          ? OfflinePhase.complete
          : OfflinePhase.interrupted,
    );
  }

  Future<void> _report(
    OfflinePhase phase, {
    int? freeBytes,
    int? neededBytes,
  }) async {
    final counts = await _store.cloudAudioCounts();
    progress.value = OfflineProgress(
      phase: phase,
      total: counts.total,
      onDevice: counts.onDevice,
      freeBytes: freeBytes,
      neededBytes: neededBytes,
    );
  }

  /// Streams [uri] into [partial] after checking the announced size against
  /// the free space; returns the response content type.
  Future<String?> _fetch(Uri uri, File partial, CancelToken cancel) async {
    final response = await _dio.getUri<ResponseBody>(
      uri,
      options: Options(responseType: ResponseType.stream),
      cancelToken: cancel,
    );
    final length = int.tryParse(
      response.headers.value(Headers.contentLengthHeader) ?? '',
    );
    if (length != null) {
      final free = await _space.freeBytes(_folder.path);
      if (free != null && free - length < minFreeBytes) {
        cancel.cancel();
        throw _NotEnoughSpace(free: free, needed: length + minFreeBytes);
      }
    }
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
    return response.headers.value(Headers.contentTypeHeader);
  }

  Future<void> _downloadTrack(Track track) async {
    final key = _safe(track.id);
    final name = fileBaseFor(track);
    var path = await _cache.take(track.id, _folder.path, fileName: name);
    if (path == null) {
      final partial = File(p.join(_folder.path, '$key.part'));
      final uri = await _playbackUrl(track.id);
      final cancel = _cancel = CancelToken();
      try {
        final extension = audioExtensionFor(
          await _fetch(uri, partial, cancel),
          uri.path,
        );
        path = p.join(_folder.path, '$name.$extension');
        await partial.rename(path);
      } finally {
        if (identical(_cancel, cancel)) _cancel = null;
        if (await partial.exists()) await partial.delete();
      }
    }

    final cover = await _coverFile(track, key);
    try {
      await _metadata.write(
        path,
        AudioMetadata(
          title: track.title,
          artist: track.artists.isEmpty
              ? null
              : track.artists.map((artist) => artist.name).join(', '),
          album: track.album,
          coverPath: cover?.path,
        ),
      );
    } finally {
      if (cover != null && p.isWithin(_folder.path, cover.path)) {
        if (await cover.exists()) await cover.delete();
      }
    }

    final relative = p.relative(path, from: _appDir);
    if (!await _store.attachOfflineAudio(track.id, relative)) {
      // The track left the library or got a file meanwhile.
      await File(path).delete();
    }
  }

  /// A local image for the cover: the track's own file, or a temporary
  /// download of its http / cloud artwork. Null when there is none.
  Future<File?> _coverFile(Track track, String key) async {
    final value = track.imageUrl;
    if (value == null || value.isEmpty) return null;
    try {
      final Uri uri;
      if (cloudArtworkTrackId(value) case final cloudId?) {
        uri = await _artworkUrl(cloudId);
      } else if (value.startsWith(RegExp(r'https?://'))) {
        uri = Uri.parse(value);
      } else {
        final file = File(value);
        return await file.exists() ? file : null;
      }
      final response = await _dio.getUri<List<int>>(
        uri,
        options: Options(responseType: ResponseType.bytes),
      );
      final mime = response.headers.value(Headers.contentTypeHeader);
      final bytes = response.data;
      if (bytes == null ||
          bytes.isEmpty ||
          mime == null ||
          !mime.toLowerCase().startsWith('image/')) {
        return null;
      }
      final file = File(p.join(_folder.path, '.cover_$key'));
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } catch (_) {
      return null; // a cover is optional
    }
  }

  Future<void> _releaseToCache(int generation) async {
    final copies = await _store.managedOfflineAudio();
    for (final entry in copies.entries) {
      if (generation != _generation) return;
      await _store.detachOfflineAudio(entry.key);
      final file = File(p.join(_appDir, entry.value));
      if (await file.exists()) await _cache.adopt(entry.key, file);
    }
    await _report(OfflinePhase.idle);
  }

  static String fileBaseFor(Track track) => audioFileBase(
    artist: track.artists.map((a) => a.name).join(', '),
    title: track.title,
    source: 'owlsonic',
    id: track.id,
  );

  /// Copies downloaded before readable names (or after a rename of the track)
  /// get the current name.
  Future<void> _renameToReadable() async {
    final copies = await _store.managedOfflineAudio();
    if (copies.isEmpty) return;
    final tracks = {
      for (final track in await _tracks.getTracksByIds(copies.keys.toList()))
        track.id: track,
    };
    for (final MapEntry(key: id, value: relative) in copies.entries) {
      final track = tracks[id];
      if (track == null) continue;
      final current = File(p.join(_appDir, relative));
      final wanted = '${fileBaseFor(track)}${p.extension(relative)}';
      if (p.basename(relative) == wanted || !await current.exists()) continue;
      final target = File(p.join(_folder.path, wanted));
      if (await target.exists()) continue;
      try {
        await current.rename(target.path);
        final moved = await _store.renameOfflineAudio(
          id,
          from: relative,
          to: p.relative(target.path, from: _appDir),
        );
        if (!moved) await target.rename(current.path);
      } catch (_) {
        // Keeps the old name; playback is unaffected.
      }
    }
  }

  /// Deletes managed copies no track points at any more, and leftovers of
  /// interrupted downloads.
  Future<void> _sweep() async {
    if (!await _folder.exists()) return;
    final referenced = {
      for (final relative in (await _store.managedOfflineAudio()).values)
        p.normalize(p.join(_appDir, relative)),
    };
    await for (final entity in _folder.list()) {
      if (entity is! File) continue;
      if (referenced.contains(p.normalize(entity.path))) continue;
      try {
        await entity.delete();
      } catch (_) {}
    }
  }

  static String _safe(String value) =>
      value.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
}
