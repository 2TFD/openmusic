import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/core/network/retry_policy.dart';
import 'package:openmusic/layers/data/datasources/remote/soundcloud_track_source.dart';
import 'package:openmusic/layers/data/repositories/search_source_impl.dart';

void main() {
  test(
    'search refreshes an expired client id once after authorization failure',
    () async {
      var scriptRequests = 0;
      final idDio = Dio();
      idDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.uri.host == 'soundcloud.com') {
              handler.resolve(
                Response<String>(
                  requestOptions: options,
                  data:
                      '<script src="https://a-v2.sndcdn.com/assets/app.js"></script>',
                  statusCode: 200,
                ),
              );
              return;
            }
            scriptRequests++;
            final id = scriptRequests == 1 ? 'expiredId' : 'freshId';
            handler.resolve(
              Response<String>(
                requestOptions: options,
                data: 'client_id:"$id"',
                statusCode: 200,
              ),
            );
          },
        ),
      );
      final source = SoundcloudTrackSource(
        dio: idDio,
        retryPolicy: RetryPolicy(delay: (_) async {}),
      );
      source.invalidateClientId();

      final usedIds = <String>[];
      final searchDio = Dio();
      searchDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final id = options.queryParameters['client_id'] as String;
            usedIds.add(id);
            if (id == 'expiredId') {
              handler.reject(
                DioException.badResponse(
                  statusCode: 401,
                  requestOptions: options,
                  response: Response<void>(
                    requestOptions: options,
                    statusCode: 401,
                  ),
                ),
              );
              return;
            }
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'collection': [
                    {
                      'id': 1,
                      'title': 'Track',
                      'permalink_url': 'https://soundcloud.com/user/track',
                      'duration': 1000,
                      'user': {'id': 42, 'username': 'User'},
                    },
                  ],
                },
              ),
            );
          },
        ),
      );
      final repository = SearchSourceImpl(
        soundcloudTrackSource: source,
        dio: searchDio,
        retryPolicy: RetryPolicy(delay: (_) async {}),
      );

      final result = await repository.searchExternal('query');

      expect(usedIds, ['expiredId', 'freshId']);
      expect(result.single.id, '1');
      expect(result.single.artistId, 'soundcloud:artist:42');
      source.invalidateClientId();
    },
  );
}
