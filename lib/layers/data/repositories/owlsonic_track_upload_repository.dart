import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:owlsonic/core/network/owlsonic/owlsonic_api_client.dart';
import 'package:owlsonic/layers/data/datasources/remote/owlsonic/owlsonic_json.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_models.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_upload.dart';
import 'package:owlsonic/layers/domain/repositories/cloud_repositories.dart';
import 'package:path/path.dart' as p;

/// `POST /v1/tracks` multipart: `manifest` (UTF-8 JSON part,
/// `application/json`), `audio`, optional `artwork`; header `Idempotency-Key`.
class OwlSonicTrackUploadRepository implements CloudTrackUploadRepository {
  OwlSonicTrackUploadRepository(this._client);
  final OwlSonicApiClient _client;

  @override
  Future<CloudTrack> upload(
    CloudUploadRequest request, {
    void Function(int sent, int total)? onProgress,
    Future<void>? cancelled,
  }) async {
    final cancelToken = CancelToken();
    cancelled?.then((_) => cancelToken.cancel());
    final json = await _client.postMultipart(
      '/v1/tracks',
      buildForm: () => buildForm(request),
      // Same key on every attempt of this logical upload (including the
      // retry after a 401 refresh).
      headers: {'Idempotency-Key': request.idempotencyKey},
      onSendProgress: onProgress,
      cancelToken: cancelToken,
    );
    return OwlSonicJson.track(json);
  }

  static Future<FormData> buildForm(CloudUploadRequest request) async {
    final artwork = request.artworkPath;
    return FormData.fromMap({
      'manifest': MultipartFile.fromString(
        jsonEncode(request.manifest.toJson()),
        filename: 'manifest.json',
        contentType: DioMediaType('application', 'json'),
      ),
      'audio': await MultipartFile.fromFile(
        request.audioPath,
        filename: p.basename(request.audioPath),
        contentType: mediaTypeFor(request.audioPath),
      ),
      if (artwork != null)
        'artwork': await MultipartFile.fromFile(
          artwork,
          filename: p.basename(artwork),
          contentType: mediaTypeFor(artwork),
        ),
    });
  }

  static DioMediaType mediaTypeFor(String path) =>
      switch (p.extension(path).toLowerCase()) {
        '.mp3' => DioMediaType('audio', 'mpeg'),
        '.flac' => DioMediaType('audio', 'flac'),
        '.m4a' || '.mp4' || '.aac' => DioMediaType('audio', 'mp4'),
        '.wav' => DioMediaType('audio', 'wav'),
        '.ogg' || '.oga' || '.opus' => DioMediaType('audio', 'ogg'),
        '.jpg' || '.jpeg' => DioMediaType('image', 'jpeg'),
        '.png' => DioMediaType('image', 'png'),
        '.webp' => DioMediaType('image', 'webp'),
        _ => DioMediaType('application', 'octet-stream'),
      };
}
