import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openmusic/core/app_router/app_router_names.dart';
import 'package:openmusic/core/themes/app_theme.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/presentation/blocs/player/player_bloc.dart';
import 'package:openmusic/layers/presentation/blocs/track/track_bloc.dart';
import 'package:openmusic/layers/presentation/widgets/track_item.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  SourceType? _filter;

  static const _filters = <(String, SourceType?)>[
    ('library.filterAll', null),
    ('library.filterLocal', SourceType.localFile),
    ('library.filterSoundcloud', SourceType.soundcloud),
    ('library.filterUnknown', SourceType.unknown),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackBloc, TrackState>(
      builder: (context, state) {
        if (state is TrackError) {
          return Scaffold(body: Center(child: Text(state.error.tr())));
        }
        if (state is! TrackLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final tracks = _filter == null
            ? state.tracks
            : state.tracks.where((t) => t.source.type == _filter).toList();

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.bg,
            actions: [
              IconButton(
                onPressed: () => context.pushNamed(AppRouterNames.settings),
                icon: const Icon(Icons.settings),
              ),
            ],
          ),
          body: Column(
            children: [
              _FilterRow(
                filters: _filters,
                selected: _filter,
                onChanged: (f) => setState(() => _filter = f),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: tracks.length,
                  itemBuilder: (context, index) {
                    final playerState = context.watch<PlayerBloc>().state;
                    return TrackItem(
                      track: tracks[index],
                      isPlaying: playerState.isPlaying,
                      isCurrent:
                          tracks[index].id == playerState.currentTrack?.id,
                      isAvailable: tracks[index].isReadyToPlay,
                      onTap: () {
                        context.read<PlayerBloc>().add(
                          PlayerQueueSet(tracks, startTrack: tracks[index]),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterRow extends StatelessWidget {
  final List<(String, SourceType?)> filters;
  final SourceType? selected;
  final ValueChanged<SourceType?> onChanged;

  const _FilterRow({
    required this.filters,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenH,
        vertical: 10,
      ),
      child: Row(
        children: filters.map((entry) {
          final (localeKey, type) = entry;
          final isSelected = selected == type;
          return GestureDetector(
            onTap: () => onChanged(type),
            child: AnimatedContainer(
              duration: AppAnim.fast,
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.surface2 : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(
                  color: isSelected ? AppColors.borderAct : AppColors.border,
                ),
              ),
              child: Text(
                context.tr(localeKey).toUpperCase(),
                style: GoogleFonts.figtree(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? AppColors.text : AppColors.muted,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
