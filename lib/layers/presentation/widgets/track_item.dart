import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openmusic/core/themes/app_theme.dart';
import 'package:openmusic/layers/domain/entities/download_track_task.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/presentation/widgets/cached_image.dart';

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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
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
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFC0C0C0),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    track.artists.map((a) => a.name).join(', '),
                    style: GoogleFonts.figtree(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _TrailingControls(status: _buildStatus(), onMoreTap: onMoreTap),
          ],
        ),
      ),
    );
  }

  Widget _buildStatus() {
    if (track.filePath == null) {
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
            color: AppColors.muted,
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
      return const Icon(Icons.cloud_off_sharp, color: AppColors.muted);
    }
    if (isCurrent) return _PlayingIndicator(isPlaying: isPlaying);
    return Text(
      _formatDuration(track.duration),
      style: GoogleFonts.figtree(fontSize: 11, color: AppColors.muted2),
      overflow: TextOverflow.ellipsis,
    );
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
          icon: const Icon(Icons.more_vert, color: AppColors.muted, size: 20),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 32, height: 32),
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
