import 'package:drift/drift.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/domain/entities/playback_session.dart';
import 'package:openmusic/layers/domain/repositories/audio_player_port.dart';
import 'package:openmusic/layers/domain/repositories/playback_session_repository.dart';

class PlaybackSessionRepositoryImpl implements PlaybackSessionRepository {
  PlaybackSessionRepositoryImpl(this.database);

  static const _sessionId = 'current';
  final AppDatabase database;

  @override
  Future<PlaybackSession?> load() async {
    final session = await (database.select(
      database.playbackSessionTable,
    )..where((row) => row.id.equals(_sessionId))).getSingleOrNull();
    if (session == null) return null;
    final items =
        await (database.select(database.playbackQueueItemTable)
              ..where((row) => row.sessionId.equals(_sessionId))
              ..orderBy([(row) => OrderingTerm.asc(row.position)]))
            .get();
    if (items.isEmpty) {
      await clear();
      return null;
    }
    return PlaybackSession(
      queueTrackIds: items.map((item) => item.trackId).toList(),
      currentTrackId: session.currentTrackId,
      currentQueuePosition: session.currentQueuePosition,
      position: Duration(
        milliseconds: session.positionMilliseconds.clamp(0, 1 << 62),
      ),
      shuffleEnabled: session.shuffleEnabled,
      loopMode: PlaybackLoopMode.values.firstWhere(
        (mode) => mode.name == session.loopMode,
        orElse: () => PlaybackLoopMode.off,
      ),
      updatedAt: session.updatedAt,
    );
  }

  @override
  Future<void> replace(PlaybackSession session) async {
    if (session.queueTrackIds.isEmpty) return clear();
    if (session.queueTrackIds.toSet().length != session.queueTrackIds.length) {
      throw ArgumentError.value(session.queueTrackIds, 'queueTrackIds');
    }
    await database.transaction(() async {
      await database
          .into(database.playbackSessionTable)
          .insertOnConflictUpdate(_sessionCompanion(session));
      await (database.delete(
        database.playbackQueueItemTable,
      )..where((row) => row.sessionId.equals(_sessionId))).go();
      await database.batch((batch) {
        batch.insertAll(database.playbackQueueItemTable, [
          for (var index = 0; index < session.queueTrackIds.length; index++)
            PlaybackQueueItemTableCompanion.insert(
              sessionId: _sessionId,
              trackId: session.queueTrackIds[index],
              position: index,
            ),
        ]);
      });
    });
  }

  @override
  Future<void> updatePlayback(PlaybackSession session) async {
    final affected =
        await (database.update(database.playbackSessionTable)
              ..where((row) => row.id.equals(_sessionId)))
            .write(_sessionCompanion(session, includeId: false));
    if (affected == 0 && session.queueTrackIds.isNotEmpty) {
      await replace(session);
    }
  }

  @override
  Future<void> clear() => database.transaction(() async {
    await (database.delete(
      database.playbackSessionTable,
    )..where((row) => row.id.equals(_sessionId))).go();
  });

  PlaybackSessionTableCompanion _sessionCompanion(
    PlaybackSession session, {
    bool includeId = true,
  }) {
    return PlaybackSessionTableCompanion(
      id: includeId ? const Value(_sessionId) : const Value.absent(),
      currentTrackId: Value(session.currentTrackId),
      currentQueuePosition: Value(session.currentQueuePosition),
      positionMilliseconds: Value(
        session.position.inMilliseconds.clamp(0, 1 << 62),
      ),
      shuffleEnabled: Value(session.shuffleEnabled),
      loopMode: Value(session.loopMode.name),
      updatedAt: Value(session.updatedAt),
    );
  }
}
