import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openmusic/core/themes/app_theme.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/wave_config.dart';
import 'package:openmusic/layers/presentation/blocs/player/player_bloc.dart';
import 'package:openmusic/layers/presentation/blocs/track/track_bloc.dart';
import 'package:openmusic/layers/presentation/blocs/wave/wave_bloc.dart';
import 'package:openmusic/layers/presentation/widgets/playlist_cover.dart';

class WaveCard extends StatelessWidget {
  const WaveCard({super.key});

  bool _isWaveQueueActive(List<Track> waveTracks, PlayerState player) {
    if (waveTracks.length != player.queue.length) return false;
    for (var index = 0; index < waveTracks.length; index++) {
      if (waveTracks[index].id != player.queue[index].id) return false;
    }
    return true;
  }

  void _openSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (_) => const _WaveSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WaveBloc, WaveState>(
      builder: (context, state) {
        final config = _configOf(state);
        final visibleTracks = _visibleTracksOf(state);
        final readyTracks = state is WaveReady ? state.tracks : const <Track>[];
        final playerState = context.watch<PlayerBloc>().state;
        final isQueueActive = _isWaveQueueActive(readyTracks, playerState);
        final isPlayingWave = isQueueActive && playerState.isPlaying;
        final hasBasis = _hasBasis(config);

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    context.tr('wave.sectionTitle').toUpperCase(),
                    style: AppText.label,
                  ),
                  const Spacer(),
                  if (hasBasis && state is! WaveGenerating)
                    _WaveHeaderAction(
                      tooltip: context.tr('wave.regenerate'),
                      icon: Icons.refresh,
                      onPressed: () =>
                          context.read<WaveBloc>().add(WaveRefreshRequested()),
                    ),
                  _WaveHeaderAction(
                    tooltip: context.tr('wave.configure'),
                    icon: Icons.tune,
                    onPressed: () => _openSettingsSheet(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _openSettingsSheet(context),
                child: Row(
                  children: [
                    PlaylistCover(
                      generatedImageUrls: visibleTracks
                          .map((track) => track.imageUrl ?? '')
                          .toList(growable: false),
                      size: 88,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                      placeholder: const Icon(
                        Icons.waves_rounded,
                        color: AppColors.muted,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('wave.mixTitle'),
                            style: AppText.display3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _statusLabel(context, state, hasBasis),
                            style: AppText.bodyM.copyWith(
                              color: state is WaveError
                                  ? AppColors.error
                                  : AppColors.textSub,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (hasBasis) ...[
                            const SizedBox(height: 3),
                            Text(
                              context.tr(
                                'wave.basedOn',
                                namedArgs: {'basis': _basisSummary(config)},
                              ),
                              style: AppText.bodyXS,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (state is WaveGenerating)
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: AppColors.textSub,
                          ),
                        ),
                      )
                    else if (state is WaveReady)
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: IconButton.filled(
                          tooltip: context.tr(
                            isPlayingWave ? 'wave.pause' : 'wave.play',
                          ),
                          onPressed: () {
                            context.read<PlayerBloc>().add(
                              isQueueActive
                                  ? PlayerPlayPauseToggled()
                                  : PlayerQueueSet(state.tracks),
                            );
                          },
                          icon: Icon(
                            isPlayingWave ? Icons.pause : Icons.play_arrow,
                            size: 22,
                          ),
                          style: IconButton.styleFrom(
                            foregroundColor: AppColors.text,
                            backgroundColor: AppColors.surface2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      )
                    else
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.muted2,
                        size: 22,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _statusLabel(BuildContext context, WaveState state, bool hasBasis) {
    return switch (state) {
      WaveGenerating() => context.tr('wave.generating'),
      WaveReady(:final tracks) => context.tr(
        'common.trackCount',
        namedArgs: {'count': tracks.length.toString()},
      ),
      WaveError(:final error) => error.tr(),
      WaveEmpty() when hasBasis => context.tr('wave.noMatches'),
      _ => context.tr('wave.selectBasis'),
    };
  }
}

class _WaveHeaderAction extends StatelessWidget {
  const _WaveHeaderAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      color: AppColors.muted,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
    );
  }
}

enum _WaveTab { artists, tracks }

class _WaveSettingsSheet extends StatefulWidget {
  const _WaveSettingsSheet();

  @override
  State<_WaveSettingsSheet> createState() => _WaveSettingsSheetState();
}

class _WaveSettingsSheetState extends State<_WaveSettingsSheet> {
  _WaveTab _tab = _WaveTab.artists;
  String _search = '';
  final _searchCtrl = TextEditingController();
  late WaveConfig _draft;

  @override
  void initState() {
    super.initState();
    _draft = _configOf(context.read<WaveBloc>().state);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allTracks = switch (context.watch<TrackBloc>().state) {
      TrackLoaded(:final tracks) =>
        tracks.where((track) => track.isReady).toList(),
      _ => <Track>[],
    };
    final allArtists = _uniqueArtists(allTracks);
    final normalizedSearch = _search.trim().toLowerCase();
    final filteredArtists = normalizedSearch.isEmpty
        ? allArtists
        : allArtists
              .where(
                (artist) => artist.toLowerCase().contains(normalizedSearch),
              )
              .toList();
    final filteredTracks = normalizedSearch.isEmpty
        ? allTracks
        : allTracks
              .where(
                (track) =>
                    track.title.toLowerCase().contains(normalizedSearch) ||
                    track.artists.any(
                      (artist) =>
                          artist.name.toLowerCase().contains(normalizedSearch),
                    ),
              )
              .toList();

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.82,
      decoration: const BoxDecoration(
        color: AppBlur.sheetColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SheetHandle(),
          _buildHeader(context),
          const Divider(height: 1, color: AppColors.border),
          _buildTabs(context),
          _buildSearch(context),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: _tab == _WaveTab.artists
                ? _buildArtistList(filteredArtists)
                : _buildTrackList(filteredTracks),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final selectedCount = _draft.seeds.length + _draft.tracks.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 8, 12),
      child: Row(
        children: [
          Text(context.tr('wave.dialogTitle'), style: AppText.display3),
          if (selectedCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surface3,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text('$selectedCount', style: AppText.bodyXS),
            ),
          ],
          const Spacer(),
          IconButton(
            tooltip: context.tr('common.close'),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 18, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: SizedBox(
        width: double.infinity,
        child: SegmentedButton<_WaveTab>(
          segments: [
            ButtonSegment(
              value: _WaveTab.artists,
              icon: const Icon(Icons.person_outline, size: 17),
              label: Text(context.tr('wave.artists')),
            ),
            ButtonSegment(
              value: _WaveTab.tracks,
              icon: const Icon(Icons.music_note, size: 17),
              label: Text(context.tr('wave.tracks')),
            ),
          ],
          selected: {_tab},
          showSelectedIcon: false,
          onSelectionChanged: (selection) => setState(() {
            _tab = selection.single;
            _search = '';
            _searchCtrl.clear();
          }),
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? AppColors.text
                  : AppColors.muted,
            ),
            backgroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? AppColors.surface2
                  : Colors.transparent,
            ),
            side: WidgetStateProperty.all(
              const BorderSide(color: AppColors.border),
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            textStyle: WidgetStateProperty.all(AppText.bodyS),
          ),
        ),
      ),
    );
  }

  Widget _buildSearch(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: SizedBox(
        height: 40,
        child: TextField(
          controller: _searchCtrl,
          onChanged: (value) => setState(() => _search = value),
          style: AppText.bodyM.copyWith(color: AppColors.text),
          decoration: InputDecoration(
            hintText: context.tr(
              _tab == _WaveTab.artists
                  ? 'wave.searchArtists'
                  : 'wave.searchTracks',
            ),
            hintStyle: AppText.bodyM,
            prefixIcon: const Icon(
              Icons.search,
              size: 16,
              color: AppColors.muted,
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            border: _searchBorder(AppColors.border),
            enabledBorder: _searchBorder(AppColors.border),
            focusedBorder: _searchBorder(AppColors.borderAct),
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _searchBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color),
    );
  }

  Widget _buildArtistList(List<String> artists) {
    if (artists.isEmpty) {
      return Center(
        child: Text(
          context.tr(_search.isEmpty ? 'wave.noArtists' : 'wave.noResults'),
          style: AppText.bodyM,
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      itemCount: artists.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, color: AppColors.border),
      itemBuilder: (context, index) {
        final artist = artists[index];
        final selected = _containsSeed(artist);
        return _WaveSeedRow(
          primary: artist,
          secondary: null,
          icon: Icons.person_outline,
          isSelected: selected,
          onTap: () => _toggleSeed(artist),
        );
      },
    );
  }

  Widget _buildTrackList(List<Track> tracks) {
    if (tracks.isEmpty) {
      return Center(
        child: Text(
          context.tr(_search.isEmpty ? 'wave.noTracksReady' : 'wave.noResults'),
          style: AppText.bodyM,
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      itemCount: tracks.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, color: AppColors.border),
      itemBuilder: (context, index) {
        final track = tracks[index];
        final selected = _draft.tracks.any((item) => item.id == track.id);
        return _WaveSeedRow(
          primary: track.title,
          secondary: track.artists.map((artist) => artist.name).join(', '),
          icon: Icons.music_note,
          isSelected: selected,
          onTap: () => _toggleTrack(track),
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    final canBuild = _hasBasis(_draft);
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        14 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: IconButton.outlined(
              tooltip: context.tr('wave.reset'),
              onPressed: () {
                context.read<WaveBloc>().add(WaveResetRequested());
                Navigator.pop(context);
              },
              icon: const Icon(Icons.restart_alt, size: 19),
              style: IconButton.styleFrom(
                foregroundColor: AppColors.textSub,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 44,
              child: OutlinedButton.icon(
                onPressed: canBuild
                    ? () {
                        context.read<WaveBloc>().add(WaveConfigApplied(_draft));
                        Navigator.pop(context);
                      }
                    : null,
                icon: const Icon(Icons.waves_rounded, size: 18),
                label: Text(context.tr('wave.build')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.text,
                  disabledForegroundColor: AppColors.muted2,
                  backgroundColor: AppColors.surface2,
                  disabledBackgroundColor: AppColors.surface,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: AppText.bodyL.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _uniqueArtists(List<Track> tracks) {
    final artists = <String, String>{};
    for (final artist in tracks.expand((track) => track.artists)) {
      final normalized = _normalizeName(artist.name);
      if (normalized.isEmpty) continue;
      artists.putIfAbsent(normalized, () => artist.name.trim());
    }
    final result = artists.values.toList();
    result.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return result;
  }

  bool _containsSeed(String artist) {
    final normalized = _normalizeName(artist);
    return _draft.seeds.any((seed) => _normalizeName(seed) == normalized);
  }

  void _toggleSeed(String artist) {
    final normalized = _normalizeName(artist);
    setState(() {
      final selected = _draft.seeds.any(
        (seed) => _normalizeName(seed) == normalized,
      );
      _draft = _draft.copyWith(
        seeds: selected
            ? _draft.seeds
                  .where((seed) => _normalizeName(seed) != normalized)
                  .toList()
            : [..._draft.seeds, artist.trim()],
      );
    });
  }

  void _toggleTrack(Track track) {
    setState(() {
      final selected = _draft.tracks.any((item) => item.id == track.id);
      _draft = _draft.copyWith(
        tracks: selected
            ? _draft.tracks.where((item) => item.id != track.id).toList()
            : [..._draft.tracks, track],
      );
    });
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
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
}

class _WaveSeedRow extends StatelessWidget {
  const _WaveSeedRow({
    required this.primary,
    required this.secondary,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String primary;
  final String? secondary;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.muted),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    primary,
                    style: AppText.bodyL.copyWith(
                      color: isSelected ? AppColors.text : AppColors.textSub,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (secondary != null && secondary!.isNotEmpty)
                    Text(
                      secondary!,
                      style: AppText.bodyXS,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            SizedBox(
              width: 24,
              child: AnimatedOpacity(
                opacity: isSelected ? 1 : 0,
                duration: AppAnim.fast,
                child: const Icon(
                  Icons.check,
                  size: 16,
                  color: AppColors.textSub,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

WaveConfig _configOf(WaveState state) => switch (state) {
  WaveReady(:final config) => config,
  WaveGenerating(:final config) => config,
  WaveEmpty(:final config) => config,
  WaveError(:final config) => config,
  _ => const WaveConfig(seeds: [], tracks: []),
};

List<Track> _visibleTracksOf(WaveState state) => switch (state) {
  WaveReady(:final tracks) => tracks,
  WaveGenerating(:final previousTracks) => previousTracks,
  WaveError(:final previousTracks) => previousTracks,
  _ => const [],
};

bool _hasBasis(WaveConfig config) {
  return config.seeds.isNotEmpty || config.tracks.isNotEmpty;
}

String _basisSummary(WaveConfig config) {
  final labels = [
    ...config.seeds.map((seed) => seed.trim()),
    ...config.tracks.map((track) => track.title.trim()),
  ].where((label) => label.isNotEmpty).toList();
  final visible = labels.take(2).join(', ');
  final hiddenCount = labels.length - 2;
  return hiddenCount > 0 ? '$visible +$hiddenCount' : visible;
}

String _normalizeName(String name) {
  return name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}
