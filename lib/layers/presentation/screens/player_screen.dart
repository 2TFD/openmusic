import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart' show LoopMode;
import 'package:openmusic/core/themes/app_theme.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/presentation/blocs/player/player_bloc.dart';
import 'package:openmusic/layers/presentation/blocs/wave/wave_bloc.dart';
import 'package:openmusic/layers/domain/entities/wave_config.dart';
import 'package:openmusic/layers/presentation/widgets/cached_image.dart';
import 'package:openmusic/layers/presentation/widgets/progress_line.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        final track = state.currentTrack;
        if (track == null) return const _EmptyState();
        return _PlayerBody(state: state, track: track);
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(child: Text('Nothing playing', style: AppText.bodyM)),
    );
  }
}

class _PlayerBody extends StatelessWidget {
  final PlayerState state;
  final Track track;

  const _PlayerBody({required this.state, required this.track});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final artworkSize = (screenWidth * 0.78).clamp(240.0, 340.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        const _DragHandle(),
        const SizedBox(height: 28),

        _Artwork(track: track, size: artworkSize, isLoading: state.isLoading),
        const SizedBox(height: 28),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _TrackMeta(track: track)),
              const SizedBox(width: 8),
              _WaveBtn(track: track),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
          child: _SeekBar(state: state),
        ),
        const SizedBox(height: 28),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: _ControlsRow(state: state),
        ),
        const SizedBox(height: 20),

        _QueueButton(
          queue: state.queue,
          currentIndex: state.currentIndex,
          shuffleEnabled: state.shuffleEnabled,
          shuffleIndices: state.shuffleIndices,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.muted2,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _Artwork extends StatelessWidget {
  final Track track;
  final double size;
  final bool isLoading;

  const _Artwork({
    required this.track,
    required this.size,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppAnim.fast,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: Container(
        key: ValueKey(track.imageUrl ?? track.id),
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.l),
          color: AppColors.surface,
          boxShadow: AppShadows.cover,
        ),
        clipBehavior: Clip.hardEdge,
        child: _ArtworkContent(track: track, isLoading: isLoading, size: size),
      ),
    );
  }
}

class _ArtworkContent extends StatelessWidget {
  final Track track;
  final bool isLoading;
  final double size;

  const _ArtworkContent({
    required this.track,
    required this.isLoading,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        color: AppColors.surface,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.muted,
            strokeWidth: 1.5,
          ),
        ),
      );
    }
    if (track.imageUrl != null) {
      return CachedImage(url: track.imageUrl, size: size);
    }
    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Icon(
          Icons.music_note_rounded,
          color: AppColors.muted2,
          size: 48,
        ),
      ),
    );
  }
}

class _TrackMeta extends StatelessWidget {
  final Track track;

  const _TrackMeta({required this.track});

  @override
  Widget build(BuildContext context) {
    final artistStr = track.artists.map((a) => a.name).join(', ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          track.title,
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: AppColors.text,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (artistStr.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            artistStr,
            style: AppText.bodyM,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class _SeekBar extends StatelessWidget {
  final PlayerState state;

  const _SeekBar({required this.state});

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProgressLine(
          progress: state.progress,
          onSeek: (value) {
            final pos = Duration(
              milliseconds: (state.duration.inMilliseconds * value).round(),
            );
            context.read<PlayerBloc>().add(PlayerSeeked(pos));
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_fmt(state.position), style: AppText.bodyXS),
            Text(_fmt(state.duration), style: AppText.bodyXS),
          ],
        ),
      ],
    );
  }
}

class _ControlsRow extends StatelessWidget {
  final PlayerState state;

  const _ControlsRow({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _ShuffleBtn(enabled: state.shuffleEnabled),
        _SkipBtn(
          icon: Icons.skip_previous_rounded,
          enabled: state.hasPrev,
          onTap: () => context.read<PlayerBloc>().add(PlayerSkippedPrevious()),
        ),
        _PlayBtn(isPlaying: state.isPlaying),
        _SkipBtn(
          icon: Icons.skip_next_rounded,
          enabled: state.hasNext,
          onTap: () => context.read<PlayerBloc>().add(PlayerSkippedNext()),
        ),
        _RepeatBtn(mode: state.loopMode),
      ],
    );
  }
}

class _ShuffleBtn extends StatelessWidget {
  final bool enabled;

  const _ShuffleBtn({required this.enabled});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<PlayerBloc>().add(PlayerShuffleToggled()),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Icon(
            Icons.shuffle_rounded,
            color: enabled ? AppColors.text : AppColors.muted,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _RepeatBtn extends StatelessWidget {
  final LoopMode mode;

  const _RepeatBtn({required this.mode});

  @override
  Widget build(BuildContext context) {
    final isActive = mode != LoopMode.off;
    final icon = mode == LoopMode.one
        ? Icons.repeat_one_rounded
        : Icons.repeat_rounded;

    return GestureDetector(
      onTap: () => context.read<PlayerBloc>().add(PlayerRepeatCycled()),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Icon(
            icon,
            color: isActive ? AppColors.text : AppColors.muted,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _SkipBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _SkipBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Icon(
            icon,
            color: enabled ? AppColors.text : AppColors.muted2,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _PlayBtn extends StatelessWidget {
  final bool isPlaying;

  const _PlayBtn({required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<PlayerBloc>().add(PlayerPlayPauseToggled()),
      child: AnimatedContainer(
        duration: AppAnim.fast,
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
          boxShadow: AppShadows.playButtonGlow(
            intensity: isPlaying ? 1.0 : 0.4,
          ),
        ),
        child: Icon(
          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: AppColors.bg,
          size: 30,
        ),
      ),
    );
  }
}

class _WaveBtn extends StatelessWidget {
  final Track track;

  const _WaveBtn({required this.track});

  WaveConfig? _configOf(WaveState state) => switch (state) {
    WaveReady(:final config) => config,
    WaveEmpty(:final config) => config,
    WaveGenerating(:final config) => config,
    WaveError(:final config) => config,
    WaveInitial() => null,
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WaveBloc, WaveState>(
      builder: (context, state) {
        final config = _configOf(state);
        final inWave = config?.tracks.any((t) => t.id == track.id) ?? false;

        return GestureDetector(
          onTap: () {
            final bloc = context.read<WaveBloc>();
            if (inWave) {
              bloc.add(WaveRemoveTrack(track));
            } else {
              bloc.add(WaveAddTrack(track));
            }
          },
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: Icon(
                Icons.waves_rounded,
                color: inWave ? AppColors.text : AppColors.muted,
                size: 20,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QueueButton extends StatelessWidget {
  final List<Track> queue;
  final int currentIndex;
  final bool shuffleEnabled;
  final List<int>? shuffleIndices;

  const _QueueButton({
    required this.queue,
    required this.currentIndex,
    required this.shuffleEnabled,
    required this.shuffleIndices,
  });

  @override
  Widget build(BuildContext context) {
    if (queue.isEmpty) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => _showQueue(context),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.queue_music_rounded,
              color: AppColors.muted,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text('QUEUE', style: AppText.label),
          ],
        ),
      ),
    );
  }

  void _showQueue(BuildContext context) {
    final bloc = context.read<PlayerBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: _QueueSheet(
          queue: queue,
          currentIndex: currentIndex,
          shuffleEnabled: shuffleEnabled,
          shuffleIndices: shuffleIndices,
        ),
      ),
    );
  }
}

class _QueueSheet extends StatelessWidget {
  final List<Track> queue;
  final int currentIndex;
  final bool shuffleEnabled;
  final List<int>? shuffleIndices;

  const _QueueSheet({
    required this.queue,
    required this.currentIndex,
    required this.shuffleEnabled,
    required this.shuffleIndices,
  });

  List<({Track track, int originalIndex})> _orderedItems() {
    final indices =
        shuffleEnabled &&
            shuffleIndices != null &&
            shuffleIndices!.length == queue.length
        ? shuffleIndices!
        : List.generate(queue.length, (i) => i);
    return [for (final i in indices) (track: queue[i], originalIndex: i)];
  }

  int _currentDisplayIndex(List<({Track track, int originalIndex})> items) {
    return items.indexWhere((e) => e.originalIndex == currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final items = _orderedItems();
    final currentDisplayIdx = _currentDisplayIndex(items);
    final screenHeight = MediaQuery.sizeOf(context).height;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.65),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          const _DragHandle(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
            child: Row(
              children: [
                Text('UP NEXT', style: AppText.label),
                if (shuffleEnabled) ...[
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.shuffle_rounded,
                    color: AppColors.muted,
                    size: 11,
                  ),
                ],
                const Spacer(),
                Text('${queue.length} tracks', style: AppText.bodyXS),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.l,
                4,
                AppSpacing.l,
                bottomPad + 16,
              ),
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                final item = items[i];
                return _QueueItem(
                  track: item.track,
                  isCurrent: i == currentDisplayIdx,
                  onTap: () {
                    ctx.read<PlayerBloc>().add(
                      PlayerIndexSeeked(index: item.originalIndex),
                    );
                    Navigator.of(ctx).pop();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueItem extends StatelessWidget {
  final Track track;
  final bool isCurrent;
  final VoidCallback onTap;

  const _QueueItem({
    required this.track,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.s),
          color: isCurrent ? AppColors.surface2 : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.xs),
                color: AppColors.surface2,
              ),
              clipBehavior: Clip.hardEdge,
              child: track.imageUrl != null
                  ? CachedImage(url: track.imageUrl, size: 40)
                  : const Center(
                      child: Icon(
                        Icons.music_note_rounded,
                        color: AppColors.muted2,
                        size: 16,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: AppColors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    track.artists.map((a) => a.name).join(', '),
                    style: AppText.bodyXS,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isCurrent)
              const Icon(
                Icons.equalizer_rounded,
                color: AppColors.muted,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}
