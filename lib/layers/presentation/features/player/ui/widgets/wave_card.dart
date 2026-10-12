import 'package:easy_localization/easy_localization.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:owlsonic/core/app_router/app_router_names.dart';
import 'package:owlsonic/core/di/di.dart';
import 'package:owlsonic/core/layout/app_layout.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/domain/entities/artist.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/domain/entities/wave_session.dart';
import 'package:owlsonic/layers/presentation/features/artist/bloc/artists/artists_cubit.dart';
import 'package:owlsonic/layers/presentation/features/mood_map/bloc/mood_map/mood_map_cubit.dart';
import 'package:owlsonic/layers/presentation/features/player/bloc/player/player_bloc.dart';
import 'package:owlsonic/layers/presentation/features/track/bloc/track/track_bloc.dart';
import 'package:owlsonic/layers/presentation/features/mood_map/ui/mood_map_page.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/cached_image.dart';
import 'package:owlsonic/layers/presentation/features/cloud_status/cloud_status_cubit.dart';
import 'package:owlsonic/layers/presentation/features/mood_map/logic/mood_description.dart';
import 'package:owlsonic/layers/presentation/features/wave/bloc/wave_readiness_cubit.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/app_surface.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/snackbars/custom_snack_bar.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/owlsonic_glyph.dart';

/// Where a Wave can start from, as far as the UI needs to tell the user.
enum WaveCardReadiness {
  /// Still looking at the library; Start is allowed and re-checks on tap.
  checking,

  /// At least one playable track already has a mood position.
  ready,

  /// Tracks exist, but none has been analyzed yet.
  preparing,

  /// Songs are only analyzed in OwlSonic Cloud, and nobody is signed in.
  needsAccount,
}

/// The event behind the one-tap "Start Wave": a mood Wave centered on the
/// library's average mood, or null while nothing has been analyzed.
Future<PlayerEvent?> defaultWaveEvent(WaveReadinessCubit readiness) async {
  final target = await readiness.defaultTarget();
  if (target == null) return null;
  return PlayerMoodWaveStarted(
    targetValence: target.valence,
    targetArousal: target.arousal,
    radius: WaveReadinessCubit.defaultRadius,
    mode: WaveReadinessCubit.defaultMode,
  );
}

/// Starts a sensible Wave right away; explains why when it cannot.
Future<void> startDefaultWave(BuildContext context) async {
  final player = context.read<PlayerBloc>();
  final event = await defaultWaveEvent(context.read<WaveReadinessCubit>());
  if (!context.mounted) return;
  if (event == null) {
    CustomSnackBar.info(context, context.tr('wave.notReady'));
    return;
  }
  player.add(event);
}

/// Mood Map is where a mood is chosen for Wave; it is not a destination of
/// its own.
void openMoodPicker(BuildContext context) =>
    context.pushNamed(AppRouterNames.moodMap);

void openWaveSettings(BuildContext context) {
  if (AppLayout.isDesktopPlatform) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.sheetSurface,
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: math.min(560, MediaQuery.sizeOf(context).width - 48),
            maxHeight: math.min(700, MediaQuery.sizeOf(context).height - 48),
          ),
          child: const WaveSettingsSheet(),
        ),
      ),
    );
    return;
  }
  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.sheetSurface,
    builder: (_) => const WaveSettingsSheet(),
  );
}

class WaveCard extends StatelessWidget {
  const WaveCard({
    super.key,
    this.padding = const EdgeInsets.fromLTRB(24, 16, 24, 0),
    this.dense = false,
  });

  final EdgeInsetsGeometry padding;

  /// Mobile Home: Wave as the primary feature, shrinking while it plays.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      buildWhen: (previous, current) =>
          previous.waveSession != current.waveSession ||
          previous.waveContinuationStatus != current.waveContinuationStatus ||
          previous.queue != current.queue ||
          previous.currentIndex != current.currentIndex,
      builder: (context, state) =>
          BlocBuilder<WaveReadinessCubit, WaveReadinessState>(
            builder: (context, readiness) =>
                BlocBuilder<CloudStatusCubit, CloudStatusState>(
                  builder: (context, cloud) => WaveCardView(
                    padding: padding,
                    dense: dense,
                    state: state,
                    readiness: !readiness.loaded
                        ? WaveCardReadiness.checking
                        : readiness.isReady
                        ? WaveCardReadiness.ready
                        : cloud.kind == CloudStatusKind.deviceOnly
                        ? WaveCardReadiness.needsAccount
                        : WaveCardReadiness.preparing,
                    onStart: () => startDefaultWave(context),
                    onChooseMood: () => openMoodPicker(context),
                    onConfigure: () => openWaveSettings(context),
                    onSignIn: () => context.pushNamed(AppRouterNames.account),
                    onStop: () =>
                        context.read<PlayerBloc>().add(PlayerWaveStopped()),
                    onRetry: () => context.read<PlayerBloc>().add(
                      PlayerWaveRetryRequested(),
                    ),
                  ),
                ),
          ),
    );
  }
}

class WaveCardView extends StatelessWidget {
  const WaveCardView({
    super.key,
    required this.state,
    required this.onConfigure,
    this.readiness = WaveCardReadiness.ready,
    this.onStart,
    this.onChooseMood,
    this.onStop,
    this.onRetry,
    this.onSignIn,
    this.padding = const EdgeInsets.fromLTRB(24, 16, 24, 0),
    this.dense = false,
  });

  final EdgeInsetsGeometry padding;
  final bool dense;
  final PlayerState state;
  final WaveCardReadiness readiness;
  final VoidCallback? onStart;
  final VoidCallback? onChooseMood;
  final VoidCallback onConfigure;
  final VoidCallback? onStop;
  final VoidCallback? onRetry;
  final VoidCallback? onSignIn;

  @override
  Widget build(BuildContext context) {
    final session = state.waveSession;
    final needsAccount =
        session == null && readiness == WaveCardReadiness.needsAccount;
    final preparing =
        needsAccount ||
        (session == null && readiness == WaveCardReadiness.preparing);
    final title = needsAccount
        ? context.tr('wave.accountTitle')
        : preparing
        ? context.tr('wave.preparingTitle')
        : session == null
        ? context.tr(dense ? 'wave.homeTitle' : 'wave.idleTitle')
        : context.tr('wave.activeTitle');
    final description = needsAccount
        ? context.tr('wave.accountDescription')
        : preparing
        ? context.tr('wave.preparingDescription')
        : session == null
        ? context.tr(dense ? 'wave.homeDescription' : 'wave.idleDescription')
        : state.isWaveGenerating
        ? context.tr('waveSession.generating')
        : state.isWaveWaiting
        ? context.tr('waveSession.waiting')
        : _sourceLabel(context, session.source);
    // Playing: a smaller card, since the mini-player already has the controls.
    final compact = dense && session != null;
    final buttonHeight = compact ? 40.0 : 44.0;
    return Padding(
      padding: padding,
      child: KeyedSubtree(
        key: const ValueKey('wave-card'),
        child: AppSurface(
          radius: AppRadius.card,
          padding: compact
              ? const EdgeInsets.fromLTRB(16, 10, 12, 2)
              : const EdgeInsets.fromLTRB(16, 14, 12, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          key: const ValueKey('wave-card-source'),
                          style: dense && !compact
                              ? AppText.display2
                              : AppText.display3,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          key: const ValueKey('wave-card-status'),
                          maxLines: compact ? 1 : null,
                          overflow: compact ? TextOverflow.ellipsis : null,
                          style: AppText.bodyM,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (state.isWaveGenerating)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 1.5),
                      ),
                    )
                  else
                    const OwlSonicGlyph(
                      type: OwlSonicGlyphType.wave,
                      size: 28,
                      color: AppColors.muted,
                    ),
                ],
              ),
              if (needsAccount && onSignIn != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    key: const ValueKey('wave-card-sign-in'),
                    onPressed: onSignIn,
                    child: Text(context.tr('wave.signIn')),
                  ),
                ),
              if (!preparing) ...[
                SizedBox(height: compact ? 4 : 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Customize keeps its label when there is room; otherwise
                    // it is an icon so the row never wraps to a second line.
                    final roomy = constraints.maxWidth >= 380;
                    return Wrap(
                      spacing: 4,
                      runSpacing: 0,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (session == null)
                          FilledButton.icon(
                            key: const ValueKey('wave-card-start'),
                            style: FilledButton.styleFrom(
                              minimumSize: Size(0, buttonHeight),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                            ),
                            onPressed: onStart,
                            icon: const Icon(Icons.waves_rounded, size: 18),
                            label: Text(context.tr('wave.start')),
                          )
                        else
                          OutlinedButton(
                            key: const ValueKey('wave-card-stop'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size(0, buttonHeight),
                            ),
                            onPressed: onStop,
                            child: Text(context.tr('waveSession.stop')),
                          ),
                        if (state.isWaveWaiting)
                          TextButton(
                            key: const ValueKey('wave-card-retry'),
                            onPressed: onRetry,
                            child: Text(context.tr('waveSession.retry')),
                          ),
                        TextButton(
                          key: const ValueKey('wave-card-choose-mood'),
                          style: TextButton.styleFrom(
                            minimumSize: Size(0, buttonHeight),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                          onPressed: onChooseMood,
                          child: Text(context.tr('wave.chooseMood')),
                        ),
                        if (roomy)
                          TextButton(
                            key: const ValueKey('wave-card-customize'),
                            style: TextButton.styleFrom(
                              minimumSize: Size(0, buttonHeight),
                            ),
                            onPressed: onConfigure,
                            child: Text(context.tr('wave.customize')),
                          )
                        else
                          IconButton(
                            key: const ValueKey('wave-card-customize'),
                            tooltip: context.tr('wave.customize'),
                            constraints: const BoxConstraints.tightFor(
                              width: 44,
                              height: 44,
                            ),
                            onPressed: onConfigure,
                            icon: const Icon(Icons.tune_rounded, size: 20),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum _WaveSourceChoice { mood, track, artist }

class WaveSettingsSheet extends StatefulWidget {
  const WaveSettingsSheet({
    super.key,
    this.playerState,
    this.tracks,
    this.artists,
    this.pickMood,
    this.onEvent,
  });

  final PlayerState? playerState;
  final List<Track>? tracks;
  final List<ArtistSummary>? artists;

  /// Opens the dedicated mood picker and returns the chosen mood. Defaults to
  /// the Mood Map page in pick mode.
  final Future<MoodPoint?> Function(BuildContext context, MoodPoint? current)?
  pickMood;
  final ValueChanged<PlayerEvent>? onEvent;

  @override
  State<WaveSettingsSheet> createState() => _WaveSettingsSheetState();
}

class _WaveSettingsSheetState extends State<WaveSettingsSheet> {
  late _WaveSourceChoice _source;
  MoodWaveMode _moodMode = MoodWaveMode.stay;
  double _radius = 0.35;
  MoodPoint? _target;

  /// True while the starting mood is the one derived from the analyzed
  /// library rather than a mood the user picked.
  bool _targetFromLibrary = false;
  String? _selectedTrackId;
  String? _selectedArtistId;
  String? _selectedArtistName;
  String? _selectedArtistImageUrl;
  String _search = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final active = _playerState(context).waveSession?.source;
    _source = switch (active) {
      TrackWaveSource() => _WaveSourceChoice.track,
      ArtistWaveSource() => _WaveSourceChoice.artist,
      _ => _WaveSourceChoice.mood,
    };
    switch (active) {
      case MoodWaveSource source:
        _moodMode = source.mode;
        _radius = source.radius;
        _target = source.userTarget;
      case TrackWaveSource source:
        _selectedTrackId = source.trackId;
      case ArtistWaveSource source:
        _selectedArtistId = source.artistId;
        _selectedArtistName = source.artistName;
        _selectedArtistImageUrl = source.imageUrl;
      case null:
        break;
    }
    if (active is! MoodWaveSource) _loadLibraryTarget();
  }

  Future<void> _loadLibraryTarget() async {
    final WaveReadinessCubit readiness;
    try {
      readiness = context.read<WaveReadinessCubit>();
    } catch (_) {
      return;
    }
    final center = await readiness.defaultTarget();
    if (!mounted || center == null || _target != null) return;
    setState(() {
      _target = center;
      _targetFromLibrary = true;
    });
  }

  Future<void> _chooseOnMap() async {
    final current = _target;
    final picked = await (widget.pickMood ?? _openMoodPicker)(context, current);
    if (!mounted || picked == null) return;
    setState(() {
      _target = picked;
      _targetFromLibrary = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tracks =
        widget.tracks ??
        switch (context.watch<TrackBloc>().state) {
          TrackLoaded(:final tracks) =>
            tracks
                .where(
                  (track) => track.isReadyToPlay && track.source.isAvailable,
                )
                .toList(growable: false),
          _ => const <Track>[],
        };
    final artists =
        widget.artists ??
        switch (context.watch<ArtistsCubit>().state) {
          ArtistsLoaded(:final artists) => artists,
          _ => const <ArtistSummary>[],
        };
    final filteredTracks = _filterTracks(tracks);
    final filteredArtists = _filterArtists(artists);

    final desktop = AppLayout.isDesktopPlatform;
    final media = MediaQuery.of(context);
    final keyboard = media.viewInsets.bottom;
    final available = media.size.height - media.padding.top - keyboard;
    return AnimatedPadding(
      duration: AppAnim.fast,
      padding: EdgeInsets.only(bottom: desktop ? 0 : keyboard),
      child: Container(
        height: desktop
            ? math.min(700, media.size.height - 48)
            : math.min(media.size.height * 0.84, available),
        decoration: BoxDecoration(
          color: AppBlur.sheetColor,
          borderRadius: desktop
              ? BorderRadius.circular(AppRadius.xl)
              : const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!desktop) const _SheetHandle(),
                _header(context),
                const Divider(height: 1, color: AppColors.border),
                _sourceSelector(context),
                Expanded(
                  child: switch (_source) {
                    _WaveSourceChoice.mood => _moodSettings(context),
                    _WaveSourceChoice.track => _trackSettings(
                      context,
                      filteredTracks,
                    ),
                    _WaveSourceChoice.artist => _artistSettings(
                      context,
                      filteredArtists,
                    ),
                  },
                ),
                _footer(context, tracks),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 4, 8, 10),
    child: Row(
      children: [
        Expanded(
          child: Text(
            context.tr('waveSession.settingsTitle'),
            style: AppText.display3,
          ),
        ),
        IconButton(
          tooltip: context.tr('common.close'),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, size: 18),
        ),
      ],
    ),
  );

  Widget _sourceSelector(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
    child: Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(AppRadius.chipBR.topLeft.x),
      ),
      child: Row(
        children: _WaveSourceChoice.values.map((choice) {
          final isSelected = _source == choice;
          final icon = switch (choice) {
            _WaveSourceChoice.mood => Icons.scatter_plot_rounded,
            _WaveSourceChoice.track => Icons.music_note_rounded,
            _WaveSourceChoice.artist => Icons.person_outline_rounded,
          };
          final label = switch (choice) {
            _WaveSourceChoice.mood => 'waveSession.mood',
            _WaveSourceChoice.track => 'waveSession.track',
            _WaveSourceChoice.artist => 'waveSession.artist',
          };
          return Expanded(
            child: InkWell(
              onTap: () => setState(() {
                _source = choice;
                _search = '';
                _searchController.clear();
              }),
              child: AnimatedContainer(
                duration: AppAnim.fast,
                curve: AppAnim.toggle,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    AppRadius.chipBR.topLeft.x,
                  ),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.borderAct
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: isSelected ? AppColors.text : AppColors.muted,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        context.tr(label),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.bodyS.copyWith(
                          color: isSelected ? AppColors.text : AppColors.muted,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ),
  );

  Widget _moodSettings(BuildContext context) {
    final target = _target ?? MoodPoint(valence: 0, arousal: 0);
    return ListView(
      key: const ValueKey('mood-wave-settings'),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      children: [
        Text(context.tr('waveSession.targetMood'), style: AppText.bodyL),
        const SizedBox(height: 8),
        _StartingMoodTile(
          description: context.tr(
            MoodDescription.keyFor(
              valence: target.valence,
              arousal: target.arousal,
            ),
          ),
          note: context.tr(
            _targetFromLibrary
                ? 'waveSession.targetFromLibrary'
                : _target == null
                ? 'waveSession.targetDefault'
                : 'waveSession.targetChosen',
          ),
          onChoose: _chooseOnMap,
        ),
        const SizedBox(height: 24),
        Text(context.tr('waveSession.mode'), style: AppText.bodyL),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: MoodWaveMode.values
              .map((mode) {
                final isSelected = _moodMode == mode;
                return InkWell(
                  key: ValueKey('wave-mode-${mode.name}'),
                  onTap: () => setState(() => _moodMode = mode),
                  child: AnimatedContainer(
                    duration: AppAnim.fast,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.surface2
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(
                        AppRadius.chipBR.topLeft.x,
                      ),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.borderAct
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      _modeLabel(context, mode).toUpperCase(),
                      style: GoogleFonts.figtree(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.text : AppColors.muted,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                );
              })
              .toList(growable: false),
        ),
        const SizedBox(height: 6),
        Text(
          context.tr('waveSession.modeDescriptions.${_moodMode.name}'),
          key: const ValueKey('wave-mode-description'),
          style: AppText.bodyXS,
        ),
        const SizedBox(height: 20),
        Text(context.tr('waveSession.radius'), style: AppText.bodyL),
        const SizedBox(height: 2),
        Text(context.tr('waveSession.radiusHint'), style: AppText.bodyXS),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.accent,
            inactiveTrackColor: AppColors.surface2,
            thumbColor: AppColors.accent,
            overlayColor: AppColors.glowWhite,
            trackHeight: 2.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
          ),
          child: Slider(
            key: const ValueKey('wave-radius'),
            value: _radius.clamp(0.05, 2),
            min: 0.05,
            max: 2,
            onChanged: (value) => setState(() => _radius = value),
          ),
        ),
      ],
    );
  }

  Widget _trackSettings(BuildContext context, List<Track> tracks) => Column(
    key: const ValueKey('track-wave-settings'),
    children: [
      _searchField(context, 'waveSession.searchTracks'),
      Expanded(
        child: tracks.isEmpty
            ? _emptyResults(context)
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: tracks.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, color: AppColors.border),
                itemBuilder: (context, index) {
                  final track = tracks[index];
                  return _SelectionRow(
                    key: ValueKey('wave-track-${track.id}'),
                    title: track.title,
                    subtitle: track.artists.map((e) => e.name).join(', '),
                    imageUrl: track.imageUrl,
                    selected: track.id == _selectedTrackId,
                    onTap: () => setState(() => _selectedTrackId = track.id),
                  );
                },
              ),
      ),
    ],
  );

  Widget _artistSettings(BuildContext context, List<ArtistSummary> artists) =>
      Column(
        key: const ValueKey('artist-wave-settings'),
        children: [
          _searchField(context, 'waveSession.searchArtists'),
          Expanded(
            child: artists.isEmpty
                ? _emptyResults(context)
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: artists.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, index) {
                      final artist = artists[index];
                      return _SelectionRow(
                        key: ValueKey('wave-artist-${artist.id}'),
                        title: artist.name,
                        subtitle: context.tr(
                          'common.trackCount',
                          namedArgs: {'count': artist.trackCount.toString()},
                        ),
                        imageUrl: artist.coverImageUrls.isEmpty
                            ? null
                            : artist.coverImageUrls.first,
                        selected: artist.id == _selectedArtistId,
                        onTap: () => setState(() {
                          _selectedArtistId = artist.id;
                          _selectedArtistName = artist.name;
                          _selectedArtistImageUrl =
                              artist.coverImageUrls.isEmpty
                              ? null
                              : artist.coverImageUrls.first;
                        }),
                      );
                    },
                  ),
          ),
        ],
      );

  Widget _searchField(BuildContext context, String hintKey) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
    child: TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _search = value),
      style: AppText.bodyM,
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.search_rounded,
          size: 18,
          color: AppColors.muted,
        ),
        hintText: context.tr(hintKey),
        hintStyle: AppText.bodyM.copyWith(color: AppColors.muted),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.s),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.s),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.s),
          borderSide: const BorderSide(color: AppColors.borderAct),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    ),
  );

  Widget _emptyResults(BuildContext context) => Center(
    child: Text(context.tr('waveSession.noResults'), style: AppText.bodyM),
  );

  Widget _footer(BuildContext context, List<Track> tracks) {
    final active = _playerState(context).waveSession;
    final selectedTrack = _trackById(tracks, _selectedTrackId);
    final canSubmit = switch (_source) {
      _WaveSourceChoice.mood => true,
      _WaveSourceChoice.track => selectedTrack != null,
      _WaveSourceChoice.artist => _selectedArtistId != null,
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (active != null) ...[
            TextButton(
              key: const ValueKey('stop-wave-in-settings'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSub,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onPressed: () {
                _dispatch(context, PlayerWaveStopped());
                Navigator.pop(context);
              },
              child: Text(context.tr('waveSession.stop')),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: ElevatedButton.icon(
              key: const ValueKey('apply-wave-settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.bg,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.chipBR),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: canSubmit
                  ? () => _submit(context, active, selectedTrack)
                  : null,
              icon: const Icon(Icons.waves_rounded, color: AppColors.bg),
              label: Text(
                context.tr(
                  active == null
                      ? 'waveSession.startWave'
                      : 'waveSession.applyOrSwitch',
                ),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submit(
    BuildContext context,
    WaveSession? active,
    Track? selectedTrack,
  ) {
    switch (_source) {
      case _WaveSourceChoice.mood:
        final target = _target ?? MoodPoint(valence: 0, arousal: 0);
        if (active?.source is MoodWaveSource) {
          _dispatch(
            context,
            PlayerWaveMoodSettingsUpdated(
              mode: _moodMode,
              radius: _radius,
              targetValence: target.valence,
              targetArousal: target.arousal,
            ),
          );
        } else {
          _dispatch(
            context,
            PlayerMoodWaveStarted(
              targetValence: target.valence,
              targetArousal: target.arousal,
              radius: _radius,
              mode: _moodMode,
            ),
          );
        }
      case _WaveSourceChoice.track:
        _dispatch(context, PlayerTrackWaveStarted(track: selectedTrack!));
      case _WaveSourceChoice.artist:
        _dispatch(
          context,
          PlayerArtistWaveStarted(
            artistId: _selectedArtistId!,
            artistName:
                _selectedArtistName ?? context.tr('waveSession.unknownArtist'),
            imageUrl: _selectedArtistImageUrl,
          ),
        );
    }
    Navigator.pop(context);
  }

  List<Track> _filterTracks(List<Track> tracks) {
    final query = _search.trim().toLowerCase();
    if (query.isEmpty) return tracks;
    return tracks
        .where(
          (track) =>
              track.title.toLowerCase().contains(query) ||
              track.artists.any(
                (artist) => artist.name.toLowerCase().contains(query),
              ),
        )
        .toList(growable: false);
  }

  List<ArtistSummary> _filterArtists(List<ArtistSummary> artists) {
    final query = _search.trim().toLowerCase();
    if (query.isEmpty) return artists;
    return artists
        .where((artist) => artist.name.toLowerCase().contains(query))
        .toList(growable: false);
  }

  PlayerState _playerState(BuildContext context) =>
      widget.playerState ?? context.read<PlayerBloc>().state;

  void _dispatch(BuildContext context, PlayerEvent event) {
    final callback = widget.onEvent;
    if (callback != null) {
      callback(event);
    } else {
      context.read<PlayerBloc>().add(event);
    }
  }
}

/// The mood a Wave starts from, with the way to change it on the Mood Map.
class _StartingMoodTile extends StatelessWidget {
  const _StartingMoodTile({
    required this.description,
    required this.note,
    required this.onChoose,
  });

  final String description;
  final String note;
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) => AppSurface(
    padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
    color: AppColors.surface2,
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                key: const ValueKey('wave-target-description'),
                style: AppText.bodyL,
              ),
              const SizedBox(height: 2),
              Text(note, style: AppText.bodyM),
            ],
          ),
        ),
        TextButton(
          key: const ValueKey('wave-choose-on-map'),
          style: TextButton.styleFrom(minimumSize: const Size(0, 44)),
          onPressed: onChoose,
          child: Text(context.tr('waveSession.chooseOnMap')),
        ),
      ],
    ),
  );
}

Future<MoodPoint?> _openMoodPicker(BuildContext context, MoodPoint? current) =>
    Navigator.of(context, rootNavigator: true).push<MoodPoint>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) {
            final cubit = getIt<MoodMapCubit>()..initialize();
            if (current != null) {
              cubit.setTarget(current.valence, current.arousal);
            }
            return cubit;
          },
          child: const MoodMapPage(pickTarget: true),
        ),
      ),
    );

class _SelectionRow extends StatelessWidget {
  const _SelectionRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String? imageUrl;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    onTap: onTap,
    leading: ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: CachedImage(
        url: imageUrl,
        size: 42,
        fallback: const Icon(Icons.music_note_rounded),
      ),
    ),
    title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
    subtitle: subtitle.isEmpty
        ? null
        : Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
    trailing: selected
        ? const Icon(Icons.check_circle_rounded)
        : const Icon(Icons.circle_outlined, color: AppColors.muted2),
  );
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 32,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.muted2,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}

Track? _trackById(List<Track> tracks, String? id) {
  if (id == null) return null;
  for (final track in tracks) {
    if (track.id == id) return track;
  }
  return null;
}

String _sourceLabel(
  BuildContext context,
  WaveSource source,
) => switch (source) {
  MoodWaveSource(:final userTarget) => context.tr(
    'waveSession.moodSource',
    namedArgs: {
      'mood': context.tr(
        MoodDescription.keyFor(
          valence: userTarget.valence,
          arousal: userTarget.arousal,
        ),
      ),
    },
  ),
  TrackWaveSource(:final trackTitle) => context.tr(
    'waveSession.trackSource',
    namedArgs: {'title': trackTitle ?? context.tr('waveSession.unknownTrack')},
  ),
  ArtistWaveSource(:final artistName) => context.tr(
    'waveSession.artistSource',
    namedArgs: {'name': artistName ?? context.tr('waveSession.unknownArtist')},
  ),
};

String _modeLabel(BuildContext context, MoodWaveMode mode) => switch (mode) {
  MoodWaveMode.stay => context.tr('moodMap.modeStay'),
  MoodWaveMode.explore => context.tr('moodMap.modeExplore'),
  MoodWaveMode.lift => context.tr('moodMap.modeLift'),
  MoodWaveMode.calm => context.tr('moodMap.modeCalm'),
};
