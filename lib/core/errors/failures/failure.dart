import 'dart:io';

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
  if (e is SocketException || e is HttpException) return const NetworkFailure();
  if (e is FileSystemException) return const FileNotFoundFailure();
  if (e is FormatException) return const ParseFailure();
  final msg = e.toString().toLowerCase();
  if (msg.contains('youtube') || msg.contains('video unavailable')) {
    return const YouTubeFailure();
  }
  if (msg.contains('database') || msg.contains('sqlite'))
    return const DbFailure();
  return UnknownFailure(e);
}

extension FailureLocaleKey on Failure {
  String toLocaleKey() => switch (this) {
    NetworkFailure() => LocaleKeys.errorNoInternet,
    FileNotFoundFailure() => LocaleKeys.errorFileNotFound,
    YouTubeFailure() => LocaleKeys.errorYoutube,
    ParseFailure() => LocaleKeys.snackErrorLoad,
    DbFailure() => LocaleKeys.snackErrorGeneric,
    UnknownFailure() => LocaleKeys.errorUnknown,
  };
}
