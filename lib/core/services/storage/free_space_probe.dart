import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

/// Free space of the volume that holds a path.
abstract interface class FreeSpaceProbe {
  /// Bytes available, or null where the platform cannot tell (Windows/Linux):
  /// callers then rely on [isOutOfSpace] while writing.
  Future<int?> freeBytes(String path);
}

/// `owlsonic/storage` platform channel (iOS, macOS, Android).
class PlatformFreeSpaceProbe implements FreeSpaceProbe {
  const PlatformFreeSpaceProbe();

  static const _channel = MethodChannel('owlsonic/storage');

  @override
  Future<int?> freeBytes(String path) async {
    try {
      final value = await _channel.invokeMethod<Object?>('freeBytes', {
        'path': path,
      });
      return value is int ? value : null;
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }
}

/// True for "no space left on device" (ENOSPC on POSIX, ERROR_DISK_FULL /
/// ERROR_HANDLE_DISK_FULL on Windows), wherever it surfaced.
bool isOutOfSpace(Object error) {
  if (error is DioException && error.error != null) {
    return isOutOfSpace(error.error!);
  }
  final os = switch (error) {
    FileSystemException(:final osError) => osError,
    OSError() => error,
    _ => null,
  };
  final code = os?.errorCode;
  if (code == null) return false;
  return Platform.isWindows ? code == 112 || code == 39 : code == 28;
}
