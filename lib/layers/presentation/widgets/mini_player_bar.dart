import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openmusic/core/di/di.dart';
import 'package:openmusic/core/themes/app_theme.dart';
import 'package:openmusic/core/services/audio_player/audio_player_service.dart';
import 'package:openmusic/layers/presentation/blocs/player/player_bloc.dart';
import 'package:openmusic/layers/presentation/screens/player_screen.dart';
import 'package:openmusic/layers/presentation/widgets/cached_image.dart';
import 'package:openmusic/layers/presentation/widgets/progress_line.dart';

class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        if (state.currentTrack == null) return const SizedBox.shrink();
        return _MiniPlayerContent(state: state);
      },
    );
  }
}

class _MiniPlayerContent extends StatefulWidget {
  final PlayerState state;
  const _MiniPlayerContent({required this.state});

  @override
  State<_MiniPlayerContent> createState() => _MiniPlayerContentState();
}

class _MiniPlayerContentState extends State<_MiniPlayerContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _slideAnim = Tween<double>(
      begin: 20,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _slideAnim.value),
        child: Opacity(opacity: _fadeAnim.value, child: child),
      ),
      child: _MiniPlayerLayout(state: widget.state),
    );
  }
}

class _MiniPlayerLayout extends StatefulWidget {
  final PlayerState state;
  const _MiniPlayerLayout({required this.state});

  @override
  State<_MiniPlayerLayout> createState() => _MiniPlayerLayoutState();
}

class _MiniPlayerLayoutState extends State<_MiniPlayerLayout> {
  double minHeight = 75;
  late final PageController pageController;
  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: widget.state.currentIndex);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _MiniPlayerLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.currentIndex != oldWidget.state.currentIndex) {
      pageController.jumpToPage(widget.state.currentIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.state.progress;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      height: minHeight,
      child: PageView.builder(
        controller: pageController,
        itemCount: widget.state.queue.length,
        onPageChanged: (value) {
          context.read<PlayerBloc>().add(PlayerIndexSeeked(index: value));
        },
        itemBuilder: (context, index) {
          final track = widget.state.queue[index];

          return GestureDetector(
            onTap: () {
              showModalBottomSheet(
                useSafeArea: true,
                isScrollControlled: true,
                backgroundColor: AppColors.bg,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.xl),
                  ),
                ),
                context: context,
                builder: (_) => BlocProvider.value(
                  value: context.read<PlayerBloc>(),
                  child: const PlayerScreen(),
                ),
              );
            },

            child: Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x80000000),
                    blurRadius: 20,
                    offset: Offset(0, -2),
                  ),
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 32,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(-0.7, 0),
                          radius: 1.0,
                          colors: [Color(0x335A3C8C), Colors.transparent],
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: ProgressLine(progress: progress),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 12, 12, 10),
                    child: Row(
                      children: [
                        _Cover(artworkUrl: track.imageUrl),
                        const SizedBox(width: 12),

                        Expanded(
                          child: _TrackInfo(
                            title: track.title,
                            artist: track.artists.map((e) => e.name).join(', '),
                          ),
                        ),
                        const SizedBox(width: 8),

                        _Controls(isPlaying: widget.state.isPlaying),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  final String? artworkUrl;
  const _Cover({this.artworkUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A2040), Color(0xFF14101E)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: artworkUrl != null
          ? CachedImage(url: artworkUrl, size: 44)
          : const _DefaultCoverIcon(),
    );
  }
}

class _DefaultCoverIcon extends StatelessWidget {
  const _DefaultCoverIcon();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '♪',
        style: TextStyle(fontSize: 18, color: Color(0xFF555555)),
      ),
    );
  }
}

class _TrackInfo extends StatelessWidget {
  final String title;
  final String artist;
  const _TrackInfo({required this.title, required this.artist});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
            letterSpacing: -0.2,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 2),
        Text(
          artist,
          style: GoogleFonts.figtree(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.muted,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  final bool isPlaying;
  const _Controls({required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CtrlBtn(
          icon: Icons.skip_previous_rounded,
          onTap: () => getIt<AudioPlayerService>().skipToPrevious(),
        ),
        const SizedBox(width: 4),
        _PlayBtn(isPlaying: isPlaying),
        const SizedBox(width: 4),
        _CtrlBtn(
          icon: Icons.skip_next_rounded,
          onTap: () => getIt<AudioPlayerService>().skipToNext(),
        ),
      ],
    );
  }
}

class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CtrlBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(icon, color: AppColors.text, size: 20),
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
        duration: const Duration(milliseconds: 150),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: isPlaying ? 0.2 : 0.1),
              blurRadius: isPlaying ? 16 : 8,
              spreadRadius: isPlaying ? 1 : 0,
            ),
          ],
        ),
        child: Icon(
          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: AppColors.bg,
          size: 22,
        ),
      ),
    );
  }
}
