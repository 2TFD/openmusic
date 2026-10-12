import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:owlsonic/core/app_router/app_router_names.dart';
import 'package:owlsonic/core/layout/app_layout.dart';
import 'package:owlsonic/layers/presentation/features/home/ui/desktop_home.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/domain/entities/playlist.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/presentation/features/cloud_status/cloud_status_cubit.dart';
import 'package:owlsonic/layers/presentation/features/cloud_status/cloud_status_line.dart';
import 'package:owlsonic/layers/presentation/features/account/ui/account_entry_button.dart';
import 'package:owlsonic/layers/presentation/features/history/bloc/history/history_bloc.dart';
import 'package:owlsonic/layers/presentation/features/player/bloc/player/player_bloc.dart';
import 'package:owlsonic/layers/presentation/features/playlist/bloc/playlist/playlist_bloc.dart';
import 'package:owlsonic/layers/presentation/features/track/bloc/track/track_bloc.dart';
import 'package:owlsonic/layers/presentation/shared/models/ui_error_localization.dart';
import 'package:owlsonic/layers/presentation/features/playlist/ui/widgets/playlist_cover.dart';
import 'package:owlsonic/layers/presentation/features/playlist/ui/widgets/sheets/create_playlist_sheet.dart';
import 'package:owlsonic/layers/presentation/features/track/ui/widgets/track_item.dart';
import 'package:owlsonic/layers/presentation/features/player/ui/widgets/wave_card.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/app_surface.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/cached_image.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/owlsonic_glyph.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/owlsonic_logo.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackBloc, TrackState>(
      builder: (context, state) {
        if (state is TrackError) {
          return Scaffold(
            body: Center(child: Text(state.error.localized(context))),
          );
        }
        if (state is! TrackLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (AppLayout.isDesktopPlatform) {
          return DesktopHome(tracks: state.tracks);
        }
        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSpacing.pageMaxWidth,
                ),
                child: state.tracks.isEmpty
                    ? CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(child: _buildHeader(context)),
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: MobileEmptyHome(),
                          ),
                        ],
                      )
                    : CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(child: _buildHeader(context)),
                          SliverToBoxAdapter(
                            child: _LibraryHero(count: state.tracks.length),
                          ),
                          const SliverToBoxAdapter(
                            child: WaveCard(
                              dense: true,
                              padding: EdgeInsets.fromLTRB(24, 12, 24, 0),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: _RecentlyAddedSection(tracks: state.tracks),
                          ),
                          const SliverToBoxAdapter(child: _PlaylistSection()),
                          const SliverToBoxAdapter(child: _HistorySection()),
                          const SliverToBoxAdapter(child: SizedBox(height: 24)),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 10),
      child: Row(
        children: [
          const Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: OwlSonicLogo(width: 80),
            ),
          ),
          IconButton(
            key: const ValueKey('home-search-button'),
            tooltip: context.tr('common.search'),
            constraints: const BoxConstraints.tightFor(width: 48, height: 48),
            onPressed: () => context.pushNamed(AppRouterNames.search),
            icon: const Icon(Icons.search_rounded, size: 22),
          ),
          const AccountEntryButton(),
        ],
      ),
    );
  }
}

/// Home before any music exists. The cloud library may still be loading, in
/// which case it says so instead of claiming the library is empty.
class MobileEmptyHome extends StatelessWidget {
  const MobileEmptyHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CloudStatusCubit, CloudStatusState>(
      builder: (context, status) {
        final loading =
            status.kind == CloudStatusKind.checking ||
            (status.signedIn &&
                status.awaitingFirstSync &&
                status.kind == CloudStatusKind.syncing);
        return Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 96),
          child: Center(
            child: loading
                ? Column(
                    key: const ValueKey('home-syncing-library'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox.square(
                        dimension: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.tr('home.syncingTitle'),
                        style: AppText.display3,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.tr('home.syncingDescription'),
                        style: AppText.bodyM,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : Column(
                    key: const ValueKey('home-empty-state'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const OwlSonicGlyph(
                        type: OwlSonicGlyphType.library,
                        size: 40,
                        color: AppColors.muted,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        context.tr('home.emptyTitle'),
                        style: AppText.display2,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        context.tr('home.emptyDescription'),
                        style: AppText.bodyL.copyWith(color: AppColors.textSub),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        key: const ValueKey('home-add-music'),
                        onPressed: () =>
                            context.pushNamed(AppRouterNames.importMusic),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: Text(context.tr('home.addMusic')),
                      ),
                      if (status.kind == CloudStatusKind.deviceOnly)
                        TextButton(
                          key: const ValueKey('home-sign-in'),
                          onPressed: () =>
                              context.pushNamed(AppRouterNames.account),
                          child: Text(context.tr('home.signInToAccess')),
                        ),
                      if (status.kind == CloudStatusKind.offline ||
                          status.kind == CloudStatusKind.failed)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: CloudStatusLine(),
                        ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

/// Library first: the way into the user's music, with where it lives.
/// One compact row: name, count and sync state on the left, Add music on the right.
class _LibraryHero extends StatelessWidget {
  const _LibraryHero({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    // On narrow screens or with large text, Add music keeps its place as an icon.
    final iconOnly =
        MediaQuery.sizeOf(context).width < 340 ||
        MediaQuery.textScalerOf(context).scale(14) / 14 > 1.3;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
      child: AppSurface(
        key: const ValueKey('home-library-hero'),
        onTap: () => context.pushNamed(AppRouterNames.library),
        radius: AppRadius.card,
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
        child: Row(
          children: [
            const OwlSonicGlyph(
              type: OwlSonicGlyphType.library,
              size: 26,
              color: AppColors.textSub,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr('home.library'), style: AppText.display3),
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        context.tr(
                          'common.trackCount',
                          namedArgs: {'count': '$count'},
                        ),
                        style: AppText.bodyM,
                      ),
                      const CloudStatusLine(minHeight: 24),
                    ],
                  ),
                ],
              ),
            ),
            if (iconOnly)
              IconButton(
                key: const ValueKey('home-add-music-button'),
                tooltip: context.tr('home.addMusic'),
                constraints: const BoxConstraints.tightFor(
                  width: 44,
                  height: 44,
                ),
                onPressed: () => context.pushNamed(AppRouterNames.importMusic),
                icon: const Icon(Icons.add_rounded, size: 22),
              )
            else
              TextButton.icon(
                key: const ValueKey('home-add-music-button'),
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                onPressed: () => context.pushNamed(AppRouterNames.importMusic),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(context.tr('home.addMusic')),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecentlyAddedSection extends StatelessWidget {
  const _RecentlyAddedSection({required this.tracks});

  final List<Track> tracks;

  @override
  Widget build(BuildContext context) {
    final recent = ([...tracks]..sort((a, b) => b.addedAt.compareTo(a.addedAt)))
        .take(12)
        .toList(growable: false);
    return _TrackShelf(title: context.tr('home.recentlyAdded'), tracks: recent);
  }
}

/// A horizontal row of artwork-led tracks; tapping one plays it with the row
/// as queue.
class _TrackShelf extends StatelessWidget {
  const _TrackShelf({required this.title, required this.tracks});

  final String title;
  final List<Track> tracks;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    // About three artwork cards fit across, with the next one peeking in.
    final artSize = ((width - 48 - 24) / 3).clamp(108.0, 124.0);
    final textScale = MediaQuery.textScalerOf(context).scale(13) / 13;
    final rowHeight = artSize + 52 + ((textScale - 1) * 40).clamp(0.0, 60.0);
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AppSectionLabel(title),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: rowHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: tracks.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, index) {
                final track = tracks[index];
                return _ShelfCard(
                  track: track,
                  size: artSize,
                  onTap: () => context.read<PlayerBloc>().add(
                    PlayerQueueSet(tracks, startTrack: track),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ShelfCard extends StatelessWidget {
  const _ShelfCard({
    required this.track,
    required this.size,
    required this.onTap,
  });

  final Track track;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final artist = track.artists.map((a) => a.name).join(', ');
    return InkWell(
      key: ValueKey('home-shelf-${track.id}'),
      onTap: onTap,
      borderRadius: AppRadius.coverBR,
      child: SizedBox(
        width: size,
        child: Opacity(
          opacity: track.isReadyToPlay ? 1 : 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: AppRadius.coverBR,
                  border: Border.all(color: AppColors.border),
                ),
                child: ClipRRect(
                  borderRadius: AppRadius.coverBR,
                  child: CachedImage(url: track.imageUrl, size: size),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                track.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.bodyL.copyWith(fontSize: 13),
              ),
              Text(
                artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.bodyM.copyWith(fontSize: 12),
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
    return InkWell(
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        useSafeArea: true,
        backgroundColor: AppColors.sheetSurface,
        builder: (_) => const HistorySheet(),
      ),

      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 8, 24, 0),
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const OwlSonicGlyph(
              type: OwlSonicGlyphType.history,
              size: 24,
              color: AppColors.textSub,
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
    final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
    final playlistHeight = 188 + ((textScale - 1) * 40).clamp(0.0, 104.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
          child: Row(
            children: [
              Text(context.tr('home.playlist'), style: AppText.label),
              const Spacer(),
              TextButton(
                onPressed: () {
                  context.pushNamed(AppRouterNames.allPlaylists);
                },
                child: Text(
                  context.tr('home.viewAll'),
                  style: GoogleFonts.figtree(
                    fontSize: 11,
                    letterSpacing: 1.0,
                    color: AppColors.textSub,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          height: playlistHeight,
          child: BlocBuilder<PlaylistBloc, PlaylistState>(
            builder: (context, state) {
              if (state is PlaylistError) {
                return Center(
                  child: Text(
                    state.error.localized(context),
                    style: GoogleFonts.figtree(
                      fontSize: 13,
                      color: AppColors.muted,
                    ),
                  ),
                );
              }
              if (state is! PlaylistLoaded) {
                return const SizedBox();
              }
              return ListView.separated(
                key: const ValueKey('home-playlists-row'),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: state.playlists.length + 1,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, i) => i == 0
                    ? const _AddPlaylistCard()
                    : _PlaylistCard(data: state.playlists[i - 1]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  final PlaylistSummary data;
  const _PlaylistCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed(
        AppRouterNames.playlist,
        pathParameters: {'id': data.id},
      ),
      child: SizedBox(
        width: 136,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlaylistCover(
              imageUrl: data.imageUrl,
              generatedImageUrls: data.coverImageUrls,
              width: 136,
              height: 136,
              borderRadius: BorderRadius.circular(AppRadius.m),
              border: Border.all(color: AppColors.border),
              placeholderIconSize: 16,
            ),
            const SizedBox(height: 8),
            Text(
              data.name,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: AppColors.text,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              context.tr(
                'common.trackCount',
                namedArgs: {'count': '${data.trackCount}'},
              ),
              style: GoogleFonts.figtree(
                fontSize: 12,
                color: AppColors.textSub,
              ),
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
      onTap: () => showCreatePlaylist(context),
      child: SizedBox(
        width: 136,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 136,
              height: 136,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: AppColors.surface2,
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(child: _CreatePlaylistGlyph()),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('home.newPlaylist'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: AppColors.textSub,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreatePlaylistGlyph extends StatelessWidget {
  const _CreatePlaylistGlyph();

  @override
  Widget build(BuildContext context) => const CustomPaint(
    size: Size.square(24),
    painter: _CreatePlaylistGlyphPainter(),
  );
}

class _CreatePlaylistGlyphPainter extends CustomPainter {
  const _CreatePlaylistGlyphPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textSub
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawLine(
      Offset(center.dx, size.height * .25),
      Offset(center.dx, size.height * .75),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * .25, center.dy),
      Offset(size.width * .75, center.dy),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Play history as a bottom sheet: opaque surface, pinned header, and a list
/// that scrolls inside the sheet.
class HistorySheet extends StatelessWidget {
  const HistorySheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      snap: true,
      initialChildSize: 0.9,
      minChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (context, scrollController) => ColoredBox(
        color: AppColors.sheetSurface,
        child: Column(
          children: [
            const _SheetGrabber(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.tr('home.history').toUpperCase(),
                      style: AppText.label,
                    ),
                  ),
                  IconButton(
                    tooltip: context.tr('common.close'),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSub,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: BlocBuilder<HistoryBloc, HistoryState>(
                builder: (context, state) {
                  if (state is HistoryError) {
                    return _centered(state.error.localized(context));
                  }
                  if (state is! HistoryLoaded) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.tracks.isEmpty) {
                    return _centered(context.tr('home.historyEmpty'));
                  }
                  return BlocSelector<
                    PlayerBloc,
                    PlayerState,
                    ({String? currentTrackId, bool isPlaying})
                  >(
                    selector: (s) => (
                      currentTrackId: s.currentTrack?.id,
                      isPlaying: s.isPlaying,
                    ),
                    builder: (context, playerSel) => ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.fromLTRB(
                        0,
                        8,
                        0,
                        16 + MediaQuery.paddingOf(context).bottom,
                      ),
                      itemCount: state.tracks.length,
                      itemBuilder: (context, index) {
                        final track = state.tracks[index];
                        return TrackItem(
                          track: track,
                          isPlaying:
                              playerSel.isPlaying &&
                              playerSel.currentTrackId == track.id,
                          isCurrent: playerSel.currentTrackId == track.id,
                          isAvailable: track.isReadyToPlay,
                          onTap: () => context.read<PlayerBloc>().add(
                            PlayerQueueSet(state.tracks, startTrack: track),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _centered(String text) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(text, style: AppText.bodyM, textAlign: TextAlign.center),
    ),
  );
}

class _SheetGrabber extends StatelessWidget {
  const _SheetGrabber();

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      margin: const EdgeInsets.only(top: 10, bottom: 6),
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.muted2,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}
