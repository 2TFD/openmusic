import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/domain/entities/download_track_task.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/presentation/features/player/bloc/player/player_bloc.dart';
import 'package:owlsonic/layers/presentation/features/playlist/ui/widgets/sheets/add_to_playlist_sheet.dart';
import 'package:owlsonic/layers/presentation/features/track/bloc/track/track_bloc.dart';
import 'package:owlsonic/layers/presentation/shared/blocs/download_status/download_status_cubit.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/snackbars/custom_snack_bar.dart';

/// Actions on the tracks selected in the library, shown above the list while
/// a selection exists. [tracks] keeps the list order.
class TrackSelectionBar extends StatelessWidget {
  const TrackSelectionBar({
    super.key,
    required this.tracks,
    required this.allSelected,
    required this.onSelectAll,
    required this.onClear,
  });

  final List<Track> tracks;
  final bool allSelected;
  final VoidCallback onSelectAll;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final failedDownloads = context
        .select<DownloadStatusCubit, Iterable<String>>(
          (cubit) => cubit.state.entries
              .where((entry) => entry.value.status == DownloadStatus.failed)
              .map((entry) => entry.key),
        )
        .toSet();
    final hasFailed = tracks.any((track) => failedDownloads.contains(track.id));
    return Container(
      key: const ValueKey('track-selection-bar'),
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: context.tr('selection.clear'),
            onPressed: onClear,
            icon: const Icon(Icons.close, size: 20),
          ),
          Expanded(
            child: Text(
              context.tr(
                'selection.count',
                namedArgs: {'count': '${tracks.length}'},
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.bodyM,
            ),
          ),
          // Scrolls on narrow windows instead of overflowing.
          Flexible(
            flex: 3,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                children: [
                  if (!allSelected)
                    IconButton(
                      tooltip: context.tr('selection.selectAll'),
                      onPressed: onSelectAll,
                      icon: const Icon(Icons.select_all, size: 20),
                    ),
                  IconButton(
                    tooltip: context.tr('selection.play'),
                    onPressed: () => playSelectedTracks(context, tracks),
                    icon: const Icon(Icons.play_arrow_rounded, size: 22),
                  ),
                  IconButton(
                    tooltip: context.tr('selection.shuffle'),
                    onPressed: () =>
                        playSelectedTracks(context, tracks, shuffle: true),
                    icon: const Icon(Icons.shuffle_rounded, size: 20),
                  ),
                  IconButton(
                    tooltip: context.tr('playlist.addToPlaylist'),
                    onPressed: () =>
                        showAddTracksToPlaylistSheet(context, tracks),
                    icon: const Icon(Icons.playlist_add_rounded, size: 22),
                  ),
                  if (hasFailed)
                    IconButton(
                      tooltip: context.tr('selection.retryDownloads'),
                      onPressed: () => retrySelectedDownloads(context, tracks),
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                    ),
                  IconButton(
                    tooltip: context.tr('track.deleteFromLibrary'),
                    onPressed: () async {
                      if (await deleteSelectedTracks(context, tracks)) {
                        onClear();
                      }
                    },
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 20,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Plays the selection (in list order, or shuffled) as the queue.
void playSelectedTracks(
  BuildContext context,
  List<Track> tracks, {
  bool shuffle = false,
}) {
  final playable = tracks.where((track) => track.isReadyToPlay).toList();
  if (playable.isEmpty) {
    CustomSnackBar.info(context, context.tr('selection.noPlayable'));
    return;
  }
  if (shuffle) playable.shuffle();
  context.read<PlayerBloc>().add(
    PlayerQueueSet(playable, startTrack: playable.first),
  );
}

/// Re-queues the failed downloads among [tracks].
Future<void> retrySelectedDownloads(
  BuildContext context,
  List<Track> tracks,
) async {
  final downloads = context.read<DownloadStatusCubit>();
  final failed = tracks
      .where(
        (track) => downloads.state[track.id]?.status == DownloadStatus.failed,
      )
      .toList();
  for (final track in failed) {
    await downloads.retry(track);
  }
  if (!context.mounted || failed.isEmpty) return;
  CustomSnackBar.info(
    context,
    context.tr(
      'download.retryQueuedMany',
      namedArgs: {'count': '${failed.length}'},
    ),
  );
}

/// Asks once, then deletes the tracks one by one (the player releases each
/// first, as for a single delete). Returns true when the user confirmed.
Future<bool> deleteSelectedTracks(
  BuildContext context,
  List<Track> tracks,
) async {
  if (tracks.isEmpty) return false;
  final single = tracks.length == 1;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.l),
      ),
      title: Text(
        single
            ? context.tr('track.deleteTitle')
            : context.tr(
                'track.deleteManyTitle',
                namedArgs: {'count': '${tracks.length}'},
              ),
        style: AppText.display3,
      ),
      content: Text(
        context.tr(single ? 'track.deleteConfirm' : 'track.deleteManyConfirm'),
        style: AppText.bodyM,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(
            context.tr('common.cancel'),
            style: AppText.bodyL.copyWith(color: AppColors.textSub),
          ),
        ),
        TextButton(
          key: const ValueKey('confirm-delete-selected'),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(
            context.tr('common.delete'),
            style: AppText.bodyL.copyWith(color: AppColors.error),
          ),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return false;

  final player = context.read<PlayerBloc>();
  final library = context.read<TrackBloc>();
  var deleted = 0;
  for (final track in tracks) {
    try {
      final released = Completer<void>();
      player.add(PlayerTrackRemoved(track.id, completer: released));
      await released.future;
      final removed = Completer<void>();
      library.add(RemoveTrackEvent(track.id, completer: removed));
      await removed.future;
      deleted++;
    } catch (_) {
      // Counted below; the rest of the selection still goes.
    }
  }
  if (!context.mounted) return true;
  if (deleted == tracks.length) {
    CustomSnackBar.success(
      context,
      single
          ? context.tr('track.deleted')
          : context.tr('track.deletedMany', namedArgs: {'count': '$deleted'}),
    );
  } else {
    CustomSnackBar.error(
      context,
      context.tr(
        'track.deletePartial',
        namedArgs: {'done': '$deleted', 'total': '${tracks.length}'},
      ),
    );
  }
  return true;
}
