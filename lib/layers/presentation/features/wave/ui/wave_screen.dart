import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:owlsonic/core/app_router/app_router_names.dart';
import 'package:owlsonic/core/layout/app_layout.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/presentation/features/player/ui/widgets/wave_card.dart';
import 'package:owlsonic/layers/presentation/features/track/bloc/track/track_bloc.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/desktop_state_view.dart';

/// Wave as a destination: start it in one tap, pick a mood, or customize.
/// Desktop reaches it from the sidebar; on mobile Home carries the same card.
class WaveScreen extends StatelessWidget {
  const WaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        scrolledUnderElevation: 0,
        title: Text(context.tr('waveSession.title'), style: AppText.display3),
      ),
      body: BlocBuilder<TrackBloc, TrackState>(
        builder: (context, state) {
          if (state is! TrackLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.tracks.isEmpty) {
            return DesktopStateView(
              icon: Icons.waves_rounded,
              title: context.tr('wave.emptyTitle'),
              detail: context.tr('wave.emptyDescription'),
              actionLabel: context.tr('home.addMusic'),
              onAction: () => AppLayout.isDesktopPlatform
                  ? context.goNamed(AppRouterNames.importMusic)
                  : context.pushNamed(AppRouterNames.importMusic),
            );
          }
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                children: [
                  const WaveCard(padding: EdgeInsets.zero),
                  const SizedBox(height: 20),
                  Text(
                    context.tr('wave.howItWorks'),
                    key: const ValueKey('wave-how-it-works'),
                    style: AppText.bodyM,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
