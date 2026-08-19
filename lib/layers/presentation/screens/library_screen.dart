import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openmusic/core/app_router/app_router_names.dart';
import 'package:openmusic/core/themes/app_theme.dart';
import 'package:openmusic/layers/domain/entities/artist.dart';
import 'package:openmusic/layers/domain/entities/download_track_task.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/presentation/blocs/artists/artists_cubit.dart';
import 'package:openmusic/layers/presentation/blocs/download_status/download_status_cubit.dart';
import 'package:openmusic/layers/presentation/blocs/player/player_bloc.dart';
import 'package:openmusic/layers/presentation/blocs/track/track_bloc.dart';
import 'package:openmusic/layers/presentation/widgets/artist_cover.dart';
import 'package:openmusic/layers/presentation/widgets/sheets/track_context_sheets.dart';
import 'package:openmusic/layers/presentation/widgets/track_item.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  SourceType? _filter;
  _LibraryView _view = _LibraryView.tracks;

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
            title: Text(context.tr('library.title'), style: AppText.display3),
            actions: [
              IconButton(
                tooltip: context.tr('settings.title'),
                onPressed: () => context.pushNamed(AppRouterNames.settings),
                icon: const Icon(Icons.settings),
              ),
            ],
          ),
          body: Column(
            children: [
              _LibraryViewSwitch(
                selected: _view,
                onChanged: (view) => setState(() => _view = view),
              ),
              if (_view == _LibraryView.tracks)
                _FilterRow(
                  filters: _filters,
                  selected: _filter,
                  onChanged: (f) => setState(() => _filter = f),
                ),
              Expanded(
                child: _view == _LibraryView.tracks
                    ? _TrackList(tracks: tracks)
                    : const _ArtistsGrid(),
              ),
            ],
          ),
        );
      },
    );
  }
}

enum _LibraryView { tracks, artists }

class _LibraryViewSwitch extends StatelessWidget {
  const _LibraryViewSwitch({required this.selected, required this.onChanged});

  final _LibraryView selected;
  final ValueChanged<_LibraryView> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
      child: SizedBox(
        width: double.infinity,
        child: SegmentedButton<_LibraryView>(
          segments: [
            ButtonSegment(
              value: _LibraryView.tracks,
              icon: const Icon(Icons.music_note, size: 17),
              label: Text(context.tr('library.tracks')),
            ),
            ButtonSegment(
              value: _LibraryView.artists,
              icon: const Icon(Icons.person_outline, size: 17),
              label: Text(context.tr('library.artists')),
            ),
          ],
          selected: {selected},
          showSelectedIcon: false,
          onSelectionChanged: (selection) => onChanged(selection.single),
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? AppColors.text
                  : AppColors.muted,
            ),
            backgroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? AppColors.surface2
                  : Colors.transparent,
            ),
            side: WidgetStateProperty.all(
              const BorderSide(color: AppColors.border),
            ),
            textStyle: WidgetStateProperty.all(AppText.bodyS),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrackList extends StatelessWidget {
  const _TrackList({required this.tracks});

  final List<Track> tracks;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadStatusCubit, Map<String, DownloadTrackTask>>(
      builder: (context, downloadTasks) {
        final playerState = context.watch<PlayerBloc>().state;
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: tracks.length,
          itemBuilder: (context, index) {
            final track = tracks[index];
            final downloadTask = downloadTasks[track.id];
            return TrackItem(
              track: track,
              isPlaying: playerState.isPlaying,
              isCurrent: track.id == playerState.currentTrack?.id,
              isAvailable: track.isReadyToPlay,
              downloadTask: downloadTask,
              onDownloadStatusTap: downloadTask?.status == DownloadStatus.failed
                  ? () =>
                        showTrackDownloadFailure(context, track, downloadTask!)
                  : null,
              onLongPress: () => showTrackLibraryActions(context, track),
              onMoreTap: () => showTrackLibraryActions(context, track),
              onTap: () {
                context.read<PlayerBloc>().add(
                  PlayerQueueSet(tracks, startTrack: track),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ArtistsGrid extends StatelessWidget {
  const _ArtistsGrid();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArtistsCubit, ArtistsState>(
      builder: (context, state) {
        return switch (state) {
          ArtistsError() => Center(child: Text(state.errorKey.tr())),
          ArtistsLoaded() when state.artists.isEmpty => Center(
            child: Text(context.tr('library.noArtists'), style: AppText.bodyM),
          ),
          ArtistsLoaded() => LayoutBuilder(
            builder: (context, constraints) {
              const horizontalPadding = 48.0;
              const spacing = 12.0;
              final availableWidth = constraints.maxWidth - horizontalPadding;
              final columns = (availableWidth / 170).floor().clamp(2, 6);
              final itemWidth =
                  (availableWidth - spacing * (columns - 1)) / columns;
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 110),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: 18,
                  mainAxisExtent: itemWidth + 48,
                ),
                itemCount: state.artists.length,
                itemBuilder: (context, index) =>
                    _ArtistCard(artist: state.artists[index]),
              );
            },
          ),
          _ => const Center(child: CircularProgressIndicator()),
        };
      },
    );
  }
}

class _ArtistCard extends StatelessWidget {
  const _ArtistCard({required this.artist});

  final ArtistSummary artist;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => context.pushNamed(
        AppRouterNames.artist,
        pathParameters: {'id': artist.id},
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ArtistCover(
              artistName: artist.name,
              imageUrls: artist.coverImageUrls,
              width: double.infinity,
              height: double.infinity,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            artist.name,
            style: AppText.bodyL.copyWith(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            context.tr(
              'common.trackCount',
              namedArgs: {'count': artist.trackCount.toString()},
            ),
            style: AppText.bodyXS,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
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
