import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openmusic/core/themes/app_theme.dart';
import 'package:openmusic/layers/domain/entities/download_track_task.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/presentation/blocs/download_status/download_status_cubit.dart';
import 'package:openmusic/layers/presentation/blocs/player/player_bloc.dart';
import 'package:openmusic/layers/presentation/blocs/track/track_bloc.dart';
import 'package:openmusic/layers/presentation/widgets/cached_image.dart';
import 'package:openmusic/layers/presentation/widgets/snackbars/custom_snack_bar.dart';

Future<void> showTrackLibraryActions(BuildContext context, Track track) async {
  final shouldDelete = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    useRootNavigator: true,
    builder: (sheetContext) => _TrackActionsSheet(
      track: track,
      onDelete: () => sheetContext.pop(true),
    ),
  );
  if (shouldDelete != true || !context.mounted) return;

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
  } catch (_) {
    if (!context.mounted) return;
    CustomSnackBar.error(context, context.tr('track.deleteFailed'));
  }
}

Future<void> showTrackDownloadFailure(
  BuildContext context,
  Track track,
  DownloadTrackTask task,
) async {
  final action = await showModalBottomSheet<_DownloadFailureAction>(
    context: context,
    backgroundColor: Colors.transparent,
    useRootNavigator: true,
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
      } catch (_) {
        if (!context.mounted) return;
        CustomSnackBar.error(context, context.tr('download.retryFailed'));
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

class _TrackActionsSheet extends StatelessWidget {
  const _TrackActionsSheet({required this.track, required this.onDelete});

  final Track track;
  final VoidCallback onDelete;

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
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: SafeArea(top: false, child: child),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
