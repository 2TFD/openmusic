import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openmusic/core/themes/app_theme.dart';
import 'package:openmusic/layers/domain/entities/playlist.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/presentation/blocs/player/player_bloc.dart';
import 'package:openmusic/layers/presentation/blocs/playlist_detail/playlist_detail_bloc.dart';
import 'package:openmusic/layers/presentation/blocs/track/track_bloc.dart';
import 'package:openmusic/layers/presentation/widgets/cached_image.dart';
import 'package:openmusic/layers/presentation/widgets/snackbars/custom_snack_bar.dart';
import 'package:openmusic/layers/presentation/widgets/track_item.dart';

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

  void _showAddTrackSheet(BuildContext ctx, Playlist playlist) {
    final detailBloc = ctx.read<PlaylistDetailBloc>();
    final trackState = ctx.read<TrackBloc>().state;
    final available = trackState is TrackLoaded
        ? trackState.tracks
              .where((track) => !playlist.trackIds.contains(track.id))
              .toList()
        : const <Track>[];
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (sheetContext) => _AddTracksSheet(
        tracks: available,
        onAdd: (track) {
          detailBloc.add(PlaylistDetailAddTrack(track));
          sheetContext.pop();
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
        if (state is PlaylistDetailLoaded && state.errorKey != null) {
          CustomSnackBar.error(context, state.errorKey!.tr());
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
    final playerState = context.watch<PlayerBloc>().state;
    final isPlayingThis =
        playerState.currentTrack != null &&
        tracks.any((track) => track.id == playerState.currentTrack!.id);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(playlist, tracks.length)),
        if (tracks.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: _PlayButton(
                isPlayingThis: isPlayingThis && playerState.isPlaying,
                onTap: () {
                  if (isPlayingThis) {
                    context.read<PlayerBloc>().add(PlayerPlayPauseToggled());
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
              child: Text(context.tr('playlist.empty'), style: AppText.bodyM),
            ),
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
                  isCurrent: track.id == playerState.currentTrack?.id,
                  isAvailable: track.isReadyToPlay,
                  onTap: () {
                    context.read<PlayerBloc>().add(
                      PlayerQueueSet(tracks, startTrack: track),
                    );
                  },
                ),
              );
            },
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
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
                onPressed: () => _showAddTrackSheet(context, playlist),
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

  Widget _buildHeader(Playlist playlist, int trackCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (playlist.imageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.m),
              child: CachedImage(url: playlist.imageUrl, size: 120),
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
            'common.trackCount'.tr(namedArgs: {'count': trackCount.toString()}),
            style: AppText.bodyXS,
          ),
        ],
      ),
    );
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
              context.tr(isPlayingThis ? 'playlist.pause' : 'playlist.playAll'),
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
            label: context.tr('playlist.removeTrack'),
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
            label: context.tr('common.rename'),
            onTap: onRename,
          ),
          const SizedBox(height: 4),
          _SheetAction(
            icon: Icons.delete_outline,
            label: context.tr('playlist.delete'),
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
  final String? initialDescription;
  final String? initialImageUrl;
  final void Function(String name, String? description, String? imageUrl)
  onSave;

  const _RenamePlaylistSheet({
    required this.initialName,
    required this.initialDescription,
    required this.initialImageUrl,
    required this.onSave,
  });

  @override
  State<_RenamePlaylistSheet> createState() => _RenamePlaylistSheetState();
}

class _RenamePlaylistSheetState extends State<_RenamePlaylistSheet> {
  late final TextEditingController _ctrl = TextEditingController(
    text: widget.initialName,
  );
  late final TextEditingController _descriptionCtrl = TextEditingController(
    text: widget.initialDescription,
  );
  late final TextEditingController _imageUrlCtrl = TextEditingController(
    text: widget.initialImageUrl,
  );
  late bool _canSave = widget.initialName.trim().isNotEmpty;

  @override
  void dispose() {
    _ctrl.dispose();
    _descriptionCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_canSave) return;
    final description = _descriptionCtrl.text.trim();
    final imageUrl = _imageUrlCtrl.text.trim();
    widget.onSave(
      _ctrl.text.trim(),
      description.isEmpty ? null : description,
      imageUrl.isEmpty ? null : imageUrl,
    );
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
              Text(context.tr('playlist.edit'), style: AppText.display3),
              const Spacer(),
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close, size: 18, color: AppColors.muted),
                padding: const EdgeInsets.all(AppSpacing.s),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(context.tr('playlist.name').toUpperCase(), style: AppText.label),
          const SizedBox(height: AppSpacing.s),
          TextField(
            controller: _ctrl,
            autofocus: true,
            onChanged: (v) => setState(() => _canSave = v.trim().isNotEmpty),
            style: AppText.display2,
            maxLength: 50,
            maxLines: 1,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: context.tr('playlist.nameHint'),
              hintStyle: AppText.display2.copyWith(color: AppColors.muted2),
              counterText: '',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            context.tr('playlist.description').toUpperCase(),
            style: AppText.label,
          ),
          TextField(
            controller: _descriptionCtrl,
            maxLength: 500,
            maxLines: 3,
            style: AppText.bodyL,
            decoration: InputDecoration(
              hintText: context.tr('playlist.descriptionHint'),
              counterText: '',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            context.tr('playlist.imageUrl').toUpperCase(),
            style: AppText.label,
          ),
          TextField(
            controller: _imageUrlCtrl,
            maxLines: 1,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
            style: AppText.bodyL,
            decoration: InputDecoration(
              hintText: context.tr('playlist.imageUrlHint'),
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
              onTap: _canSave ? _save : null,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.m + 2),
                decoration: BoxDecoration(
                  color: AppColors.surface3,
                  borderRadius: BorderRadius.circular(AppRadius.m),
                ),
                child: Text(
                  context.tr('common.save'),
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

class _AddTracksSheet extends StatelessWidget {
  const _AddTracksSheet({required this.tracks, required this.onAdd});

  final List<Track> tracks;
  final ValueChanged<Track> onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: AppBlur.sheetColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.muted2,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          Text(context.tr('playlist.addTrack'), style: AppText.display3),
          const SizedBox(height: 12),
          if (tracks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                context.tr('playlist.noTracksToAdd'),
                style: AppText.bodyM,
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                itemCount: tracks.length,
                itemBuilder: (context, index) {
                  final track = tracks[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.s),
                      child: CachedImage(url: track.imageUrl, size: 40),
                    ),
                    title: Text(track.title, style: AppText.bodyL),
                    subtitle: Text(
                      track.artists.map((artist) => artist.name).join(', '),
                      style: AppText.bodyM,
                    ),
                    trailing: const Icon(Icons.add, color: AppColors.textSub),
                    onTap: () => onAdd(track),
                  );
                },
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
