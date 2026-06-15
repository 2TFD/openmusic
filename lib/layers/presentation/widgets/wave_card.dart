import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openmusic/core/themes/app_theme.dart';
import 'package:openmusic/core/utils/locale_keys.dart';
import 'package:openmusic/layers/domain/entities/wave_config.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/presentation/blocs/player/player_bloc.dart';
import 'package:openmusic/layers/presentation/blocs/track/track_bloc.dart';
import 'package:openmusic/layers/presentation/blocs/wave/wave_bloc.dart';
import 'package:openmusic/layers/presentation/widgets/cached_image.dart';

class WaveCard extends StatefulWidget {
  const WaveCard({super.key});
  @override
  State<WaveCard> createState() => _WaveCardState();
}

class _WaveCardState extends State<WaveCard> {
  Widget _buildPlayButton(bool isWaveQueueActive, bool isPlaying) {
    if (!isWaveQueueActive) {
      return const Icon(Icons.play_arrow, color: AppColors.text, size: 22);
    }
    return Icon(
      isPlaying ? Icons.pause : Icons.play_arrow,
      color: AppColors.text,
      size: 22,
    );
  }

  void _openSettingsSheet() {
    showModalBottomSheet(
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => const _WaveSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WaveBloc, WaveState>(
      listener: (context, state) {
        if (state is WaveReady) {
          context.read<PlayerBloc>().add(PlayerQueueSet(state.tracks));
        }
      },
      builder: (context, state) {
        if (state is WaveError) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.muted,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'own mood',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: AppColors.text,
                          ),
                        ),
                        Text(
                          state.error.tr(),
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.read<WaveBloc>().add(WaveRefreshed()),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.bg,
                      ),
                      child: const Icon(
                        Icons.refresh,
                        color: AppColors.text,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final currentImageUrl = context.select<PlayerBloc, String?>(
          (playerBloc) => playerBloc.state.currentTrack?.imageUrl,
        );
        final isWaveQueueActive = state is WaveReady;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                (currentImageUrl != null && isWaveQueueActive)
                    ? Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedImage(url: currentImageUrl, size: 40),
                        ),
                      )
                    : const Icon(
                        Icons.music_note,
                        color: AppColors.muted,
                        size: 18,
                      ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'own mood',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              color: AppColors.text,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _openSettingsSheet(),
                            icon: const Icon(Icons.settings),
                          ),
                        ],
                      ),
                      Text(
                        state is WaveReady ? state.config.seeds.join(', ') : '',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.2,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    if (state is WaveReady) {
                      context.read<PlayerBloc>().add(PlayerPlayPauseToggled());
                    }
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.bg,
                    ),
                    child: _buildPlayButton(
                      isWaveQueueActive,
                      context.select<PlayerBloc, bool>(
                        (playerBloc) => playerBloc.state.isPlaying,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

  static const _moods = [
    ('melancholy', LocaleKeys.moodMelancholy),
    ('energy', LocaleKeys.moodEnergy),
    ('focus', LocaleKeys.moodFocus),
    ('night', LocaleKeys.moodNight),
    ('drive', LocaleKeys.moodDrive),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  WaveConfig _configOf(WaveState s) => switch (s) {
    WaveReady(:final config) => config,
    WaveGenerating(:final config) => config,
    WaveEmpty(:final config) => config,
    WaveError(:final config) => config,
    _ => const WaveConfig(seeds: [], mood: '', tracks: []),
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WaveBloc, WaveState>(
      builder: (context, waveState) {
        final config = _configOf(waveState);

        final allTracks = switch (context.read<TrackBloc>().state) {
          TrackLoaded(:final tracks) => tracks.where((t) => t.isReady).toList(),
          _ => <Track>[],
        };

        final allArtists =
            (allTracks
                    .expand((t) => t.artists)
                    .map((a) => a.name)
                    .toSet()
                    .toList()
                  ..sort())
                .cast<String>();

        final filteredArtists = _search.isEmpty
            ? allArtists
            : allArtists
                  .where((a) => a.toLowerCase().contains(_search.toLowerCase()))
                  .toList();

        final filteredTracks = _search.isEmpty
            ? allTracks
            : allTracks
                  .where(
                    (t) =>
                        t.title.toLowerCase().contains(_search.toLowerCase()) ||
                        t.artists.any(
                          (a) => a.name.toLowerCase().contains(
                            _search.toLowerCase(),
                          ),
                        ),
                  )
                  .toList();

        return Container(
          height: MediaQuery.of(context).size.height * 0.78,
          decoration: const BoxDecoration(
            color: AppBlur.sheetColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHandle(),
              _buildHeader(context, config),
              _buildMoodRow(context, config.mood),
              const Divider(height: 1, thickness: 1, color: AppColors.border),
              _buildTabBar(),
              _buildSearch(),
              const Divider(height: 1, thickness: 1, color: AppColors.border),
              Expanded(
                child: _tab == _WaveTab.artists
                    ? _buildArtistList(context, filteredArtists, config.seeds)
                    : _buildTrackList(context, filteredTracks, config.tracks),
              ),
              _buildFooter(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() => Center(
    child: Container(
      margin: const EdgeInsets.only(top: AppSpacing.m, bottom: AppSpacing.s),
      width: 32,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.muted2,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );

  Widget _buildHeader(BuildContext context, WaveConfig config) {
    final seedCount = config.seeds.length + config.tracks.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xs,
        AppSpacing.s,
        AppSpacing.m,
      ),
      child: Row(
        children: [
          Text('Wave', style: AppText.display3),
          if (seedCount > 0) ...[
            const SizedBox(width: AppSpacing.s),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface3,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                '$seedCount',
                style: AppText.bodyXS.copyWith(color: AppColors.textSub),
              ),
            ),
          ],
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 18, color: AppColors.muted),
            padding: const EdgeInsets.all(AppSpacing.s),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodRow(BuildContext context, String currentMood) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.xl,
      0,
      AppSpacing.xl,
      AppSpacing.m,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('MOOD', style: AppText.label),
        const SizedBox(height: AppSpacing.s),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _moods.map((m) {
              final (key, localeKey) = m;
              final active = currentMood == key;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.s),
                child: GestureDetector(
                  onTap: () => context.read<WaveBloc>().add(
                    WaveMoodChanged(active ? '' : key),
                  ),
                  child: AnimatedContainer(
                    duration: AppAnim.fast,
                    curve: AppAnim.toggle,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.m,
                      vertical: AppSpacing.s - 2,
                    ),
                    decoration: BoxDecoration(
                      color: active ? AppColors.surface3 : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                        color: active ? AppColors.borderAct : AppColors.border,
                      ),
                    ),
                    child: Text(
                      localeKey.tr(),
                      style: AppText.bodyS.copyWith(
                        color: active ? AppColors.text : AppColors.muted,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    ),
  );

  Widget _buildTabBar() => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.xl,
      AppSpacing.m,
      AppSpacing.xl,
      AppSpacing.m,
    ),
    child: Row(
      children: [
        _WaveTabButton(
          label: 'Artists',
          active: _tab == _WaveTab.artists,
          onTap: () => setState(() {
            _tab = _WaveTab.artists;
            _search = '';
            _searchCtrl.clear();
          }),
        ),
        const SizedBox(width: AppSpacing.xl),
        _WaveTabButton(
          label: 'Tracks',
          active: _tab == _WaveTab.tracks,
          onTap: () => setState(() {
            _tab = _WaveTab.tracks;
            _search = '';
            _searchCtrl.clear();
          }),
        ),
      ],
    ),
  );

  Widget _buildSearch() => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.xl,
      AppSpacing.s,
      AppSpacing.xl,
      AppSpacing.s,
    ),
    child: SizedBox(
      height: 38,
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _search = v),
        style: AppText.bodyM.copyWith(color: AppColors.text),
        decoration: InputDecoration(
          hintText: _tab == _WaveTab.artists
              ? 'Search artists…'
              : 'Search tracks…',
          hintStyle: AppText.bodyM,
          prefixIcon: const Icon(
            Icons.search,
            size: 16,
            color: AppColors.muted,
          ),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
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
        ),
      ),
    ),
  );

  Widget _buildArtistList(
    BuildContext context,
    List<String> artists,
    List<String> seeds,
  ) {
    if (artists.isEmpty) {
      return Center(
        child: Text(
          _search.isEmpty ? 'No artists in library' : 'No results',
          style: AppText.bodyM,
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xs,
      ),
      itemCount: artists.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, thickness: 1, color: AppColors.border),
      itemBuilder: (context, i) {
        final artist = artists[i];
        final selected = seeds.contains(artist);
        return _WaveSeedRow(
          primary: artist,
          secondary: null,
          icon: Icons.person_outline,
          isSelected: selected,
          onTap: () => context.read<WaveBloc>().add(
            selected ? WaveSeedRemoved(artist) : WaveSeedAdded(artist),
          ),
        );
      },
    );
  }

  Widget _buildTrackList(
    BuildContext context,
    List<Track> tracks,
    List<Track> selected,
  ) {
    if (tracks.isEmpty) {
      return Center(
        child: Text(
          _search.isEmpty ? 'No tracks ready' : 'No results',
          style: AppText.bodyM,
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xs,
      ),
      itemCount: tracks.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, thickness: 1, color: AppColors.border),
      itemBuilder: (context, i) {
        final track = tracks[i];
        final isSelected = selected.contains(track);
        return _WaveSeedRow(
          primary: track.title,
          secondary: track.artists.map((a) => a.name).join(', '),
          icon: Icons.music_note,
          isSelected: isSelected,
          onTap: () => context.read<WaveBloc>().add(
            isSelected ? WaveRemoveTrack(track) : WaveAddTrack(track),
          ),
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      AppSpacing.xl,
      AppSpacing.m,
      AppSpacing.xl,
      AppSpacing.xxl + MediaQuery.of(context).padding.bottom,
    ),
    child: Center(
      child: GestureDetector(
        onTap: () {
          context.read<WaveBloc>().add(WaveReset());
          Navigator.pop(context);
        },
        child: Text('Reset wave', style: AppText.bodyM),
      ),
    ),
  );
}

class _WaveTabButton extends StatelessWidget {
  const _WaveTabButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppText.bodyL.copyWith(
              color: active ? AppColors.text : AppColors.muted,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          AnimatedContainer(
            duration: AppAnim.fast,
            curve: AppAnim.toggle,
            height: 2,
            width: active ? 20.0 : 0.0,
            decoration: BoxDecoration(
              color: AppColors.text,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.m - 2),
        child: Row(
          children: [
            Icon(icon, size: 14, color: AppColors.muted),
            const SizedBox(width: AppSpacing.m),
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
            AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: AppAnim.fast,
              child: const Icon(
                Icons.check,
                size: 14,
                color: AppColors.textSub,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
