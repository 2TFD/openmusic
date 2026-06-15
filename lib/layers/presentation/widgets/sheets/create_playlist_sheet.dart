import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openmusic/core/themes/app_theme.dart';
import 'package:openmusic/core/utils/locale_keys.dart';
import 'package:openmusic/layers/domain/entities/playlist.dart';
import 'package:openmusic/layers/presentation/blocs/playlist/playlist_bloc.dart';

class CreatePlaylistSheet extends StatefulWidget {
  const CreatePlaylistSheet({super.key});

  @override
  State<CreatePlaylistSheet> createState() => _CreatePlaylistSheetState();
}

class _CreatePlaylistSheetState extends State<CreatePlaylistSheet> {
  final _nameCtrl = TextEditingController();
  bool _canCreate = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    context.read<PlaylistBloc>().add(
      CreatePlaylisyEvent(
        Playlist(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          trackIds: const [],
          imageUrl: null,
          createdAt: DateTime.now(),
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppBlur.sheetColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
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
          Text('NAME', style: AppText.label),
          const SizedBox(height: AppSpacing.s),
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            onChanged: (v) => setState(() => _canCreate = v.trim().isNotEmpty),
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
            opacity: _canCreate ? 1.0 : 0.35,
            duration: AppAnim.fast,
            child: GestureDetector(
              onTap: _canCreate ? _submit : null,
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
                  LocaleKeys.playlistCreateButton.tr(),
                  style: AppText.bodyL.copyWith(
                    color: _canCreate ? AppColors.text : AppColors.muted,
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
