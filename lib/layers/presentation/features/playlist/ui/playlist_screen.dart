import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:owlsonic/core/di/di.dart';
import 'package:owlsonic/core/services/cloud/auto_sync_service.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/core/layout/app_layout.dart';
import 'package:owlsonic/core/layout/adaptive_presentation.dart';
import 'package:owlsonic/layers/domain/entities/playlist.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/presentation/features/player/bloc/player/player_bloc.dart';
import 'package:owlsonic/layers/presentation/features/playlist/bloc/playlist_detail/playlist_detail_bloc.dart';
import 'package:owlsonic/layers/presentation/shared/models/ui_error_localization.dart';
import 'package:owlsonic/layers/presentation/features/track/bloc/track/track_bloc.dart';
import 'package:owlsonic/layers/presentation/features/playlist/ui/widgets/playlist_cover.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/snackbars/custom_snack_bar.dart';
import 'package:owlsonic/layers/presentation/features/track/ui/widgets/track_item.dart';
import 'package:owlsonic/layers/presentation/features/library/ui/library_screen.dart';
import 'package:owlsonic/layers/presentation/features/playlist/ui/widgets/playlist_components.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/stagger_item.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/desktop_state_view.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) => const _PlaylistScreenBody();
}

class _PlaylistScreenBody extends StatefulWidget {
  const _PlaylistScreenBody();

  @override
  State<_PlaylistScreenBody> createState() => _PlaylistScreenBodyState();
}

class _PlaylistScreenBodyState extends State<_PlaylistScreenBody> {
  bool _isEditing = false;
  String? _selectedTrackId;

  void _showMoreMenu(BuildContext ctx) {
    if (AppLayout.isDesktopPlatform) {
      final size = MediaQuery.sizeOf(ctx);
      showMenu<String>(
        context: ctx,
        position: RelativeRect.fromLTRB(size.width - 210, 52, 20, 0),
        items: [
          PopupMenuItem(value: 'rename', child: Text(ctx.tr('playlist.edit'))),
          PopupMenuItem(
            value: 'delete',
            child: Text(ctx.tr('playlist.delete')),
          ),
        ],
      ).then((action) {
        if (!mounted || !ctx.mounted) return;
        if (action == 'rename') _showRenameSheet(ctx);
        if (action == 'delete') _confirmDelete(ctx);
      });
      return;
    }
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (_) => PlaylistActionsSheet(
        onRename: () {
          ctx.pop();
          _showRenameSheet(ctx);
        },
        onDelete: () {
          ctx.pop();
          _confirmDelete(ctx);
        },
      ),
    );
  }

  void _showRenameSheet(BuildContext ctx) {
    final bloc = ctx.read<PlaylistDetailBloc>();
    final loaded = bloc.state;
    if (loaded is! PlaylistDetailLoaded) return;
    AdaptivePresentation.showSurface<void>(
      ctx,
      maxWidth: 480,
      maxHeight: 600,
      builder: (_) => PlaylistRenameSheet(
        initialName: loaded.playlist.name,
        initialDescription: loaded.playlist.description,
        initialImageUrl: loaded.playlist.imageUrl,
        onSave: (name, description, imageUrl) {
          bloc.add(
            PlaylistDetailRename(
              name: name,
              description: description,
              imageUrl: imageUrl,
            ),
          );
          ctx.pop();
        },
      ),
    );
  }

  void _confirmDelete(BuildContext ctx) {
    final bloc = ctx.read<PlaylistDetailBloc>();
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.l),
        ),
        title: Text(context.tr('playlist.delete'), style: AppText.display3),
        content: Text(
          context.tr('playlist.deleteConfirm'),
          style: AppText.bodyM,
        ),
        actions: [
          TextButton(
            onPressed: () => dialogCtx.pop(),
            child: Text(
              context.tr('common.cancel'),
              style: AppText.bodyL.copyWith(color: AppColors.textSub),
            ),
          ),
          TextButton(
            onPressed: () {
              bloc.add(const PlaylistDetailDelete());
              dialogCtx.pop();
            },
            child: Text(
              context.tr('common.delete'),
              style: AppText.bodyL.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _syncTrack(BuildContext ctx, Track track) {
    unawaited(getIt<AutoSyncService>().syncTrack(track.id));
    CustomSnackBar.info(ctx, ctx.tr('playlist.syncingTrack'));
  }

  void _showTrackOptions(BuildContext ctx, Track track) {
    final bloc = ctx.read<PlaylistDetailBloc>();
    final detail = bloc.state;
    final unsynced =
        detail is PlaylistDetailLoaded &&
        detail.playlist.unsyncedTrackIds.contains(track.id) &&
        getIt.isRegistered<AutoSyncService>();
    if (AppLayout.isDesktopPlatform) {
      final box = ctx.findRenderObject() as RenderBox?;
      final offset = box?.localToGlobal(Offset.zero) ?? Offset.zero;
      showMenu<String>(
        context: ctx,
        position: RelativeRect.fromLTRB(offset.dx + 16, offset.dy + 20, 0, 0),
        items: [
          if (unsynced)
            PopupMenuItem(
              value: 'sync',
              child: Text(ctx.tr('playlist.syncTrack')),
            ),
          PopupMenuItem(
            value: 'remove',
            child: Text(ctx.tr('playlist.removeTrack')),
          ),
        ],
      ).then((action) {
        if (action == 'remove') bloc.add(PlaylistDetailRemoveTrack(track.id));
        if (action == 'sync' && ctx.mounted) _syncTrack(ctx, track);
      });
      return;
    }
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (_) => PlaylistTrackOptionsSheet(
        track: track,
        onRemove: () {
          bloc.add(PlaylistDetailRemoveTrack(track.id));
          ctx.pop();
        },
        onSync: unsynced
            ? () {
                ctx.pop();
                _syncTrack(ctx, track);
              }
            : null,
      ),
    );
  }

  void _showAddTrackSheet(BuildContext ctx) {
    final detailBloc = ctx.read<PlaylistDetailBloc>();
    final trackState = ctx.read<TrackBloc>().state;
    final allTracks = trackState is TrackLoaded
        ? trackState.tracks
        : const <Track>[];
    AdaptivePresentation.showSurface<void>(
      ctx,
      maxWidth: 560,
      maxHeight: 660,
      builder: (_) => BlocProvider.value(
        value: detailBloc,
        child: PlaylistAddTracksSheet(
          allTracks: allTracks,
          onAdd: (track) {
            detailBloc.add(PlaylistDetailAddTrack(track));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlaylistDetailBloc, PlaylistDetailState>(
      listener: (context, state) {
        if (state is PlaylistDetailDeleted) {
          AdaptivePresentation.close(context);
        }
        if (state is PlaylistDetailLoaded && state.error != null) {
          CustomSnackBar.uiError(context, state.error!);
        }
      },
      child: BlocBuilder<PlaylistDetailBloc, PlaylistDetailState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.bg,
            appBar: _buildAppBar(context, state),
            body: switch (state) {
              PlaylistDetailLoading() || PlaylistDetailInitial() =>
                AppLayout.isDesktopPlatform
                    ? DesktopStateView(
                        icon: Icons.queue_music,
                        title: context.tr('common.loading'),
                        loading: true,
                      )
                    : const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                          strokeWidth: 1.5,
                        ),
                      ),
              PlaylistDetailError(:final error) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    error.localized(context),
                    style: AppText.bodyL.copyWith(color: AppColors.textSub),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              PlaylistDetailLoaded(:final playlist, :final tracks) =>
                _isEditing
                    ? _buildEditView(context, playlist, tracks)
                    : _buildViewMode(context, playlist, tracks),
              PlaylistDetailDeleted() => const SizedBox.shrink(),
            },
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, PlaylistDetailState state) {
    final playlistName = state is PlaylistDetailLoaded
        ? state.playlist.name
        : '';

    return AppBar(
      backgroundColor: AppColors.bg,
      scrolledUnderElevation: 0,
      title: Text(
        _isEditing ? context.tr('common.edit') : playlistName,
        style: AppText.display3,
      ),
      actions: _isEditing
          ? [
              TextButton(
                onPressed: () => setState(() => _isEditing = false),
                child: Text(
                  context.tr('common.done'),
                  style: AppText.bodyL.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ]
          : [
              if (state is PlaylistDetailLoaded) ...[
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.textSub,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _isEditing = true),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.textSub,
                    size: 22,
                  ),
                  onPressed: () => _showMoreMenu(context),
                ),
              ],
            ],
    );
  }

  Widget _buildViewMode(
    BuildContext context,
    Playlist playlist,
    List<Track> tracks,
  ) {
    final desktop = AppLayout.isDesktopPlatform;
    return BlocSelector<
      PlayerBloc,
      PlayerState,
      ({String? currentTrackId, bool isPlaying})
    >(
      selector: (s) =>
          (currentTrackId: s.currentTrack?.id, isPlaying: s.isPlaying),
      builder: (context, playerSel) {
        final isPlayingThis =
            playerSel.currentTrackId != null &&
            tracks.any((track) => track.id == playerSel.currentTrackId);

        if (desktop) {
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(
                  AppLayout.desktopPaddingFor(MediaQuery.sizeOf(context).width),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    PlaylistCover(
                      imageUrl: playlist.imageUrl,
                      generatedImageUrls: tracks
                          .map((track) => track.imageUrl)
                          .whereType<String>()
                          .take(4)
                          .toList(),
                      width: 132,
                      height: 132,
                      borderRadius: BorderRadius.circular(AppRadius.m),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            playlist.name,
                            style: AppText.display2,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (playlist.description?.trim().isNotEmpty == true)
                            Text(
                              playlist.description!,
                              style: AppText.bodyM,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 8),
                          Text(
                            context.tr(
                              'common.trackCount',
                              namedArgs: {'count': '${tracks.length}'},
                            ),
                            style: AppText.bodyXS,
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: tracks.isEmpty
                                ? null
                                : () {
                                    if (isPlayingThis) {
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
                              isPlayingThis && playerSel.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              size: 18,
                            ),
                            label: Text(
                              context.tr(
                                isPlayingThis && playerSel.isPlaying
                                    ? 'playlist.pause'
                                    : 'playlist.playAll',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: tracks.isEmpty
                    ? DesktopStateView(
                        icon: Icons.queue_music_outlined,
                        title: context.tr('playlist.empty'),
                        actionLabel: context.tr('playlist.addTrack'),
                        onAction: () => _showAddTrackSheet(context),
                      )
                    : DesktopLibraryTrackTable(
                        tracks: tracks,
                        onMore: _showTrackOptions,
                        unsyncedTrackIds: playlist.unsyncedTrackIds,
                      ),
              ),
            ],
          );
        }

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(playlist, tracks)),
            if (tracks.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: PlaylistPlayButton(
                    isPlayingThis: isPlayingThis && playerSel.isPlaying,
                    onTap: () {
                      if (isPlayingThis) {
                        context.read<PlayerBloc>().add(
                          PlayerPlayPauseToggled(),
                        );
                      } else {
                        context.read<PlayerBloc>().add(PlayerQueueSet(tracks));
                      }
                    },
                  ),
                ),
              ),
            if (tracks.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    context.tr('playlist.empty'),
                    style: AppText.bodyM,
                  ),
                ),
              )
            else ...[
              if (desktop)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(
                            context.tr('library.tracks').toUpperCase(),
                            style: AppText.label,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            context.tr('track.album').toUpperCase(),
                            style: AppText.label,
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: Text(
                            context.tr('track.duration').toUpperCase(),
                            style: AppText.label,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SliverList.builder(
                itemCount: tracks.length,
                itemBuilder: (context, index) {
                  final track = tracks[index];
                  final minutes = track.duration.inMinutes;
                  final duration =
                      '$minutes:${(track.duration.inSeconds % 60).toString().padLeft(2, '0')}';
                  return StaggerItem(
                    index: index,
                    child: GestureDetector(
                      onLongPress: () => _showTrackOptions(context, track),
                      onSecondaryTap: desktop
                          ? () => _showTrackOptions(context, track)
                          : null,
                      onDoubleTap: desktop
                          ? () => context.read<PlayerBloc>().add(
                              PlayerQueueSet(tracks, startTrack: track),
                            )
                          : null,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Container(
                              color: desktop && _selectedTrackId == track.id
                                  ? AppColors.surface2
                                  : Colors.transparent,
                              child: TrackItem(
                                track: track,
                                isPlaying: playerSel.isPlaying,
                                isCurrent: track.id == playerSel.currentTrackId,
                                isAvailable: track.isReadyToPlay,
                                onTap: () {
                                  if (desktop) {
                                    setState(() => _selectedTrackId = track.id);
                                    return;
                                  }
                                  context.read<PlayerBloc>().add(
                                    PlayerQueueSet(tracks, startTrack: track),
                                  );
                                },
                                onMoreTap: desktop
                                    ? () => _showTrackOptions(context, track)
                                    : null,
                              ),
                            ),
                          ),
                          if (playlist.unsyncedTrackIds.contains(track.id))
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Tooltip(
                                message: context.tr('playlist.notSynced'),
                                child: const Icon(
                                  Icons.cloud_off_outlined,
                                  size: 18,
                                  color: AppColors.muted,
                                ),
                              ),
                            ),
                          if (desktop) ...[
                            Expanded(
                              flex: 2,
                              child: Text(
                                track.album ?? '—',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.bodyS,
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(duration, style: AppText.bodyS),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        );
      },
    );
  }

  Widget _buildEditView(
    BuildContext context,
    Playlist playlist,
    List<Track> tracks,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
          child: Row(
            children: [
              Text(
                context.tr(
                  'common.trackCount',
                  namedArgs: {'count': tracks.length.toString()},
                ),
                style: AppText.label,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showAddTrackSheet(context),
                icon: const Icon(Icons.add, size: 16),
                label: Text(context.tr('playlist.addTrack')),
              ),
              Text(
                context.tr('playlist.holdToDrag').toUpperCase(),
                style: AppText.label,
              ),
            ],
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            itemCount: tracks.length,
            onReorderItem: (oldIndex, newIndex) {
              context.read<PlaylistDetailBloc>().add(
                PlaylistDetailReorder(oldIndex, newIndex),
              );
            },
            proxyDecorator: (child, index, animation) =>
                Material(color: Colors.transparent, child: child),
            itemBuilder: (context, index) {
              final track = tracks[index];
              return PlaylistEditableTrackItem(
                key: ValueKey(track.id),
                track: track,
                onRemove: () => context.read<PlaylistDetailBloc>().add(
                  PlaylistDetailRemoveTrack(track.id),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(Playlist playlist, List<Track> tracks) {
    final generatedImageUrls = tracks
        .map((track) => track.imageUrl?.trim())
        .whereType<String>()
        .where((url) => url.isNotEmpty)
        .take(4)
        .toList(growable: false);
    final hasCover =
        (playlist.imageUrl?.trim().isNotEmpty ?? false) ||
        generatedImageUrls.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasCover) ...[
            PlaylistCover(
              imageUrl: playlist.imageUrl,
              generatedImageUrls: generatedImageUrls,
              width: 120,
              height: 120,
              borderRadius: BorderRadius.circular(AppRadius.m),
            ),
            const SizedBox(height: 16),
          ],
          Text(playlist.name, style: AppText.display2),
          if (playlist.description?.trim().isNotEmpty ?? false) ...[
            const SizedBox(height: 6),
            Text(playlist.description!, style: AppText.bodyM),
          ],
          const SizedBox(height: 6),
          Text(
            'common.trackCount'.tr(
              namedArgs: {'count': tracks.length.toString()},
            ),
            style: AppText.bodyXS,
          ),
        ],
      ),
    );
  }
}
