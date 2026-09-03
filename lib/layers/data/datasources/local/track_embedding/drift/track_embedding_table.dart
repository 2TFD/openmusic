import 'package:drift/drift.dart';

import '../../track/drift/track_table.dart';

class TrackEmbeddingTable extends Table {
  TextColumn get trackId =>
      text().references(TrackTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get modality => text()();
  TextColumn get modelId => text()();
  TextColumn get modelVersion => text()();
  TextColumn get preprocessingVersion =>
      text().withDefault(const Constant('legacy-unknown'))();
  TextColumn get provider => text()();
  IntColumn get audioRevision => integer().nullable()();
  TextColumn get contentRevision => text().nullable()();
  TextColumn get dtype => text().withDefault(const Constant('float32'))();
  BoolColumn get normalized => boolean().nullable()();
  IntColumn get dimensions => integer()();
  BlobColumn get vector => blob()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {
    trackId,
    modality,
    modelId,
    modelVersion,
    preprocessingVersion,
    provider,
  };
}
