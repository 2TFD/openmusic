import 'package:bloc/bloc.dart';
import 'package:owlsonic/core/errors/failures/failure.dart';
import 'package:owlsonic/core/services/cloud/cloud_import_service.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_upload.dart';
import 'package:equatable/equatable.dart';
import 'package:owlsonic/layers/domain/entities/import_candidate.dart';
import 'package:owlsonic/layers/domain/usecases/import_local_track_item_use_case.dart';
import 'package:owlsonic/layers/domain/usecases/scan_local_import_use_case.dart';
import 'package:owlsonic/layers/presentation/shared/models/ui_error.dart';
import 'package:path/path.dart' as p;

part 'import_workspace_state.dart';

/// Drives the desktop import workspace: select -> scan -> review -> import.
/// Scan and import are separate phases so nothing is committed before the user
/// confirms, and one bad file never aborts the batch.
class ImportWorkspaceCubit extends Cubit<ImportWorkspaceState> {
  ImportWorkspaceCubit({
    required ScanLocalImportUseCase scan,
    required ImportLocalTrackItemUseCase importItem,
    CloudImportService? cloudImport,
  }) : _scan = scan,
       _importItem = importItem,
       _cloudImport = cloudImport,
       super(const ImportWorkspaceState());

  final ScanLocalImportUseCase _scan;
  final ImportLocalTrackItemUseCase _importItem;

  /// While signed in, the final Import step uploads to OwlSonic instead of
  /// writing a local-only track.
  final CloudImportService? _cloudImport;
  bool _cancelRequested = false;

  Future<void> pickFiles() => _select(_scan.pickFiles);

  Future<void> pickFolder() => _select(_scan.pickFolder, fromFolder: true);

  /// Entry point for drag & drop. Ignored while a scan/import is running.
  Future<void> addPaths(List<String> paths) =>
      _select(() => _scan.expand(paths), fromFolder: true);

  Future<void> _select(
    Future<List<String>> Function() resolve, {
    bool fromFolder = false,
  }) async {
    if (state.busy) return;
    final List<String> paths;
    try {
      paths = await resolve();
    } catch (error, stackTrace) {
      if (!isClosed) {
        emit(
          state.copyWith(
            error: UiError.fromException(
              error,
              stackTrace,
              operation: 'import.select_files',
            ),
            folderEmpty: false,
          ),
        );
      }
      return;
    }
    if (isClosed || state.busy) return;
    if (paths.isEmpty) {
      if (fromFolder) {
        emit(state.copyWith(folderEmpty: true, clearError: true));
      }
      return;
    }
    await _scanPaths(paths);
  }

  Future<void> _scanPaths(List<String> paths) async {
    final base = state.phase == ImportPhase.done
        ? const ImportWorkspaceState()
        : state;
    final known = {for (final item in base.items) item.path};
    final fresh = paths.where(known.add).toList();
    if (fresh.isEmpty) {
      emit(base.copyWith(phase: ImportPhase.review, clearError: true));
      return;
    }

    var items = [
      ...base.items,
      for (final path in fresh)
        ImportCandidate.scanning(path: path, name: p.basename(path)),
    ];
    final batchIdentities = <String, String>{
      for (final item in base.items)
        if (item.contentIdentity != null &&
            item.status != ImportItemStatus.invalid)
          item.contentIdentity!: item.title,
    };
    final selected = {...base.selected};
    emit(
      base.copyWith(
        phase: ImportPhase.scanning,
        items: items,
        selected: selected,
        scanTotal: items.length,
        clearError: true,
        folderEmpty: false,
      ),
    );

    for (final path in fresh) {
      final scanned = await _scan.scan(path, batchIdentities: batchIdentities);
      if (isClosed) return;
      items = [for (final item in items) item.path == path ? scanned : item];
      if (scanned.canImport) selected.add(path);
      emit(state.copyWith(items: items, selected: {...selected}));
    }
    if (isClosed) return;
    emit(state.copyWith(phase: ImportPhase.review));
  }

  void toggle(String path) {
    if (state.phase != ImportPhase.review) return;
    final item = state.items.where((i) => i.path == path).firstOrNull;
    if (item == null || !item.canImport) return;
    final selected = {...state.selected};
    if (!selected.add(path)) selected.remove(path);
    emit(state.copyWith(selected: selected));
  }

  void setAllSelected(bool value) {
    if (state.phase != ImportPhase.review) return;
    emit(
      state.copyWith(
        selected: value
            ? {
                for (final item in state.items)
                  if (item.canImport) item.path,
              }
            : <String>{},
      ),
    );
  }

  void remove(String path) {
    if (state.phase != ImportPhase.review) return;
    emit(
      state.copyWith(
        items: state.items.where((item) => item.path != path).toList(),
        selected: {...state.selected}..remove(path),
      ),
    );
    if (state.items.isEmpty) reset();
  }

  void reset() {
    if (state.phase == ImportPhase.importing) return;
    emit(
      const ImportWorkspaceState().copyWith(
        completionSerial: state.completionSerial,
      ),
    );
  }

  void dismissError() {
    if (state.error != null || state.folderEmpty) {
      emit(state.copyWith(clearError: true, folderEmpty: false));
    }
  }

  Future<void> startImport() => _runImport(
    state.items
        .where((item) => item.canImport && state.selected.contains(item.path))
        .map((item) => item.path)
        .toList(),
  );

  Future<void> retryFailed() => _runImport(
    state.items
        .where((item) => item.status == ImportItemStatus.failed)
        .map((item) => item.path)
        .toList(),
  );

  Future<void> retryItem(String path) => _runImport([path]);

  /// Stops after the file currently being imported; the rest go back to ready.
  void cancelImport() {
    if (state.phase == ImportPhase.importing) {
      _cancelRequested = true;
      _cloudImport?.stop();
    }
  }

  Future<void> _runImport(List<String> paths) async {
    if (paths.isEmpty || state.busy) return;
    final cloud = _cloudImport;
    if (cloud != null && await cloud.autoUploadAllowed()) {
      return _runCloudImport(cloud, paths);
    }
    _cancelRequested = false;
    var items = _withStatus(
      state.items,
      paths.toSet(),
      ImportItemStatus.queued,
    );
    emit(
      state.copyWith(
        phase: ImportPhase.importing,
        items: items,
        importTotal: paths.length,
        importDone: 0,
        clearError: true,
      ),
    );

    var added = 0;
    var done = 0;
    for (final path in paths) {
      if (_cancelRequested) break;
      items = _replace(
        items,
        path,
        (item) => item.copyWith(
          status: ImportItemStatus.importing,
          clearFailure: true,
        ),
      );
      emit(state.copyWith(items: items));

      final preview = items.firstWhere((item) => item.path == path).preview!;
      final outcome = await _importItem(preview);
      if (isClosed) return;
      done++;
      items = _replace(items, path, (item) {
        switch (outcome) {
          case LocalImportAdded():
            added++;
            return item.copyWith(status: ImportItemStatus.imported);
          case LocalImportExisting(:final track):
            return ImportCandidate(
              path: item.path,
              fileName: item.fileName,
              status: ImportItemStatus.duplicate,
              preview: item.preview,
              contentIdentity: item.contentIdentity,
              duplicateOfTitle: track.title,
              duplicateOfTrackId: track.id,
            );
          case LocalImportFailed(:final failure):
            return item.copyWith(
              status: ImportItemStatus.failed,
              failure: failure,
            );
        }
      });
      emit(state.copyWith(items: items, importDone: done));
    }

    final cancelled = _cancelRequested;
    _cancelRequested = false;
    if (cancelled) {
      items = [
        for (final item in items)
          item.status == ImportItemStatus.queued
              ? item.copyWith(status: ImportItemStatus.ready)
              : item,
      ];
    }
    emit(
      state.copyWith(
        phase: cancelled && items.any((item) => item.canImport)
            ? ImportPhase.review
            : ImportPhase.done,
        items: items,
        completionSerial: state.completionSerial + 1,
        lastAddedCount: added,
      ),
    );
  }

  /// Uploads confirmed items with bounded concurrency. A 201 is "Imported":
  /// the track is in the library at once; analysis continues in the cloud.
  /// Identical audio already stored on the backend is not an error.
  Future<void> _runCloudImport(
    CloudImportService cloud,
    List<String> paths,
  ) async {
    _cancelRequested = false;
    var items = _withStatus(
      state.items,
      paths.toSet(),
      ImportItemStatus.queued,
    );
    emit(
      state.copyWith(
        phase: ImportPhase.importing,
        items: items,
        importTotal: paths.length,
        importDone: 0,
        clearError: true,
      ),
    );

    final sources = [
      for (final path in paths)
        if (items.firstWhere((item) => item.path == path).preview
            case final preview?)
          CloudImportSource(
            key: path,
            audioPath: path,
            title: preview.title,
            artistName: preview.artist,
            albumTitle: preview.album,
            year: preview.year,
            artworkPath: _localFile(preview.artworkUrl),
            sourceProvider: communityProviderFor(preview.source),
            contentIdentity: items
                .firstWhere((item) => item.path == path)
                .contentIdentity,
          ),
    ];

    var added = 0;
    var done = 0;
    final results = await cloud.importAll(
      sources,
      onUpdate: (path, upload) {
        if (isClosed) return;
        items = _replace(items, path, (item) => _withUpload(item, upload));
        if (upload.phase == CloudUploadPhase.succeeded) added++;
        if (upload.isTerminal) done++;
        emit(state.copyWith(items: items, importDone: done));
      },
    );
    if (isClosed) return;
    items = [
      for (final item in items)
        switch (results[item.path]) {
          final upload? => _withUpload(item, upload),
          null =>
            item.status == ImportItemStatus.queued
                ? item.copyWith(status: ImportItemStatus.ready)
                : item,
        },
    ];
    final cancelled = _cancelRequested;
    _cancelRequested = false;
    emit(
      state.copyWith(
        phase: cancelled && items.any((item) => item.canImport)
            ? ImportPhase.review
            : ImportPhase.done,
        items: items,
        importDone: done,
        completionSerial: state.completionSerial + 1,
        lastAddedCount: added,
      ),
    );
  }

  static ImportCandidate _withUpload(
    ImportCandidate item,
    CloudUploadItemState upload,
  ) => switch (upload.phase) {
    CloudUploadPhase.queued => item.copyWith(status: ImportItemStatus.queued),
    CloudUploadPhase.uploading || CloudUploadPhase.retrying => item.copyWith(
      status: ImportItemStatus.importing,
      clearFailure: true,
    ),
    CloudUploadPhase.succeeded => item.copyWith(
      status: ImportItemStatus.imported,
      clearFailure: true,
    ),
    CloudUploadPhase.skipped => item.copyWith(status: ImportItemStatus.ready),
    CloudUploadPhase.failed => item.copyWith(
      status: ImportItemStatus.failed,
      failure: CloudUploadFailure(
        (upload.failureKind ?? CloudUploadFailureKind.unknown).name,
        code: upload.errorCode,
        message: upload.errorMessage,
        requestId: upload.requestId,
      ),
    ),
  };

  /// Extracted artwork is a local file path; URLs are not uploaded.
  static String? _localFile(String? value) {
    if (value == null) return null;
    final lower = value.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return null;
    }
    return value;
  }

  static List<ImportCandidate> _withStatus(
    List<ImportCandidate> items,
    Set<String> paths,
    ImportItemStatus status,
  ) => [
    for (final item in items)
      paths.contains(item.path)
          ? item.copyWith(status: status, clearFailure: true)
          : item,
  ];

  static List<ImportCandidate> _replace(
    List<ImportCandidate> items,
    String path,
    ImportCandidate Function(ImportCandidate) update,
  ) => [for (final item in items) item.path == path ? update(item) : item];
}
