import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/cloud_session_cubit.dart';

/// Where a link import ends up and whose rights it needs, shown next to the
/// link field. It informs; it is not a licence from YouTube, SoundCloud or
/// Spotify.
class ImportRightsNotice extends StatelessWidget {
  const ImportRightsNotice({super.key});

  @override
  Widget build(BuildContext context) {
    var cloud = false;
    try {
      final session = context.watch<CloudSessionCubit>().state;
      cloud = session.configured && session.signedIn;
    } catch (_) {
      // No session above this widget (e.g. an isolated screen): local wording.
    }
    final storage = cloud
        ? 'import.linkStorageCloud'
        : 'import.linkStorageLocal';
    return Row(
      key: const ValueKey('import-rights-notice'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.info_outline_rounded,
          size: 16,
          color: AppColors.textSub,
        ),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: Text(
            '${context.tr(storage)} ${context.tr('import.linkRights')}',
            style: AppText.bodyM.copyWith(fontSize: 12),
          ),
        ),
      ],
    );
  }
}
