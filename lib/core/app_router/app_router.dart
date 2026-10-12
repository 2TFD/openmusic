import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:owlsonic/core/app_router/app_router_names.dart';
import 'package:owlsonic/core/app_router/transitions/fade_slide_transition_page.dart';
import 'package:owlsonic/core/di/di.dart';
import 'package:owlsonic/layers/presentation/shared/blocs/music_analysis_status/music_analysis_status_cubit.dart';
import 'package:owlsonic/layers/presentation/features/artist/bloc/artist_detail/artist_detail_bloc.dart';
import 'package:owlsonic/layers/presentation/features/import_music/bloc/import_music/import_music_cubit.dart';
import 'package:owlsonic/layers/presentation/features/playlist/bloc/playlist_detail/playlist_detail_bloc.dart';
import 'package:owlsonic/layers/presentation/features/playlist/ui/all_playlists_screen.dart';
import 'package:owlsonic/layers/presentation/features/artist/ui/artist_screen.dart';
import 'package:owlsonic/layers/presentation/features/home/ui/home_screen.dart';
import 'package:owlsonic/layers/presentation/features/import_music/ui/import_music_screen.dart';
import 'package:owlsonic/layers/presentation/features/library/ui/library_screen.dart';
import 'package:owlsonic/layers/presentation/features/playlist/ui/playlist_screen.dart';
import 'package:owlsonic/layers/presentation/features/search/ui/search_screen.dart';
import 'package:owlsonic/layers/presentation/features/settings/ui/settings_screen.dart';
import 'package:owlsonic/layers/presentation/features/mood_map/ui/mood_map_page.dart';
import 'package:owlsonic/layers/presentation/features/mood_map/bloc/mood_map/mood_map_cubit.dart';
import 'package:owlsonic/layers/presentation/features/history/ui/history_screen.dart';
import 'package:owlsonic/core/app_router/app_shell.dart';
import 'package:owlsonic/layers/presentation/features/telemetry/bloc/telemetry/telemetry_cubit.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/cloud_account_cubit.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/password_reset_cubit.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/verify_email_cubit.dart';
import 'package:owlsonic/layers/presentation/features/account/ui/cloud_account_screen.dart';
import 'package:owlsonic/layers/presentation/features/account/ui/forgot_password_screen.dart';
import 'package:owlsonic/layers/presentation/features/account/ui/verify_email_screen.dart';
import 'package:owlsonic/layers/presentation/features/wave/ui/wave_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/${AppRouterNames.home}',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          // ── Root tabs: no push animation (instant shell switch) ──────────
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
            path: '/${AppRouterNames.history}',
            name: AppRouterNames.history,
            builder: (context, state) => const HistoryScreen(),
          ),

          // ── Push screens: fade + slide ────────────────────────────────────
          GoRoute(
            path: '/${AppRouterNames.importMusic}',
            name: AppRouterNames.importMusic,
            pageBuilder: (context, state) => FadeSlideTransitionPage<void>(
              key: state.pageKey,
              child: BlocProvider(
                create: (_) => getIt<ImportMusicCubit>(),
                child: const ImportMusicScreen(),
              ),
            ),
          ),
          GoRoute(
            path: '/${AppRouterNames.playlist}/:id',
            name: AppRouterNames.playlist,
            pageBuilder: (context, state) {
              final playlistId = state.pathParameters['id'] ?? '';
              return FadeSlideTransitionPage<void>(
                key: state.pageKey,
                child: BlocProvider(
                  create: (_) =>
                      getIt<PlaylistDetailBloc>()
                        ..add(PlaylistDetailLoad(playlistId)),
                  child: const PlaylistScreen(),
                ),
              );
            },
          ),
          GoRoute(
            path: '/${AppRouterNames.artist}/:id',
            name: AppRouterNames.artist,
            pageBuilder: (context, state) {
              final artistId = state.pathParameters['id'] ?? '';
              return FadeSlideTransitionPage<void>(
                key: state.pageKey,
                child: BlocProvider(
                  create: (_) =>
                      getIt<ArtistDetailBloc>()
                        ..add(ArtistDetailLoad(artistId)),
                  child: const ArtistScreen(),
                ),
              );
            },
          ),
          GoRoute(
            path: '/${AppRouterNames.search}',
            name: AppRouterNames.search,
            pageBuilder: (context, state) => FadeSlideTransitionPage<void>(
              key: state.pageKey,
              child: const SearchScreen(),
            ),
          ),
          GoRoute(
            path: '/${AppRouterNames.allPlaylists}',
            name: AppRouterNames.allPlaylists,
            pageBuilder: (context, state) => FadeSlideTransitionPage<void>(
              key: state.pageKey,
              child: const AllPlaylistsScreen(),
            ),
          ),
          GoRoute(
            path: '/${AppRouterNames.settings}',
            name: AppRouterNames.settings,
            pageBuilder: (context, state) => FadeSlideTransitionPage<void>(
              key: state.pageKey,
              child: MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (_) =>
                        getIt<MusicAnalysisStatusCubit>()..initialize(),
                  ),
                  BlocProvider(create: (_) => getIt<TelemetryCubit>()),
                ],
                child: const SettingsScreen(),
              ),
            ),
          ),
          GoRoute(
            path: '/${AppRouterNames.about}',
            name: AppRouterNames.about,
            pageBuilder: (context, state) => FadeSlideTransitionPage<void>(
              key: state.pageKey,
              child: const AboutAppScreen(),
            ),
          ),
          GoRoute(
            path: '/${AppRouterNames.account}',
            name: AppRouterNames.account,
            pageBuilder: (context, state) => FadeSlideTransitionPage<void>(
              key: state.pageKey,
              child: BlocProvider(
                create: (_) => getIt<CloudAccountCubit>()..initialize(),
                child: CloudAccountScreen(
                  initialRegister:
                      state.uri.queryParameters['mode'] == 'register',
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/${AppRouterNames.verifyEmail}',
            name: AppRouterNames.verifyEmail,
            pageBuilder: (context, state) => FadeSlideTransitionPage<void>(
              key: state.pageKey,
              child: BlocProvider(
                create: (_) => getIt<VerifyEmailCubit>()..initialize(),
                child: const VerifyEmailScreen(),
              ),
            ),
          ),
          GoRoute(
            path: '/${AppRouterNames.forgotPassword}',
            name: AppRouterNames.forgotPassword,
            pageBuilder: (context, state) => FadeSlideTransitionPage<void>(
              key: state.pageKey,
              child: BlocProvider(
                create: (_) => getIt<PasswordResetCubit>(),
                child: ForgotPasswordScreen(
                  initialEmail: state.uri.queryParameters['email'] ?? '',
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/${AppRouterNames.wave}',
            name: AppRouterNames.wave,
            pageBuilder: (context, state) => FadeSlideTransitionPage<void>(
              key: state.pageKey,
              child: const WaveScreen(),
            ),
          ),
          GoRoute(
            path: '/${AppRouterNames.moodMap}',
            name: AppRouterNames.moodMap,
            pageBuilder: (context, state) => FadeSlideTransitionPage<void>(
              key: state.pageKey,
              child: BlocProvider(
                create: (_) => getIt<MoodMapCubit>()..initialize(),
                child: const MoodMapPage(),
              ),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Center(
      child: Text(
        context.tr(
          'errors.app',
          namedArgs: {'message': state.error?.message ?? ''},
        ),
      ),
    ),
  );
}
