import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/core/layout/app_layout.dart';
import 'package:owlsonic/layers/presentation/features/library/ui/library_screen.dart';
import 'package:owlsonic/layers/domain/entities/artist.dart';
import 'package:owlsonic/layers/domain/entities/download_track_task.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/presentation/features/artist/bloc/artist_detail/artist_detail_bloc.dart';
import 'package:owlsonic/layers/presentation/shared/models/ui_error_localization.dart';
import 'package:owlsonic/layers/presentation/shared/blocs/download_status/download_status_cubit.dart';
import 'package:owlsonic/layers/presentation/features/player/bloc/player/player_bloc.dart';
import 'package:owlsonic/layers/presentation/features/artist/ui/widgets/artist_cover.dart';
import 'package:owlsonic/layers/presentation/features/track/ui/widgets/sheets/track_context_sheets.dart';
import 'package:owlsonic/layers/presentation/features/track/ui/widgets/track_item.dart';

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
    if (AppLayout.isDesktopPlatform) {
      return _DesktopArtistContent(artist: artist, tracks: tracks);
    }
    return BlocBuilder<DownloadStatusCubit, Map<String, DownloadTrackTask>>(
      builder: (context, downloadTasks) {
        return BlocSelector<
          PlayerBloc,
          PlayerState,
          ({String? currentTrackId, bool isPlaying})
        >(
          selector: (s) =>
              (currentTrackId: s.currentTrack?.id, isPlaying: s.isPlaying),
          builder: (context, playerSel) {
            final isCurrentArtist =
                playerSel.currentTrackId != null &&
                tracks.any((track) => track.id == playerSel.currentTrackId);
            final isPlayingArtist = isCurrentArtist && playerSel.isPlaying;

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
                        Text(
                          _artistMeta(context, artist),
                          style: AppText.bodyXS,
                        ),
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
                                  isPlayingArtist
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  size: 20,
                                ),
                                label: Text(
                                  context.tr(
                                    isPlayingArtist
                                        ? 'artist.pause'
                                        : 'artist.playAll',
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.text,
                                  backgroundColor: AppColors.surface2,
                                  side: const BorderSide(
                                    color: AppColors.border,
                                  ),
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
                      child: Text(
                        context.tr('artist.empty'),
                        style: AppText.bodyM,
                      ),
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
                        isPlaying: playerSel.isPlaying,
                        isCurrent: track.id == playerSel.currentTrackId,
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
                        onLongPress: () =>
                            showTrackLibraryActions(context, track),
                        onMoreTap: () =>
                            showTrackLibraryActions(context, track),
                        onTap: () {
                          context.read<PlayerBloc>().add(
                            PlayerQueueSet(tracks, startTrack: track),
                          );
                        },
                      );
                    },
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          },
        );
      },
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

class _DesktopArtistContent extends StatelessWidget {
  const _DesktopArtistContent({required this.artist, required this.tracks});
  final ArtistSummary artist;
  final List<Track> tracks;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: EdgeInsets.all(
          AppLayout.desktopPaddingFor(MediaQuery.sizeOf(context).width),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ArtistCover(
              artistName: artist.name,
              imageUrls: artist.coverImageUrls,
              size: 128,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artist.name,
                    style: AppText.display2,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr(
                      'common.trackCount',
                      namedArgs: {'count': '${tracks.length}'},
                    ),
                    style: AppText.bodyM,
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: tracks.isEmpty
                            ? null
                            : () => context.read<PlayerBloc>().add(
                                PlayerQueueSet(tracks),
                              ),
                        icon: const Icon(Icons.play_arrow, size: 18),
                        label: Text(context.tr('artist.playAll')),
                      ),
                      ArtistWaveStartButton(
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
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      Expanded(
        child: tracks.isEmpty
            ? Center(
                child: Text(context.tr('artist.empty'), style: AppText.bodyM),
              )
            : DesktopLibraryTrackTable(tracks: tracks),
      ),
    ],
  );
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
