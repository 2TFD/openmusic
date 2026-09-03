import 'package:drift/drift.dart';

import '../../domain/entities/listening_event.dart';
import '../../domain/repositories/listening_event_repository.dart';
import '../database/app_database.dart';

class ListeningEventRepositoryImpl implements ListeningEventRepository {
  ListeningEventRepositoryImpl(this.database);

  final AppDatabase database;

  @override
  Future<void> save(ListeningEvent event) async {
    await database
        .into(database.listeningEventTable)
        .insert(
          ListeningEventTableCompanion.insert(
            id: event.id,
            sessionId: Value(event.sessionId),
            trackId: event.trackId,
            type: event.type.name,
            occurredAt: event.occurredAt,
            positionMs: Value(event.positionMs),
            listenedMs: Value(event.listenedMs),
            durationMs: Value(event.durationMs),
            previousTrackId: Value(event.previousTrackId),
            transitionReason: Value(event.transitionReason?.name),
          ),
        );
  }

  @override
  Future<List<ListeningEvent>> getForTrack(String trackId) async {
    final rows =
        await (database.select(database.listeningEventTable)
              ..where((table) => table.trackId.equals(trackId))
              ..orderBy([(table) => OrderingTerm.asc(table.occurredAt)]))
            .get();
    return rows.map(_toEntity).toList(growable: false);
  }

  @override
  Future<List<ListeningEvent>> getAll() async {
    final rows = await (database.select(
      database.listeningEventTable,
    )..orderBy([(table) => OrderingTerm.asc(table.occurredAt)])).get();
    return rows.map(_toEntity).toList(growable: false);
  }

  static ListeningEvent _toEntity(ListeningEventTableData row) {
    return ListeningEvent(
      id: row.id,
      sessionId: row.sessionId,
      trackId: row.trackId,
      type: ListeningEventType.values.byName(row.type),
      occurredAt: row.occurredAt,
      positionMs: row.positionMs,
      listenedMs: row.listenedMs,
      durationMs: row.durationMs,
      previousTrackId: row.previousTrackId,
      transitionReason: row.transitionReason == null
          ? null
          : ListeningTransitionReason.values.byName(row.transitionReason!),
    );
  }
}
