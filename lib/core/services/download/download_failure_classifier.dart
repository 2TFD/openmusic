import 'dart:io';

import 'package:dio/dio.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/layers/domain/entities/download_track_task.dart';

class DownloadFailureClassifier {
  const DownloadFailureClassifier._();

  static DownloadFailureInfo classify(
    Object error,
    StackTrace stackTrace, {
    required String trackId,
    required String originalUrl,
    DateTime? failedAt,
  }) {
    final code = _codeFor(error);
    final message = _messageFor(error, code);
    final details = _limit(
      [
        'trackId: $trackId',
        'originalUrl: $originalUrl',
        'code: $code',
        'errorType: ${error.runtimeType}',
        'error: $error',
        'stackTrace:',
        stackTrace.toString(),
      ].join('\n'),
      8000,
    );
    return DownloadFailureInfo(
      code: code,
      message: message,
      details: details,
      failedAt: failedAt ?? DateTime.now(),
    );
  }

  static String _codeFor(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 429) return DownloadFailureCodes.rateLimited;
      if (statusCode != null && statusCode >= 400 && statusCode < 500) {
        return DownloadFailureCodes.sourceUnavailable;
      }
    }

    if (error is FileSystemException) {
      final code = error.osError?.errorCode;
      final message = error.message.toLowerCase();
      if (code == 2) return DownloadFailureCodes.fileNotFound;
      if (code == 13 || message.contains('permission')) {
        return DownloadFailureCodes.filePermission;
      }
      return DownloadFailureCodes.fileSystem;
    }

    final failure = failureFromException(error);
    return switch (failure) {
      NetworkFailure() => DownloadFailureCodes.network,
      FileNotFoundFailure() => DownloadFailureCodes.fileNotFound,
      PermissionFailure() => DownloadFailureCodes.filePermission,
      StorageFailure() => DownloadFailureCodes.fileSystem,
      RateLimitFailure() => DownloadFailureCodes.rateLimited,
      UnsupportedSourceFailure() ||
      UnsupportedMediaFailure() => DownloadFailureCodes.unsupported,
      RemoteServiceFailure(:final statusCode) when statusCode == 429 =>
        DownloadFailureCodes.rateLimited,
      RemoteServiceFailure() ||
      RemoteAccessFailure() ||
      EmptyResultFailure() ||
      ValidationFailure() ||
      YouTubeFailure() ||
      ParseFailure() => DownloadFailureCodes.sourceUnavailable,
      DbFailure() => DownloadFailureCodes.fileSystem,
      NotFoundFailure() ||
      ConflictFailure() ||
      TrackNotReadyFailure() ||
      UnknownFailure() => DownloadFailureCodes.unknown,
    };
  }

  static String _messageFor(Object error, String code) {
    final fallback = switch (code) {
      DownloadFailureCodes.network => 'Network request failed',
      DownloadFailureCodes.sourceUnavailable => 'Source is unavailable',
      DownloadFailureCodes.rateLimited => 'Source rate limit reached',
      DownloadFailureCodes.fileNotFound => 'Source file was not found',
      DownloadFailureCodes.filePermission => 'File permission denied',
      DownloadFailureCodes.fileSystem => 'File system error',
      DownloadFailureCodes.unsupported => 'Unsupported media',
      _ => 'Unknown download error',
    };
    if (error is Failure) return fallback;
    return _limit(_singleLine(error.toString()), 500);
  }

  static String _singleLine(String value) =>
      value.replaceAll(RegExp(r'\s+'), ' ').trim();

  static String _limit(String value, int maxLength) {
    if (value.length <= maxLength) return value;
    return '${value.substring(0, maxLength)}...';
  }
}
