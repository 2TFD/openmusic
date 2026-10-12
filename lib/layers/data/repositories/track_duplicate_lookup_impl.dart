import 'package:owlsonic/layers/data/database/app_database.dart';
import 'package:owlsonic/layers/data/datasources/local/track/track_local_data_source.dart';
import 'package:owlsonic/layers/data/mappers/track_mapper.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/domain/repositories/track_duplicate_lookup.dart';

class TrackDuplicateLookupImpl implements TrackDuplicateLookup {
  TrackDuplicateLookupImpl({
    required this.database,
    required this.trackLocalDataSource,
  });

  final AppDatabase database;
  final TrackLocalDataSource trackLocalDataSource;

  @override
  Future<Track?> findByContentIdentity(String contentIdentity) async {
    final row =
        await (database.select(database.trackTable)
              ..where((t) => t.contentIdentity.equals(contentIdentity))
              ..limit(1))
            .getSingleOrNull();
    if (row == null) return null;
    final dto = await trackLocalDataSource.getTrackById(row.id);
    return dto == null ? null : TrackMapper.toEntity(dto);
  }
}
