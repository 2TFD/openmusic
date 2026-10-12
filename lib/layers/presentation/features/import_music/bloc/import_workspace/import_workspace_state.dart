part of 'import_workspace_cubit.dart';

enum ImportPhase { idle, scanning, review, importing, done }

class ImportWorkspaceState extends Equatable {
  const ImportWorkspaceState({
    this.phase = ImportPhase.idle,
    this.items = const [],
    this.selected = const {},
    this.scanTotal = 0,
    this.importTotal = 0,
    this.importDone = 0,
    this.error,
    this.folderEmpty = false,
    this.completionSerial = 0,
    this.lastAddedCount = 0,
  });

  final ImportPhase phase;
  final List<ImportCandidate> items;

  /// Paths the user wants to import. Only `ready` items can be selected.
  final Set<String> selected;
  final int scanTotal;
  final int importTotal;
  final int importDone;
  final UiError? error;

  /// A folder was chosen but held no supported audio.
  final bool folderEmpty;

  /// Bumps once per finished import run so the UI can toast exactly once.
  final int completionSerial;
  final int lastAddedCount;

  int _count(ImportItemStatus status) =>
      items.where((item) => item.status == status).length;

  int get scannedCount =>
      items.where((item) => item.status != ImportItemStatus.scanning).length;
  int get importedCount => _count(ImportItemStatus.imported);
  int get duplicateCount => _count(ImportItemStatus.duplicate);
  int get invalidCount => _count(ImportItemStatus.invalid);
  int get failedCount => _count(ImportItemStatus.failed);
  int get selectedReadyCount => items
      .where((item) => item.canImport && selected.contains(item.path))
      .length;
  bool get hasImportable => items.any((item) => item.canImport);
  bool get busy =>
      phase == ImportPhase.scanning || phase == ImportPhase.importing;

  ImportWorkspaceState copyWith({
    ImportPhase? phase,
    List<ImportCandidate>? items,
    Set<String>? selected,
    int? scanTotal,
    int? importTotal,
    int? importDone,
    UiError? error,
    bool clearError = false,
    bool? folderEmpty,
    int? completionSerial,
    int? lastAddedCount,
  }) => ImportWorkspaceState(
    phase: phase ?? this.phase,
    items: items ?? this.items,
    selected: selected ?? this.selected,
    scanTotal: scanTotal ?? this.scanTotal,
    importTotal: importTotal ?? this.importTotal,
    importDone: importDone ?? this.importDone,
    error: clearError ? null : error ?? this.error,
    folderEmpty: folderEmpty ?? this.folderEmpty,
    completionSerial: completionSerial ?? this.completionSerial,
    lastAddedCount: lastAddedCount ?? this.lastAddedCount,
  );

  @override
  List<Object?> get props => [
    phase,
    items,
    selected,
    scanTotal,
    importTotal,
    importDone,
    error,
    folderEmpty,
    completionSerial,
    lastAddedCount,
  ];
}
