import 'dart:ui';

import 'package:owlsonic/layers/domain/entities/track.dart';

abstract interface class TrackExternalActions {
  Future<void> openSource(Track track, {Rect? sharePositionOrigin});
  Future<void> openMediaSource(Track track);
}
