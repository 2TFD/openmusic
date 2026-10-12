import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:owlsonic/core/layout/app_layout.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/domain/repositories/audio_player_port.dart';
import 'package:owlsonic/layers/presentation/features/player/bloc/player/player_bloc.dart';
import 'package:owlsonic/layers/presentation/features/player/ui/widgets/progress_line.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/cached_image.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/owlsonic_glyph.dart';

/// Persistent playback bar: track on the left, transport + seek in the centre,
/// queue + volume on the right.
class DesktopPlayerBar extends StatelessWidget {
  const DesktopPlayerBar({
    super.key,
    required this.onOpenPlayer,
    required this.onToggleContext,
    required this.contextOpen,
    required this.onToggleSidebar,
    required this.sidebarOpen,
  });

  final VoidCallback onOpenPlayer;
  final VoidCallback onToggleContext;
  final bool contextOpen;
  final VoidCallback onToggleSidebar;
  final bool sidebarOpen;

  @override
  Widget build(BuildContext context) => BlocBuilder<PlayerBloc, PlayerState>(
    builder: (context, state) {
      final track = state.currentTrack;
      final bloc = context.read<PlayerBloc>();
      return Container(
        height: AppLayout.desktopPlayerHeight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: track == null
                  ? Text(
                      context.tr('player.nothingPlaying'),
                      style: AppText.bodyXS,
                    )
                  : InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: onOpenPlayer,
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CachedImage(
                              url: track.imageUrl,
                              size: 52,
                              fallback: const Icon(
                                Icons.music_note_rounded,
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  track.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.bodyL,
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
                        ],
                      ),
                    ),
            ),
            Expanded(
              flex: 4,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _button(
                            Icons.shuffle,
                            context.tr('player.shuffle'),
                            track == null
                                ? null
                                : () => bloc.add(PlayerShuffleToggled()),
                            selected: state.isShuffleEnabled,
                          ),
                          _button(
                            Icons.skip_previous_rounded,
                            context.tr('player.previous'),
                            state.hasPrev
                                ? () => bloc.add(PlayerSkippedPrevious())
                                : null,
                            size: 22,
                          ),
                          _button(
                            state.isPlaying
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_circle_fill_rounded,
                            state.isPlaying
                                ? context.tr('player.pause')
                                : context.tr('player.play'),
                            track == null
                                ? null
                                : () => bloc.add(PlayerPlayPauseToggled()),
                            size: 34,
                            prominent: true,
                          ),
                          _button(
                            Icons.skip_next_rounded,
                            context.tr('player.next'),
                            state.hasNext
                                ? () => bloc.add(PlayerSkippedNext())
                                : null,
                            size: 22,
                          ),
                          _button(
                            state.loopMode == PlaybackLoopMode.one
                                ? Icons.repeat_one
                                : Icons.repeat,
                            state.loopMode == PlaybackLoopMode.one
                                ? context.tr('player.repeatOne')
                                : context.tr('player.repeat'),
                            track == null
                                ? null
                                : () => bloc.add(PlayerRepeatCycled()),
                            selected: state.loopMode != PlaybackLoopMode.off,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 40,
                            child: Text(
                              _format(state.position),
                              style: AppText.bodyXS,
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 14,
                              child: ProgressLine(
                                progress: state.progress.clamp(0.0, 1.0),
                                onSeek: track == null
                                    ? null
                                    : (progress) => bloc.add(
                                        PlayerSeeked(
                                          Duration(
                                            milliseconds:
                                                (state.duration.inMilliseconds *
                                                        progress)
                                                    .round(),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            child: Text(
                              _format(state.duration),
                              textAlign: TextAlign.end,
                              style: AppText.bodyXS,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: context.tr('player.sidebarToggle'),
                    onPressed: onToggleSidebar,
                    icon: Icon(
                      Icons.view_sidebar_outlined,
                      size: 20,
                      color: sidebarOpen ? AppColors.text : AppColors.textSub,
                    ),
                  ),
                  IconButton(
                    tooltip: context.tr('player.queueToggle'),
                    onPressed: onToggleContext,
                    icon: OwlSonicGlyph(
                      type: OwlSonicGlyphType.queue,
                      color: contextOpen ? AppColors.text : AppColors.textSub,
                    ),
                  ),
                  const Icon(
                    Icons.volume_up_outlined,
                    size: 18,
                    color: AppColors.textSub,
                  ),
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 104),
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 5,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 12,
                          ),
                        ),
                        child: Slider(
                          value: state.volume.clamp(0.0, 1.0),
                          onChanged: (value) =>
                              bloc.add(PlayerVolumeChanged(value)),
                          semanticFormatterCallback: (value) =>
                              '${context.tr('player.volume')} '
                              '${(value * 100).round()}%',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );

  static Widget _button(
    IconData icon,
    String tooltip,
    VoidCallback? action, {
    bool selected = false,
    bool prominent = false,
    double size = 18,
  }) => IconButton(
    tooltip: tooltip,
    onPressed: action,
    visualDensity: VisualDensity.compact,
    icon: Icon(
      icon,
      size: size,
      color: selected || prominent ? AppColors.text : AppColors.textSub,
    ),
  );

  static String _format(Duration value) {
    final minutes = value.inMinutes;
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
