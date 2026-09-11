import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openmusic/core/themes/app_theme.dart';
import 'package:openmusic/layers/domain/entities/artist.dart';
import 'package:openmusic/layers/domain/entities/download_track_task.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/presentation/blocs/artist_detail/artist_detail_bloc.dart';
import 'package:openmusic/layers/presentation/models/ui_error_localization.dart';
import 'package:openmusic/layers/presentation/blocs/download_status/download_status_cubit.dart';
import 'package:openmusic/layers/presentation/blocs/player/player_bloc.dart';
import 'package:openmusic/layers/presentation/widgets/artist_cover.dart';
import 'package:openmusic/layers/presentation/widgets/sheets/track_context_sheets.dart';
import 'package:openmusic/layers/presentation/widgets/track_item.dart';

class ArtistScreen extends StatelessWidget {
  const ArtistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArtistDetailBloc, ArtistDetailState>(
      builder: (context, state) {
        final title = state is ArtistDetailLoaded
            ? state.artist.name
            : context.tr('artist.title');
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.bg,
            title: Text(
              title,
              style: AppText.display3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          body: switch (state) {
            ArtistDetailLoaded() => _ArtistContent(
              artist: state.artist,
              tracks: state.tracks,
            ),
            ArtistDetailError() => Center(
              child: Text(state.error.localized(context)),
            ),
            ArtistDetailNotFound() => Center(
              child: Text(context.tr('artist.notFound'), style: AppText.bodyM),
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        );
      },
    );
  }
}

class _ArtistContent extends StatelessWidget {
  const _ArtistContent({required this.artist, required this.tracks});

  final ArtistSummary artist;
  final List<Track> tracks;

  @override
  Widget build(BuildContext context) {
    final playerState = context.watch<PlayerBloc>().state;
    final downloadTasks = context.watch<DownloadStatusCubit>().state;
    final isCurrentArtist =
        playerState.currentTrack != null &&
        tracks.any((track) => track.id == playerState.currentTrack!.id);
    final isPlayingArtist = isCurrentArtist && playerState.isPlaying;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ArtistCover(
                  artistName: artist.name,
                  imageUrls: artist.coverImageUrls,
                  size: 120,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                const SizedBox(height: 16),
                Text(artist.name, style: AppText.display2),
                const SizedBox(height: 6),
                Text(_artistMeta(context, artist), style: AppText.bodyXS),
              ],
            ),
          ),
        ),
        if (tracks.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          if (isCurrentArtist) {
                            context.read<PlayerBloc>().add(
                              PlayerPlayPauseToggled(),
                            );
                          } else {
                            context.read<PlayerBloc>().add(
                              PlayerQueueSet(tracks),
                            );
                          }
                        },
                        icon: Icon(
                          isPlayingArtist ? Icons.pause : Icons.play_arrow,
                          size: 20,
                        ),
                        label: Text(
                          context.tr(
                            isPlayingArtist ? 'artist.pause' : 'artist.playAll',
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.text,
                          backgroundColor: AppColors.surface2,
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: AppText.bodyL.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton.outlined(
                      tooltip: context.tr('artist.shuffle'),
                      onPressed: () {
                        final shuffled = [...tracks]..shuffle();
                        context.read<PlayerBloc>().add(
                          PlayerQueueSet(shuffled),
                        );
                      },
                      icon: const Icon(Icons.shuffle, size: 20),
                      style: IconButton.styleFrom(
                        foregroundColor: AppColors.textSub,
                        backgroundColor: AppColors.surface,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (tracks.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: ArtistWaveStartButton(
                artist: artist,
                onPressed: () => context.read<PlayerBloc>().add(
                  PlayerArtistWaveStarted(
                    artistId: artist.id,
                    artistName: artist.name,
                    imageUrl: artist.coverImageUrls.isEmpty
                        ? null
                        : artist.coverImageUrls.first,
                  ),
                ),
              ),
            ),
          ),
        if (tracks.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                context.tr('artist.tracks').toUpperCase(),
                style: AppText.label,
              ),
            ),
          ),
        if (tracks.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Text(context.tr('artist.empty'), style: AppText.bodyM),
            ),
          )
        else
          SliverList.builder(
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
                onDownloadStatusTap:
                    downloadTask?.status == DownloadStatus.failed
                    ? () => showTrackDownloadFailure(
                        context,
                        track,
                        downloadTask!,
                      )
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
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  String _artistMeta(BuildContext context, ArtistSummary artist) {
    final duration = artist.totalDuration;
    final durationLabel = duration.inHours > 0
        ? context.tr(
            'artist.durationHoursMinutes',
            namedArgs: {
              'hours': duration.inHours.toString(),
              'minutes': (duration.inMinutes % 60).toString(),
            },
          )
        : context.tr(
            'artist.durationMinutes',
            namedArgs: {'minutes': duration.inMinutes.toString()},
          );
    return context.tr(
      'artist.meta',
      namedArgs: {
        'count': artist.trackCount.toString(),
        'duration': durationLabel,
      },
    );
  }
}

class ArtistWaveStartButton extends StatelessWidget {
  const ArtistWaveStartButton({
    super.key,
    required this.artist,
    required this.onPressed,
  });

  final ArtistSummary artist;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    label: artist.name,
    button: true,
    child: SizedBox(
      height: 48,
      child: FilledButton.icon(
        key: const ValueKey('start-artist-wave'),
        onPressed: onPressed,
        icon: const Icon(Icons.waves_rounded, size: 20),
        label: Text(context.tr('waveSession.startWave')),
      ),
    ),
  );
}
