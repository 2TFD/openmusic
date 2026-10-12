import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/core/layout/app_layout.dart';
import 'package:owlsonic/core/layout/adaptive_presentation.dart';
import 'package:owlsonic/layers/presentation/features/track/bloc/add_track/add_track_bloc.dart';
import 'package:owlsonic/layers/presentation/features/import_music/bloc/import_music/import_music_cubit.dart';
import 'package:owlsonic/layers/presentation/features/track/ui/widgets/add_track_sheet.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/snackbars/custom_snack_bar.dart';
import 'package:owlsonic/layers/presentation/features/import_music/ui/desktop/desktop_import_workspace.dart';
import 'package:owlsonic/layers/presentation/features/import_music/ui/widgets/import_music_components.dart';

class ImportMusicScreen extends StatefulWidget {
  const ImportMusicScreen({super.key});

  @override
  State<ImportMusicScreen> createState() => _ImportMusicScreenState();
}

class _ImportMusicScreenState extends State<ImportMusicScreen> {
  final _linkController = TextEditingController();

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  void _openAddLocalFile() =>
      context.read<ImportMusicCubit>().pickLocalTracks();

  void _onImportState(BuildContext context, ImportMusicState state) {
    switch (state) {
      case LocalTracksPicked(:final previews):
        final cubit = context.read<ImportMusicCubit>();
        showModalBottomSheet<void>(
          context: context,
          useRootNavigator: true,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => BlocProvider.value(
            value: cubit,
            child: ImportFilesSheet(previews: previews),
          ),
        );
      case LocalTracksSelectionEmpty():
        CustomSnackBar.info(context, context.tr('import.noFilesSelected'));
      case LocalTracksPickFailure():
        CustomSnackBar.uiError(context, state.error);
      default:
        break;
    }
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

    AdaptivePresentation.showSurface<void>(
      context,
      maxWidth: 540,
      maxHeight: 560,
      builder: (_) => AddTrackSheet(url: url),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Desktop has its own workspace; this screen is the iOS/Android layout.
    if (AppLayout.isDesktopPlatform) return const DesktopImportWorkspace();
    return BlocConsumer<ImportMusicCubit, ImportMusicState>(
      listener: _onImportState,
      builder: (context, state) => Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          title: Text(context.tr('import.title')),
          backgroundColor: AppColors.bg,
          elevation: 0,
        ),
        body: SafeArea(
          child: Center(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                ImportSectionHeader(
                  label: context.tr('import.filesTitle'),
                  actionLabel: context.tr('import.fileFormats'),
                ),
                const SizedBox(height: 10),
                ImportFilePanel(
                  isLoading: state is LocalTracksPicking,
                  onTap: _openAddLocalFile,
                ),
                const SizedBox(height: 28),
                ImportSectionHeader(label: context.tr('import.linkTitle')),
                const SizedBox(height: 10),
                ImportLinkPanel(
                  controller: _linkController,
                  onPaste: _pasteLink,
                  onAdd: _openLinkPreview,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
