import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/domain/entities/play_record.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/repositories/listening_checkpoint_repository.dart';
import 'package:uuid/uuid.dart';

class ListeningCheckpointRepositoryImpl
    implements ListeningCheckpointRepository {
  ListeningCheckpointRepositoryImpl(this.database);

  final AppDatabase database;

  @override
  Future<ListeningCheckpoint> save(
    Track track,
    Duration listenedDuration,
  ) => database.transaction(() async {
    final current = await database
        .select(database.listeningCheckpointTable)
        .getSingleOrNull();
    final id = current?.trackId == track.id ? current!.id : const Uuid().v4();
    final milliseconds = current?.trackId == track.id
        ? listenedDuration.inMilliseconds.clamp(
            current!.listenedMilliseconds,
            1 << 62,
          )
        : listenedDuration.inMilliseconds;
    if (current != null && current.trackId != track.id) {
      await database.delete(database.listeningCheckpointTable).go();
    }
    final now = DateTime.now();
    await database
        .into(database.listeningCheckpointTable)
        .insertOnConflictUpdate(
          ListeningCheckpointTableCompanion.insert(
            id: id,
            trackId: track.id,
            trackTitle: track.title,
            artistName: track.artists.map((artist) => artist.name).join(', '),
            sourceType: track.source.type.name,
            listenedMilliseconds: milliseconds,
            updatedAt: now,
          ),
        );
    return ListeningCheckpoint(
      id: id,
      trackId: track.id,
      trackTitle: track.title,
      artistName: track.artists.map((artist) => artist.name).join(', '),
      sourceType: track.source.type,
      listenedDuration: Duration(milliseconds: milliseconds),
      updatedAt: now,
    );
  });

  @override
  Future<ListeningCheckpoint?> load() async {
    final row = await database
        .select(database.listeningCheckpointTable)
        .getSingleOrNull();
    if (row == null) return null;
    return ListeningCheckpoint(
      id: row.id,
      trackId: row.trackId,
      trackTitle: row.trackTitle,
      artistName: row.artistName,
      sourceType: SourceType.values.firstWhere(
        (source) => source.name == row.sourceType,
        orElse: () => SourceType.unknown,
      ),
      listenedDuration: Duration(milliseconds: row.listenedMilliseconds),
      updatedAt: row.updatedAt,
    );
  }

  @override
  Future<void> clear(String id) async {
    await (database.delete(
      database.listeningCheckpointTable,
    )..where((row) => row.id.equals(id))).go();
  }
}
