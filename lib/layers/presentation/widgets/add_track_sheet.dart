import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openmusic/core/themes/app_theme.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';
import 'package:openmusic/layers/presentation/blocs/add_track/add_track_bloc.dart';
import 'package:openmusic/layers/presentation/widgets/cached_image.dart';
import 'package:openmusic/layers/presentation/widgets/snackbars/custom_snack_bar.dart';

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
            CustomSnackBar.trackAdded(context, state.track.title);
            Navigator.pop(context);
            context.read<AddTrackBloc>().add(const ResetAddTrack());
          } else if (state is AddTrackError) {
            CustomSnackBar.error(context, 'Error: ${state.message.tr()}');
          }
        },
        builder: (context, state) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(top: BorderSide(color: AppColors.border)),
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
                const _Handle(),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _buildBody(context, state, url),
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
      return const _LoadingBody(key: ValueKey('loading'));
    } else if (state is AddTrackPreviewLoaded) {
      return _PreviewBody(
        key: const ValueKey('preview'),
        preview: state.preview,
        adding: false,
        onAdd: () {
          context.read<AddTrackBloc>().add(AddTrackToLibrary(state.preview));
        },
        onCancel: () => Navigator.pop(context),
      );
    } else if (state is AddTrackLoading) {
      return _PreviewBody(
        key: const ValueKey('preview_loading'),
        preview: state.preview,
        adding: true,
        onAdd: () {},
        onCancel: () {},
      );
    } else if (state is AddTrackError) {
      return _ErrorBody(
        key: const ValueKey('error'),
        message: state.message.tr(),
        onRetry: () {
          context.read<AddTrackBloc>().add(FetchTrackPreview(url));
        },
        onCancel: () => Navigator.pop(context),
      );
    } else if (state is AddTrackSuccess) {
      return _PreviewBody(
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
      album: album,
      artworkUrl: imageUrl,
      duration: duration,
      source: source.type,
      originalUrl: source.originalUrl,
      year: null,
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.muted2,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Row(
        children: [
          _Shimmer(width: 64, height: 64, radius: 12),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Shimmer(width: double.infinity, height: 14, radius: 7),
                SizedBox(height: 8),
                _Shimmer(width: 140, height: 12, radius: 6),
                SizedBox(height: 8),
                _Shimmer(width: 80, height: 10, radius: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Shimmer extends StatefulWidget {
  final double width, height, radius;
  const _Shimmer({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          color: Color.lerp(
            AppColors.surface2,
            const Color(0xFF252525),
            _ctrl.value,
          ),
        ),
      ),
    );
  }
}

class _PreviewBody extends StatelessWidget {
  final TrackPreview preview;
  final bool adding;
  final VoidCallback onAdd;
  final VoidCallback onCancel;

  const _PreviewBody({
    super.key,
    required this.preview,
    required this.adding,
    required this.onAdd,
    required this.onCancel,
  });

  String _fmt(Duration? d) {
    if (d == null) return '—';
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.surface2,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x60000000),
                      blurRadius: 20,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                clipBehavior: Clip.hardEdge,
                child: preview.artworkUrl != null
                    ? CachedImage(url: preview.artworkUrl, size: 40)
                    : const Icon(Icons.music_note, color: AppColors.muted),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preview.title,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                        letterSpacing: -0.4,
                        height: 1.15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preview.artist,
                      style: GoogleFonts.figtree(
                        fontSize: 13,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _SourceBadge(source: preview.source),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: const BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                if (preview.duration != null)
                  _DetailItem(
                    label: context.tr('track.duration'),
                    value: _fmt(preview.duration),
                  ),
                if (preview.album != null) ...[
                  const SizedBox(width: 24),
                  _DetailItem(
                    label: context.tr('track.album'),
                    value: preview.album!,
                  ),
                ],
                if (preview.year != null) ...[
                  const SizedBox(width: 24),
                  _DetailItem(
                    label: context.tr('track.year'),
                    value: preview.year.toString(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          _AddButton(adding: adding, onTap: onAdd),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onCancel,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: Text(
                  context.tr('track.cancel'),
                  style: GoogleFonts.figtree(
                    fontSize: 13,
                    color: AppColors.muted,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  final SourceType source;
  const _SourceBadge({required this.source});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 3, 10, 3),
      decoration: BoxDecoration(
        color: const Color(0x1AFF5500),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x26FF5500)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFF7744),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            source.name,
            style: GoogleFonts.figtree(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFF9944),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label, value;
  const _DetailItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label.toUpperCase(),
        style: GoogleFonts.figtree(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
          color: AppColors.muted,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        value,
        style: GoogleFonts.figtree(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.text,
        ),
      ),
    ],
  );
}

class _AddButton extends StatelessWidget {
  final bool adding;
  final VoidCallback onTap;
  const _AddButton({required this.adding, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: adding ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: adding ? const Color(0xFFCCCCCC) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: adding ? 0.05 : 0.12),
              blurRadius: 20,
            ),
          ],
        ),
        child: Center(
          child: adding
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.bg,
                  ),
                )
              : Text(
                  '+ Добавить в библиотеку',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.bg,
                    letterSpacing: -0.2,
                  ),
                ),
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;
  final VoidCallback onCancel;

  const _ErrorBody({
    super.key,
    this.message,
    required this.onRetry,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0x1AFF3C3C),
              border: Border.all(color: const Color(0x26FF3C3C)),
            ),
            child: const Icon(
              Icons.close_rounded,
              color: Color(0xFFFF6B6B),
              size: 22,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.tr('track.failedToLoad'),
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message ?? context.tr('track.unavailable'),
            style: GoogleFonts.figtree(
              fontSize: 12,
              color: AppColors.muted,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                context.tr('track.retry'),
                style: GoogleFonts.figtree(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onCancel,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                context.tr('track.cancel'),
                style: GoogleFonts.figtree(
                  fontSize: 13,
                  color: AppColors.muted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessToast extends StatefulWidget {
  final Track track;
  final VoidCallback onDone;
  const _SuccessToast({required this.track, required this.onDone});

  @override
  State<_SuccessToast> createState() => _SuccessToastState();
}

class _SuccessToastState extends State<_SuccessToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _slide, _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slide = Tween<double>(
      begin: 60,
      end: 0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();

    Future.delayed(const Duration(milliseconds: 2600), () async {
      if (mounted) {
        await _ctrl.reverse();
        widget.onDone();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Positioned(
      left: 12,
      right: 12,
      bottom: bottomPad + 16,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, _slide.value),
          child: Opacity(opacity: _fade.value, child: child),
        ),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E1E1E)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x50000000),
                  blurRadius: 20,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.surface,
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: widget.track.imageUrl != null
                      ? CachedImage(url: widget.track.imageUrl, size: 38)
                      : const Icon(
                          Icons.music_note,
                          color: AppColors.muted,
                          size: 18,
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '✓ Добавлено в библиотеку',
                        style: GoogleFonts.figtree(
                          fontSize: 10,
                          color: const Color(0xFF4ADE80),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${widget.track.title} — ${widget.track.artists}',
                        style: GoogleFonts.figtree(
                          fontSize: 12,
                          color: AppColors.text,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0x1A4ADE80),
                    border: Border.all(color: const Color(0x334ADE80)),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF4ADE80),
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
