import 'package:dio/dio.dart';
import 'package:openmusic/core/errors/failures/failure_platform_stub.dart'
    if (dart.library.io) 'package:openmusic/core/errors/failures/failure_platform_io.dart';
import 'package:openmusic/core/errors/failures/platform_failure_kind.dart';
import 'package:openmusic/core/utils/locale_keys.dart';
import 'package:sqlite3/common.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

sealed class Failure implements Exception {
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

class NotFoundFailure extends Failure {
  const NotFoundFailure(this.resource, [this.id]);

  final String resource;
  final Object? id;
}

class ConflictFailure extends Failure {
  const ConflictFailure(this.resource, [this.id]);

  final String resource;
  final Object? id;
}

class UnsupportedSourceFailure extends Failure {
  const UnsupportedSourceFailure(this.input);

  final String input;
}

class UnsupportedMediaFailure extends Failure {
  const UnsupportedMediaFailure(this.details);

  final String details;
}

class RemoteServiceFailure extends Failure {
  const RemoteServiceFailure(this.service, {this.statusCode});

  final String service;
  final int? statusCode;
}

class EmptyResultFailure extends Failure {
  const EmptyResultFailure(this.operation);

  final String operation;
}

class UnknownFailure extends Failure {
  const UnknownFailure(this.cause);
  final Object cause;
}

Failure failureFromException(Object e) {
  if (e is Failure) return e;
  if (e is DioException) return _failureFromDio(e);
  if (e is YoutubeExplodeException) return const YouTubeFailure();
  if (e is SqliteException) return const DbFailure();
  if (e is FormatException) return const ParseFailure();
  switch (platformFailureKind(e)) {
    case PlatformFailureKind.network:
      return const NetworkFailure();
    case PlatformFailureKind.fileNotFound:
      return const FileNotFoundFailure();
    case null:
      break;
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
    NotFoundFailure() => LocaleKeys.snackErrorLoad,
    ConflictFailure() => LocaleKeys.snackErrorGeneric,
    UnsupportedSourceFailure() => LocaleKeys.snackErrorLoad,
    UnsupportedMediaFailure() => LocaleKeys.snackErrorLoad,
    RemoteServiceFailure() => LocaleKeys.snackErrorNetwork,
    EmptyResultFailure() => LocaleKeys.snackErrorLoad,
    UnknownFailure() => LocaleKeys.errorUnknown,
  };
}
