import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:owlsonic/core/di/di.dart';
import 'package:owlsonic/core/layout/app_layout.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/domain/entities/playlist.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/domain/usecases/add_track_to_playlist_use_case.dart';
import 'package:owlsonic/layers/presentation/features/playlist/bloc/playlist/playlist_bloc.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/cached_image.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/snackbars/custom_snack_bar.dart';

Future<void> showAddToPlaylistSheet(BuildContext context, Track track) =>
    showAddTracksToPlaylistSheet(context, [track]);

/// Adds every track in [tracks] to the playlist the user picks; tracks already
/// in it are skipped by the repository.
Future<void> showAddTracksToPlaylistSheet(
  BuildContext context,
  List<Track> tracks,
) async {
  if (tracks.isEmpty) return;
  if (AppLayout.isDesktopPlatform) {
    return showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.surface,
        child: SizedBox(width: 440, child: _AddToPlaylistSheet(tracks: tracks)),
      ),
    );
  }
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (sheetContext) => _AddToPlaylistSheet(tracks: tracks),
  );
}

class _AddToPlaylistSheet extends StatelessWidget {
  final List<Track> tracks;
  const _AddToPlaylistSheet({required this.tracks});

  @override
  Widget build(BuildContext context) {
    final desktop = AppLayout.isDesktopPlatform;
    return Container(
      decoration: BoxDecoration(
        color: AppBlur.sheetColor,
        borderRadius: desktop
            ? BorderRadius.circular(AppRadius.xl)
            : const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.7,
      ),
      // ListTiles paint ink on the nearest Material; without one here the
      // sheet's own background would hide it (Flutter asserts on this).
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!desktop)
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(
                      top: AppSpacing.m,
                      bottom: AppSpacing.s,
                    ),
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.muted2,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 16,
                ),
                child: Text(
                  context.tr('playlist.addToPlaylist'),
                  style: AppText.display3,
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              Flexible(
                child: BlocBuilder<PlaylistBloc, PlaylistState>(
                  builder: (context, state) {
                    if (state is PlaylistLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is PlaylistLoaded) {
                      final playlists = state.playlists;
                      if (playlists.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(
                            child: Text(
                              context.tr('allPlaylists.empty'),
                              style: AppText.bodyM.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: playlists.length,
                        itemBuilder: (context, index) {
                          final playlist = playlists[index];
                          return _PlaylistTile(
                            playlist: playlist,
                            onTap: () async {
                              try {
                                final addTrack =
                                    getIt<AddTrackToPlaylistUseCase>();
                                for (final track in tracks) {
                                  await addTrack(
                                    playlistId: playlist.id,
                                    trackId: track.id,
                                  );
                                }
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  CustomSnackBar.info(
                                    context,
                                    context.tr(
                                      'playlist.tracksAdded',
                                      namedArgs: {
                                        'count': '${tracks.length}',
                                        'name': playlist.name,
                                      },
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  CustomSnackBar.error(context, e.toString());
                                }
                              }
                            },
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaylistTile extends StatelessWidget {
  final PlaylistSummary playlist;
  final VoidCallback onTap;

  const _PlaylistTile({required this.playlist, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      onTap: onTap,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xs),
          color: AppColors.surface,
          border: Border.all(color: AppColors.borderAct),
        ),
        clipBehavior: Clip.hardEdge,
        child: playlist.imageUrl != null
            ? CachedImage(url: playlist.imageUrl!, size: 48)
            : const Center(
                child: Icon(Icons.queue_music_rounded, color: AppColors.muted),
              ),
      ),
      title: Text(playlist.name, style: AppText.bodyL),
      subtitle: Text(
        context.tr(
          'common.trackCount',
          namedArgs: {'count': playlist.trackCount.toString()},
        ),
        style: AppText.bodyM.copyWith(color: AppColors.muted),
      ),
    );
  }
}
