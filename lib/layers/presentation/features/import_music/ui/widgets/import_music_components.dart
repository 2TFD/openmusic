import 'package:easy_localization/easy_localization.dart';
import 'package:owlsonic/core/errors/failures/failure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/domain/entities/track_preview.dart';
import 'package:owlsonic/layers/presentation/features/import_music/bloc/import_music/import_music_cubit.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/cached_image.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/snackbars/custom_snack_bar.dart';

class ImportSectionHeader extends StatelessWidget {
  const ImportSectionHeader({super.key, required this.label, this.actionLabel});

  final String label;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label.toUpperCase(), style: AppText.label),
        if (actionLabel != null) ...[
          const Spacer(),
          Flexible(
            child: Text(
              actionLabel!,
              style: AppText.bodyXS,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ],
    );
  }
}

class ImportFilePanel extends StatelessWidget {
  const ImportFilePanel({
    super.key,
    required this.isLoading,
    required this.onTap,
  });

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ImportPanelBase(
      child: Row(
        children: [
          const ImportPanelIcon(icon: Icons.folder_open_rounded),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('import.fileAction'),
                  style: AppText.display3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('import.fileActionSub'),
                  style: AppText.bodyM,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ImportPrimaryIconButton(
            tooltip: context.tr('import.fileAction'),
            icon: Icons.add_rounded,
            isLoading: isLoading,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class ImportLinkPanel extends StatelessWidget {
  const ImportLinkPanel({
    super.key,
    required this.controller,
    required this.onPaste,
    required this.onAdd,
  });

  final TextEditingController controller;
  final VoidCallback onPaste;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return ImportPanelBase(
      child: Column(
        children: [
          Row(
            children: [
              const ImportPanelIcon(icon: Icons.link_rounded),
              const SizedBox(width: 14),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => onAdd(),
                  style: AppText.bodyL,
                  decoration: InputDecoration(
                    hintText: context.tr('import.linkHint'),
                    hintStyle: AppText.bodyM,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ImportSecondaryButton(
                  icon: Icons.content_paste_rounded,
                  label: context.tr('import.paste'),
                  onTap: onPaste,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ImportPrimaryTextButton(
                  icon: Icons.arrow_forward_rounded,
                  label: context.tr('import.addLink'),
                  onTap: onAdd,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ImportPanelBase extends StatelessWidget {
  const ImportPanelBase({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class ImportPanelIcon extends StatelessWidget {
  const ImportPanelIcon({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(icon, color: AppColors.text, size: 22),
    );
  }
}

class ImportPrimaryIconButton extends StatelessWidget {
  const ImportPrimaryIconButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.isLoading,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isLoading ? null : onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: isLoading
              ? const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.bg,
                    ),
                  ),
                )
              : Icon(icon, color: AppColors.bg, size: 24),
        ),
      ),
    );
  }
}

class ImportPrimaryTextButton extends StatelessWidget {
  const ImportPrimaryTextButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.bg, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: AppText.bodyL.copyWith(color: AppColors.bg),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImportSecondaryButton extends StatelessWidget {
  const ImportSecondaryButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.text, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: AppText.bodyL,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImportFilesSheet extends StatefulWidget {
  const ImportFilesSheet({super.key, required this.previews});

  final List<TrackPreview> previews;

  @override
  State<ImportFilesSheet> createState() => ImportFilesSheetState();
}

class ImportFilesSheetState extends State<ImportFilesSheet> {
  late final Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = widget.previews.map((preview) => preview.id).toSet();
  }

  List<TrackPreview> get _selectedPreviews {
    return widget.previews
        .where((preview) => _selectedIds.contains(preview.id))
        .toList();
  }

  void _importSelected() {
    final selected = _selectedPreviews;
    if (selected.isEmpty) return;
    context.read<ImportMusicCubit>().importLocalTracks(selected);
  }

  void _toggle(TrackPreview preview) {
    if (context.read<ImportMusicCubit>().state is LocalTracksImporting) return;

    setState(() {
      if (_selectedIds.contains(preview.id)) {
        _selectedIds.remove(preview.id);
      } else {
        _selectedIds.add(preview.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _selectedIds.length;
    final isImporting = context.select(
      (ImportMusicCubit cubit) => cubit.state is LocalTracksImporting,
    );

    return BlocListener<ImportMusicCubit, ImportMusicState>(
      listener: (context, state) {
        if (state case LocalTracksImported(:final result)) {
          final reason = result.failures.isEmpty
              ? null
              : context.tr(result.failures.first.toLocaleKey());
          if (result.failed == 0) {
            final added = context.tr(
              'import.filesAdded',
              namedArgs: {'count': result.added.toString()},
            );
            CustomSnackBar.success(
              context,
              result.localOnly
                  ? '$added · ${context.tr('cloud.storedOnDevice')}'
                  : added,
            );
          } else if (result.added > 0) {
            final partial = context.tr(
              'import.filesPartiallyAdded',
              namedArgs: {
                'added': result.added.toString(),
                'failed': result.failed.toString(),
              },
            );
            CustomSnackBar.warning(
              context,
              reason == null ? partial : '$partial — $reason',
            );
          } else {
            CustomSnackBar.error(
              context,
              reason ?? context.tr('import.filesAddFailed'),
            );
          }
          Navigator.pop(context);
        }
      },
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 14),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.muted2,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.tr('import.selectedFiles'),
                      style: AppText.display3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '$selectedCount/${widget.previews.length}',
                    style: AppText.bodyM,
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                itemCount: widget.previews.length,
                separatorBuilder: (_, _) => const Divider(
                  height: 1,
                  color: AppColors.border,
                  indent: 78,
                ),
                itemBuilder: (context, index) {
                  final preview = widget.previews[index];
                  return ImportFileRow(
                    preview: preview,
                    selected: _selectedIds.contains(preview.id),
                    onTap: () => _toggle(preview),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: ImportSelectedButton(
                count: selectedCount,
                isLoading: isImporting,
                onTap: selectedCount == 0 ? null : _importSelected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImportFileRow extends StatelessWidget {
  const ImportFileRow({
    super.key,
    required this.preview,
    required this.selected,
    required this.onTap,
  });

  final TrackPreview preview;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: selected,
                onChanged: (_) => onTap(),
                activeColor: AppColors.accent,
                checkColor: AppColors.bg,
                side: const BorderSide(color: AppColors.muted),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.hardEdge,
              child: preview.artworkUrl != null
                  ? CachedImage(filePath: preview.artworkUrl, size: 44)
                  : const Icon(Icons.music_note, color: AppColors.muted),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    preview.title,
                    style: AppText.bodyL,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    preview.artist,
                    style: AppText.bodyM,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatDuration(preview.duration),
              style: AppText.bodyXS,
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration? duration) {
    if (duration == null || duration == Duration.zero) return '--:--';

    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = duration.inHours;

    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }

    return '$minutes:$seconds';
  }
}

class ImportSelectedButton extends StatelessWidget {
  const ImportSelectedButton({
    super.key,
    required this.count,
    required this.isLoading,
    required this.onTap,
  });

  final int count;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !isLoading;

    return Tooltip(
      message: context.tr('import.addSelected'),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: AppAnim.fast,
          height: 52,
          decoration: BoxDecoration(
            color: enabled ? AppColors.accent : AppColors.surface3,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.bg,
                    ),
                  )
                : Text(
                    context.tr(
                      'import.addSelectedCount',
                      namedArgs: {'count': count.toString()},
                    ),
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: enabled ? AppColors.bg : AppColors.muted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ),
      ),
    );
  }
}
