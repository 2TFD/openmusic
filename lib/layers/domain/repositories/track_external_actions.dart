import 'dart:ui';

import 'package:openmusic/layers/domain/entities/track.dart';

abstract interface class TrackExternalActions {
  Future<void> openSource(Track track, {Rect? sharePositionOrigin});
}
