import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/core/errors/failures/failure.dart';
import 'package:owlsonic/core/services/download/download_failure_classifier.dart';
import 'package:owlsonic/layers/domain/entities/download_track_task.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

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

  test('YouTube bot check gets its own code, not "source unavailable"', () {
    DownloadFailureInfo classify(Object error) =>
        DownloadFailureClassifier.classify(
          error,
          StackTrace.current,
          trackId: 'track-3',
          originalUrl: 'https://www.youtube.com/watch?v=x',
        );

    expect(
      classify(const YouTubeFailure(botCheck: true)).code,
      DownloadFailureCodes.botCheck,
    );
    expect(
      classify(
        VideoUnplayableException.unplayable(
          VideoId('dQw4w9WgXcQ'),
          reason: 'Sign in to confirm you’re not a bot',
        ),
      ).code,
      DownloadFailureCodes.botCheck,
    );
    expect(
      classify(
        VideoUnavailableException.unavailable(VideoId('dQw4w9WgXcQ')),
      ).code,
      DownloadFailureCodes.sourceUnavailable,
    );
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
