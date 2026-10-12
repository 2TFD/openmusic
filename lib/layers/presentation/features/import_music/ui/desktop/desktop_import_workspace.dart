import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:owlsonic/core/layout/app_layout.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/presentation/features/import_music/ui/desktop/import_files_tab.dart';
import 'package:owlsonic/layers/presentation/features/import_music/ui/desktop/import_link_tab.dart';

/// Desktop Import Music screen: FILES and LINK are separate modes, and
/// progress / results stay on the page instead of in sheets or snackbars.
class DesktopImportWorkspace extends StatefulWidget {
  const DesktopImportWorkspace({super.key});

  @override
  State<DesktopImportWorkspace> createState() => _DesktopImportWorkspaceState();
}

class _DesktopImportWorkspaceState extends State<DesktopImportWorkspace> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pad = AppLayout.desktopPaddingFor(MediaQuery.sizeOf(context).width);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Padding(
              padding: EdgeInsets.fromLTRB(pad, 24, pad, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(context.tr('import.title'), style: AppText.display2),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _TabButton(
                        label: context.tr('import.tabFiles'),
                        selected: _tab == 0,
                        onTap: () => setState(() => _tab = 0),
                      ),
                      const SizedBox(width: 8),
                      _TabButton(
                        label: context.tr('import.tabLink'),
                        selected: _tab == 1,
                        onTap: () => setState(() => _tab = 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _tab == 0
                        ? const ImportFilesTab()
                        : const ImportLinkTab(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? AppColors.surface2 : Colors.transparent,
    shape: StadiumBorder(
      side: BorderSide(
        color: selected ? AppColors.borderAct : AppColors.border,
      ),
    ),
    child: InkWell(
      customBorder: const StadiumBorder(),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Text(
          label,
          style: AppText.bodyL.copyWith(
            color: selected ? AppColors.text : AppColors.textSub,
          ),
        ),
      ),
    ),
  );
}
