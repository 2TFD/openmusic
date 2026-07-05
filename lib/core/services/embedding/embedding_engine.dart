import 'package:dio/dio.dart';
import 'package:openmusic/core/utils/app_logger.dart';
import 'package:path_provider/path_provider.dart';

class EmbeddingEngine {
  Future<List<double>> compute(String filePath) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      var data = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          "${dir.path}/$filePath",
          filename: filePath,
        ),
      });

      var dio = Dio();
      var response = await dio.request(
        "https://kxmwebwe-trackembeddingapi.hf.space/embedding/smart",
        options: Options(method: 'POST'),
        data: data,
      );

      if (response.statusCode == 200) {
        return List<double>.from(response.data['embedding']);
      } else {
        throw Exception(
          'Failed to compute embedding: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      await AppLogger.log(
        '[EmbeddingEngine.compute] DioException: statusCode=${e.response?.statusCode}, data=${e.response?.data}',
      );
      rethrow;
    }
  }
}
