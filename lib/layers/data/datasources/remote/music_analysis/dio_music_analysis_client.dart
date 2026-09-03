import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;

import '../../../../../core/network/retry_policy.dart';
import '../../../../../core/services/music_analysis/music_analysis_config.dart';
import '../../../../domain/entities/music_analysis.dart';
import '../../../../domain/entities/music_analysis_failure.dart';
import '../../../../domain/repositories/music_analysis_client.dart';
import 'music_analysis_api_parser.dart';

class DioMusicAnalysisClient implements MusicAnalysisClient {
  DioMusicAnalysisClient({
    required MusicAnalysisConfig config,
    required this.appDirectory,
    Dio? dio,
    RetryPolicy? retryPolicy,
    MusicAnalysisApiParser parser = const MusicAnalysisApiParser(),
  }) : _config = config,
       _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 15),
               sendTimeout: const Duration(minutes: 5),
               receiveTimeout: const Duration(minutes: 5),
             ),
           ),
       _retryPolicy = retryPolicy ?? RetryPolicy(maxAttempts: 2),
       _parser = parser;

  final MusicAnalysisConfig _config;
  final String appDirectory;
  final Dio _dio;
  final RetryPolicy _retryPolicy;
  final MusicAnalysisApiParser _parser;

  @override
  String get baseUrl => _config.baseUrl;

  @override
  Future<MusicAnalysisModels> getModels() async {
    try {
      final response = await _retryPolicy.execute(
        () => _dio.get<dynamic>('$baseUrl/v1/models'),
      );
      _validateStatus(response.statusCode);
      return _parser.parseModels(response.data);
    } on MusicAnalysisFailure {
      rethrow;
    } on DioException catch (error) {
      throw _fromDio(error);
    } catch (error) {
      throw MusicAnalysisFailure(
        MusicAnalysisFailureKind.invalidRepresentation,
        details: error.runtimeType.toString(),
      );
    }
  }

  @override
  Future<MusicAnalysisResponse> analyze({
    required String trackId,
    required String filePath,
    String? contentIdentity,
    String? lyrics,
    required Set<MusicAnalysisRepresentation> requestedRepresentations,
  }) async {
    final file = File(
      path.isAbsolute(filePath) ? filePath : path.join(appDirectory, filePath),
    );
    if (!await file.exists()) {
      throw const MusicAnalysisFailure(MusicAnalysisFailureKind.fileNotFound);
    }
    if (requestedRepresentations.isEmpty) {
      throw const MusicAnalysisFailure(
        MusicAnalysisFailureKind.invalidRepresentation,
        details: 'No representations requested',
      );
    }
    final requestsLyrics = requestedRepresentations.contains(
      MusicAnalysisRepresentation.lyricsGlobal,
    );
    if (requestsLyrics && (lyrics == null || lyrics.trim().isEmpty)) {
      throw const MusicAnalysisFailure(
        MusicAnalysisFailureKind.invalidRepresentation,
        details: 'lyrics.global requires non-empty lyrics',
      );
    }
    try {
      final response = await _retryPolicy.execute(
        () async => _dio.post<dynamic>(
          '$baseUrl/v1/tracks/analyze',
          data: FormData.fromMap({
            'audio': await MultipartFile.fromFile(
              file.path,
              filename: path.basename(file.path),
            ),
            'track_id': trackId,
            'content_identity': ?contentIdentity,
            if (requestsLyrics) 'lyrics': lyrics,
            'requested_representations': requestedRepresentations
                .map((entry) => entry.apiName)
                .toList(growable: false),
          }, ListFormat.multi),
        ),
      );
      _validateStatus(response.statusCode);
      return _parser.parseAnalysis(response.data);
    } on MusicAnalysisFailure {
      rethrow;
    } on DioException catch (error) {
      throw _fromDio(error);
    } on FileSystemException {
      throw const MusicAnalysisFailure(MusicAnalysisFailureKind.fileNotFound);
    } catch (error) {
      throw MusicAnalysisFailure(
        MusicAnalysisFailureKind.invalidRepresentation,
        details: error.runtimeType.toString(),
      );
    }
  }

  static void _validateStatus(int? statusCode) {
    if (statusCode == 200) return;
    if ((statusCode ?? 0) >= 500 || statusCode == 429) {
      throw MusicAnalysisFailure(
        MusicAnalysisFailureKind.server,
        details: 'HTTP $statusCode',
        retryable: true,
      );
    }
    if (statusCode == 422) {
      throw const MusicAnalysisFailure(MusicAnalysisFailureKind.decode);
    }
    throw MusicAnalysisFailure(
      MusicAnalysisFailureKind.server,
      details: 'HTTP $statusCode',
    );
  }

  static MusicAnalysisFailure _fromDio(DioException error) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 422) {
      return const MusicAnalysisFailure(MusicAnalysisFailureKind.decode);
    }
    if (statusCode == 429 || (statusCode ?? 0) >= 500) {
      return MusicAnalysisFailure(
        MusicAnalysisFailureKind.server,
        details: 'HTTP $statusCode',
        retryable: true,
      );
    }
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError => const MusicAnalysisFailure(
        MusicAnalysisFailureKind.network,
        retryable: true,
      ),
      _ => MusicAnalysisFailure(
        MusicAnalysisFailureKind.server,
        details: 'HTTP $statusCode',
      ),
    };
  }
}
