import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/app_theme.dart';
import '../../domain/entities/mood_map.dart';
import '../../domain/entities/wave_session.dart';
import '../../domain/services/mood_label_policy.dart';
import '../blocs/mood_map/mood_map_cubit.dart';
import '../mood_map/mood_map_geometry.dart';
import '../mood_map/mood_map_view_policy.dart';
import '../widgets/cached_image.dart';

class MoodMapPage extends StatelessWidget {
  const MoodMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: context.pop,
          icon: const Icon(Icons.keyboard_arrow_left, size: 28),
        ),
        title: Text(context.tr('moodMap.title'), style: AppText.display3),
      ),
      body: BlocBuilder<MoodMapCubit, MoodMapState>(
        bloc: context.read<MoodMapCubit>(),
        builder: (context, state) => switch (state.status) {
          MoodMapStatus.initial || MoodMapStatus.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          MoodMapStatus.failure => Center(
            child: Text(context.tr('moodMap.error'), style: AppText.bodyM),
          ),
          MoodMapStatus.ready =>
            state.tracks.isEmpty ? _EmptyMoodMap() : _MoodMapBody(state: state),
        },
      ),
    );
  }
}

class _EmptyMoodMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.scatter_plot_rounded,
            size: 42,
            color: AppColors.muted,
          ),
          const SizedBox(height: 12),
          Text(context.tr('moodMap.empty'), style: AppText.display3),
          const SizedBox(height: 6),
          Text(
            context.tr('moodMap.emptyHint'),
            style: AppText.bodyM,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class MoodMapPanel extends StatelessWidget {
  const MoodMapPanel({
    super.key,
    required this.state,
    required this.onTargetChanged,
  });

  final MoodMapState state;
  final ValueChanged<MoodPoint> onTargetChanged;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        context.tr('moodMap.energetic'),
        textAlign: TextAlign.center,
        style: AppText.bodyXS,
      ),
      const SizedBox(height: 6),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RotatedBox(
            quarterTurns: 3,
            child: Text(context.tr('moodMap.dark'), style: AppText.bodyXS),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: _MoodMapCanvas(
                state: state,
                onTrackTap: (track) => _MoodMapBody.showTrack(context, track),
                onTrackLongPress: (track) =>
                    _MoodMapBody.showTrack(context, track),
                onTargetChanged: onTargetChanged,
              ),
            ),
          ),
          const SizedBox(width: 6),
          RotatedBox(
            quarterTurns: 1,
            child: Text(context.tr('moodMap.bright'), style: AppText.bodyXS),
          ),
        ],
      ),
      const SizedBox(height: 6),
      Text(
        context.tr('moodMap.calm'),
        textAlign: TextAlign.center,
        style: AppText.bodyXS,
      ),
    ],
  );
}

class _MoodMapBody extends StatelessWidget {
  const _MoodMapBody({required this.state});

  final MoodMapState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.tr('moodMap.energetic'),
                textAlign: TextAlign.center,
                style: AppText.bodyXS,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RotatedBox(
              quarterTurns: 3,
              child: Text(context.tr('moodMap.dark'), style: AppText.bodyXS),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: _MoodMapCanvas(
                  state: state,
                  onTrackTap: (track) => showTrack(context, track),
                  onTrackLongPress: (track) => showTrack(context, track),
                  onTargetChanged: (target) => context
                      .read<MoodMapCubit>()
                      .setTarget(target.valence, target.arousal),
                ),
              ),
            ),
            const SizedBox(width: 6),
            RotatedBox(
              quarterTurns: 1,
              child: Text(context.tr('moodMap.bright'), style: AppText.bodyXS),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          context.tr('moodMap.calm'),
          textAlign: TextAlign.center,
          style: AppText.bodyXS,
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Text(context.tr('moodMap.target'), style: AppText.bodyL),
            const Spacer(),
            Text(
              state.targetValence == null || state.targetArousal == null
                  ? '—'
                  : context.tr(
                      'moodMap.targetPosition',
                      namedArgs: {
                        'valence': state.targetValence!.toStringAsFixed(2),
                        'arousal': state.targetArousal!.toStringAsFixed(2),
                      },
                    ),
              style: AppText.bodyM,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          state.targetValence == null
              ? context.tr('moodMap.targetHint')
              : context.tr('moodMap.targetSelected'),
          style: AppText.bodyM,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          key: const ValueKey('select-mood-target'),
          onPressed: state.targetValence == null || state.targetArousal == null
              ? null
              : () => context.pop(
                  MoodPoint(
                    valence: state.targetValence!,
                    arousal: state.targetArousal!,
                  ),
                ),
          icon: const Icon(Icons.check_rounded),
          label: Text(context.tr('moodMap.useTarget')),
        ),
        if (state.targetValence != null)
          TextButton(
            onPressed: context.read<MoodMapCubit>().clearTarget,
            child: Text(context.tr('moodMap.clearTarget')),
          ),
      ],
    );
  }

  static Future<void> showTrack(
    BuildContext pageContext,
    MoodMapTrack entry,
  ) async {
    pageContext.read<MoodMapCubit>().selectTrack(entry.track.id);
    final labels = const MoodLabelPolicy().topLabels(
      entry.modelAnalysis.moodDistribution,
    );
    await showModalBottomSheet<void>(
      context: pageContext,
      useRootNavigator: true,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: AppRadius.coverBR,
                    child: CachedImage(url: entry.track.imageUrl, size: 52),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.track.title, style: AppText.display3),
                        Text(
                          entry.track.artists
                              .map((artist) => artist.name)
                              .join(', '),
                          style: AppText.bodyM,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '${entry.hasPersonalPosition ? sheetContext.tr('moodMap.personalPosition') : sheetContext.tr('moodMap.modelPosition')}  '
                'V ${entry.valence.toStringAsFixed(2)} · A ${entry.arousal.toStringAsFixed(2)}',
                style: AppText.bodyM,
              ),
              if (labels.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: labels
                      .map(
                        (label) => Chip(
                          label: Text(
                            '${label.key} ${(label.value * 100).round()}%',
                            style: AppText.bodyXS,
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              ],
              const SizedBox(height: 12),
              if (entry.hasPersonalPosition)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () async {
                      await pageContext
                          .read<MoodMapCubit>()
                          .resetPersonalPosition(entry.track.id);
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                    },
                    child: Text(sheetContext.tr('moodMap.resetToModel')),
                  ),
                ),
              Text(sheetContext.tr('moodMap.dragHint'), style: AppText.bodyXS),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoodMapCanvas extends StatefulWidget {
  const _MoodMapCanvas({
    required this.state,
    required this.onTrackTap,
    required this.onTrackLongPress,
    required this.onTargetChanged,
  });

  final MoodMapState state;
  final ValueChanged<MoodMapTrack> onTrackTap;
  final ValueChanged<MoodMapTrack> onTrackLongPress;
  final ValueChanged<MoodPoint> onTargetChanged;

  @override
  State<_MoodMapCanvas> createState() => _MoodMapCanvasState();
}

class _MoodMapCanvasState extends State<_MoodMapCanvas> {
  final _controller = TransformationController();
  final _plotKey = GlobalKey();
  double _scale = 1;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTransform);
  }

  void _onTransform() {
    final scale = _controller.value.getMaxScaleOnAxis();
    if (mounted) setState(() => _scale = scale);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTransform);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, constraints.maxHeight);
        final size = Size.square(side);
        return ClipRRect(
          borderRadius: AppRadius.cardBR,
          child: InteractiveViewer(
            transformationController: _controller,
            minScale: 1,
            maxScale: MoodMapViewPolicy.maxScale,
            child: GestureDetector(
              key: _plotKey,
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) => _handlePlotTap(details.localPosition, size),
              child: SizedBox.square(
                dimension: side,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CustomPaint(
                      size: size,
                      painter: _MoodMapPainter(
                        state: widget.state,
                        scale: _scale,
                      ),
                    ),
                    ..._markers(size),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Iterable<Widget> _markers(Size size) {
    final artworkOpacity = MoodMapViewPolicy.artworkOpacity(_scale);
    final showArtwork = artworkOpacity > 0;
    final entries = showArtwork
        ? _visibleArtworkEntries(size)
        : widget.state.tracks.where(
            (entry) => entry.track.id == widget.state.selectedTrackId,
          );
    return entries.map((entry) {
      final center = MoodMapGeometry.toCanvas(
        valence: entry.valence,
        arousal: entry.arousal,
        size: size,
      );
      final markerSize = showArtwork
          ? MoodMapViewPolicy.artworkMarkerScreenSize / _scale
          : 24 / _scale;
      final isSelected = entry.track.id == widget.state.selectedTrackId;
      return Positioned(
        left: center.dx - markerSize / 2,
        top: center.dy - markerSize / 2,
        child: GestureDetector(
          key: ValueKey('mood-map-track-${entry.track.id}'),
          onTap: () => widget.onTrackTap(entry),
          onLongPress: () => widget.onTrackLongPress(entry),
          onPanUpdate: (details) => _drag(entry, details.globalPosition, size),
          onPanEnd: (_) {
            final cubit = context.read<MoodMapCubit>();
            final current = cubit.state.tracks.firstWhere(
              (candidate) => candidate.track.id == entry.track.id,
            );
            cubit.savePersonalPosition(
              current.track.id,
              current.valence,
              current.arousal,
            );
          },
          child: Opacity(
            opacity: showArtwork ? artworkOpacity : 1,
            child: Container(
              width: markerSize,
              height: markerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.text,
                border: Border.all(
                  color: isSelected ? AppColors.text : AppColors.bg,
                  width: (isSelected ? 3 : 2) / _scale,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: showArtwork
                  ? CachedImage(
                      url: entry.track.imageUrl,
                      size: markerSize,
                      fallback: Icon(
                        Icons.music_note_rounded,
                        size: 18 / _scale,
                        color: AppColors.bg,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      );
    });
  }

  List<MoodMapTrack> _visibleArtworkEntries(Size size) {
    final viewport = Rect.fromPoints(
      _controller.toScene(Offset.zero),
      _controller.toScene(Offset(size.width, size.height)),
    ).inflate(MoodMapViewPolicy.artworkMarkerScreenSize / _scale);
    return MoodMapViewPolicy.selectVisible(
      entries: widget.state.tracks,
      viewport: viewport,
      positionOf: (entry) => MoodMapGeometry.toCanvas(
        valence: entry.valence,
        arousal: entry.arousal,
        size: size,
      ),
      isPrioritized: (entry) => entry.track.id == widget.state.selectedTrackId,
    );
  }

  void _drag(MoodMapTrack entry, Offset globalPosition, Size size) {
    final box = _plotKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final position = MoodMapGeometry.fromCanvas(
      offset: box.globalToLocal(globalPosition),
      size: size,
    );
    context.read<MoodMapCubit>().previewPersonalPosition(
      entry.track.id,
      position.valence,
      position.arousal,
    );
  }

  void _handlePlotTap(Offset offset, Size size) {
    MoodMapTrack? nearest;
    var distance = 18 / _scale;
    for (final entry in widget.state.tracks) {
      final point = MoodMapGeometry.toCanvas(
        valence: entry.valence,
        arousal: entry.arousal,
        size: size,
      );
      final candidate = (point - offset).distance;
      if (candidate < distance) {
        distance = candidate;
        nearest = entry;
      }
    }
    if (nearest != null) {
      widget.onTrackTap(nearest);
      return;
    }
    final target = MoodMapGeometry.fromCanvas(offset: offset, size: size);
    widget.onTargetChanged(
      MoodPoint(valence: target.valence, arousal: target.arousal),
    );
  }
}

class _MoodMapPainter extends CustomPainter {
  const _MoodMapPainter({required this.state, required this.scale});

  final MoodMapState state;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.surface);
    final grid = Paint()
      ..color = AppColors.borderAct
      ..strokeWidth = 1 / scale;
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      grid,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      grid,
    );

    final targetV = state.targetValence;
    final targetA = state.targetArousal;
    if (targetV != null && targetA != null) {
      final center = MoodMapGeometry.toCanvas(
        valence: targetV,
        arousal: targetA,
        size: size,
      );
      canvas.drawCircle(
        center,
        10 / scale,
        Paint()
          ..color = AppColors.textSub
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 / scale,
      );
      canvas.drawCircle(center, 4 / scale, Paint()..color = AppColors.text);
    }

    if (state.tracks.length > 500 && scale < 1.6) {
      _paintDensity(canvas, size);
      return;
    }
    for (final entry in state.tracks) {
      final point = MoodMapGeometry.toCanvas(
        valence: entry.valence,
        arousal: entry.arousal,
        size: size,
      );
      canvas.drawCircle(point, 2.5 / scale, Paint()..color = AppColors.textSub);
    }
  }

  void _paintDensity(Canvas canvas, Size size) {
    const cells = 24;
    final bins = List<int>.filled(cells * cells, 0);
    for (final entry in state.tracks) {
      final x = (((entry.valence + 1) / 2) * cells).floor().clamp(0, cells - 1);
      final y = (((1 - entry.arousal) / 2) * cells).floor().clamp(0, cells - 1);
      bins[y * cells + x]++;
    }
    final maxCount = bins.reduce(math.max);
    final cellSize = size.width / cells;
    for (var i = 0; i < bins.length; i++) {
      if (bins[i] == 0) continue;
      final opacity = 0.15 + 0.75 * bins[i] / maxCount;
      canvas.drawRect(
        Rect.fromLTWH(
          (i % cells) * cellSize,
          (i ~/ cells) * cellSize,
          cellSize,
          cellSize,
        ),
        Paint()..color = AppColors.text.withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MoodMapPainter oldDelegate) =>
      oldDelegate.state != state || oldDelegate.scale != scale;
}
