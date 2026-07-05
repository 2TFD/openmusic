import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openmusic/core/di/di.dart';
import 'package:openmusic/core/themes/app_theme.dart';
import 'package:openmusic/layers/data/datasources/remote/local_file_track_source.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';
import 'package:openmusic/layers/domain/usecases/add_track_use_case.dart';
import 'package:openmusic/layers/presentation/blocs/add_track/add_track_bloc.dart';
import 'package:openmusic/layers/presentation/widgets/add_track_sheet.dart';
import 'package:openmusic/layers/presentation/widgets/cached_image.dart';
import 'package:openmusic/layers/presentation/widgets/snackbars/custom_snack_bar.dart';

class ImportMusicScreen extends StatefulWidget {
  const ImportMusicScreen({super.key});

  @override
  State<ImportMusicScreen> createState() => _ImportMusicScreenState();
}

class _ImportMusicScreenState extends State<ImportMusicScreen> {
  final _linkController = TextEditingController();
  bool _isPickingFiles = false;

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _openAddLocalFile() async {
    if (_isPickingFiles) return;

    setState(() => _isPickingFiles = true);
    try {
      final previews = await LocalFileTrackSource.pickFiles();
      if (!mounted) return;

      if (previews.isEmpty) {
        CustomSnackBar.info(context, context.tr('import.noFilesSelected'));
        return;
      }

      await showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => _ImportFilesSheet(
          previews: previews,
          onImport: _importLocalPreviews,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      CustomSnackBar.error(context, context.tr('import.filePickError'));
    } finally {
      if (mounted) setState(() => _isPickingFiles = false);
    }
  }

  Future<_ImportResult> _importLocalPreviews(
    List<TrackPreview> previews,
  ) async {
    final addTrack = getIt<AddTrackUseCase>();
    var added = 0;
    var failed = 0;

    for (final preview in previews) {
      try {
        await addTrack.execute(preview.originalUrl);
        added++;
      } catch (_) {
        failed++;
      }
    }

    return _ImportResult(added: added, failed: failed);
  }

  Future<void> _pasteLink() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();

    if (text == null || text.isEmpty) {
      if (!mounted) return;
      CustomSnackBar.info(context, context.tr('import.clipboardEmpty'));
      return;
    }

    _linkController.text = text;
    _linkController.selection = TextSelection.collapsed(offset: text.length);
  }

  void _openLinkPreview() {
    final url = _linkController.text.trim();
    if (url.isEmpty) {
      CustomSnackBar.warning(context, context.tr('import.linkRequired'));
      return;
    }

    FocusScope.of(context).unfocus();
    final bloc = context.read<AddTrackBloc>();
    bloc.add(const ResetAddTrack());
    bloc.add(FetchTrackPreview(url));

    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AddTrackSheet(url: url),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(context.tr('import.title')),
        backgroundColor: AppColors.bg,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            _SectionHeader(
              label: context.tr('import.filesTitle'),
              actionLabel: context.tr('import.fileFormats'),
            ),
            const SizedBox(height: 10),
            _FileImportPanel(
              isLoading: _isPickingFiles,
              onTap: _openAddLocalFile,
            ),
            const SizedBox(height: 28),
            _SectionHeader(label: context.tr('import.linkTitle')),
            const SizedBox(height: 10),
            _LinkImportPanel(
              controller: _linkController,
              onPaste: _pasteLink,
              onAdd: _openLinkPreview,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, this.actionLabel});

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

class _FileImportPanel extends StatelessWidget {
  const _FileImportPanel({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _ImportPanel(
      child: Row(
        children: [
          const _PanelIcon(icon: Icons.folder_open_rounded),
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
          _PrimaryIconButton(
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

class _LinkImportPanel extends StatelessWidget {
  const _LinkImportPanel({
    required this.controller,
    required this.onPaste,
    required this.onAdd,
  });

  final TextEditingController controller;
  final VoidCallback onPaste;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return _ImportPanel(
      child: Column(
        children: [
          Row(
            children: [
              const _PanelIcon(icon: Icons.link_rounded),
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
                child: _SecondaryButton(
                  icon: Icons.content_paste_rounded,
                  label: context.tr('import.paste'),
                  onTap: onPaste,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PrimaryTextButton(
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

class _ImportPanel extends StatelessWidget {
  const _ImportPanel({required this.child});

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

class _PanelIcon extends StatelessWidget {
  const _PanelIcon({required this.icon});

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

class _PrimaryIconButton extends StatelessWidget {
  const _PrimaryIconButton({
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

class _PrimaryTextButton extends StatelessWidget {
  const _PrimaryTextButton({
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

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
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

class _ImportFilesSheet extends StatefulWidget {
  const _ImportFilesSheet({required this.previews, required this.onImport});

  final List<TrackPreview> previews;
  final Future<_ImportResult> Function(List<TrackPreview> previews) onImport;

  @override
  State<_ImportFilesSheet> createState() => _ImportFilesSheetState();
}

class _ImportFilesSheetState extends State<_ImportFilesSheet> {
  late final Set<String> _selectedIds;
  bool _isImporting = false;

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

  Future<void> _importSelected() async {
    final selected = _selectedPreviews;
    if (selected.isEmpty || _isImporting) return;

    setState(() => _isImporting = true);
    final result = await widget.onImport(selected);

    if (!mounted) return;

    if (result.failed == 0) {
      CustomSnackBar.success(
        context,
        context.tr(
          'import.filesAdded',
          namedArgs: {'count': result.added.toString()},
        ),
      );
    } else if (result.added > 0) {
      CustomSnackBar.warning(
        context,
        context.tr(
          'import.filesPartiallyAdded',
          namedArgs: {
            'added': result.added.toString(),
            'failed': result.failed.toString(),
          },
        ),
      );
    } else {
      CustomSnackBar.error(context, context.tr('import.filesAddFailed'));
    }

    Navigator.pop(context);
  }

  void _toggle(TrackPreview preview) {
    if (_isImporting) return;

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

    return Container(
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
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: AppColors.border, indent: 78),
              itemBuilder: (context, index) {
                final preview = widget.previews[index];
                return _ImportFileRow(
                  preview: preview,
                  selected: _selectedIds.contains(preview.id),
                  onTap: () => _toggle(preview),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: _ImportSelectedButton(
              count: selectedCount,
              isLoading: _isImporting,
              onTap: selectedCount == 0 ? null : _importSelected,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImportFileRow extends StatelessWidget {
  const _ImportFileRow({
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

class _ImportSelectedButton extends StatelessWidget {
  const _ImportSelectedButton({
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

class _ImportResult {
  const _ImportResult({required this.added, required this.failed});

  final int added;
  final int failed;
}
