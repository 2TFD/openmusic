import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/domain/entities/download_track_task.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:owlsonic/layers/presentation/shared/blocs/music_analysis_status/music_analysis_status_cubit.dart';
import 'package:owlsonic/layers/domain/entities/music_analysis_task.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/cached_image.dart';

class TrackItem extends StatelessWidget {
  final Track track;
  final bool isCurrent;
  final bool isPlaying;
  final bool isAvailable;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onMoreTap;
  final DownloadTrackTask? downloadTask;
  final VoidCallback? onDownloadStatusTap;

  const TrackItem({
    super.key,
    required this.track,
    required this.isCurrent,
    required this.isPlaying,
    required this.isAvailable,
    required this.onTap,
    this.onLongPress,
    this.onMoreTap,
    this.downloadTask,
    this.onDownloadStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: isCurrent
            ? BoxDecoration(
                border: Border.all(color: AppColors.border, width: 0.5),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
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
                    style: GoogleFonts.figtree(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (_pendingDownload case final status?) ...[
                        TrackDownloadPendingLabel(status: status),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          track.artists.map((a) => a.name).join(', '),
                          style: GoogleFonts.figtree(
                            fontSize: 12,
                            color: AppColors.textSub,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _TrailingControls(
              status: _buildStatus(context),
              onMoreTap: onMoreTap,
            ),
          ],
        ),
      ),
    );
  }

  /// Queued or downloading, for a track that has no audio yet.
  DownloadStatus? get _pendingDownload {
    if (track.filePath != null || track.isCloudTrack) return null;
    final status = downloadTask?.status;
    return status == DownloadStatus.queued ||
            status == DownloadStatus.downloading
        ? status
        : null;
  }

  Widget _buildStatus(BuildContext context) {
    // Cloud tracks stream without a local file; they are not "downloads".
    if (track.filePath == null && !track.isCloudTrack) {
      final status = downloadTask?.status;
      if (status == DownloadStatus.failed) {
        return IconButton(
          key: ValueKey('track-download-failed-${track.id}'),
          onPressed: onDownloadStatusTap,
          icon: const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 20,
          ),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 32, height: 32),
        );
      }
      if (status == DownloadStatus.downloading) {
        return const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: AppColors.accent,
          ),
        );
      }
      if (status == DownloadStatus.queued) {
        return const Icon(
          Icons.cloud_download_outlined,
          color: AppColors.muted,
          size: 20,
        );
      }
      return const Icon(
        Icons.cloud_off_sharp,
        color: AppColors.muted,
        size: 20,
      );
    }

    final analysisState = context.watch<MusicAnalysisStatusCubit>().state;
    final activeTask = analysisState.activeTasks[track.id];
    final isAnalyzed = analysisState.isAnalyzed(track.id);

    if (analysisState.isCloudFailed(track.id)) {
      return Tooltip(
        key: ValueKey('track-cloud-analysis-failed-${track.id}'),
        message: _localized(context, 'cloud.analysisFailed', 'Analysis failed'),
        child: const Icon(
          Icons.error_outline,
          color: AppColors.muted,
          size: 20,
        ),
      );
    }
    if (analysisState.isCloudAnalyzing(track.id)) {
      return Tooltip(
        key: ValueKey('track-cloud-analyzing-${track.id}'),
        message: _localized(context, 'cloud.analyzing', 'Analyzing'),
        child: const Icon(
          Icons.pending_outlined,
          color: AppColors.muted,
          size: 20,
        ),
      );
    }
    if (activeTask != null && !track.isCloudTrack) {
      if (activeTask.status == MusicAnalysisTaskStatus.failed) {
        return IconButton(
          key: ValueKey('track-analysis-failed-${track.id}'),
          tooltip: _localized(
            context,
            'analysis.viewError',
            'View analysis error',
          ),
          onPressed: () => _showAnalysisFailure(context, activeTask),
          icon: const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 20,
          ),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 32, height: 32),
        );
      }
      if (activeTask.status == MusicAnalysisTaskStatus.running) {
        return const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: AppColors.muted,
          ),
        );
      }
      if (activeTask.status == MusicAnalysisTaskStatus.queued) {
        return const Icon(
          Icons.pending_outlined,
          color: AppColors.muted,
          size: 20,
        );
      }
    } else if (isAnalyzed) {
      // OwlSonic has learned this song's mood, so Wave can use it.
      final label = _localized(
        context,
        'library.readyForWave',
        'Ready for Wave',
      );
      return Tooltip(
        key: ValueKey('track-ready-for-wave-${track.id}'),
        message: label,
        child: Semantics(
          label: label,
          child: const Icon(
            Icons.check_circle_outline,
            color: AppColors.muted,
            size: 20,
          ),
        ),
      );
    }

    if (isCurrent) return _PlayingIndicator(isPlaying: isPlaying);
    final duration = Text(
      _formatDuration(track.duration),
      style: GoogleFonts.figtree(fontSize: 12, color: AppColors.muted),
      overflow: TextOverflow.ellipsis,
    );
    if (!track.isCloudTrack) return duration;
    // Cloud track: a file path means a copy is on this device, otherwise it
    // streams from OwlSonic Cloud.
    final onDevice = track.filePath != null;
    final label = onDevice
        ? _localized(context, 'cloud.onDevice', 'Saved on this device')
        : _localized(context, 'cloud.inCloud', 'In OwlSonic Cloud');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          key: ValueKey('track-cloud-state-${track.id}'),
          message: label,
          child: Semantics(
            label: label,
            child: Icon(
              onDevice ? Icons.download_done : Icons.cloud_outlined,
              color: AppColors.muted,
              size: 16,
            ),
          ),
        ),
        const SizedBox(width: 6),
        duration,
      ],
    );
  }

  Future<void> _showAnalysisFailure(
    BuildContext context,
    MusicAnalysisTask task,
  ) {
    final details = [
      if (task.lastErrorCode?.trim().isNotEmpty == true)
        task.lastErrorCode!.trim(),
      if (task.lastError?.trim().isNotEmpty == true) task.lastError!.trim(),
    ].join('\n\n');
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          _localized(dialogContext, 'analysis.failureTitle', 'Analysis failed'),
          style: AppText.display3,
        ),
        content: SelectableText(
          details.isEmpty
              ? _localized(
                  dialogContext,
                  'analysis.failureUnknown',
                  'The track could not be analyzed. Try again later.',
                )
              : details,
          style: AppText.bodyM,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(_localized(dialogContext, 'common.close', 'Close')),
          ),
        ],
      ),
    );
  }

  String _localized(BuildContext context, String key, String fallback) {
    if (EasyLocalization.of(context) == null) return fallback;
    return context.tr(key);
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _TrailingControls extends StatelessWidget {
  final Widget status;
  final VoidCallback? onMoreTap;

  const _TrailingControls({required this.status, required this.onMoreTap});

  @override
  Widget build(BuildContext context) {
    if (onMoreTap == null) return status;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 36, child: Center(child: status)),
        const SizedBox(width: 4),
        IconButton(
          onPressed: onMoreTap,
          icon: const Icon(Icons.more_vert, color: AppColors.textSub, size: 20),
          tooltip: MaterialLocalizations.of(context).showMenuTooltip,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 44, height: 44),
        ),
      ],
    );
  }
}

class _PlayingIndicator extends StatefulWidget {
  final bool isPlaying;

  const _PlayingIndicator({required this.isPlaying});
  @override
  State<_PlayingIndicator> createState() => _PlayingIndicatorState();
}

class _PlayingIndicatorState extends State<_PlayingIndicator>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      4,
      (i) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + i * 80),
      )..repeat(reverse: true),
    );

    _anims = _controllers
        .map(
          (c) => Tween<double>(
            begin: 3,
            end: 12,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)),
        )
        .toList();
    _anims.first.addListener(() {});
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: 14,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          4,
          (i) => AnimatedBuilder(
            animation: _anims[i],
            builder: (_, _) => Container(
              width: 2.5,
              height: widget.isPlaying
                  ? _anims[i].value
                  : 1 + (i * 2).toDouble(),
              decoration: BoxDecoration(
                color: AppColors.text,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// «Скачивается…» / «В очереди» next to a freshly imported track. [compact]
/// shows only the icon, with the text as a tooltip (desktop table).
class TrackDownloadPendingLabel extends StatelessWidget {
  const TrackDownloadPendingLabel({
    super.key,
    required this.status,
    this.compact = false,
  });

  final DownloadStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final downloading = status == DownloadStatus.downloading;
    final text = context.tr(
      downloading ? 'download.inProgress' : 'download.queued',
    );
    final icon = downloading
        ? const SizedBox.square(
            dimension: 10,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: AppColors.accent,
            ),
          )
        : const Icon(Icons.schedule_rounded, size: 12, color: AppColors.text);
    if (compact) {
      return Tooltip(
        key: const ValueKey('track-download-pending'),
        message: text,
        child: icon,
      );
    }
    return Row(
      key: const ValueKey('track-download-pending'),
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.figtree(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}
