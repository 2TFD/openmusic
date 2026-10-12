import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:owlsonic/core/errors/failures/failure.dart';
import 'package:owlsonic/core/services/cloud/cloud_import_service.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_upload.dart';
import 'package:owlsonic/layers/domain/repositories/track_content_identity_service.dart';
import 'package:owlsonic/layers/domain/entities/track_preview.dart';
import 'package:owlsonic/layers/domain/usecases/import_local_tracks_use_case.dart';
import 'package:owlsonic/layers/domain/usecases/pick_local_tracks_use_case.dart';
import 'package:owlsonic/layers/presentation/shared/models/ui_error.dart';

part 'import_music_state.dart';

class ImportMusicCubit extends Cubit<ImportMusicState> {
  ImportMusicCubit({
    required PickLocalTracksUseCase pickLocalTracks,
    required ImportLocalTracksUseCase importLocalTracks,
    CloudImportService? cloudImport,
    TrackContentIdentityService? identity,
  }) : _pickLocalTracks = pickLocalTracks,
       _importLocalTracks = importLocalTracks,
       _cloudImport = cloudImport,
       _identity = identity,
       super(const ImportMusicInitial());

  final PickLocalTracksUseCase _pickLocalTracks;
  final ImportLocalTracksUseCase _importLocalTracks;

  /// While signed in, files are uploaded to OwlSonic through the same service
  /// the desktop workspace uses; signed out they stay local-only.
  final CloudImportService? _cloudImport;
  final TrackContentIdentityService? _identity;

  Future<void> pickLocalTracks() async {
    if (state is LocalTracksPicking || state is LocalTracksImporting) return;

    emit(const LocalTracksPicking());
    try {
      final previews = await _pickLocalTracks();
      if (isClosed) return;
      if (previews.isEmpty) {
        emit(const LocalTracksSelectionEmpty());
      } else {
        emit(LocalTracksPicked(previews));
      }
    } catch (error, stackTrace) {
      if (!isClosed) {
        emit(
          LocalTracksPickFailure(
            UiError.fromException(
              error,
              stackTrace,
              operation: 'import.pick_local_tracks',
            ),
          ),
        );
      }
    }
  }

  Future<void> importLocalTracks(List<TrackPreview> previews) async {
    if (previews.isEmpty || state is LocalTracksImporting) return;

    emit(const LocalTracksImporting());
    final cloud = _cloudImport;
    final toCloud = cloud != null && await cloud.autoUploadAllowed();
    final result = toCloud
        ? await _importToCloud(cloud, previews)
        : await _importLocalTracks(previews).then(
            (local) => ImportLocalTracksResult(
              added: local.added,
              failed: local.failed,
              failures: local.failures,
              localOnly: cloud != null && cloud.configured && !cloud.enabled,
            ),
          );
    // Cloud uploads may resume later from the picked paths; keep them then.
    if (!toCloud) {
      await _pickLocalTracks.clearPickedCache();
    }
    if (!isClosed) emit(LocalTracksImported(result));
  }

  /// A 201 is a finished import (track visible at once, analysis continues in
  /// the cloud). Retries of the same file reuse the persisted track id and
  /// Idempotency-Key (see `CloudUploadStore.createOrReuse`).
  Future<ImportLocalTracksResult> _importToCloud(
    CloudImportService cloud,
    List<TrackPreview> previews,
  ) async {
    final sources = <CloudImportSource>[];
    for (final preview in previews) {
      sources.add(
        CloudImportSource(
          key: preview.id,
          audioPath: preview.urlFile,
          title: preview.title,
          artistName: preview.artist,
          albumTitle: preview.album,
          year: preview.year,
          artworkPath: _localFile(preview.artworkUrl),
          sourceProvider: communityProviderFor(preview.source),
          contentIdentity: await _contentIdentity(preview.urlFile),
        ),
      );
    }
    final results = await cloud.importAll(sources);
    var added = 0;
    final failures = <Failure>[];
    for (final upload in results.values) {
      switch (upload.phase) {
        case CloudUploadPhase.succeeded:
          added++;
        case CloudUploadPhase.failed:
          failures.add(
            CloudUploadFailure(
              (upload.failureKind ?? CloudUploadFailureKind.unknown).name,
              code: upload.errorCode,
              message: upload.errorMessage,
              requestId: upload.requestId,
            ),
          );
        default:
          break;
      }
    }
    return ImportLocalTracksResult(
      added: added,
      failed: failures.length,
      failures: failures,
    );
  }

  Future<String?> _contentIdentity(String path) async {
    try {
      return await _identity?.forLocalFile(path);
    } catch (_) {
      return null; // identity is an optimisation, never a reason to fail
    }
  }

  /// Extracted artwork is a local file path; URLs are not uploaded.
  static String? _localFile(String? value) {
    if (value == null) return null;
    final lower = value.toLowerCase();
    return lower.startsWith('http://') || lower.startsWith('https://')
        ? null
        : value;
  }
}
