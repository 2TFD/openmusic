import 'package:equatable/equatable.dart';
import 'package:owlsonic/core/errors/failures/failure.dart';
import 'package:owlsonic/layers/domain/entities/track_preview.dart';

/// Per-file lifecycle in the desktop import workspace. Every state is distinct
/// so the UI never has to overload a single "loading" flag.
enum ImportItemStatus {
  scanning,
  ready,
  duplicate,
  invalid,
  queued,
  importing,
  imported,
  failed,
}

class ImportCandidate extends Equatable {
  const ImportCandidate({
    required this.path,
    required this.fileName,
    required this.status,
    this.preview,
    this.contentIdentity,
    this.failure,
    this.duplicateOfTitle,
    this.duplicateOfTrackId,
  });

  const ImportCandidate.scanning({required String path, required String name})
    : this(path: path, fileName: name, status: ImportItemStatus.scanning);

  /// Absolute file path. Also the candidate's identity inside one batch.
  final String path;
  final String fileName;
  final ImportItemStatus status;
  final TrackPreview? preview;
  final String? contentIdentity;
  final Failure? failure;
  final String? duplicateOfTitle;
  final String? duplicateOfTrackId;

  String get title => preview?.title ?? fileName;
  String get artist => preview?.artist ?? '';

  bool get canImport => status == ImportItemStatus.ready;

  ImportCandidate copyWith({
    ImportItemStatus? status,
    Failure? failure,
    bool clearFailure = false,
  }) => ImportCandidate(
    path: path,
    fileName: fileName,
    status: status ?? this.status,
    preview: preview,
    contentIdentity: contentIdentity,
    failure: clearFailure ? null : failure ?? this.failure,
    duplicateOfTitle: duplicateOfTitle,
    duplicateOfTrackId: duplicateOfTrackId,
  );

  @override
  List<Object?> get props => [
    path,
    status,
    preview,
    contentIdentity,
    failure,
    duplicateOfTitle,
    duplicateOfTrackId,
  ];
}
