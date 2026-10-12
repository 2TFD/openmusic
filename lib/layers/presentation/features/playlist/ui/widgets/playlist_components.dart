import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:owlsonic/core/layout/adaptive_presentation.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/core/layout/app_layout.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/presentation/features/playlist/bloc/playlist_detail/playlist_detail_bloc.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/cached_image.dart';

class PlaylistPlayButton extends StatelessWidget {
  final bool isPlayingThis;
  final VoidCallback onTap;

  const PlaylistPlayButton({
    super.key,
    required this.isPlayingThis,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
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

class PlaylistEditableTrackItem extends StatelessWidget {
  final Track track;
  final VoidCallback onRemove;

  const PlaylistEditableTrackItem({
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
                    color: AppColors.imageOverlay,
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

class PlaylistTrackOptionsSheet extends StatelessWidget {
  final Track track;
  final VoidCallback onRemove;

  /// Set for a song that is not part of the synced playlist yet.
  final VoidCallback? onSync;

  const PlaylistTrackOptionsSheet({
    super.key,
    required this.track,
    required this.onRemove,
    this.onSync,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppBlur.sheetColor,
        borderRadius: AppLayout.isDesktopPlatform
            ? BorderRadius.circular(AppRadius.xl)
            : const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!AppLayout.isDesktopPlatform)
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
          if (onSync != null)
            PlaylistSheetAction(
              icon: Icons.cloud_upload_outlined,
              label: context.tr('playlist.syncTrack'),
              onTap: onSync!,
            ),
          PlaylistSheetAction(
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

class PlaylistActionsSheet extends StatelessWidget {
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const PlaylistActionsSheet({
    super.key,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppBlur.sheetColor,
        borderRadius: AppLayout.isDesktopPlatform
            ? BorderRadius.circular(AppRadius.xl)
            : const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
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
          PlaylistSheetAction(
            icon: Icons.edit_outlined,
            label: context.tr('common.rename'),
            onTap: onRename,
          ),
          const SizedBox(height: 4),
          PlaylistSheetAction(
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

class PlaylistRenameSheet extends StatefulWidget {
  final String initialName;
  final String? initialDescription;
  final String? initialImageUrl;
  final void Function(String name, String? description, String? imageUrl)
  onSave;

  const PlaylistRenameSheet({
    super.key,
    required this.initialName,
    required this.initialDescription,
    required this.initialImageUrl,
    required this.onSave,
  });

  @override
  State<PlaylistRenameSheet> createState() => PlaylistRenameSheetState();
}

class PlaylistRenameSheetState extends State<PlaylistRenameSheet> {
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
      decoration: BoxDecoration(
        color: AppBlur.sheetColor,
        borderRadius: AppLayout.isDesktopPlatform
            ? BorderRadius.circular(AppRadius.xl)
            : const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.xxl + bottomInset,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!AppLayout.isDesktopPlatform)
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
                  onPressed: () => AdaptivePresentation.close(context),
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.muted,
                  ),
                  padding: const EdgeInsets.all(AppSpacing.s),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              context.tr('playlist.name').toUpperCase(),
              style: AppText.label,
            ),
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
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.m + 2,
                  ),
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
      ),
    );
  }
}

class PlaylistAddTracksSheet extends StatelessWidget {
  const PlaylistAddTracksSheet({
    super.key,
    required this.allTracks,
    required this.onAdd,
  });

  final List<Track> allTracks;
  final ValueChanged<Track> onAdd;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistDetailBloc, PlaylistDetailState>(
      builder: (context, state) {
        final playlist = state is PlaylistDetailLoaded ? state.playlist : null;
        final tracks = playlist == null
            ? const <Track>[]
            : allTracks
                  .where((track) => !playlist.trackIds.contains(track.id))
                  .toList();

        return _buildSheet(context, tracks);
      },
    );
  }

  Widget _buildSheet(BuildContext context, List<Track> tracks) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      decoration: BoxDecoration(
        color: AppBlur.sheetColor,
        borderRadius: AppLayout.isDesktopPlatform
            ? BorderRadius.circular(AppRadius.xl)
            : const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        children: [
          if (!AppLayout.isDesktopPlatform)
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
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CachedImage(url: track.imageUrl, size: 40),
                      ),
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

class PlaylistSheetAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const PlaylistSheetAction({
    super.key,
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
