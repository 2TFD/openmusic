import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openmusic/core/di/di.dart';
import 'package:openmusic/core/themes/app_theme.dart';
import 'package:openmusic/layers/domain/entities/artist.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/wave_session.dart';
import 'package:openmusic/layers/presentation/blocs/artists/artists_cubit.dart';
import 'package:openmusic/layers/presentation/blocs/mood_map/mood_map_cubit.dart';
import 'package:openmusic/layers/presentation/blocs/player/player_bloc.dart';
import 'package:openmusic/layers/presentation/blocs/track/track_bloc.dart';
import 'package:openmusic/layers/presentation/screens/mood_map_page.dart';
import 'package:openmusic/layers/presentation/widgets/cached_image.dart';

class WaveCard extends StatelessWidget {
  const WaveCard({super.key});

  void _openSettings(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => getIt<MoodMapCubit>()..initialize(),
        child: const WaveSettingsSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      buildWhen: (previous, current) =>
          previous.waveSession != current.waveSession ||
          previous.waveContinuationStatus != current.waveContinuationStatus ||
          previous.queue != current.queue ||
          previous.currentIndex != current.currentIndex,
      builder: (context, state) => WaveCardView(
        state: state,
        onConfigure: () => _openSettings(context),
        onRetry: () =>
            context.read<PlayerBloc>().add(PlayerWaveRetryRequested()),
      ),
    );
  }
}

class WaveCardView extends StatelessWidget {
  const WaveCardView({
    super.key,
    required this.state,
    required this.onConfigure,
    this.onRetry,
  });

  final PlayerState state;
  final VoidCallback onConfigure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final session = state.waveSession;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('waveSession.title').toUpperCase(),
            style: AppText.label,
          ),
          const SizedBox(height: 8),
          Material(
            color: AppColors.surface,
            borderRadius: AppRadius.cardBR,
            child: InkWell(
              key: const ValueKey('wave-card'),
              borderRadius: AppRadius.cardBR,
              onTap: onConfigure,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: AppRadius.cardBR,
                ),
                child: Row(
                  children: [
                    _WaveArtwork(source: session?.source),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session == null
                                ? context.tr('waveSession.inactiveTitle')
                                : _sourceLabel(context, session.source),
                            key: const ValueKey('wave-card-source'),
                            style: AppText.display3,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Semantics(
                            liveRegion: true,
                            child: Text(
                              session == null
                                  ? context.tr(
                                      'waveSession.inactiveDescription',
                                    )
                                  : context.tr(
                                      state.isWaveGenerating
                                          ? 'waveSession.generating'
                                          : state.isWaveWaiting
                                          ? 'waveSession.waiting'
                                          : 'waveSession.readyWithRemaining',
                                      namedArgs: {
                                        'count': state.remainingQueueCount
                                            .toString(),
                                      },
                                    ),
                              key: const ValueKey('wave-card-status'),
                              style: AppText.bodyM,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (state.isWaveGenerating)
                      const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 1.5),
                      )
                    else if (state.isWaveWaiting)
                      IconButton(
                        key: const ValueKey('wave-card-retry'),
                        tooltip: context.tr('waveSession.retry'),
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh_rounded, size: 20),
                      )
                    else
                      IconButton(
                        key: const ValueKey('configure-wave'),
                        tooltip: context.tr('waveSession.configure'),
                        onPressed: onConfigure,
                        icon: Icon(
                          session == null ? Icons.add_rounded : Icons.tune,
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveArtwork extends StatelessWidget {
  const _WaveArtwork({required this.source});

  final WaveSource? source;

  @override
  Widget build(BuildContext context) {
    final imageUrl = source?.imageUrl;
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl == null
          ? Icon(
              source == null
                  ? Icons.waves_rounded
                  : source is MoodWaveSource
                  ? Icons.scatter_plot_rounded
                  : source is ArtistWaveSource
                  ? Icons.person_outline_rounded
                  : Icons.music_note_rounded,
              size: 28,
              color: AppColors.muted,
            )
          : CachedImage(
              url: imageUrl,
              size: 68,
              fallback: const Icon(Icons.waves_rounded, color: AppColors.muted),
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
    this.moodMapState,
    this.onEvent,
  });

  final PlayerState? playerState;
  final List<Track>? tracks;
  final List<ArtistSummary>? artists;
  final MoodMapState? moodMapState;
  final ValueChanged<PlayerEvent>? onEvent;

  @override
  State<WaveSettingsSheet> createState() => _WaveSettingsSheetState();
}

class _WaveSettingsSheetState extends State<WaveSettingsSheet> {
  late _WaveSourceChoice _source;
  MoodWaveMode _moodMode = MoodWaveMode.stay;
  double _radius = 0.35;
  MoodPoint _target = MoodPoint(valence: 0, arousal: 0);
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

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.84,
      decoration: const BoxDecoration(
        color: AppBlur.sheetColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandle(),
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
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
    child: SizedBox(
      width: double.infinity,
      child: SegmentedButton<_WaveSourceChoice>(
        key: const ValueKey('wave-source-selector'),
        segments: [
          ButtonSegment(
            value: _WaveSourceChoice.mood,
            label: Text(context.tr('waveSession.mood')),
            icon: const Icon(Icons.scatter_plot_rounded, size: 16),
          ),
          ButtonSegment(
            value: _WaveSourceChoice.track,
            label: Text(context.tr('waveSession.track')),
            icon: const Icon(Icons.music_note_rounded, size: 16),
          ),
          ButtonSegment(
            value: _WaveSourceChoice.artist,
            label: Text(context.tr('waveSession.artist')),
            icon: const Icon(Icons.person_outline_rounded, size: 16),
          ),
        ],
        selected: {_source},
        showSelectedIcon: false,
        onSelectionChanged: (value) => setState(() {
          _source = value.single;
          _search = '';
          _searchController.clear();
        }),
      ),
    ),
  );

  Widget _moodSettings(BuildContext context) {
    final injectedState = widget.moodMapState;
    if (injectedState != null) {
      return _moodSettingsContent(context, injectedState);
    }
    return BlocBuilder<MoodMapCubit, MoodMapState>(
      builder: _moodSettingsContent,
    );
  }

  Widget _moodSettingsContent(BuildContext context, MoodMapState mapState) {
    final displayState = mapState.copyWith(
      targetValence: _target.valence,
      targetArousal: _target.arousal,
    );
    return ListView(
      key: const ValueKey('mood-wave-settings'),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      children: [
        Text(context.tr('waveSession.mode'), style: AppText.bodyL),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: MoodWaveMode.values
              .map(
                (mode) => ChoiceChip(
                  key: ValueKey('wave-mode-${mode.name}'),
                  label: Text(_modeLabel(context, mode)),
                  selected: _moodMode == mode,
                  onSelected: (_) => setState(() => _moodMode = mode),
                ),
              )
              .toList(growable: false),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Text(context.tr('waveSession.radius'), style: AppText.bodyL),
            const Spacer(),
            Text(_radius.toStringAsFixed(2), style: AppText.bodyM),
          ],
        ),
        Slider(
          key: const ValueKey('wave-radius'),
          value: _radius.clamp(0.05, 2),
          min: 0.05,
          max: 2,
          onChanged: (value) => setState(() => _radius = value),
        ),
        const SizedBox(height: 8),
        Text(context.tr('waveSession.targetMood'), style: AppText.bodyL),
        const SizedBox(height: 4),
        Text(
          context.tr(
            'waveSession.target',
            namedArgs: {
              'valence': _target.valence.toStringAsFixed(2),
              'arousal': _target.arousal.toStringAsFixed(2),
            },
          ),
          style: AppText.bodyM,
        ),
        const SizedBox(height: 10),
        switch (mapState.status) {
          MoodMapStatus.initial || MoodMapStatus.loading => const SizedBox(
            height: 280,
            child: Center(child: CircularProgressIndicator()),
          ),
          MoodMapStatus.failure => SizedBox(
            height: 280,
            child: Center(
              child: Text(context.tr('moodMap.error'), style: AppText.bodyM),
            ),
          ),
          MoodMapStatus.ready => MoodMapPanel(
            key: const ValueKey('wave-target-map'),
            state: displayState,
            onTargetChanged: (target) => setState(() => _target = target),
          ),
        },
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
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search_rounded, size: 18),
        hintText: context.tr(hintKey),
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
              onPressed: () {
                _dispatch(context, PlayerWaveStopped());
                Navigator.pop(context);
              },
              child: Text(context.tr('waveSession.stop')),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: FilledButton.icon(
              key: const ValueKey('apply-wave-settings'),
              onPressed: canSubmit
                  ? () => _submit(context, active, selectedTrack)
                  : null,
              icon: const Icon(Icons.waves_rounded),
              label: Text(
                context.tr(
                  active == null
                      ? 'waveSession.startWave'
                      : 'waveSession.applyOrSwitch',
                ),
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
        final target = _target;
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
  MoodWaveSource(:final mode) => context.tr(
    'waveSession.moodSource',
    namedArgs: {'mode': _modeLabel(context, mode)},
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
