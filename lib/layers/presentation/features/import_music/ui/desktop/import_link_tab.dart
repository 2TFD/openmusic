import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:owlsonic/layers/presentation/features/import_music/ui/widgets/import_rights_notice.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/domain/entities/resolved_track_input.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/entities/track_preview.dart';
import 'package:owlsonic/layers/presentation/features/track/bloc/add_track/add_track_bloc.dart';
import 'package:owlsonic/layers/presentation/shared/models/ui_error_localization.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/cached_image.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/snackbars/custom_snack_bar.dart';

/// LINK mode: paste -> preview (inline, bounded) -> add. Reuses AddTrackBloc.
class ImportLinkTab extends StatefulWidget {
  const ImportLinkTab({super.key});

  @override
  State<ImportLinkTab> createState() => _ImportLinkTabState();
}

class _ImportLinkTabState extends State<ImportLinkTab> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // A previous mobile-style flow may have left a stale result behind.
    context.read<AddTrackBloc>().add(const ResetAddTrack());
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _preview() {
    final url = _controller.text.trim();
    if (url.isEmpty) return;
    final bloc = context.read<AddTrackBloc>();
    bloc
      ..add(const ResetAddTrack())
      ..add(FetchTrackPreview(url));
  }

  void _onState(BuildContext context, AddTrackState state) {
    if (state is! AddTrackSuccess) return;
    final result = state.result;
    final added = result.addedTracks
        .where((t) => !result.existingTrackIds.contains(t.id))
        .length;
    if (result.playlistFailure != null) {
      CustomSnackBar.warning(
        context,
        context.tr('import.collectionPlaylistFailed'),
      );
    } else if (added == 0) {
      CustomSnackBar.info(
        context,
        context.tr(
          'import.duplicateOf',
          namedArgs: {'title': state.track.title},
        ),
      );
    } else if (added == 1 && state.resolved.collection == null) {
      CustomSnackBar.trackAdded(context, state.track.title);
    } else {
      CustomSnackBar.success(
        context,
        context.tr('import.toastAdded', namedArgs: {'count': '$added'}),
      );
    }
    _controller.clear();
    context.read<AddTrackBloc>().add(const ResetAddTrack());
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<AddTrackBloc, AddTrackState>(
        listener: _onState,
        builder: (context, state) {
          final lookingUp = state is AddTrackPreviewLoading;
          final adding = state is AddTrackLoading;
          return ListView(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !adding,
                      onSubmitted: (_) => _preview(),
                      decoration: InputDecoration(
                        hintText: context.tr('import.linkPlaceholder'),
                        prefixIcon: const Icon(Icons.link_rounded, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed:
                        lookingUp || adding || _controller.text.trim().isEmpty
                        ? null
                        : _preview,
                    child: Text(context.tr('import.preview')),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const ImportRightsNotice(),
              const SizedBox(height: 20),
              if (lookingUp)
                _Message(loading: true, title: context.tr('import.lookingUp'))
              else if (state is AddTrackPreviewLoaded)
                _PreviewCard(
                  resolved: state.resolved,
                  adding: false,
                  onCancel: () =>
                      context.read<AddTrackBloc>().add(const ResetAddTrack()),
                  onAdd: () => context.read<AddTrackBloc>().add(
                    AddTrackToLibrary(state.resolved),
                  ),
                )
              else if (state is AddTrackLoading)
                _PreviewCard(
                  resolved: state.resolved,
                  adding: true,
                  onCancel: null,
                  onAdd: null,
                )
              else if (state is AddTrackError)
                _Message(
                  title: context.tr('import.linkFailed'),
                  detail: state.error.localized(context),
                  isError: true,
                  action: OutlinedButton(
                    onPressed: _preview,
                    child: Text(context.tr('common.retry')),
                  ),
                ),
            ],
          );
        },
      );
}

class _Message extends StatelessWidget {
  const _Message({
    required this.title,
    this.detail,
    this.loading = false,
    this.isError = false,
    this.action,
  });

  final String title;
  final String? detail;
  final bool loading;
  final bool isError;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.l),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        if (loading)
          const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          Icon(
            isError ? Icons.error_outline_rounded : Icons.info_outline_rounded,
            size: 20,
            color: isError ? const Color(0xFFFF6B6B) : AppColors.textSub,
          ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.bodyL),
              if (detail != null) ...[
                const SizedBox(height: 2),
                Text(detail!, style: AppText.bodyM),
              ],
            ],
          ),
        ),
        ?action,
      ],
    ),
  );
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.resolved,
    required this.adding,
    required this.onCancel,
    required this.onAdd,
  });

  final ResolvedTrackInput resolved;
  final bool adding;
  final VoidCallback? onCancel;
  final VoidCallback? onAdd;

  static String _source(SourceType type) => switch (type) {
    SourceType.youtube => 'YouTube',
    SourceType.soundcloud => 'SoundCloud',
    SourceType.spotify => 'Spotify',
    SourceType.localFile => 'Local file',
    SourceType.owlsonic => 'OwlSonic',
    SourceType.unknown => '',
  };

  static String _duration(Duration value) =>
      '${value.inMinutes}:${value.inSeconds.remainder(60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final TrackPreview preview = resolved.firstTrack;
    final collection = resolved.collection;
    final meta = [
      if (collection != null)
        context.tr(
          'import.linkTracks',
          namedArgs: {'count': '${resolved.tracks.length}'},
        )
      else ...[
        if (preview.album != null && preview.album!.isNotEmpty) preview.album!,
        if (preview.duration != null && preview.duration! > Duration.zero)
          _duration(preview.duration!),
      ],
      _source(preview.source),
    ].where((part) => part.isNotEmpty).join(' · ');
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.l),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.s),
                  child: SizedBox.square(
                    dimension: 96,
                    child: ColoredBox(
                      color: AppColors.surface2,
                      child: CachedImage(
                        url: collection?.imageUrl ?? preview.artworkUrl,
                        size: 96,
                        fallback: const Icon(
                          Icons.music_note_rounded,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        collection?.name ?? preview.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.display3,
                      ),
                      if (collection == null) ...[
                        const SizedBox(height: 4),
                        Text(
                          preview.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.bodyM,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(meta, style: AppText.bodyXS),
                      if (resolved.issues.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          context.tr(
                            'import.collectionPreview',
                            namedArgs: {
                              'ready': '${resolved.tracks.length}',
                              'skipped': '${resolved.issues.length}',
                            },
                          ),
                          style: AppText.bodyXS,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onCancel,
                  child: Text(context.tr('common.cancel')),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: onAdd,
                  child: adding
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(context.tr('import.addToLibrary')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
