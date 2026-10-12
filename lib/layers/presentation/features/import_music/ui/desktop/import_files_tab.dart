import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/presentation/features/import_music/bloc/import_workspace/import_workspace_cubit.dart';
import 'package:owlsonic/layers/presentation/features/import_music/ui/desktop/import_item_row.dart';
import 'package:owlsonic/layers/presentation/shared/models/ui_error_localization.dart';

/// FILES mode: drop zone -> review list -> progress -> completion summary.
class ImportFilesTab extends StatelessWidget {
  const ImportFilesTab({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ImportWorkspaceCubit, ImportWorkspaceState>(
        builder: (context, state) {
          final cubit = context.read<ImportWorkspaceCubit>();
          final hasItems = state.items.isNotEmpty;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ImportDropZone(compact: hasItems, busy: state.busy),
              if (state.error != null)
                _Notice(
                  message: state.error!.localized(context),
                  onDismiss: cubit.dismissError,
                ),
              if (state.folderEmpty)
                _Notice(
                  message: context.tr('import.folderEmpty'),
                  onDismiss: cubit.dismissError,
                ),
              if (hasItems) ...[
                const SizedBox(height: 20),
                _StatusHeader(state: state),
                const SizedBox(height: 8),
                Expanded(child: _ReviewList(state: state)),
                const SizedBox(height: 12),
                _Footer(state: state),
              ] else ...[
                const SizedBox(height: 16),
                Text(
                  context.tr('import.duplicatePolicy'),
                  textAlign: TextAlign.center,
                  style: AppText.bodyXS,
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('import.backgroundNote'),
                  textAlign: TextAlign.center,
                  style: AppText.bodyXS,
                ),
                const Spacer(),
              ],
            ],
          );
        },
      );
}

class ImportDropZone extends StatelessWidget {
  const ImportDropZone({super.key, required this.compact, required this.busy});

  final bool compact;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ImportWorkspaceCubit>();
    final actions = Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        FilledButton(
          onPressed: busy ? null : cubit.pickFiles,
          child: Text(context.tr('import.chooseFiles')),
        ),
        OutlinedButton(
          onPressed: busy ? null : cubit.pickFolder,
          child: Text(context.tr('import.chooseFolder')),
        ),
      ],
    );
    return Container(
      constraints: BoxConstraints(minHeight: compact ? 0 : 300),
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: compact ? 14 : 36,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.borderAct),
      ),
      child: compact
          ? Row(
              children: [
                const Icon(
                  Icons.library_music_outlined,
                  size: 20,
                  color: AppColors.textSub,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.tr('import.dropTitle'),
                    style: AppText.bodyL,
                  ),
                ),
                actions,
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.library_music_outlined,
                  size: 34,
                  color: AppColors.textSub,
                ),
                const SizedBox(height: 16),
                Text(context.tr('import.dropTitle'), style: AppText.display3),
                const SizedBox(height: 6),
                Text(context.tr('import.formats'), style: AppText.bodyXS),
                const SizedBox(height: 24),
                actions,
              ],
            ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Row(
      children: [
        const Icon(
          Icons.error_outline_rounded,
          size: 16,
          color: Color(0xFFFF6B6B),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: AppText.bodyM.copyWith(color: const Color(0xFFFF6B6B)),
          ),
        ),
        IconButton(
          tooltip: context.tr('common.close'),
          visualDensity: VisualDensity.compact,
          onPressed: onDismiss,
          icon: const Icon(Icons.close, size: 16),
        ),
      ],
    ),
  );
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.state});

  final ImportWorkspaceState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ImportWorkspaceCubit>();
    switch (state.phase) {
      case ImportPhase.scanning:
        return _Progress(
          label: context.tr(
            'import.scanningProgress',
            namedArgs: {
              'done': '${state.scannedCount}',
              'total': '${state.scanTotal}',
            },
          ),
          value: state.scanTotal == 0
              ? null
              : state.scannedCount / state.scanTotal,
        );
      case ImportPhase.importing:
        return _Progress(
          label: context.tr(
            'import.importingProgress',
            namedArgs: {
              'current':
                  '${(state.importDone + 1).clamp(1, state.importTotal)}',
              'total': '${state.importTotal}',
            },
          ),
          value: state.importTotal == 0
              ? null
              : state.importDone / state.importTotal,
          action: TextButton(
            onPressed: cubit.cancelImport,
            child: Text(context.tr('import.stop')),
          ),
        );
      case ImportPhase.done:
        return _Summary(state: state);
      case ImportPhase.idle:
      case ImportPhase.review:
        return Row(
          children: [
            Expanded(
              child: Text(
                context.tr('import.readyToImport').toUpperCase(),
                style: AppText.label,
              ),
            ),
            if (state.hasImportable)
              TextButton(
                onPressed: () =>
                    cubit.setAllSelected(state.selectedReadyCount == 0),
                child: Text(
                  state.selectedReadyCount == 0
                      ? context.tr('import.selectAll')
                      : context.tr('common.clear'),
                ),
              ),
          ],
        );
    }
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.label, required this.value, this.action});

  final String label;
  final double? value;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(child: Text(label, style: AppText.bodyL)),
          ?action,
        ],
      ),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value: value,
          minHeight: 3,
          backgroundColor: AppColors.border,
          color: AppColors.textSub,
        ),
      ),
    ],
  );
}

class _Summary extends StatelessWidget {
  const _Summary({required this.state});

  final ImportWorkspaceState state;

  @override
  Widget build(BuildContext context) {
    final parts = <(String, Color)>[
      if (state.importedCount > 0)
        (
          context.tr(
            'import.summaryImported',
            namedArgs: {'count': '${state.importedCount}'},
          ),
          AppColors.success,
        ),
      if (state.duplicateCount > 0)
        (
          context.tr(
            'import.summaryDuplicates',
            namedArgs: {'count': '${state.duplicateCount}'},
          ),
          const Color(0xFFFBBF24),
        ),
      if (state.invalidCount > 0)
        (
          context.tr(
            'import.summaryInvalid',
            namedArgs: {'count': '${state.invalidCount}'},
          ),
          const Color(0xFFFF6B6B),
        ),
      if (state.failedCount > 0)
        (
          context.tr(
            'import.summaryFailed',
            namedArgs: {'count': '${state.failedCount}'},
          ),
          const Color(0xFFFF6B6B),
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 20,
          runSpacing: 4,
          children: [
            for (final (text, color) in parts)
              Text(text, style: AppText.display3.copyWith(color: color)),
          ],
        ),
        if (state.importedCount > 0) ...[
          const SizedBox(height: 4),
          Text(context.tr('import.backgroundNote'), style: AppText.bodyXS),
        ],
      ],
    );
  }
}

class _ReviewList extends StatelessWidget {
  const _ReviewList({required this.state});

  final ImportWorkspaceState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ImportWorkspaceCubit>();
    final review = state.phase == ImportPhase.review;
    final showArtist = MediaQuery.sizeOf(context).width >= 1000;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.l),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.l),
        child: ListView.builder(
          itemCount: state.items.length,
          itemExtent: ImportItemRow.height,
          itemBuilder: (context, index) {
            final item = state.items[index];
            return ImportItemRow(
              key: ValueKey(item.path),
              item: item,
              selected: state.selected.contains(item.path),
              selectable: review,
              showArtist: showArtist,
              onToggle: () => cubit.toggle(item.path),
              onRetry: state.phase == ImportPhase.importing
                  ? null
                  : () => cubit.retryItem(item.path),
              onRemove: review ? () => cubit.remove(item.path) : null,
            );
          },
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.state});

  final ImportWorkspaceState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ImportWorkspaceCubit>();
    switch (state.phase) {
      case ImportPhase.review:
        final count = state.selectedReadyCount;
        return Row(
          children: [
            Expanded(
              child: Text(
                context.tr('import.duplicatePolicy'),
                style: AppText.bodyXS,
              ),
            ),
            TextButton(
              onPressed: cubit.reset,
              child: Text(context.tr('import.clear')),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: count == 0 ? null : cubit.startImport,
              child: Text(
                count == 0
                    ? context.tr('import.importNone')
                    : count == 1
                    ? context.tr('import.importOne')
                    : context.tr(
                        'import.importCount',
                        namedArgs: {'count': '$count'},
                      ),
              ),
            ),
          ],
        );
      case ImportPhase.done:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (state.failedCount > 0) ...[
              OutlinedButton(
                onPressed: cubit.retryFailed,
                child: Text(context.tr('import.retryFailed')),
              ),
              const SizedBox(width: 8),
            ],
            FilledButton(
              onPressed: cubit.reset,
              child: Text(context.tr('import.importMore')),
            ),
          ],
        );
      case ImportPhase.idle:
      case ImportPhase.scanning:
      case ImportPhase.importing:
        return const SizedBox(height: 36);
    }
  }
}
