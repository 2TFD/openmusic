import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/core/services/download/download_failure_classifier.dart';
import 'package:openmusic/layers/domain/entities/download_track_task.dart';

void main() {
  test('classifies network failures for user-facing copy', () {
    final failure = DownloadFailureClassifier.classify(
      const SocketException('offline'),
      StackTrace.current,
      trackId: 'track-1',
      originalUrl: 'https://example.com/track',
      failedAt: DateTime.utc(2026, 8, 18),
    );

    expect(failure.code, DownloadFailureCodes.network);
    expect(failure.message, 'SocketException: offline');
    expect(failure.details, contains('trackId: track-1'));
    expect(failure.details, contains('originalUrl: https://example.com/track'));
  });

  test('classifies rate limits separately from generic source failures', () {
    final failure = DownloadFailureClassifier.classify(
      DioException(
        requestOptions: RequestOptions(path: '/download'),
        response: Response(
          requestOptions: RequestOptions(path: '/download'),
          statusCode: 429,
        ),
        type: DioExceptionType.badResponse,
      ),
      StackTrace.current,
      trackId: 'track-2',
      originalUrl: 'https://example.com/track',
    );

    expect(failure.code, DownloadFailureCodes.rateLimited);
  });

  test('classifies file permission failures', () {
    final failure = DownloadFailureClassifier.classify(
      const FileSystemException(
        'Permission denied',
        '/music/track.mp3',
        OSError('Permission denied', 13),
      ),
      StackTrace.current,
      trackId: 'track-3',
      originalUrl: '/music/track.mp3',
    );

    expect(failure.code, DownloadFailureCodes.filePermission);
  });
}
