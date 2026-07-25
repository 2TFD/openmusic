import 'dart:io';

import 'package:dio/dio.dart';
import 'package:openmusic/core/utils/locale_keys.dart';

sealed class Failure {
  const Failure();
}

class NetworkFailure extends Failure {
  const NetworkFailure();
}

class FileNotFoundFailure extends Failure {
  const FileNotFoundFailure();
}

class TrackNotReadyFailure extends Failure {
  const TrackNotReadyFailure();
}

class YouTubeFailure extends Failure {
  const YouTubeFailure();
}

class ParseFailure extends Failure {
  const ParseFailure();
}

class DbFailure extends Failure {
  const DbFailure();
}

class UnknownFailure extends Failure {
  const UnknownFailure(this.cause);
  final Object cause;
}

Failure failureFromException(Object e) {
  if (e is Failure) return e;
  if (e is DioException) return _failureFromDio(e);
  if (e is SocketException || e is HttpException) return const NetworkFailure();
  if (e is FileSystemException) return const FileNotFoundFailure();
  if (e is FormatException) return const ParseFailure();
  final msg = e.toString().toLowerCase();
  if (msg.contains('youtube') || msg.contains('video unavailable')) {
    return const YouTubeFailure();
  }
  if (e.runtimeType.toString().toLowerCase().contains('sqlite') ||
      msg.contains('sqlite')) {
    return const DbFailure();
  }
  return UnknownFailure(e);
}

Failure _failureFromDio(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return const NetworkFailure();
    case DioExceptionType.badResponse:
      final code = e.response?.statusCode;
      if (code != null && code >= 500) return const NetworkFailure();
      return UnknownFailure(e);
    case DioExceptionType.cancel:
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      final inner = e.error;
      if (inner != null && inner is! DioException) {
        final mapped = failureFromException(inner);
        if (mapped is! UnknownFailure) return mapped;
      }
      return UnknownFailure(e);
  }
}

extension FailureLocaleKey on Failure {
  String toLocaleKey() => switch (this) {
    NetworkFailure() => LocaleKeys.errorNoInternet,
    FileNotFoundFailure() => LocaleKeys.errorFileNotFound,
    TrackNotReadyFailure() => LocaleKeys.snackDownloading,
    YouTubeFailure() => LocaleKeys.errorYoutube,
    ParseFailure() => LocaleKeys.snackErrorLoad,
    DbFailure() => LocaleKeys.snackErrorGeneric,
    UnknownFailure() => LocaleKeys.errorUnknown,
  };
}
