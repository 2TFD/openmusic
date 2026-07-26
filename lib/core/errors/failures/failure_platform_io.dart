import 'dart:io';

import 'package:openmusic/core/errors/failures/platform_failure_kind.dart';

PlatformFailureKind? platformFailureKind(Object error) {
  if (error is SocketException || error is HttpException) {
    return PlatformFailureKind.network;
  }
  if (error is FileSystemException) {
    return PlatformFailureKind.fileNotFound;
  }
  return null;
}
