import 'package:owlsonic/layers/domain/entities/track_preview.dart';

abstract class SearchSource {
  Future<List<TrackPreview>> searchExternal(String query, {int offset = 0});
}
