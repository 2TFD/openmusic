import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';

import 'package:owlsonic/layers/domain/entities/track_preview.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/cached_image.dart';

class AddTrackHandle extends StatelessWidget {
  const AddTrackHandle({super.key});

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

class AddTrackLoadingBody extends StatelessWidget {
  const AddTrackLoadingBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Row(
        children: [
          AddTrackShimmer(width: 64, height: 64, radius: 12),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AddTrackShimmer(width: double.infinity, height: 14, radius: 7),
                SizedBox(height: 8),
                AddTrackShimmer(width: 140, height: 12, radius: 6),
                SizedBox(height: 8),
                AddTrackShimmer(width: 80, height: 10, radius: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AddTrackShimmer extends StatefulWidget {
  final double width, height, radius;
  const AddTrackShimmer({
    super.key,
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  State<AddTrackShimmer> createState() => AddTrackShimmerState();
}

class AddTrackShimmerState extends State<AddTrackShimmer>
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

class AddTrackPreviewBody extends StatelessWidget {
  final TrackPreview preview;
  final bool adding;
  final VoidCallback onAdd;
  final VoidCallback onCancel;
  final String? collectionName;
  final int trackCount;
  final int skippedCount;

  const AddTrackPreviewBody({
    super.key,
    required this.preview,
    required this.adding,
    required this.onAdd,
    required this.onCancel,
    this.collectionName,
    this.trackCount = 1,
    this.skippedCount = 0,
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
                    AddTrackSourceBadge(preview: preview),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (collectionName != null) ...[
            Text(collectionName!, style: AppText.display3),
            const SizedBox(height: 4),
            Text(
              context.tr(
                'import.collectionPreview',
                namedArgs: {'ready': '$trackCount', 'skipped': '$skippedCount'},
              ),
              style: AppText.bodyXS,
            ),
            const SizedBox(height: 12),
          ],
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
                  AddTrackDetailItem(
                    label: context.tr('track.duration'),
                    value: _fmt(preview.duration),
                  ),
                if (preview.album != null) ...[
                  const SizedBox(width: 24),
                  AddTrackDetailItem(
                    label: context.tr('track.album'),
                    value: preview.album!,
                  ),
                ],
                if (preview.year != null) ...[
                  const SizedBox(width: 24),
                  AddTrackDetailItem(
                    label: context.tr('track.year'),
                    value: preview.year.toString(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          AddTrackAddButton(adding: adding, onTap: onAdd),
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

class AddTrackSourceBadge extends StatelessWidget {
  final TrackPreview preview;
  const AddTrackSourceBadge({super.key, required this.preview});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 3, 10, 3),
      decoration: BoxDecoration(
        color: AppColors.downloadPending,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.downloadPendingBorder),
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
            preview.source == SourceType.spotify && preview.media != null
                ? context.tr(
                    preview.media!.type == SourceType.soundcloud
                        ? 'import.spotifySoundcloudSource'
                        : 'import.spotifyYoutubeSource',
                  )
                : context.tr(switch (preview.source) {
                    SourceType.localFile ||
                    SourceType.owlsonic => 'library.filterLocal',
                    SourceType.soundcloud => 'library.filterSoundcloud',
                    SourceType.youtube => 'library.filterYoutube',
                    SourceType.spotify => 'library.filterSpotify',
                    SourceType.unknown => 'library.filterUnknown',
                  }),
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

class AddTrackDetailItem extends StatelessWidget {
  final String label, value;
  const AddTrackDetailItem({
    super.key,
    required this.label,
    required this.value,
  });

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

class AddTrackAddButton extends StatelessWidget {
  final bool adding;
  final VoidCallback onTap;
  const AddTrackAddButton({
    super.key,
    required this.adding,
    required this.onTap,
  });

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
                  context.tr('track.addToLibrary'),
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

class AddTrackErrorBody extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;
  final VoidCallback onCancel;

  const AddTrackErrorBody({
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
