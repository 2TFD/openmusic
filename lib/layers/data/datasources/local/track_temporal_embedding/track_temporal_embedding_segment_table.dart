import 'package:drift/drift.dart';

import 'track_temporal_embedding_table.dart';

class TrackTemporalEmbeddingSegmentTable extends Table {
  TextColumn get temporalEmbeddingId => text().references(
    TrackTemporalEmbeddingTable,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get segmentIndex => integer()();
  IntColumn get startMs => integer()();
  IntColumn get endMs => integer()();
  IntColumn get dimensions => integer()();
  BlobColumn get vector => blob()();

  @override
  Set<Column<Object>> get primaryKey => {temporalEmbeddingId, segmentIndex};
}
