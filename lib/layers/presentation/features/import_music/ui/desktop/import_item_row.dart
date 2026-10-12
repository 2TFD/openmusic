import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:owlsonic/core/errors/failures/failure.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/domain/entities/import_candidate.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/cached_image.dart';

const _warning = Color(0xFFFBBF24);
const _danger = Color(0xFFFF6B6B);

/// Human-readable reason for an item, or null when there is nothing to explain.
String? importItemReason(BuildContext context, ImportCandidate item) {
  switch (item.status) {
    case ImportItemStatus.duplicate:
      return context.tr(
        item.duplicateOfTrackId == null
            ? 'import.duplicateInBatch'
            : 'import.duplicateOf',
        namedArgs: {'title': item.duplicateOfTitle ?? item.fileName},
      );
    case ImportItemStatus.invalid:
    case ImportItemStatus.failed:
      final failure = item.failure;
      if (failure == null) return null;
      final reason = context.tr(failure.toLocaleKey());
      // The backend request id lets support find this exact upload.
      final requestId = failure is CloudUploadFailure
          ? failure.requestId
          : null;
      return requestId == null ? reason : '$reason (ref $requestId)';
    case _:
      return null;
  }
}

class ImportItemRow extends StatelessWidget {
  const ImportItemRow({
    super.key,
    required this.item,
    required this.selected,
    required this.selectable,
    required this.showArtist,
    this.onToggle,
    this.onRetry,
    this.onRemove,
  });

  static const double height = 56;

  final ImportCandidate item;
  final bool selected;

  /// Whether the leading checkbox is shown (review phase, ready items).
  final bool selectable;
  final bool showArtist;
  final VoidCallback? onToggle;
  final VoidCallback? onRetry;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final reason = importItemReason(context, item);
    final reasonColor = switch (item.status) {
      ImportItemStatus.duplicate => _warning,
      ImportItemStatus.invalid || ImportItemStatus.failed => _danger,
      _ => AppColors.textSub,
    };
    return SizedBox(
      height: height,
      child: InkWell(
        onTap: selectable && item.canImport ? onToggle : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: selectable && item.canImport
                    ? Checkbox(
                        value: selected,
                        onChanged: (_) => onToggle?.call(),
                        visualDensity: VisualDensity.compact,
                      )
                    : _LeadingIcon(status: item.status),
              ),
              const SizedBox(width: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox.square(
                  dimension: 38,
                  child: ColoredBox(
                    color: AppColors.surface2,
                    child: CachedImage(
                      url: item.preview?.artworkUrl,
                      size: 38,
                      fallback: const Icon(
                        Icons.music_note_rounded,
                        size: 16,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodyL,
                    ),
                    if (reason != null)
                      Text(
                        reason,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.bodyXS.copyWith(color: reasonColor),
                      )
                    else if (!showArtist && item.artist.isNotEmpty)
                      Text(
                        item.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.bodyXS,
                      ),
                  ],
                ),
              ),
              if (showArtist)
                Expanded(
                  flex: 3,
                  child: Text(
                    item.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodyM,
                  ),
                ),
              SizedBox(
                width: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (item.status == ImportItemStatus.failed &&
                        onRetry != null)
                      TextButton(
                        onPressed: onRetry,
                        child: Text(context.tr('common.retry')),
                      ),
                    if (onRemove != null)
                      IconButton(
                        tooltip: context.tr('import.remove'),
                        visualDensity: VisualDensity.compact,
                        onPressed: onRemove,
                        icon: const Icon(Icons.close, size: 16),
                      ),
                    Flexible(child: ImportStatusLabel(status: item.status)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({required this.status});

  final ImportItemStatus status;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (status) {
      ImportItemStatus.duplicate => (Icons.error_outline_rounded, _warning),
      ImportItemStatus.invalid => (Icons.close_rounded, _danger),
      ImportItemStatus.failed => (Icons.close_rounded, _danger),
      ImportItemStatus.imported => (Icons.check_rounded, AppColors.success),
      _ => (Icons.circle_outlined, AppColors.muted),
    };
    return Icon(icon, size: 18, color: color);
  }
}

class ImportStatusLabel extends StatelessWidget {
  const ImportStatusLabel({super.key, required this.status});

  final ImportItemStatus status;

  @override
  Widget build(BuildContext context) {
    final busy =
        status == ImportItemStatus.scanning ||
        status == ImportItemStatus.importing;
    final color = switch (status) {
      ImportItemStatus.ready => AppColors.textSub,
      ImportItemStatus.duplicate => _warning,
      ImportItemStatus.invalid || ImportItemStatus.failed => _danger,
      ImportItemStatus.imported => AppColors.success,
      _ => AppColors.textSub,
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (busy) ...[
          const SizedBox.square(
            dimension: 12,
            child: CircularProgressIndicator(strokeWidth: 1.5),
          ),
          const SizedBox(width: 6),
        ],
        Text(
          context.tr('import.status.${status.name}'),
          style: AppText.bodyS.copyWith(color: color),
        ),
      ],
    );
  }
}
