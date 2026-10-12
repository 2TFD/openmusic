import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:owlsonic/layers/presentation/features/import_music/ui/widgets/import_rights_notice.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/core/layout/app_layout.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/domain/entities/track_preview.dart';
import 'package:owlsonic/layers/presentation/features/track/bloc/add_track/add_track_bloc.dart';
import 'package:owlsonic/layers/presentation/shared/models/ui_error_localization.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/snackbars/custom_snack_bar.dart';
import 'add_track_sheet_widgets/add_track_components.dart';

class AddTrackSheet extends StatelessWidget {
  final String url;
  final TrackPreview? preview;
  const AddTrackSheet({super.key, required this.url, this.preview});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<AddTrackBloc>(),
      child: BlocConsumer<AddTrackBloc, AddTrackState>(
        listener: (context, state) {
          if (state is AddTrackSuccess) {
            final skipped =
                state.resolved.issues.length + state.result.failures.length;
            if (state.result.playlistFailure != null) {
              CustomSnackBar.warning(
                context,
                context.tr('import.collectionPlaylistFailed'),
              );
            } else if (state.resolved.collection != null || skipped > 0) {
              CustomSnackBar.success(
                context,
                context.tr(
                  'import.collectionResult',
                  namedArgs: {
                    'added': '${state.result.addedTracks.length}',
                    'skipped': '$skipped',
                  },
                ),
              );
            } else {
              CustomSnackBar.trackAdded(context, state.track.title);
            }
            Navigator.pop(context);
            context.read<AddTrackBloc>().add(const ResetAddTrack());
          } else if (state is AddTrackError) {
            CustomSnackBar.uiError(context, state.error);
          }
        },
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppLayout.isDesktopPlatform
                  ? BorderRadius.circular(16)
                  : const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: AppColors.border),
            ),
            padding: EdgeInsets.only(
              bottom:
                  MediaQuery.of(context).viewInsets.bottom +
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                if (!AppLayout.isDesktopPlatform) const AddTrackHandle(),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _buildBody(context, state, url),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: ImportRightsNotice(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, AddTrackState state, String url) {
    if (state is AddTrackInitial || state is AddTrackPreviewLoading) {
      return const AddTrackLoadingBody(key: ValueKey('loading'));
    } else if (state is AddTrackPreviewLoaded) {
      return AddTrackPreviewBody(
        key: const ValueKey('preview'),
        preview: state.preview,
        collectionName: state.resolved.collection?.name,
        trackCount: state.resolved.tracks.length,
        skippedCount: state.resolved.issues.length,
        adding: false,
        onAdd: () {
          context.read<AddTrackBloc>().add(AddTrackToLibrary(state.resolved));
        },
        onCancel: () => Navigator.pop(context),
      );
    } else if (state is AddTrackLoading) {
      return AddTrackPreviewBody(
        key: const ValueKey('preview_loading'),
        preview: state.preview,
        collectionName: state.resolved.collection?.name,
        trackCount: state.resolved.tracks.length,
        skippedCount: state.resolved.issues.length,
        adding: true,
        onAdd: () {},
        onCancel: () {},
      );
    } else if (state is AddTrackError) {
      return AddTrackErrorBody(
        key: const ValueKey('error'),
        message: state.error.localized(context),
        onRetry: () {
          context.read<AddTrackBloc>().add(FetchTrackPreview(url));
        },
        onCancel: () => Navigator.pop(context),
      );
    } else if (state is AddTrackSuccess) {
      return AddTrackPreviewBody(
        key: const ValueKey('preview_success'),
        preview: state.track.toTrackPreview(),
        adding: false,
        onAdd: () {},
        onCancel: () => Navigator.pop(context),
      );
    }

    return const SizedBox.shrink();
  }
}

extension on Track {
  TrackPreview toTrackPreview() {
    return TrackPreview(
      urlFile: '',
      id: id,
      title: title,
      artist: artists.map((a) => a.name).join(', '),
      artistId: artists.length == 1 ? artists.first.id : null,
      album: album,
      artworkUrl: imageUrl,
      duration: duration,
      source: source.type,
      originalUrl: source.originalUrl,
      media: source.media,
      year: null,
    );
  }
}
