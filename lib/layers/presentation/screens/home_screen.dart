import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openmusic/core/app_router/app_router_names.dart';
import 'package:openmusic/core/themes/app_theme.dart';
import 'package:openmusic/layers/domain/entities/playlist.dart';
import 'package:openmusic/layers/presentation/blocs/history/history_bloc.dart';
import 'package:openmusic/layers/presentation/blocs/player/player_bloc.dart';
import 'package:openmusic/layers/presentation/blocs/playlist/playlist_bloc.dart';
import 'package:openmusic/layers/presentation/blocs/statistic/statistic_bloc.dart';
import 'package:openmusic/layers/presentation/blocs/track/track_bloc.dart';
import 'package:openmusic/layers/presentation/widgets/cached_image.dart';
import 'package:openmusic/layers/presentation/widgets/sheets/create_playlist_sheet.dart';
import 'package:openmusic/layers/presentation/widgets/track_item.dart';
import 'package:openmusic/layers/presentation/widgets/wave_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _timeContext(BuildContext context) {
    final h = DateTime.now().hour;
    final weekday = _weekdayName(context, DateTime.now().weekday);
    if (h >= 5 && h < 12) return '$weekday ${context.tr('time.morning')}';
    if (h >= 12 && h < 17) return '$weekday ${context.tr('time.day')}';
    if (h >= 17 && h < 22) return '$weekday ${context.tr('time.evening')}';
    return '$weekday ${context.tr('time.night')}';
  }

  String _weekdayName(BuildContext context, int w) {
    const Map<int, String> keyMap = {
      1: 'time.monday',
      2: 'time.tuesday',
      3: 'time.wednesday',
      4: 'time.thursday',
      5: 'time.friday',
      6: 'time.saturday',
      7: 'time.sunday',
    };
    final key = keyMap[w] ?? 'time.monday';
    return context.tr(key);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TrackBloc, TrackState>(
      listener: (context, state) {
        if (state is TrackLoaded) {
          final playerState = context.read<PlayerBloc>().state;
          if (playerState.currentTrack == null) {
            context.read<PlayerBloc>().add(PlayerQueueSet(state.tracks));
          }
        }
      },
      builder: (context, state) {
        if (state is TrackError) {
          return Scaffold(body: Center(child: Text(state.error.tr())));
        }
        if (state is! TrackLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(30.0),
            child: AppBar(
              toolbarOpacity: 0,
              title: _buildMiniTextHeader(context),
              scrolledUnderElevation: 0,
              backgroundColor: AppColors.bg,
            ),
          ),

          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context)),
                const SliverToBoxAdapter(child: WaveCard()),
                const SliverToBoxAdapter(child: _PlaylistSection()),
                SliverToBoxAdapter(
                  child: _LibraryRow(lengthTracks: state.tracks.length),
                ),
                const SliverToBoxAdapter(child: _HistorySection()),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniTextHeader(BuildContext context) {
    return Row(
      children: [
        Text(
          _timeContext(context).toUpperCase(),
          style: GoogleFonts.figtree(
            fontSize: 10,
            letterSpacing: 1.5,
            color: AppColors.muted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        BlocBuilder<StatisticBloc, StatisticState>(
          builder: (context, state) {
            final Duration hours = state is StatisticsLoaded
                ? state.statistics.totalTime
                : Duration.zero;
            return Text(
              context
                  .tr(
                    'home.statisticsHours',
                    namedArgs: {'hours': hours.inHours.toString()},
                  )
                  .toUpperCase(),
              style: GoogleFonts.figtree(
                fontSize: 10,
                letterSpacing: 1.5,
                color: AppColors.muted,
                fontWeight: FontWeight.w500,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                context.tr('app.title'),
                style: GoogleFonts.outfit(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () async {
                  context.pushNamed(AppRouterNames.search);
                },
                icon: const Icon(Icons.search, size: 60),
              ),
              IconButton(
                onPressed: () async {
                  context.pushNamed(AppRouterNames.importMusic);
                },
                icon: const Icon(Icons.add, size: 60),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LibraryRow extends StatelessWidget {
  const _LibraryRow({required this.lengthTracks});

  final int lengthTracks;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GestureDetector(
        onTap: () => context.pushNamed(AppRouterNames.library),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.grid_view_rounded,
                  color: AppColors.muted,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('home.library'),
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr(
                        'home.libraryTracks',
                        namedArgs: {'count': lengthTracks.toString()},
                      ),
                      style: GoogleFonts.figtree(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.muted2,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          backgroundColor: const Color.fromARGB(154, 0, 0, 0),
          builder: (context) {
            return DraggableScrollableSheet(
              snap: true,
              initialChildSize: 0.9,
              minChildSize: 0.6,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  child: BlocBuilder<HistoryBloc, HistoryState>(
                    builder: (context, state) {
                      if (state is! HistoryLoaded) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (state.tracks.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          child: Text(
                            context.tr('home.historyEmpty'),
                            style: GoogleFonts.figtree(
                              fontSize: 13,
                              color: AppColors.muted,
                            ),
                          ),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  24,
                                  24,
                                  10,
                                ),
                                child: Text(
                                  context.tr('home.history'),
                                  style: GoogleFonts.figtree(
                                    fontSize: 10,
                                    letterSpacing: 1.5,
                                    color: AppColors.muted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(
                                  Icons.close,
                                  color: AppColors.textSub,
                                ),
                              ),
                            ],
                          ),

                          ...state.tracks.asMap().entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TrackItem(
                                track: entry.value,
                                isPlaying: false,
                                isCurrent: false,
                                isAvailable: entry.value.isReadyToPlay,
                                onTap: () {
                                  context.read<PlayerBloc>().add(
                                    PlayerQueueSet(
                                      state.tracks,
                                      startIndex: entry.key,
                                    ),
                                  );
                                  context.read<PlayerBloc>().add(
                                    PlayerPlayPauseToggled(),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },

      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.history,
                color: AppColors.muted,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              context.tr('home.historySidebar'),
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: AppColors.text,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.muted2, size: 18),
          ],
        ),
      ),
    );
  }
}

class _PlaylistSection extends StatelessWidget {
  const _PlaylistSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
          child: Row(
            children: [
              Text(
                context.tr('home.playlist'),
                style: GoogleFonts.figtree(
                  fontSize: 10,
                  letterSpacing: 1.5,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  context.pushNamed(AppRouterNames.allPlaylists);
                },
                child: Text(
                  context.tr('home.viewAll'),
                  style: GoogleFonts.figtree(
                    fontSize: 10,
                    color: AppColors.muted2,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          height: 180,
          child: BlocBuilder<PlaylistBloc, PlaylistState>(
            builder: (context, state) {
              if (state is! PlaylistLoaded) {
                return const SizedBox();
              }
              if (state.playlists.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: _AddPlaylistCard(),
                );
              } else {
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: state.playlists.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (_, i) =>
                      _PlaylistCard(data: state.playlists[i]),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  final Playlist data;
  const _PlaylistCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed(
        AppRouterNames.playlist,
        pathParameters: {'id': data.id},
      ),
      child: SizedBox(
        width: 130,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: data.imageUrl != null
                    ? CachedImage(url: data.imageUrl, size: 130)
                    : const Icon(
                        Icons.music_note,
                        color: AppColors.muted2,
                        size: 16,
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data.name,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: const Color(0xFFC0C0C0),
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              data.trackIds.length.toString(),
              style: GoogleFonts.figtree(fontSize: 10, color: AppColors.muted2),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPlaylistCard extends StatelessWidget {
  const _AddPlaylistCard();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          useRootNavigator: true,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          context: context,
          builder: (context) => const CreatePlaylistSheet(),
        );
      },
      child: SizedBox(
        width: 130,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: AppColors.surface2,
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Icon(Icons.add, color: AppColors.muted2, size: 28),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('home.newPlaylist'),
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: const Color(0xFFC0C0C0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
