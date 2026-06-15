import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openmusic/core/app_router/app_router_names.dart';
import 'package:openmusic/core/app_router/transitions/goo_transition_page.dart';
import 'package:openmusic/layers/presentation/screens/all_playlists_screen.dart';
import 'package:openmusic/layers/presentation/screens/home_screen.dart';
import 'package:openmusic/layers/presentation/screens/import_music_screen.dart';
import 'package:openmusic/layers/presentation/screens/library_screen.dart';
import 'package:openmusic/layers/presentation/screens/playlist_screen.dart';
import 'package:openmusic/layers/presentation/screens/search_screen.dart';
import 'package:openmusic/layers/presentation/screens/settings_screen.dart';
import 'package:openmusic/core/app_router/app_shell.dart';

class AppRouter {
  static GoRouter get router => GoRouter(
    initialLocation: '/${AppRouterNames.home}',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/${AppRouterNames.home}',
            name: AppRouterNames.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/${AppRouterNames.library}',
            name: AppRouterNames.library,
            builder: (context, state) => const LibraryScreen(),
          ),
          GoRoute(
            path: '/${AppRouterNames.importMusic}',
            name: AppRouterNames.importMusic,
            pageBuilder: (context, state) => GooTransitionPage<void>(
              key: state.pageKey,
              child: const ImportMusicScreen(),
            ),
          ),
          GoRoute(
            path: '/${AppRouterNames.playlist}/:id',
            name: AppRouterNames.playlist,
            builder: (context, state) {
              final playlistId = state.pathParameters['id'];
              return PlaylistScreen(playlistId: playlistId ?? '');
            },
          ),
          GoRoute(
            path: '/${AppRouterNames.search}',
            name: AppRouterNames.search,
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: '/${AppRouterNames.allPlaylists}',
            name: AppRouterNames.allPlaylists,
            builder: (context, state) => const AllPlaylistsScreen(),
          ),
          GoRoute(
            path: '/${AppRouterNames.settings}',
            name: AppRouterNames.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) =>
        Center(child: Text("App error ${state.error?.message}")),
  );
}
