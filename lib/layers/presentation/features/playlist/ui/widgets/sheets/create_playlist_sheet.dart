import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/core/layout/app_layout.dart';
import 'package:owlsonic/core/utils/locale_keys.dart';
import 'package:owlsonic/layers/domain/entities/playlist.dart';
import 'package:owlsonic/layers/presentation/features/playlist/bloc/playlist/playlist_bloc.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/snackbars/custom_snack_bar.dart';
import 'package:uuid/uuid.dart';

Future<void> showCreatePlaylist(BuildContext context) {
  if (AppLayout.isDesktopPlatform) {
    return showDialog<void>(
      context: context,
      builder: (_) => const Dialog(
        backgroundColor: AppColors.surface,
        child: SizedBox(width: 420, child: CreatePlaylistSheet()),
      ),
    );
  }
  return showModalBottomSheet<void>(
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    context: context,
    builder: (_) => const CreatePlaylistSheet(),
  );
}

class CreatePlaylistSheet extends StatefulWidget {
  const CreatePlaylistSheet({super.key});

  @override
  State<CreatePlaylistSheet> createState() => _CreatePlaylistSheetState();
}

class _CreatePlaylistSheetState extends State<CreatePlaylistSheet> {
  final _nameCtrl = TextEditingController();
  bool _canCreate = false;
  bool _isSubmitting = false;
  String? _operationId;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _isSubmitting) return;
    // UUIDv7: also the OwlSonic playlist id, which the backend requires.
    final operationId = const Uuid().v7();
    setState(() {
      _isSubmitting = true;
      _operationId = operationId;
    });
    context.read<PlaylistBloc>().add(
      CreatePlaylistEvent(
        Playlist(
          id: operationId,
          name: name,
          trackIds: const [],
          imageUrl: null,
          createdAt: DateTime.now(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final desktop = AppLayout.isDesktopPlatform;

    return BlocListener<PlaylistBloc, PlaylistState>(
      listener: (context, state) {
        if (state is! PlaylistLoaded || _operationId == null) return;
        if (state.completedOperationId == _operationId) {
          Navigator.of(context).pop();
        } else if (state.failedOperationId == _operationId) {
          setState(() => _isSubmitting = false);
          if (state.error != null) {
            CustomSnackBar.uiError(context, state.error!);
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppBlur.sheetColor,
          borderRadius: desktop
              ? BorderRadius.circular(AppRadius.xl)
              : const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
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
            Row(
              children: [
                Text(
                  LocaleKeys.playlistCreateTitle.tr(),
                  style: AppText.display3,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
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
              controller: _nameCtrl,
              enabled: !_isSubmitting,
              autofocus: true,
              onChanged: (v) =>
                  setState(() => _canCreate = v.trim().isNotEmpty),
              onSubmitted: (_) => _submit(),
              style: AppText.display2,
              maxLength: 50,
              maxLines: 1,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: LocaleKeys.playlistCreateName.tr(),
                hintStyle: AppText.display2.copyWith(color: AppColors.muted2),
                counterText: '',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AnimatedOpacity(
              opacity: _canCreate && !_isSubmitting ? 1.0 : 0.35,
              duration: AppAnim.fast,
              child: GestureDetector(
                onTap: _canCreate && !_isSubmitting ? _submit : null,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.m + 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface3,
                    borderRadius: BorderRadius.circular(AppRadius.m),
                  ),
                  child: _isSubmitting
                      ? const Center(
                          child: SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 1.5),
                          ),
                        )
                      : Text(
                          LocaleKeys.playlistCreateButton.tr(),
                          style: AppText.bodyL.copyWith(
                            color: _canCreate
                                ? AppColors.text
                                : AppColors.muted,
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
