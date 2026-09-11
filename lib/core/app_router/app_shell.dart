import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openmusic/core/layout/app_layout.dart';
import 'package:openmusic/core/themes/app_theme.dart';
import 'package:openmusic/layers/presentation/blocs/player/player_bloc.dart';
import 'package:openmusic/layers/presentation/blocs/playlist/playlist_bloc.dart';
import 'package:openmusic/layers/presentation/widgets/mini_player_bar.dart';
import 'package:openmusic/layers/presentation/widgets/snackbars/custom_snack_bar.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PlayerBloc, PlayerState>(
          listenWhen: (prev, curr) =>
              curr.error != null &&
              prev.error?.occurrenceId != curr.error?.occurrenceId,
          listener: (context, state) {
            CustomSnackBar.uiError(context, state.error!);
            context.read<PlayerBloc>().add(PlayerErrorShown());
          },
        ),
        BlocListener<PlaylistBloc, PlaylistState>(
          listenWhen: (previous, current) =>
              current is PlaylistLoaded &&
              current.error != null &&
              current.failedOperationId == null &&
              (previous is! PlaylistLoaded ||
                  previous.error?.occurrenceId != current.error?.occurrenceId),
          listener: (context, state) {
            final loaded = state as PlaylistLoaded;
            CustomSnackBar.uiError(context, loaded.error!);
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Stack(
          children: [
            Positioned.fill(child: AppContentFrame(child: child)),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                minimum: const EdgeInsets.only(bottom: 12),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppLayout.maxMiniPlayerWidth,
                    ),
                    child: const MiniPlayerBar(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
