import 'package:owlsonic/layers/presentation/features/mood_map/bloc/mood_map/mood_map_cubit.dart';
import 'package:owlsonic/layers/presentation/features/mood_map/logic/mood_description.dart';
import 'package:owlsonic/layers/presentation/features/mood_map/logic/mood_map_geometry.dart';
import 'package:owlsonic/layers/presentation/features/mood_map/logic/mood_map_view_policy.dart';
import 'package:owlsonic/layers/domain/entities/mood_map.dart';
import 'package:owlsonic/layers/presentation/features/player/bloc/player/player_bloc.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/cached_image.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/core/layout/app_layout.dart';
import 'package:owlsonic/core/layout/adaptive_presentation.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/desktop_state_view.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/snackbars/custom_snack_bar.dart';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:owlsonic/layers/domain/entities/wave_session.dart';
import 'package:owlsonic/layers/domain/services/mood_label_policy.dart';

/// "Choose a mood": the interactive way to pick what Wave plays. Tapping the
/// map picks a mood; the primary action starts a Wave with it.
class MoodMapPage extends StatelessWidget {
  const MoodMapPage({super.key, this.onEvent, this.pickTarget = false});

  /// When true the page only chooses a mood: the primary action closes the
  /// page with the chosen [MoodPoint] instead of starting playback.
  final bool pickTarget;

  /// Receives the playback events this page raises. Defaults to the app's
  /// [PlayerBloc].
  final ValueChanged<PlayerEvent>? onEvent;

  @override
  Widget build(BuildContext context) {
    final dispatch = onEvent;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: context.tr('common.back'),
          onPressed: () => pickTarget
              ? Navigator.of(context).maybePop()
              : context.canPop()
              ? context.pop()
              : AdaptivePresentation.close(context),
          icon: const Icon(Icons.keyboard_arrow_left, size: 28),
        ),
        title: Text(context.tr('moodMap.title'), style: AppText.display3),
      ),
      body: BlocBuilder<MoodMapCubit, MoodMapState>(
        bloc: context.read<MoodMapCubit>(),
        builder: (context, state) => switch (state.status) {
          MoodMapStatus.initial || MoodMapStatus.loading =>
            AppLayout.isDesktopPlatform
                ? DesktopStateView(
                    icon: Icons.scatter_plot_outlined,
                    title: context.tr('common.loading'),
                    loading: true,
                  )
                : const Center(child: CircularProgressIndicator()),
          MoodMapStatus.failure => _MoodMapProblem(
            onRetry: context.read<MoodMapCubit>().reload,
          ),
          MoodMapStatus.ready =>
            state.tracks.isEmpty
                ? const _EmptyMoodMap()
                : _MoodMapBody(
                    state: state,
                    onEvent: dispatch,
                    pickTarget: pickTarget,
                  ),
        },
      ),
    );
  }
}

class _MoodMapProblem extends StatelessWidget {
  const _MoodMapProblem({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 36, color: AppColors.muted),
          const SizedBox(height: 12),
          Text(
            context.tr('moodMap.error'),
            style: AppText.bodyM,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onRetry,
            child: Text(context.tr('common.retry')),
          ),
        ],
      ),
    ),
  );
}

class _EmptyMoodMap extends StatelessWidget {
  const _EmptyMoodMap();

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
          Text(
            context.tr('moodMap.empty'),
            style: AppText.display3,
            textAlign: TextAlign.center,
          ),
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
        style: _axisLabelStyle,
      ),
      const SizedBox(height: 6),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RotatedBox(
            quarterTurns: 3,
            child: Text(context.tr('moodMap.dark'), style: _axisLabelStyle),
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
            child: Text(context.tr('moodMap.bright'), style: _axisLabelStyle),
          ),
        ],
      ),
      const SizedBox(height: 6),
      Text(
        context.tr('moodMap.calm'),
        textAlign: TextAlign.center,
        style: _axisLabelStyle,
      ),
    ],
  );
}

/// Axis words around the map: readable, but quieter than song titles.
final _axisLabelStyle = AppText.bodyS.copyWith(
  color: AppColors.textSub,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.4,
);

/// Tag names come from the analysis model; show them as plain words.
String _moodTag(String raw) =>
    raw.isEmpty ? raw : raw[0].toUpperCase() + raw.substring(1);

class _MoodMapBody extends StatelessWidget {
  const _MoodMapBody({
    required this.state,
    this.onEvent,
    this.pickTarget = false,
  });

  final MoodMapState state;
  final bool pickTarget;
  final ValueChanged<PlayerEvent>? onEvent;

  void _dispatch(BuildContext context, PlayerEvent event) {
    final callback = onEvent;
    if (callback != null) {
      callback(event);
    } else {
      context.read<PlayerBloc>().add(event);
    }
  }

  /// The primary action: start a Wave around the chosen mood.
  void _playMood(BuildContext context) {
    final valence = state.targetValence;
    final arousal = state.targetArousal;
    if (valence == null || arousal == null) return;
    if (pickTarget) {
      Navigator.of(context).pop(MoodPoint(valence: valence, arousal: arousal));
      return;
    }
    _dispatch(
      context,
      PlayerMoodWaveStarted(
        targetValence: valence,
        targetArousal: arousal,
        radius: state.radius,
        mode: MoodWaveMode.stay,
      ),
    );
    if (!AppLayout.isDesktopPlatform && context.canPop()) {
      context.pop();
    } else {
      CustomSnackBar.success(context, context.tr('moodMap.waveStarted'));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (AppLayout.isDesktopPlatform) {
      return _DesktopMoodMapBody(
        state: state,
        onPlayMood: () => _playMood(context),
        pickTarget: pickTarget,
        onEvent: (event) => _dispatch(context, event),
      );
    }
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.pageMaxWidth),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.tr('moodMap.energetic'),
                    textAlign: TextAlign.center,
                    style: _axisLabelStyle,
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
                  child: Text(
                    context.tr('moodMap.dark'),
                    style: _axisLabelStyle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.08,
                    child: _MoodMapCanvas(
                      state: state,
                      onTrackTap: (track) => showTrack(
                        context,
                        track,
                        dispatch: (event) => _dispatch(context, event),
                      ),
                      onTrackLongPress: (track) => showTrack(
                        context,
                        track,
                        dispatch: (event) => _dispatch(context, event),
                      ),
                      onTargetChanged: (target) => context
                          .read<MoodMapCubit>()
                          .setTarget(target.valence, target.arousal),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                RotatedBox(
                  quarterTurns: 1,
                  child: Text(
                    context.tr('moodMap.bright'),
                    style: _axisLabelStyle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              context.tr('moodMap.calm'),
              textAlign: TextAlign.center,
              style: _axisLabelStyle,
            ),
            if (state.tracks.length < 5) ...[
              const SizedBox(height: 12),
              Text(
                context.tr(
                  'moodMap.sparseHint',
                  namedArgs: {'count': '${state.tracks.length}'},
                ),
                key: const ValueKey('mood-map-sparse-hint'),
                style: AppText.bodyM,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 18),
            _PlayMoodSection(
              state: state,
              onPlay: () => _playMood(context),
              pickTarget: pickTarget,
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> showTrack(
    BuildContext pageContext,
    MoodMapTrack entry, {
    ValueChanged<PlayerEvent>? dispatch,
  }) async {
    pageContext.read<MoodMapCubit>().selectTrack(entry.track.id);
    void send(PlayerEvent event) => dispatch != null
        ? dispatch(event)
        : pageContext.read<PlayerBloc>().add(event);
    Widget builder(BuildContext sheetContext) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        child: _TrackMoodDetails(
          entry: entry,
          onPlay: () {
            send(PlayerQueueSet([entry.track], startTrack: entry.track));
            Navigator.pop(sheetContext);
          },
          onStartWave: () {
            send(PlayerTrackWaveStarted(track: entry.track));
            Navigator.pop(sheetContext);
          },
          onReset: entry.hasPersonalPosition
              ? () async {
                  await pageContext.read<MoodMapCubit>().resetPersonalPosition(
                    entry.track.id,
                  );
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                }
              : null,
        ),
      ),
    );
    if (AppLayout.isDesktopPlatform) {
      await AdaptivePresentation.showSurface<void>(
        pageContext,
        maxWidth: 460,
        maxHeight: 500,
        builder: builder,
      );
    } else {
      await showModalBottomSheet<void>(
        context: pageContext,
        useRootNavigator: true,
        isScrollControlled: true,
        backgroundColor: AppColors.sheetSurface,
        showDragHandle: true,
        builder: builder,
      );
    }
  }
}

/// What the chosen spot on the map means, and the action that plays it.
class _PlayMoodSection extends StatelessWidget {
  const _PlayMoodSection({
    required this.state,
    required this.onPlay,
    this.pickTarget = false,
  });

  final MoodMapState state;
  final VoidCallback onPlay;
  final bool pickTarget;

  @override
  Widget build(BuildContext context) {
    final valence = state.targetValence;
    final arousal = state.targetArousal;
    final chosen = valence != null && arousal != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          chosen
              ? context.tr(
                  MoodDescription.keyFor(valence: valence, arousal: arousal),
                )
              : context.tr('moodMap.targetHint'),
          key: const ValueKey('mood-target-description'),
          style: chosen ? AppText.display3 : AppText.bodyL,
          textAlign: TextAlign.center,
        ),
        if (chosen && state.tracksInsideRadius.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            context.tr(
              'moodMap.nearbyCount',
              namedArgs: {'count': '${state.tracksInsideRadius.length}'},
            ),
            key: const ValueKey('mood-nearby-count'),
            style: AppText.bodyM,
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 16),
        FilledButton.icon(
          key: const ValueKey('play-this-mood'),
          onPressed: chosen ? onPlay : null,
          icon: Icon(
            pickTarget ? Icons.check_rounded : Icons.play_arrow_rounded,
          ),
          label: Text(
            context.tr(pickTarget ? 'moodMap.useMood' : 'moodMap.playMood'),
          ),
        ),
        if (chosen)
          TextButton(
            key: const ValueKey('clear-mood-target'),
            onPressed: context.read<MoodMapCubit>().clearTarget,
            child: Text(context.tr('moodMap.clearTarget')),
          ),
        const SizedBox(height: 8),
        Text(
          context.tr('moodMap.dragHint'),
          style: AppText.bodyXS.copyWith(color: AppColors.textSub),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// A song's place on the map in plain words, with Play and the personal
/// override. Raw coordinates and model scores are not shown.
class _TrackMoodDetails extends StatelessWidget {
  const _TrackMoodDetails({
    required this.entry,
    required this.onPlay,
    required this.onStartWave,
    required this.onReset,
  });

  final MoodMapTrack entry;
  final VoidCallback onPlay;
  final VoidCallback onStartWave;
  final Future<void> Function()? onReset;

  @override
  Widget build(BuildContext context) {
    final labels = const MoodLabelPolicy().topLabels(
      entry.modelAnalysis.moodDistribution,
    );
    return Column(
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
                  Text(
                    entry.track.title,
                    style: AppText.display3,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    entry.track.artists.map((artist) => artist.name).join(', '),
                    style: AppText.bodyM,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          context.tr(
            MoodDescription.keyFor(
              valence: entry.valence,
              arousal: entry.arousal,
            ),
          ),
          key: const ValueKey('mood-track-description'),
          style: AppText.bodyL,
        ),
        if (labels.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: labels
                .map(
                  (label) => Chip(
                    label: Text(_moodTag(label.key), style: AppText.bodyXS),
                  ),
                )
                .toList(growable: false),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          entry.hasPersonalPosition
              ? context.tr('moodMap.placedByYou')
              : context.tr('moodMap.placedByOwlSonic'),
          style: AppText.bodyXS,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          key: const ValueKey('mood-track-play'),
          onPressed: onPlay,
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(context.tr('moodMap.play')),
        ),
        TextButton(
          key: const ValueKey('mood-track-wave'),
          onPressed: onStartWave,
          child: Text(context.tr('moodMap.waveFromTrack')),
        ),
        if (onReset != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              key: const ValueKey('mood-track-reset'),
              onPressed: onReset,
              child: Text(context.tr('moodMap.resetToModel')),
            ),
          ),
        const SizedBox(height: 4),
        Text(context.tr('moodMap.dragHint'), style: AppText.bodyXS),
      ],
    );
  }
}

class _DesktopMoodMapBody extends StatelessWidget {
  const _DesktopMoodMapBody({
    required this.state,
    required this.onPlayMood,
    required this.onEvent,
    this.pickTarget = false,
  });

  final bool pickTarget;
  final MoodMapState state;
  final VoidCallback onPlayMood;
  final ValueChanged<PlayerEvent> onEvent;

  @override
  Widget build(BuildContext context) {
    final selected = state.selectedTrack;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: _MoodMapCanvas(
              state: state,
              onTrackTap: (track) =>
                  context.read<MoodMapCubit>().selectTrack(track.track.id),
              onTrackLongPress: (track) =>
                  context.read<MoodMapCubit>().selectTrack(track.track.id),
              onTargetChanged: (target) => context
                  .read<MoodMapCubit>()
                  .setTarget(target.valence, target.arousal),
            ),
          ),
          const SizedBox(width: 24),
          SizedBox(
            width: 270,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PlayMoodSection(
                    state: state,
                    onPlay: onPlayMood,
                    pickTarget: pickTarget,
                  ),
                  const Divider(height: 32, color: AppColors.border),
                  if (selected != null)
                    _TrackMoodDetails(
                      entry: selected,
                      onPlay: () => onEvent(
                        PlayerQueueSet([
                          selected.track,
                        ], startTrack: selected.track),
                      ),
                      onStartWave: () => onEvent(
                        PlayerTrackWaveStarted(track: selected.track),
                      ),
                      onReset: selected.hasPersonalPosition
                          ? () => context
                                .read<MoodMapCubit>()
                                .resetPersonalPosition(selected.track.id)
                          : null,
                    ),
                ],
              ),
            ),
          ),
        ],
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
        final size = Size(constraints.maxWidth, constraints.maxHeight);
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
              child: SizedBox(
                width: size.width,
                height: size.height,
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
    final desktop = AppLayout.isDesktopPlatform;
    final artworkOpacity = desktop
        ? math.max(0.72, MoodMapViewPolicy.artworkOpacity(_scale))
        : MoodMapViewPolicy.artworkOpacity(_scale);
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
          onTap: showArtwork ? () => widget.onTrackTap(entry) : null,
          onLongPress: showArtwork
              ? () => widget.onTrackLongPress(entry)
              : null,
          onPanUpdate: showArtwork
              ? (details) => _drag(entry, details.globalPosition, size)
              : null,
          onPanEnd: showArtwork
              ? (_) {
                  final cubit = context.read<MoodMapCubit>();
                  final current = cubit.state.tracks.firstWhere(
                    (candidate) => candidate.track.id == entry.track.id,
                  );
                  cubit.savePersonalPosition(
                    current.track.id,
                    current.valence,
                    current.arousal,
                  );
                }
              : null,
          child: Tooltip(
            message: entry.track.title,
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
    if (MoodMapViewPolicy.artworkOpacity(_scale) > 0) {
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
    final bounds = Offset.zero & size;
    final moodField = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.75, -0.7),
        radius: 1.45,
        colors: [Color(0xFF20291F), AppColors.surface, Color(0xFF161A22)],
        stops: [0, .55, 1],
      ).createShader(bounds);
    canvas.drawRect(bounds, moodField);
    final grid = Paint()
      ..color = AppColors.borderAct.withValues(alpha: 0.8)
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
      // The reach of the chosen mood: songs inside it are "nearby".
      final reach = state.radius * size.width / 2;
      canvas.drawCircle(
        center,
        reach,
        Paint()..color = AppColors.text.withValues(alpha: 0.06),
      );
      canvas.drawCircle(
        center,
        reach,
        Paint()
          ..color = AppColors.text.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1 / scale,
      );
      // Mood target: ring with crosshair, unlike the round song artwork.
      final cross = Paint()
        ..color = AppColors.text
        ..strokeWidth = 1.5 / scale;
      canvas.drawCircle(
        center,
        11 / scale,
        Paint()
          ..color = AppColors.text
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 / scale,
      );
      canvas.drawLine(
        center.translate(-17 / scale, 0),
        center.translate(-6 / scale, 0),
        cross,
      );
      canvas.drawLine(
        center.translate(6 / scale, 0),
        center.translate(17 / scale, 0),
        cross,
      );
      canvas.drawLine(
        center.translate(0, -17 / scale),
        center.translate(0, -6 / scale),
        cross,
      );
      canvas.drawLine(
        center.translate(0, 6 / scale),
        center.translate(0, 17 / scale),
        cross,
      );
      canvas.drawCircle(center, 2.5 / scale, Paint()..color = AppColors.text);
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
      canvas.drawCircle(point, 4 / scale, Paint()..color = AppColors.bg);
      canvas.drawCircle(point, 3 / scale, Paint()..color = AppColors.text);
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
    final cellWidth = size.width / cells;
    final cellHeight = size.height / cells;
    for (var i = 0; i < bins.length; i++) {
      if (bins[i] == 0) continue;
      final opacity = 0.15 + 0.75 * bins[i] / maxCount;
      canvas.drawRect(
        Rect.fromLTWH(
          (i % cells) * cellWidth,
          (i ~/ cells) * cellHeight,
          cellWidth,
          cellHeight,
        ),
        Paint()..color = AppColors.text.withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MoodMapPainter oldDelegate) =>
      oldDelegate.state != state || oldDelegate.scale != scale;
}
