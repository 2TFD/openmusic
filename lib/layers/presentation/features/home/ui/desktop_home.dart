import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:owlsonic/core/app_router/app_router_names.dart';
import 'package:owlsonic/core/layout/adaptive_presentation.dart';
import 'package:owlsonic/core/layout/app_layout.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/domain/entities/playlist.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/presentation/features/history/bloc/history/history_bloc.dart';
import 'package:owlsonic/layers/presentation/features/player/bloc/player/player_bloc.dart';
import 'package:owlsonic/layers/presentation/features/player/ui/widgets/wave_card.dart';
import 'package:owlsonic/layers/presentation/features/playlist/bloc/playlist/playlist_bloc.dart';
import 'package:owlsonic/layers/presentation/features/playlist/ui/widgets/playlist_cover.dart';
import 'package:owlsonic/layers/presentation/features/playlist/ui/widgets/sheets/create_playlist_sheet.dart';
import 'package:owlsonic/layers/presentation/features/search/ui/search_screen.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/app_surface.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/cached_image.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/owlsonic_glyph.dart';

/// Desktop Home: Wave + Mood Map stay the primary entry points, followed by
/// music shelves that only render when they have content.
class DesktopHome extends StatelessWidget {
  const DesktopHome({super.key, required this.tracks});

  final List<Track> tracks;

  @override
  Widget build(BuildContext context) {
    final windowWidth = MediaQuery.sizeOf(context).width;
    final pad = AppLayout.desktopPaddingFor(windowWidth);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLayout.desktopRailWidth,
            ),
            child: ListView(
              padding: EdgeInsets.fromLTRB(pad, 20, pad, 40),
              children: [
                const _DesktopHomeHeader(),
                const SizedBox(height: 20),
                if (tracks.isEmpty)
                  const _EmptyLibraryHome()
                else ...[
                  _PrimaryFeatures(trackCount: tracks.length),
                  _RecentlyAddedShelf(tracks: tracks),
                  const _RecentlyPlayedShelf(),
                  const _PlaylistsShelf(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopHomeHeader extends StatelessWidget {
  const _DesktopHomeHeader();

  static const _weekdayKeys = [
    'time.monday',
    'time.tuesday',
    'time.wednesday',
    'time.thursday',
    'time.friday',
    'time.saturday',
    'time.sunday',
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daypartKey = switch (now.hour) {
      >= 5 && < 12 => 'time.morning',
      >= 12 && < 17 => 'time.day',
      >= 17 && < 22 => 'time.evening',
      _ => 'time.night',
    };
    return Row(
      children: [
        Expanded(
          child: Text(
            '${context.tr(_weekdayKeys[now.weekday - 1])} '
            '${context.tr(daypartKey)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.display2,
          ),
        ),
        IconButton(
          tooltip: context.tr('common.search'),
          onPressed: () => AdaptivePresentation.showSurface<void>(
            context,
            maxWidth: 720,
            maxHeight: 720,
            builder: (_) => const SearchScreen(),
          ),
          icon: const Icon(Icons.search_rounded, size: 22),
        ),
        const SizedBox(width: 4),
        OutlinedButton.icon(
          onPressed: () => context.goNamed(AppRouterNames.importMusic),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: Text(context.tr('home.addMusic')),
        ),
      ],
    );
  }
}

/// Wave is the primary discovery action; Mood Map lives inside it. On wide
/// windows the library and history shortcuts sit beside it instead of leaving
/// that space empty.
class _PrimaryFeatures extends StatelessWidget {
  const _PrimaryFeatures({required this.trackCount});

  final int trackCount;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final wide = constraints.maxWidth >= 820;
      const wave = WaveCard(padding: EdgeInsets.zero);
      if (!wide) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            wave,
            const SizedBox(height: 14),
            _Shortcuts(trackCount: trackCount),
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(flex: 5, child: wave),
          const SizedBox(width: 16),
          Expanded(flex: 3, child: _LibraryPanel(trackCount: trackCount)),
        ],
      );
    },
  );
}

class _LibraryPanel extends StatelessWidget {
  const _LibraryPanel({required this.trackCount});

  final int trackCount;

  @override
  Widget build(BuildContext context) => AppSurface(
    key: const ValueKey('desktop-library-panel'),
    radius: AppRadius.card,
    padding: EdgeInsets.zero,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PanelRow(
          glyph: OwlSonicGlyphType.library,
          title: context.tr('home.library'),
          subtitle: context.tr(
            'common.trackCount',
            namedArgs: {'count': '$trackCount'},
          ),
          onTap: () => context.goNamed(AppRouterNames.library),
        ),
        const Divider(height: 1, color: AppColors.border),
        _PanelRow(
          glyph: OwlSonicGlyphType.history,
          title: context.tr('home.historySidebar'),
          onTap: () => context.goNamed(AppRouterNames.history),
        ),
      ],
    ),
  );
}

class _PanelRow extends StatelessWidget {
  const _PanelRow({
    required this.glyph,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final OwlSonicGlyphType glyph;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          OwlSonicGlyph(type: glyph, size: 24, color: AppColors.textSub),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.display3),
                if (subtitle != null) Text(subtitle!, style: AppText.bodyM),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: AppColors.textSub,
          ),
        ],
      ),
    ),
  );
}

/// A titled row that shows as many cards as fit the width. No horizontal
/// scrolling, so it behaves with a mouse and fills wide windows.
class _Shelf extends StatelessWidget {
  const _Shelf({
    required this.title,
    required this.itemBuilder,
    required this.itemCount,
    this.onShowAll,
  });

  final String title;
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final VoidCallback? onShowAll;
  static const double cardWidth = 176;
  static const double gap = 16;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionLabel(
          title,
          action: onShowAll == null
              ? null
              : TextButton(
                  onPressed: onShowAll,
                  child: Text(
                    context.tr('home.viewAll'),
                    style: AppText.bodyXS.copyWith(color: AppColors.textSub),
                  ),
                ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = AppLayout.gridColumnCount(
              availableWidth: constraints.maxWidth,
              minItemWidth: cardWidth,
              spacing: gap,
              minColumns: 2,
              maxColumns: 8,
            );
            final width =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
            final shown = itemCount < columns ? itemCount : columns;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < shown; i++) ...[
                  if (i > 0) const SizedBox(width: gap),
                  SizedBox(width: width, child: itemBuilder(context, i)),
                ],
              ],
            );
          },
        ),
      ],
    ),
  );
}

class _ArtworkCard extends StatelessWidget {
  const _ArtworkCard({
    required this.cover,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.dimmed = false,
  });

  final Widget cover;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool dimmed;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: dimmed ? .5 : 1,
    child: InkWell(
      borderRadius: BorderRadius.circular(AppRadius.s),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(AppRadius.s),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.s),
                child: cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.bodyL,
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.bodyM.copyWith(fontSize: 12),
          ),
        ],
      ),
    ),
  );
}

Widget _trackCover(Track track) => LayoutBuilder(
  builder: (context, c) => CachedImage(
    url: track.imageUrl,
    size: c.maxWidth,
    fallback: const Icon(
      Icons.music_note_rounded,
      size: 32,
      color: AppColors.muted,
    ),
  ),
);

String _artists(Track track) => track.artists.map((a) => a.name).join(', ');

void _play(BuildContext context, List<Track> queue, Track track) =>
    context.read<PlayerBloc>().add(PlayerQueueSet(queue, startTrack: track));

class _RecentlyPlayedShelf extends StatelessWidget {
  const _RecentlyPlayedShelf();

  @override
  Widget build(BuildContext context) => BlocBuilder<HistoryBloc, HistoryState>(
    builder: (context, state) {
      if (state is! HistoryLoaded || state.tracks.isEmpty) {
        return const SizedBox.shrink();
      }
      final tracks = state.tracks;
      return _Shelf(
        title: context.tr('home.recentlyPlayed'),
        itemCount: tracks.length,
        onShowAll: () => context.goNamed(AppRouterNames.history),
        itemBuilder: (context, i) => _ArtworkCard(
          cover: _trackCover(tracks[i]),
          title: tracks[i].title,
          subtitle: _artists(tracks[i]),
          dimmed: !tracks[i].isReadyToPlay,
          onTap: () => tracks[i].isReadyToPlay
              ? _play(context, tracks, tracks[i])
              : null,
        ),
      );
    },
  );
}

class _PlaylistsShelf extends StatelessWidget {
  const _PlaylistsShelf();

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<PlaylistBloc, PlaylistState>(
        builder: (context, state) {
          if (state is! PlaylistLoaded || state.playlists.isEmpty) {
            return const SizedBox.shrink();
          }
          final playlists = state.playlists;
          return _Shelf(
            title: context.tr('home.yourPlaylists'),
            // One extra slot for the "+ New playlist" tile.
            itemCount: playlists.length + 1,
            onShowAll: () => context.goNamed(AppRouterNames.allPlaylists),
            itemBuilder: (context, i) => i == playlists.length
                ? const _NewPlaylistTile()
                : _PlaylistCard(playlist: playlists[i]),
          );
        },
      );
}

class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({required this.playlist});

  final PlaylistSummary playlist;

  @override
  Widget build(BuildContext context) => _ArtworkCard(
    cover: LayoutBuilder(
      builder: (context, c) => PlaylistCover(
        imageUrl: playlist.imageUrl,
        generatedImageUrls: playlist.coverImageUrls,
        size: c.maxWidth,
        borderRadius: BorderRadius.zero,
        placeholderIconSize: 24,
      ),
    ),
    title: playlist.name,
    subtitle: context.tr(
      'common.trackCount',
      namedArgs: {'count': '${playlist.trackCount}'},
    ),
    onTap: () => context.goNamed(
      AppRouterNames.playlist,
      pathParameters: {'id': playlist.id},
    ),
  );
}

class _NewPlaylistTile extends StatelessWidget {
  const _NewPlaylistTile();

  @override
  Widget build(BuildContext context) => _ArtworkCard(
    cover: const Center(
      child: Icon(Icons.add_rounded, size: 28, color: AppColors.textSub),
    ),
    title: context.tr('home.newPlaylist'),
    subtitle: '',
    onTap: () => showCreatePlaylist(context),
  );
}

class _RecentlyAddedShelf extends StatelessWidget {
  const _RecentlyAddedShelf({required this.tracks});

  final List<Track> tracks;

  @override
  Widget build(BuildContext context) {
    final recent = [...tracks]..sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return _Shelf(
      title: context.tr('home.recentlyAdded'),
      itemCount: recent.length,
      onShowAll: () => context.goNamed(AppRouterNames.library),
      itemBuilder: (context, i) => _ArtworkCard(
        cover: _trackCover(recent[i]),
        title: recent[i].title,
        subtitle: _artists(recent[i]),
        dimmed: !recent[i].isReadyToPlay,
        onTap: () =>
            recent[i].isReadyToPlay ? _play(context, recent, recent[i]) : null,
      ),
    );
  }
}

class _Shortcuts extends StatelessWidget {
  const _Shortcuts({required this.trackCount});

  final int trackCount;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 10,
    runSpacing: 10,
    children: [
      _ShortcutChip(
        glyph: OwlSonicGlyphType.library,
        label:
            '${context.tr('home.library')} '
            '${context.tr('home.libraryTracks', namedArgs: {'count': '$trackCount'})}',
        onTap: () => context.goNamed(AppRouterNames.library),
      ),
      _ShortcutChip(
        glyph: OwlSonicGlyphType.history,
        label: context.tr('home.historySidebar'),
        onTap: () => context.goNamed(AppRouterNames.history),
      ),
    ],
  );
}

class _ShortcutChip extends StatelessWidget {
  const _ShortcutChip({
    required this.glyph,
    required this.label,
    required this.onTap,
  });

  final OwlSonicGlyphType glyph;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppSurface(
    onTap: onTap,
    radius: AppRadius.pill,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OwlSonicGlyph(type: glyph, size: 16, color: AppColors.textSub),
        const SizedBox(width: 8),
        Text(label, style: AppText.bodyM),
      ],
    ),
  );
}

/// Onboarding shown instead of a nearly empty dashboard when there are no
/// tracks yet. Wave and Mood Map stay visible but explain why they're locked.
class _EmptyLibraryHome extends StatelessWidget {
  const _EmptyLibraryHome();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const SizedBox(height: 28),
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            children: [
              const OwlSonicGlyph(
                type: OwlSonicGlyphType.library,
                size: 40,
                color: AppColors.muted,
              ),
              const SizedBox(height: 20),
              Text(
                context.tr('home.emptyTitle'),
                textAlign: TextAlign.center,
                style: AppText.display1,
              ),
              const SizedBox(height: 10),
              Text(
                context.tr('home.emptyDescription'),
                textAlign: TextAlign.center,
                style: AppText.bodyL.copyWith(color: AppColors.textSub),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.goNamed(AppRouterNames.importMusic),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(context.tr('home.addMusic')),
              ),
              const SizedBox(height: 14),
              Text(
                context.tr('home.dropHint'),
                style: AppText.bodyM.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 40),
      Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: _LockedFeatureCard(
            label: context.tr('waveSession.title'),
            title: context.tr('home.startWave'),
            description: context.tr('home.waveLocked'),
            glyph: OwlSonicGlyphType.wave,
          ),
        ),
      ),
    ],
  );
}

class _LockedFeatureCard extends StatelessWidget {
  const _LockedFeatureCard({
    required this.label,
    required this.title,
    required this.description,
    required this.glyph,
  });

  final String label;
  final String title;
  final String description;
  final OwlSonicGlyphType glyph;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: .6,
    child: AppSurface(
      radius: AppRadius.card,
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 80),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label.toUpperCase(), style: AppText.label),
                  const SizedBox(height: 10),
                  Text(title, style: AppText.display3),
                  const SizedBox(height: 4),
                  Text(description, style: AppText.bodyM),
                ],
              ),
            ),
            const SizedBox(width: 12),
            OwlSonicGlyph(type: glyph, size: 32, color: AppColors.muted),
          ],
        ),
      ),
    ),
  );
}
