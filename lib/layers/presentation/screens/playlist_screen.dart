import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openmusic/core/di/di.dart';
import 'package:openmusic/core/themes/app_theme.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/repositories/playlist_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_repository.dart';
import 'package:openmusic/layers/presentation/blocs/player/player_bloc.dart';
import 'package:openmusic/layers/presentation/blocs/playlist_detail/playlist_detail_bloc.dart';
import 'package:openmusic/layers/presentation/widgets/cached_image.dart';
import 'package:openmusic/layers/presentation/widgets/track_item.dart';

class PlaylistScreen extends StatelessWidget {
  final String playlistId;
  const PlaylistScreen({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PlaylistDetailBloc(
        playlistRepo: getIt<PlaylistRepository>(),
        trackRepo: getIt<TrackRepository>(),
      )..add(PlaylistDetailLoad(playlistId)),
      child: _PlaylistScreenBody(playlistId: playlistId),
    );
  }
}

class _PlaylistScreenBody extends StatefulWidget {
  final String playlistId;
  const _PlaylistScreenBody({required this.playlistId});

  @override
  State<_PlaylistScreenBody> createState() => _PlaylistScreenBodyState();
}

class _PlaylistScreenBodyState extends State<_PlaylistScreenBody> {
  bool _isEditing = false;

  void _showMoreMenu(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (_) => _PlaylistActionsSheet(
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
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (_) => _RenamePlaylistSheet(
        initialName: loaded.playlist.name,
        onSave: (name) {
          bloc.add(PlaylistDetailRename(name));
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
        title: Text('Delete playlist', style: AppText.display3),
        content: Text('This cannot be undone.', style: AppText.bodyM),
        actions: [
          TextButton(
            onPressed: () => dialogCtx.pop(),
            child: Text(
              'Cancel',
              style: AppText.bodyL.copyWith(color: AppColors.textSub),
            ),
          ),
          TextButton(
            onPressed: () {
              bloc.add(const PlaylistDetailDelete());
              dialogCtx.pop();
            },
            child: Text(
              'Delete',
              style: AppText.bodyL.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showTrackOptions(BuildContext ctx, Track track) {
    final bloc = ctx.read<PlaylistDetailBloc>();
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (_) => _TrackOptionsSheet(
        track: track,
        onRemove: () {
          bloc.add(PlaylistDetailRemoveTrack(track.id));
          ctx.pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlaylistDetailBloc, PlaylistDetailState>(
      listener: (context, state) {
        if (state is PlaylistDetailDeleted) {
          context.pop();
        }
      },
      child: BlocBuilder<PlaylistDetailBloc, PlaylistDetailState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.bg,
            appBar: _buildAppBar(context, state),
            body: switch (state) {
              PlaylistDetailLoading() ||
              PlaylistDetailInitial() => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                  strokeWidth: 1.5,
                ),
              ),
              PlaylistDetailError(:final message) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    message,
                    style: AppText.bodyL.copyWith(color: AppColors.textSub),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              PlaylistDetailLoaded(:final playlist, :final tracks) =>
                _isEditing
                    ? _buildEditView(context, tracks)
                    : _buildViewMode(context, playlist.name, tracks),
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
      title: Text(_isEditing ? 'Edit' : playlistName, style: AppText.display3),
      actions: _isEditing
          ? [
              TextButton(
                onPressed: () => setState(() => _isEditing = false),
                child: Text(
                  'Done',
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
    String playlistName,
    List<Track> tracks,
  ) {
    final playerState = context.watch<PlayerBloc>().state;
    final isPlayingThis =
        playerState.currentTrack != null &&
        tracks.contains(playerState.currentTrack);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(playlistName, tracks.length)),
        if (tracks.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: _PlayButton(
                isPlayingThis: isPlayingThis && playerState.isPlaying,
                onTap: () {
                  context.read<PlayerBloc>().add(
                    PlayerQueueSet(tracks, startIndex: 0),
                  );
                  if (!playerState.isPlaying || !isPlayingThis) {
                    context.read<PlayerBloc>().add(PlayerPlayPauseToggled());
                  }
                },
              ),
            ),
          ),
        if (tracks.isEmpty)
          SliverFillRemaining(
            child: Center(child: Text('No tracks yet', style: AppText.bodyM)),
          )
        else
          SliverList.builder(
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final track = tracks[index];
              return GestureDetector(
                onLongPress: () => _showTrackOptions(context, track),
                child: TrackItem(
                  track: track,
                  isPlaying: playerState.isPlaying,
                  isCurrent: track == playerState.currentTrack,
                  isAvailable: track.isReadyToPlay,
                  onTap: () {
                    context.read<PlayerBloc>().add(
                      PlayerQueueSet(tracks, startIndex: index),
                    );
                    context.read<PlayerBloc>().add(PlayerPlayPauseToggled());
                  },
                ),
              );
            },
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildEditView(BuildContext context, List<Track> tracks) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
          child: Row(
            children: [
              Text(
                '${tracks.length} ${_pluralTracks(tracks.length)}',
                style: AppText.label,
              ),
              const Spacer(),
              Text('HOLD TO DRAG', style: AppText.label),
            ],
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            itemCount: tracks.length,
            onReorder: (oldIndex, newIndex) {
              context.read<PlaylistDetailBloc>().add(
                PlaylistDetailReorder(oldIndex, newIndex),
              );
            },
            proxyDecorator: (child, index, animation) =>
                Material(color: Colors.transparent, child: child),
            itemBuilder: (context, index) {
              final track = tracks[index];
              return _EditableTrackItem(
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

  Widget _buildHeader(String name, int trackCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: AppText.display2),
          const SizedBox(height: 6),
          Text(
            '$trackCount ${_pluralTracks(trackCount)}',
            style: AppText.bodyXS,
          ),
        ],
      ),
    );
  }

  String _pluralTracks(int count) {
    final mod10 = count % 10;
    final mod100 = count % 100;
    if (mod10 == 1 && mod100 != 11) return 'трек';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 10 || mod100 >= 20)) {
      return 'трека';
    }
    return 'треков';
  }
}

class _PlayButton extends StatelessWidget {
  final bool isPlayingThis;
  final VoidCallback onTap;

  const _PlayButton({required this.isPlayingThis, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(AppRadius.m),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPlayingThis ? Icons.pause : Icons.play_arrow,
              color: AppColors.text,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              isPlayingThis ? 'Pause' : 'Play all',
              style: AppText.bodyL.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditableTrackItem extends StatelessWidget {
  final Track track;
  final VoidCallback onRemove;

  const _EditableTrackItem({
    super.key,
    required this.track,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.drag_handle, color: AppColors.muted2, size: 20),
          const SizedBox(width: 14),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.s),
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.s),
              child: CachedImage(url: track.imageUrl, size: 40),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  style: GoogleFonts.figtree(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFC0C0C0),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  track.artists.map((a) => a.name).join(', '),
                  style: GoogleFonts.figtree(
                    fontSize: 11,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: const Padding(
              padding: EdgeInsets.only(left: 12),
              child: Icon(
                Icons.remove_circle_outline,
                color: AppColors.muted,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackOptionsSheet extends StatelessWidget {
  final Track track;
  final VoidCallback onRemove;

  const _TrackOptionsSheet({required this.track, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppBlur.sheetColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.s),
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.s),
                    child: CachedImage(url: track.imageUrl, size: 40),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        style: AppText.bodyL,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        track.artists.map((a) => a.name).join(', '),
                        style: AppText.bodyM,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),
          _SheetAction(
            icon: Icons.remove_circle_outline,
            label: 'Remove from playlist',
            color: AppColors.error,
            onTap: onRemove,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _PlaylistActionsSheet extends StatelessWidget {
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _PlaylistActionsSheet({required this.onRename, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppBlur.sheetColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(
                top: AppSpacing.m,
                bottom: AppSpacing.xl,
              ),
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.muted2,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          _SheetAction(
            icon: Icons.edit_outlined,
            label: 'Rename',
            onTap: onRename,
          ),
          const SizedBox(height: 4),
          _SheetAction(
            icon: Icons.delete_outline,
            label: 'Delete playlist',
            color: AppColors.error,
            onTap: onDelete,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _RenamePlaylistSheet extends StatefulWidget {
  final String initialName;
  final ValueChanged<String> onSave;

  const _RenamePlaylistSheet({required this.initialName, required this.onSave});

  @override
  State<_RenamePlaylistSheet> createState() => _RenamePlaylistSheetState();
}

class _RenamePlaylistSheetState extends State<_RenamePlaylistSheet> {
  late final TextEditingController _ctrl = TextEditingController(
    text: widget.initialName,
  );
  late bool _canSave = widget.initialName.trim().isNotEmpty;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppBlur.sheetColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.xxl + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Row(
            children: [
              Text('Rename', style: AppText.display3),
              const Spacer(),
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close, size: 18, color: AppColors.muted),
                padding: const EdgeInsets.all(AppSpacing.s),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('NAME', style: AppText.label),
          const SizedBox(height: AppSpacing.s),
          TextField(
            controller: _ctrl,
            autofocus: true,
            onChanged: (v) => setState(() => _canSave = v.trim().isNotEmpty),
            onSubmitted: (_) {
              if (_canSave) widget.onSave(_ctrl.text.trim());
            },
            style: AppText.display2,
            maxLength: 50,
            maxLines: 1,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: 'Playlist name',
              hintStyle: AppText.display2.copyWith(color: AppColors.muted2),
              counterText: '',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AnimatedOpacity(
            opacity: _canSave ? 1.0 : 0.35,
            duration: AppAnim.fast,
            child: GestureDetector(
              onTap: _canSave ? () => widget.onSave(_ctrl.text.trim()) : null,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.m + 2),
                decoration: BoxDecoration(
                  color: AppColors.surface3,
                  borderRadius: BorderRadius.circular(AppRadius.m),
                ),
                child: Text(
                  'Save',
                  style: AppText.bodyL.copyWith(
                    color: _canSave ? AppColors.text : AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 14),
            Text(label, style: AppText.bodyL.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
