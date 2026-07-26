import 'package:dio/dio.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/core/network/retry_policy.dart';
import 'package:openmusic/core/utils/app_logger.dart';
import 'package:openmusic/layers/domain/entities/operation_cancellation.dart';
import 'package:path_provider/path_provider.dart';

class EmbeddingEngine {
  EmbeddingEngine({
    Dio? dio,
    RetryPolicy? retryPolicy,
    this.endpoint =
        'https://kxmwebwe-trackembeddingapi.hf.space/embedding/smart',
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 15),
               receiveTimeout: const Duration(minutes: 2),
               sendTimeout: const Duration(minutes: 2),
             ),
           ),
       _retryPolicy = retryPolicy ?? RetryPolicy(maxAttempts: 2);

  final Dio _dio;
  final RetryPolicy _retryPolicy;
  final String endpoint;

  Future<List<double>> compute(
    String filePath, {
    OperationCancellation? cancellation,
  }) async {
    try {
      cancellation?.throwIfCancelled();
      final dir = await getApplicationDocumentsDirectory();
      final cancelToken = CancelToken();
      cancellation?.whenCancelled.then((_) {
        if (!cancelToken.isCancelled) cancelToken.cancel();
      });

      final response = await _retryPolicy.execute(
        () async => _dio.post(
          endpoint,
          data: FormData.fromMap({
            'file': await MultipartFile.fromFile(
              '${dir.path}/$filePath',
              filename: filePath,
            ),
          }),
          cancelToken: cancelToken,
        ),
      );
      cancellation?.throwIfCancelled();

      if (response.statusCode != 200) {
        throw RemoteServiceFailure(
          'embedding',
          statusCode: response.statusCode,
        );
      }

      final data = response.data;
      if (data is! Map || data['embedding'] is! List) {
        throw const ParseFailure();
      }

      final rawEmbedding = data['embedding'] as List;
      if (rawEmbedding.isEmpty) throw const ParseFailure();

      final embedding = <double>[];
      for (final value in rawEmbedding) {
        if (value is! num) throw const ParseFailure();
        final component = value.toDouble();
        if (!component.isFinite) throw const ParseFailure();
        embedding.add(component);
      }
      return embedding;
    } on DioException catch (e) {
      await AppLogger.log(
        '[EmbeddingEngine.compute] DioException: statusCode=${e.response?.statusCode}, data=${e.response?.data}',
      );
      rethrow;
    }
  }
}
