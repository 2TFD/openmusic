import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:openmusic/layers/data/datasources/local/embeding_task/drift/embedding_task_table.dart';
import 'package:openmusic/layers/data/datasources/local/play_record/drift/play_record_table.dart';
import 'package:openmusic/layers/data/datasources/local/playlist/drift/playlist_table.dart';
import 'package:openmusic/layers/data/datasources/local/track/drift/track_table.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

final AppDatabase appDatabase = AppDatabase();

@DriftDatabase(
  tables: [PlayRecordTable, PlaylistTable, TrackTable, EmbeddingTaskTable],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());
  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: "openmusic_database",
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
        shareAcrossIsolates: true,
      ),
    );
  }
}
