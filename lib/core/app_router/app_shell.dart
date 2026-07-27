import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
              curr.error != null && prev.error != curr.error,
          listener: (context, state) {
            CustomSnackBar.error(context, state.error!.tr());
            context.read<PlayerBloc>().add(PlayerErrorShown());
          },
        ),
        BlocListener<PlaylistBloc, PlaylistState>(
          listenWhen: (previous, current) =>
              current is PlaylistLoaded &&
              current.errorKey != null &&
              current.failedOperationId == null &&
              (previous is! PlaylistLoaded ||
                  previous.errorKey != current.errorKey),
          listener: (context, state) {
            final loaded = state as PlaylistLoaded;
            CustomSnackBar.error(context, loaded.errorKey!.tr());
          },
        ),
      ],
      child: Scaffold(
        body: Stack(
          children: [
            child,
            const Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: MiniPlayerBar(),
            ),
          ],
        ),
      ),
    );
  }
}
