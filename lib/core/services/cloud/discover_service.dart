import 'package:owlsonic/layers/data/repositories/cloud_local_store.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_models.dart';
import 'package:owlsonic/layers/domain/repositories/cloud_repositories.dart';

/// Discover: the backend returns the eligible candidate pool with canonical
/// analysis; ranking stays on the client. Adding a candidate creates the
/// user's LibraryEntry server-side and lands it in the local library at once.
class DiscoverService {
  DiscoverService({
    required CloudDiscoverRepository remote,
    required CloudLocalStore local,
    required void Function() requestSync,
  }) : _remote = remote,
       _local = local,
       _requestSync = requestSync;

  final CloudDiscoverRepository _remote;
  final CloudLocalStore _local;
  final void Function() _requestSync;

  Future<CloudPage<DiscoverCandidate>> candidates({
    String? cursor,
    int limit = 50,
  }) => _remote.candidates(cursor: cursor, limit: limit);

  Future<CloudLibraryItem> add(String trackId) async {
    final item = await _remote.addToLibrary(trackId);
    await _local.upsertLibraryItem(item);
    _requestSync();
    return item;
  }

  Future<SignedUrl> artwork(String trackId) => _remote.artworkUrl(trackId);
}
