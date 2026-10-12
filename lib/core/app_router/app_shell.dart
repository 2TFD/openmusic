import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:owlsonic/core/layout/app_layout.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/presentation/features/desktop_shell/ui/desktop_shell.dart';
import 'package:owlsonic/layers/presentation/features/player/bloc/player/player_bloc.dart';
import 'package:owlsonic/layers/presentation/features/playlist/bloc/playlist/playlist_bloc.dart';
import 'package:owlsonic/layers/presentation/features/player/ui/widgets/mini_player_bar.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/snackbars/custom_snack_bar.dart';

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
      child: AppLayout.isDesktopPlatform
          ? DesktopShell(child: child)
          : _MobileShell(child: child),
    );
  }
}

/// Content sits above the mini-player instead of underneath it, so the last
/// item on every screen is always reachable. While the keyboard is open the
/// player steps aside and the screen uses the whole area.
class _MobileShell extends StatelessWidget {
  const _MobileShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Scaffold(
      backgroundColor: AppColors.bg,
      resizeToAvoidBottomInset: false,
      body: BlocSelector<PlayerBloc, PlayerState, bool>(
        selector: (state) => state.currentTrack != null,
        builder: (context, hasTrack) {
          final showPlayer = hasTrack && !keyboardOpen;
          // The player already sits above the home indicator, so screens must
          // not add the bottom safe area a second time.
          final content = AppContentFrame(child: child);
          return Column(
            children: [
              Expanded(
                child: showPlayer
                    ? MediaQuery.removePadding(
                        context: context,
                        removeBottom: true,
                        child: content,
                      )
                    : content,
              ),
              if (showPlayer)
                SafeArea(
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
            ],
          );
        },
      ),
    );
  }
}
