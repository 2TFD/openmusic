import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:owlsonic/core/app_router/app_router_names.dart';
import 'package:owlsonic/core/layout/app_layout.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/domain/entities/playlist.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/cloud_session_cubit.dart';
import 'package:owlsonic/layers/presentation/features/playlist/bloc/playlist/playlist_bloc.dart';
import 'package:owlsonic/layers/presentation/features/playlist/ui/widgets/playlist_cover.dart';
import 'package:owlsonic/layers/presentation/features/playlist/ui/widgets/sheets/create_playlist_sheet.dart';
import 'package:owlsonic/layers/presentation/features/track/bloc/track/track_bloc.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/owlsonic_glyph.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/owlsonic_logo.dart';

/// Persistent navigation + library column. Expanded on standard/large windows,
/// an icon rail on compact ones.
class DesktopSidebar extends StatelessWidget {
  const DesktopSidebar({super.key, required this.compact, this.onSearch});

  final bool compact;
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    final path = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.uri.path;
    bool at(String name) => path == '/$name';
    final trackCount = context.select<TrackBloc, int?>(
      (bloc) => bloc.state is TrackLoaded
          ? (bloc.state as TrackLoaded).tracks.length
          : null,
    );

    return Container(
      width: compact ? AppLayout.compactRailWidth : AppLayout.sidebarWidth,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(compact ? 0 : 22, 24, 8, 20),
              child: Align(
                alignment: compact ? Alignment.center : Alignment.centerLeft,
                child: OwlSonicLogo(width: compact ? 44 : 104),
              ),
            ),
            SidebarNavItem(
              label: context.tr('nav.home'),
              icon: Icons.home_outlined,
              selected: at(AppRouterNames.home),
              compact: compact,
              onTap: () => context.goNamed(AppRouterNames.home),
            ),
            SidebarNavItem(
              label: context.tr('nav.search'),
              icon: Icons.search_rounded,
              selected: false,
              compact: compact,
              onTap: onSearch ?? () {},
            ),
            SidebarNavItem(
              label: context.tr('library.title'),
              glyph: OwlSonicGlyphType.library,
              selected:
                  at(AppRouterNames.library) ||
                  path.startsWith('/${AppRouterNames.artist}/'),
              compact: compact,
              trailing: trackCount == null ? null : '$trackCount',
              onTap: () => context.goNamed(AppRouterNames.library),
            ),
            SidebarNavItem(
              key: const ValueKey('sidebar-wave'),
              label: context.tr('waveSession.title'),
              glyph: OwlSonicGlyphType.wave,
              // Mood Map is part of Wave, so Wave stays selected inside it.
              selected: at(AppRouterNames.wave) || at(AppRouterNames.moodMap),
              compact: compact,
              onTap: () => context.goNamed(AppRouterNames.wave),
            ),
            SidebarNavItem(
              label: context.tr('home.historySidebar'),
              glyph: OwlSonicGlyphType.history,
              selected: at(AppRouterNames.history),
              compact: compact,
              onTap: () => context.goNamed(AppRouterNames.history),
            ),
            SidebarNavItem(
              key: const ValueKey('sidebar-add-music'),
              label: context.tr('home.addMusic'),
              icon: Icons.add_circle_outline_rounded,
              selected: at(AppRouterNames.importMusic),
              compact: compact,
              onTap: () => context.goNamed(AppRouterNames.importMusic),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: compact
                  ? ListView(
                      padding: const EdgeInsets.only(top: 8),
                      children: [
                        SidebarNavItem(
                          label: context.tr('nav.allPlaylists'),
                          icon: Icons.queue_music_outlined,
                          selected: at(AppRouterNames.allPlaylists),
                          compact: true,
                          onTap: () =>
                              context.goNamed(AppRouterNames.allPlaylists),
                        ),
                        SidebarNavItem(
                          label: context.tr('nav.newPlaylist'),
                          icon: Icons.add_rounded,
                          selected: false,
                          compact: true,
                          onTap: () => showCreatePlaylist(context),
                        ),
                      ],
                    )
                  : _LibrarySection(path: path),
            ),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 8),
            BlocBuilder<CloudSessionCubit, CloudSessionState>(
              buildWhen: (a, b) => a != b,
              builder: (context, session) => SidebarNavItem(
                key: const ValueKey('sidebar-account'),
                label: context.tr('nav.account'),
                icon: session.signedIn
                    ? Icons.person_rounded
                    : Icons.person_outline_rounded,
                selected: at(AppRouterNames.account),
                compact: compact,
                indicator: session.signedIn,
                onTap: () => context.goNamed(AppRouterNames.account),
              ),
            ),
            SidebarNavItem(
              label: context.tr('settings.title'),
              icon: Icons.settings_outlined,
              selected: at(AppRouterNames.settings),
              compact: compact,
              onTap: () => context.goNamed(AppRouterNames.settings),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _LibrarySection extends StatelessWidget {
  const _LibrarySection({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final playlists = context.select<PlaylistBloc, List<PlaylistSummary>>(
      (bloc) => bloc.state is PlaylistLoaded
          ? (bloc.state as PlaylistLoaded).playlists
          : const [],
    );
    final recent = [...playlists]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ListView(
      padding: const EdgeInsets.only(top: 14),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(26, 0, 16, 6),
          child: Text(
            context.tr('nav.yourLibrary').toUpperCase(),
            style: AppText.label,
          ),
        ),
        SidebarNavItem(
          label: context.tr('nav.allPlaylists'),
          icon: Icons.queue_music_outlined,
          selected: path == '/${AppRouterNames.allPlaylists}',
          compact: false,
          onTap: () => context.goNamed(AppRouterNames.allPlaylists),
        ),
        SidebarNavItem(
          label: context.tr('nav.newPlaylist'),
          icon: Icons.add_rounded,
          selected: false,
          compact: false,
          onTap: () => showCreatePlaylist(context),
        ),
        const SizedBox(height: 6),
        for (final playlist in recent.take(12))
          _SidebarPlaylistItem(
            playlist: playlist,
            selected: path == '/${AppRouterNames.playlist}/${playlist.id}',
          ),
      ],
    );
  }
}

class _SidebarPlaylistItem extends StatelessWidget {
  const _SidebarPlaylistItem({required this.playlist, required this.selected});

  final PlaylistSummary playlist;
  final bool selected;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
    child: Material(
      color: selected ? AppColors.surface2 : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => context.goNamed(
          AppRouterNames.playlist,
          pathParameters: {'id': playlist.id},
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
          child: Row(
            children: [
              PlaylistCover(
                imageUrl: playlist.imageUrl,
                generatedImageUrls: playlist.coverImageUrls,
                size: 32,
                borderRadius: BorderRadius.circular(6),
                placeholderIconSize: 14,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodyS.copyWith(
                        color: selected
                            ? AppColors.text
                            : AppColors.imageOverlay,
                      ),
                    ),
                    Text(
                      context.tr(
                        'nav.tracksCount',
                        namedArgs: {'count': '${playlist.trackCount}'},
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodyXS,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class SidebarNavItem extends StatelessWidget {
  const SidebarNavItem({
    super.key,
    required this.label,
    required this.selected,
    required this.compact,
    required this.onTap,
    this.glyph,
    this.icon,
    this.trailing,
    this.indicator = false,
  });

  final String label;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;
  final OwlSonicGlyphType? glyph;
  final IconData? icon;
  final String? trailing;

  /// Small dot on the icon, e.g. signed-in state.
  final bool indicator;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.text : AppColors.textSub;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      child: Tooltip(
        message: label,
        child: Material(
          color: selected ? AppColors.surface2 : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 0 : 12,
                vertical: 10,
              ),
              child: Row(
                mainAxisAlignment: compact
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  if (glyph != null)
                    OwlSonicGlyph(type: glyph!, size: 20, color: color)
                  else if (indicator)
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(icon, size: 20, color: color),
                        const Positioned(
                          right: -2,
                          top: -2,
                          child: _IndicatorDot(),
                        ),
                      ],
                    )
                  else
                    Icon(icon, size: 20, color: color),
                  if (!compact) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.bodyM.copyWith(color: color),
                      ),
                    ),
                    if (trailing != null)
                      Text(trailing!, style: AppText.bodyXS),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IndicatorDot extends StatelessWidget {
  const _IndicatorDot();

  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('account-signed-in-dot'),
    width: 7,
    height: 7,
    decoration: BoxDecoration(
      color: AppColors.accent,
      shape: BoxShape.circle,
      border: Border.all(color: AppColors.surface, width: 1.5),
    ),
  );
}
