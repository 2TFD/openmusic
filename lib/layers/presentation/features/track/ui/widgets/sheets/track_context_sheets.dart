import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:owlsonic/core/di/di.dart';
import 'package:owlsonic/core/errors/failures/failure.dart';
import 'package:owlsonic/core/services/cloud/cloud_offline_library.dart';
import 'package:owlsonic/core/services/cloud/device_storage_mode_store.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/core/layout/app_layout.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/entities/download_track_task.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/domain/repositories/track_external_actions.dart';
import 'package:owlsonic/layers/presentation/shared/blocs/download_status/download_status_cubit.dart';
import 'package:owlsonic/layers/presentation/features/player/bloc/player/player_bloc.dart';
import 'package:owlsonic/layers/presentation/features/track/bloc/track/track_bloc.dart';
import 'package:owlsonic/layers/presentation/features/playlist/ui/widgets/sheets/add_to_playlist_sheet.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/cached_image.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/snackbars/custom_snack_bar.dart';
import 'package:owlsonic/layers/presentation/shared/models/ui_error.dart';

Future<T?> _showTrackActions<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  if (AppLayout.isDesktopPlatform) {
    return showDialog<T>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.surface,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: builder(dialogContext),
        ),
      ),
    );
  }
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    useRootNavigator: true,
    builder: builder,
  );
}

Future<T?> _showDesktopActionMenu<T>(
  BuildContext context,
  List<PopupMenuEntry<T>> items,
) {
  final rect = _sharePositionOriginOf(context);
  final screen = MediaQuery.sizeOf(context);
  return showMenu<T>(
    context: context,
    position: RelativeRect.fromLTRB(
      rect.left,
      rect.bottom,
      (screen.width - rect.right).clamp(0, screen.width),
      (screen.height - rect.bottom).clamp(0, screen.height),
    ),
    items: items,
  );
}

Future<void> showPlayerTrackActions(
  BuildContext context,
  Track track, {
  ValueChanged<Track>? onStartWave,
}) async {
  final externalActions = context.read<TrackExternalActions>();
  final sharePositionOrigin = _sharePositionOriginOf(context);

  final action = AppLayout.isDesktopPlatform
      ? await _showDesktopActionMenu<_PlayerTrackAction>(context, [
          PopupMenuItem(
            value: _PlayerTrackAction.startWave,
            child: Text(context.tr('waveSession.startWave')),
          ),
          if (track.source.type != SourceType.unknown)
            PopupMenuItem(
              value: _PlayerTrackAction.openSource,
              child: Text(
                context.tr(switch (track.source.type) {
                  SourceType.soundcloud => 'player.openInSoundCloud',
                  SourceType.youtube => 'player.openInYouTube',
                  SourceType.spotify => 'player.openInSpotify',
                  SourceType.localFile ||
                  SourceType.owlsonic => 'player.shareFile',
                  SourceType.unknown => 'player.openSource',
                }),
              ),
            ),
          if (track.source.media?.type == SourceType.youtube)
            PopupMenuItem(
              value: _PlayerTrackAction.openMediaSource,
              child: Text(context.tr('player.openAudioInYouTube')),
            ),
        ])
      : await _showTrackActions<_PlayerTrackAction>(
          context,
          builder: (sheetContext) => _PlayerTrackActionsSheet(
            track: track,
            onStartWave: () =>
                Navigator.of(sheetContext).pop(_PlayerTrackAction.startWave),
            onOpenSource: () =>
                Navigator.of(sheetContext).pop(_PlayerTrackAction.openSource),
            onOpenMediaSource: () => Navigator.of(
              sheetContext,
            ).pop(_PlayerTrackAction.openMediaSource),
          ),
        );
  if (action == null || !context.mounted) return;

  switch (action) {
    case _PlayerTrackAction.startWave:
      if (onStartWave != null) {
        onStartWave(track);
      } else {
        context.read<PlayerBloc>().add(PlayerTrackWaveStarted(track: track));
      }
    case _PlayerTrackAction.openSource:
      try {
        await externalActions.openSource(
          track,
          sharePositionOrigin: sharePositionOrigin,
        );
      } on FileNotFoundFailure {
        if (!context.mounted) return;
        CustomSnackBar.error(
          context,
          context.tr('player.localFileUnavailable'),
        );
      } on TrackNotReadyFailure {
        if (!context.mounted) return;
        CustomSnackBar.error(
          context,
          context.tr('player.localFileUnavailable'),
        );
      } catch (error, stackTrace) {
        if (!context.mounted) return;
        CustomSnackBar.uiError(
          context,
          UiError.fromException(
            error,
            stackTrace,
            operation: 'track_actions.open_source',
          ),
        );
      }
    case _PlayerTrackAction.openMediaSource:
      try {
        await externalActions.openMediaSource(track);
      } catch (error, stackTrace) {
        if (!context.mounted) return;
        CustomSnackBar.uiError(
          context,
          UiError.fromException(
            error,
            stackTrace,
            operation: 'track_actions.open_media_source',
          ),
        );
      }
  }
}

Rect _sharePositionOriginOf(BuildContext context) {
  final renderObject = context.findRenderObject();
  if (renderObject is RenderBox && renderObject.hasSize) {
    return renderObject.localToGlobal(Offset.zero) & renderObject.size;
  }
  return Offset.zero & MediaQuery.sizeOf(context);
}

enum _PlayerTrackAction { startWave, openSource, openMediaSource }

class _PlayerTrackActionsSheet extends StatelessWidget {
  const _PlayerTrackActionsSheet({
    required this.track,
    required this.onStartWave,
    required this.onOpenSource,
    required this.onOpenMediaSource,
  });

  final Track track;
  final VoidCallback onStartWave;
  final VoidCallback onOpenSource;
  final VoidCallback onOpenMediaSource;

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetHandle(),
          _TrackHeader(track: track),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),
          _SheetAction(
            icon: Icons.waves_rounded,
            label: context.tr('waveSession.startWave'),
            onTap: onStartWave,
          ),
          if (track.source.type == SourceType.soundcloud ||
              track.source.type == SourceType.youtube ||
              track.source.type == SourceType.spotify)
            _SheetAction(
              icon: Icons.open_in_new_rounded,
              label: context.tr(switch (track.source.type) {
                SourceType.soundcloud => 'player.openInSoundCloud',
                SourceType.youtube => 'player.openInYouTube',
                SourceType.spotify => 'player.openInSpotify',
                SourceType.localFile ||
                SourceType.owlsonic ||
                SourceType.unknown => 'player.openSource',
              }),
              onTap: onOpenSource,
            ),
          if (track.source.media?.type == SourceType.youtube)
            _SheetAction(
              icon: Icons.play_circle_outline_rounded,
              label: context.tr('player.openAudioInYouTube'),
              onTap: onOpenMediaSource,
            ),
          if (track.source.type == SourceType.localFile)
            _SheetAction(
              icon: Icons.ios_share_rounded,
              label: context.tr('player.shareFile'),
              onTap: onOpenSource,
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// [onSelect] adds a "Select" entry that starts multi-selection with [track].
Future<void> showTrackLibraryActions(
  BuildContext context,
  Track track, {
  VoidCallback? onSelect,
}) async {
  final playerBloc = context.read<PlayerBloc>();
  final offlineAction = _offlineActionFor(track);
  final action = AppLayout.isDesktopPlatform
      ? await _showDesktopActionMenu<_LibraryTrackAction>(context, [
          if (offlineAction != null)
            PopupMenuItem(
              value: offlineAction,
              child: Text(_offlineActionLabel(context, offlineAction)),
            ),
          if (onSelect != null)
            PopupMenuItem(
              value: _LibraryTrackAction.select,
              child: Text(context.tr('selection.select')),
            ),
          PopupMenuItem(
            value: _LibraryTrackAction.startWave,
            child: Text(context.tr('waveSession.startWave')),
          ),
          PopupMenuItem(
            value: _LibraryTrackAction.addToPlaylist,
            child: Text(context.tr('playlist.addToPlaylist')),
          ),
          PopupMenuItem(
            value: _LibraryTrackAction.delete,
            child: Text(
              context.tr('track.deleteFromLibrary'),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ])
      : await _showTrackActions<_LibraryTrackAction>(
          context,
          builder: (sheetContext) => _TrackActionsSheet(
            track: track,
            onSelect: onSelect == null
                ? null
                : () => sheetContext.pop(_LibraryTrackAction.select),
            offlineAction: offlineAction,
            onOfflineAction: offlineAction == null
                ? null
                : () => sheetContext.pop(offlineAction),
            onStartWave: () => sheetContext.pop(_LibraryTrackAction.startWave),
            onDelete: () => sheetContext.pop(_LibraryTrackAction.delete),
            onAddToPlaylist: () =>
                sheetContext.pop(_LibraryTrackAction.addToPlaylist),
          ),
        );
  if (action == null || !context.mounted) return;
  if (action == _LibraryTrackAction.select) {
    onSelect?.call();
    return;
  }
  if (action == _LibraryTrackAction.startWave) {
    playerBloc.add(PlayerTrackWaveStarted(track: track));
    return;
  }

  if (action == _LibraryTrackAction.addToPlaylist) {
    showAddToPlaylistSheet(context, track);
    return;
  }

  if (action == _LibraryTrackAction.downloadToDevice ||
      action == _LibraryTrackAction.removeDownload) {
    await _runOfflineAction(context, track, action);
    return;
  }

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.l),
      ),
      title: Text(context.tr('track.deleteTitle'), style: AppText.display3),
      content: Text(context.tr('track.deleteConfirm'), style: AppText.bodyM),
      actions: [
        TextButton(
          onPressed: () => dialogContext.pop(false),
          child: Text(
            context.tr('common.cancel'),
            style: AppText.bodyL.copyWith(color: AppColors.textSub),
          ),
        ),
        TextButton(
          onPressed: () => dialogContext.pop(true),
          child: Text(
            context.tr('common.delete'),
            style: AppText.bodyL.copyWith(color: AppColors.error),
          ),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  final playerRelease = Completer<void>();
  context.read<PlayerBloc>().add(
    PlayerTrackRemoved(track.id, completer: playerRelease),
  );

  try {
    await playerRelease.future;
    if (!context.mounted) return;
    final removal = Completer<void>();
    context.read<TrackBloc>().add(
      RemoveTrackEvent(track.id, completer: removal),
    );
    await removal.future;
    if (!context.mounted) return;
    CustomSnackBar.success(context, context.tr('track.deleted'));
  } catch (error, stackTrace) {
    if (!context.mounted) return;
    CustomSnackBar.uiError(
      context,
      UiError.fromException(
        error,
        stackTrace,
        operation: 'track_actions.delete',
      ),
    );
  }
}

Future<void> _runOfflineAction(
  BuildContext context,
  Track track,
  _LibraryTrackAction action,
) async {
  final offline = getIt<CloudOfflineLibrary>();
  final download = action == _LibraryTrackAction.downloadToDevice;
  try {
    if (download) {
      CustomSnackBar.info(context, context.tr('cloud.downloading'));
      await offline.downloadTrack(track.id);
    } else {
      await offline.removeDownload(track.id);
    }
    if (!context.mounted) return;
    CustomSnackBar.success(
      context,
      context.tr(download ? 'cloud.downloaded' : 'cloud.removedFromDevice'),
    );
  } catch (error, stackTrace) {
    if (!context.mounted) return;
    CustomSnackBar.uiError(
      context,
      UiError.fromException(
        error,
        stackTrace,
        operation: 'track_actions.offline',
      ),
    );
  }
}

Future<void> showTrackDownloadFailure(
  BuildContext context,
  Track track,
  DownloadTrackTask task,
) async {
  final action = await _showTrackActions<_DownloadFailureAction>(
    context,
    builder: (sheetContext) => _DownloadFailureSheet(
      track: track,
      task: task,
      reason: context.tr(_failureReasonKey(task.failure?.code)),
      onRetry: () => sheetContext.pop(_DownloadFailureAction.retry),
      onCopyDetails: () => sheetContext.pop(_DownloadFailureAction.copyDetails),
    ),
  );
  if (action == null || !context.mounted) return;

  switch (action) {
    case _DownloadFailureAction.retry:
      try {
        await context.read<DownloadStatusCubit>().retry(track);
        if (!context.mounted) return;
        CustomSnackBar.info(context, context.tr('download.retryQueued'));
      } catch (error, stackTrace) {
        if (!context.mounted) return;
        CustomSnackBar.uiError(
          context,
          UiError.fromException(error, stackTrace, operation: 'download.retry'),
        );
      }
    case _DownloadFailureAction.copyDetails:
      final failure = task.failure;
      final details = failure?.details.trim().isNotEmpty == true
          ? failure!.details
          : [
              'trackId: ${task.trackId}',
              'originalUrl: ${task.originalUrl}',
              'status: ${task.status.name}',
              'failureCode: ${failure?.code ?? DownloadFailureCodes.unknown}',
              'failureMessage: ${failure?.message ?? ''}',
            ].join('\n');
      await Clipboard.setData(ClipboardData(text: details));
      if (!context.mounted) return;
      CustomSnackBar.info(context, context.tr('download.detailsCopied'));
  }
}

enum _DownloadFailureAction { retry, copyDetails }

String _failureReasonKey(String? code) {
  return switch (code) {
    DownloadFailureCodes.network => 'download.failureNetwork',
    DownloadFailureCodes.sourceUnavailable => 'download.failureSource',
    DownloadFailureCodes.botCheck => 'download.failureBotCheck',
    DownloadFailureCodes.rateLimited => 'download.failureRateLimited',
    DownloadFailureCodes.fileNotFound => 'download.failureFileNotFound',
    DownloadFailureCodes.filePermission => 'download.failurePermission',
    DownloadFailureCodes.fileSystem => 'download.failureFileSystem',
    DownloadFailureCodes.unsupported => 'download.failureUnsupported',
    _ => 'download.failureUnknown',
  };
}

class _DownloadFailureSheet extends StatelessWidget {
  const _DownloadFailureSheet({
    required this.track,
    required this.task,
    required this.reason,
    required this.onRetry,
    required this.onCopyDetails,
  });

  final Track track;
  final DownloadTrackTask task;
  final String reason;
  final VoidCallback onRetry;
  final VoidCallback onCopyDetails;

  @override
  Widget build(BuildContext context) {
    final failure = task.failure;
    final hasDetails =
        failure?.details.trim().isNotEmpty == true ||
        failure?.message.trim().isNotEmpty == true;

    return _SheetFrame(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetHandle(),
          _TrackHeader(track: track, trailingError: true),
          Text(context.tr('download.failureTitle'), style: AppText.display3),
          const SizedBox(height: 8),
          Text(reason, style: AppText.bodyM),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),
          _SheetAction(
            icon: Icons.refresh,
            label: context.tr('download.retry'),
            onTap: onRetry,
          ),
          if (hasDetails) ...[
            const SizedBox(height: 4),
            _SheetAction(
              icon: Icons.content_copy,
              label: context.tr('download.copyDetails'),
              onTap: onCopyDetails,
            ),
          ],
        ],
      ),
    );
  }
}

enum _LibraryTrackAction {
  select,
  startWave,
  delete,
  addToPlaylist,
  downloadToDevice,
  removeDownload,
}

/// The per-track offline action for a cloud track, or null. In the "offline"
/// storage mode every track is kept on the device, so there is nothing to pick.
_LibraryTrackAction? _offlineActionFor(Track track) {
  if (!track.isCloudTrack) return null;
  if (getIt<DeviceStorageModeStore>().effective == DeviceStorageMode.offline) {
    return null;
  }
  if (track.filePath == null) return _LibraryTrackAction.downloadToDevice;
  if (CloudOfflineLibrary.hasManagedCopy(track)) {
    return _LibraryTrackAction.removeDownload;
  }
  return null;
}

String _offlineActionLabel(BuildContext context, _LibraryTrackAction action) =>
    action == _LibraryTrackAction.downloadToDevice
    ? context.tr('cloud.downloadToDevice')
    : context.tr('cloud.removeFromDevice');

class _TrackActionsSheet extends StatelessWidget {
  const _TrackActionsSheet({
    required this.track,
    required this.onStartWave,
    required this.onDelete,
    required this.onAddToPlaylist,
    this.onSelect,
    this.offlineAction,
    this.onOfflineAction,
  });

  final Track track;
  final VoidCallback onStartWave;
  final VoidCallback onDelete;
  final VoidCallback onAddToPlaylist;
  final VoidCallback? onSelect;
  final _LibraryTrackAction? offlineAction;
  final VoidCallback? onOfflineAction;

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetHandle(),
          _TrackHeader(track: track),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),
          if (onSelect case final select?)
            _SheetAction(
              icon: Icons.check_box_outlined,
              label: context.tr('selection.select'),
              onTap: select,
            ),
          if (offlineAction case final action?)
            _SheetAction(
              icon: action == _LibraryTrackAction.downloadToDevice
                  ? Icons.download_rounded
                  : Icons.cloud_outlined,
              label: _offlineActionLabel(context, action),
              onTap: onOfflineAction!,
            ),
          _SheetAction(
            icon: Icons.waves_rounded,
            label: context.tr('waveSession.startWave'),
            onTap: onStartWave,
          ),
          _SheetAction(
            icon: Icons.playlist_add_rounded,
            label: context.tr('playlist.addToPlaylist'),
            onTap: onAddToPlaylist,
          ),
          _SheetAction(
            icon: Icons.delete_outline,
            label: context.tr('track.deleteFromLibrary'),
            color: AppColors.error,
            onTap: onDelete,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppBlur.sheetColor,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.xl)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: SafeArea(top: false, child: child),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (AppLayout.isDesktopPlatform) return const SizedBox.shrink();
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: AppSpacing.m, bottom: AppSpacing.s),
        width: 32,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.muted2,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _TrackHeader extends StatelessWidget {
  const _TrackHeader({required this.track, this.trailingError = false});

  final Track track;
  final bool trailingError;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.s),
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.s),
              child: CachedImage(url: track.imageUrl, size: 40),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  style: AppText.bodyL,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  track.artists.map((artist) => artist.name).join(', '),
                  style: AppText.bodyM,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (trailingError) ...[
            const SizedBox(width: 12),
            const Icon(Icons.error_outline, color: AppColors.error, size: 22),
          ],
        ],
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.text,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppText.bodyL.copyWith(color: color),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
