import 'package:owlsonic/layers/domain/entities/track.dart';

/// Finds a track that already represents the same audio, using the existing
/// content-identity semantics.
abstract interface class TrackDuplicateLookup {
  Future<Track?> findByContentIdentity(String contentIdentity);
}
