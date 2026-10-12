import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/core/layout/app_layout.dart';
import 'package:owlsonic/layers/presentation/features/library/ui/library_screen.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/desktop_state_view.dart';
import 'package:owlsonic/layers/presentation/features/history/bloc/history/history_bloc.dart';
import 'package:owlsonic/layers/presentation/features/player/bloc/player/player_bloc.dart';
import 'package:owlsonic/layers/presentation/features/track/ui/widgets/track_item.dart';
import 'package:owlsonic/layers/presentation/shared/models/ui_error_localization.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bg,
    appBar: AppBar(title: Text(context.tr('home.historySidebar'))),
    body: BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        if (state is HistoryError) {
          if (AppLayout.isDesktopPlatform)
            return DesktopStateView(
              icon: Icons.error_outline,
              title: state.error.localized(context),
              actionLabel: context.tr('common.retry'),
              onAction: () =>
                  context.read<HistoryBloc>().add(const RefreshHistoryEvent()),
            );
          return Center(child: Text(state.error.localized(context)));
        }
        if (state is! HistoryLoaded) {
          if (AppLayout.isDesktopPlatform)
            return DesktopStateView(
              icon: Icons.history,
              title: context.tr('common.loading'),
              loading: true,
            );
          return const Center(child: CircularProgressIndicator());
        }
        if (state.tracks.isEmpty) {
          if (AppLayout.isDesktopPlatform)
            return DesktopStateView(
              icon: Icons.history,
              title: context.tr('home.historySidebar'),
              detail: context.tr('home.historyEmpty'),
            );
          return Center(child: Text(context.tr('home.historyEmpty')));
        }
        if (AppLayout.isDesktopPlatform) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppLayout.wideContentWidth,
              ),
              child: DesktopLibraryTrackTable(tracks: state.tracks),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          itemCount: state.tracks.length,
          itemBuilder: (context, index) {
            final track = state.tracks[index];
            return TrackItem(
              track: track,
              isPlaying: false,
              isCurrent: false,
              isAvailable: track.isReadyToPlay,
              onTap: () => context.read<PlayerBloc>().add(
                PlayerQueueSet(state.tracks, startTrack: track),
              ),
            );
          },
        );
      },
    ),
  );
}
