import 'dart:io';

import 'package:openmusic/core/errors/failures/platform_failure_kind.dart';

PlatformFailureKind? platformFailureKind(Object error) {
  if (error is SocketException || error is HttpException) {
    return PlatformFailureKind.network;
  }
  if (error is PathNotFoundException) {
    return PlatformFailureKind.fileNotFound;
  }
  if (error is FileSystemException) {
    final code = error.osError?.errorCode;
    if (code == 1 || code == 5 || code == 13) {
      return PlatformFailureKind.permission;
    }
    return PlatformFailureKind.storage;
  }
  return null;
}
