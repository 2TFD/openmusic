import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:owlsonic/core/layout/app_layout.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/presentation/features/player/bloc/player/player_bloc.dart';
import 'package:owlsonic/layers/presentation/shared/blocs/music_analysis_status/music_analysis_status_cubit.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/cached_image.dart';

/// Right-hand context pane: details of the current track and the queue. It
/// only reads existing player/analysis state.
class DesktopContextPanel extends StatelessWidget {
  const DesktopContextPanel({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Container(
    width: AppLayout.contextPanelWidth,
    decoration: const BoxDecoration(
      color: AppColors.surface,
      border: Border(left: BorderSide(color: AppColors.border)),
    ),
    child: BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        final track = state.currentTrack;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 8, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.tr('player.nowPlaying').toUpperCase(),
                      style: AppText.label,
                    ),
                  ),
                  IconButton(
                    tooltip: context.tr('common.close'),
                    onPressed: onClose,
                    icon: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: [
                  if (track == null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        context.tr('context.nothingSelected'),
                        textAlign: TextAlign.center,
                        style: AppText.bodyM,
                      ),
                    )
                  else
                    _NowPlayingDetails(track: track),
                  const SizedBox(height: 24),
                  Text(
                    context.tr('player.queue').toUpperCase(),
                    style: AppText.label,
                  ),
                  const SizedBox(height: 8),
                  if (state.queue.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        context.tr('context.queueEmpty'),
                        style: AppText.bodyM,
                      ),
                    )
                  else
                    for (var i = 0; i < state.queue.length; i++)
                      _QueueRow(
                        track: state.queue[i],
                        current: i == state.currentIndex,
                        onTap: () => context.read<PlayerBloc>().add(
                          PlayerTrackSelected(index: i),
                        ),
                      ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _NowPlayingDetails extends StatelessWidget {
  const _NowPlayingDetails({required this.track});

  final Track track;

  @override
  Widget build(BuildContext context) {
    final artists = track.artists.map((a) => a.name).join(', ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.m),
            child: ColoredBox(
              color: AppColors.surface2,
              child: LayoutBuilder(
                builder: (context, c) => CachedImage(
                  url: track.imageUrl,
                  size: c.maxWidth,
                  fallback: const Icon(
                    Icons.music_note_rounded,
                    size: 40,
                    color: AppColors.muted,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          track.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppText.display3,
        ),
        if (artists.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            artists,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.bodyM,
          ),
        ],
        if (track.album != null && track.album!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            track.album!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.bodyXS,
          ),
        ],
        const SizedBox(height: 12),
        BlocBuilder<MusicAnalysisStatusCubit, MusicAnalysisStatusState>(
          builder: (context, analysis) {
            final key = analysis.isAnalyzed(track.id)
                ? 'context.analysisReady'
                : analysis.isCloudFailed(track.id)
                ? 'cloud.analysisFailed'
                : analysis.isCloudAnalyzing(track.id) ||
                      (!track.isCloudTrack &&
                          analysis.activeTasks.containsKey(track.id))
                ? 'context.analyzing'
                : null;
            if (key == null) return const SizedBox.shrink();
            return Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: key == 'context.analysisReady'
                        ? AppColors.success
                        : AppColors.muted,
                  ),
                ),
                const SizedBox(width: 8),
                Text(context.tr(key), style: AppText.bodyXS),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _QueueRow extends StatelessWidget {
  const _QueueRow({
    required this.track,
    required this.current,
    required this.onTap,
  });

  final Track track;
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(8),
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CachedImage(
              url: track.imageUrl,
              size: 36,
              fallback: const Icon(
                Icons.music_note_rounded,
                size: 16,
                color: AppColors.muted,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodyS.copyWith(
                    color: current ? AppColors.text : AppColors.imageOverlay,
                    fontWeight: current ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                Text(
                  track.artists.map((a) => a.name).join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodyXS,
                ),
              ],
            ),
          ),
          if (current)
            const Icon(Icons.equalizer, size: 16, color: AppColors.text),
        ],
      ),
    ),
  );
}
