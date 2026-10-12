import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:owlsonic/core/app_router/app_router_names.dart';
import 'package:owlsonic/core/di/di.dart';
import 'package:owlsonic/core/layout/adaptive_presentation.dart';
import 'package:owlsonic/core/layout/app_layout.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/presentation/features/desktop_shell/ui/desktop_context_panel.dart';
import 'package:owlsonic/layers/presentation/features/desktop_shell/ui/desktop_drop_target.dart';
import 'package:owlsonic/layers/presentation/features/desktop_shell/ui/desktop_player_bar.dart';
import 'package:owlsonic/layers/presentation/features/desktop_shell/ui/desktop_sidebar.dart';
import 'package:owlsonic/layers/presentation/features/import_music/bloc/import_workspace/import_workspace_cubit.dart';
import 'package:owlsonic/layers/presentation/features/player/bloc/player/player_bloc.dart';
import 'package:owlsonic/layers/presentation/features/player/ui/player_screen.dart';
import 'package:owlsonic/layers/presentation/features/search/ui/search_screen.dart';
import 'package:owlsonic/layers/presentation/features/track/bloc/track/track_bloc.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/snackbars/custom_snack_bar.dart';

/// macOS / Windows / Linux shell:
/// `[ sidebar ][ content ][ optional context panel ]` over a player bar; the
/// sidebar (Cmd/Ctrl+B) and the context panel can both be hidden.
/// Chosen by platform, never by window width.
class DesktopShell extends StatelessWidget {
  const DesktopShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => BlocProvider<ImportWorkspaceCubit>(
    // Lives with the shell so a scan/import keeps running while the user
    // navigates, and drops anywhere in the window can feed it.
    create: (_) => getIt<ImportWorkspaceCubit>(),
    child: _DesktopShellBody(child: child),
  );
}

class _DesktopShellBody extends StatefulWidget {
  const _DesktopShellBody({required this.child});

  final Widget child;

  @override
  State<_DesktopShellBody> createState() => _DesktopShellBodyState();
}

class _DesktopShellBodyState extends State<_DesktopShellBody> {
  /// `null` = automatic (open on very wide windows while something plays).
  bool? _contextChoice;

  /// The left navigation column can be collapsed to give content the room.
  bool _sidebarHidden = false;

  bool get _isTyping {
    final focus = FocusManager.instance.primaryFocus?.context;
    return focus?.widget is EditableText ||
        focus?.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  bool _docked(double width, bool hasTrack) =>
      width >= AppLayout.contextPanelDockWidth &&
      (_contextChoice ??
          (width >= AppLayout.contextPanelAutoWidth && hasTrack));

  void _navigate(String name) {
    if (_isTyping) FocusManager.instance.primaryFocus?.unfocus();
    context.goNamed(name);
  }

  Future<void> _openSearch() async {
    final previousFocus = FocusManager.instance.primaryFocus;
    await AdaptivePresentation.showSurface<void>(
      context,
      maxWidth: 720,
      maxHeight: 720,
      builder: (_) => const SearchScreen(),
    );
    if (mounted) previousFocus?.requestFocus();
  }

  void _openPlayer() {
    final size = MediaQuery.sizeOf(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.surface,
        child: SizedBox(
          width: (size.width - 48).clamp(0.0, 900.0),
          height: (size.height - 48).clamp(0.0, 740.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: dialogContext.tr('common.close'),
                  onPressed: () => Navigator.pop(dialogContext),
                  icon: const Icon(Icons.close),
                ),
              ),
              const Expanded(child: PlayerScreen()),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleContext(double width, bool docked) {
    if (width >= AppLayout.contextPanelDockWidth) {
      setState(() => _contextChoice = !docked);
      return;
    }
    final height = MediaQuery.sizeOf(context).height;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.surface,
        child: SizedBox(
          width: AppLayout.contextPanelWidth,
          height: (height - 96).clamp(240.0, 640.0),
          child: DesktopContextPanel(
            onClose: () => Navigator.pop(dialogContext),
          ),
        ),
      ),
    );
  }

  void _toggleSidebar() => setState(() => _sidebarHidden = !_sidebarHidden);

  void _handleDrop(List<String> paths) {
    context.read<ImportWorkspaceCubit>().addPaths(paths);
    context.goNamed(AppRouterNames.importMusic);
  }

  /// Runs even if the user navigated away from Import while it was working.
  void _onImportFinished(BuildContext context, ImportWorkspaceState state) {
    final added = state.lastAddedCount;
    if (added == 0) return;
    // The library also refreshes from the DB change stream; this makes it
    // explicit so Home/Library/sidebar never lag behind a finished import.
    context.read<TrackBloc>().add(LoadTracksEvent());
    CustomSnackBar.success(
      context,
      added == 1
          ? context.tr('import.toastAddedOne')
          : context.tr('import.toastAdded', namedArgs: {'count': '$added'}),
    );
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final command =
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    if (!_isTyping && command && key == LogicalKeyboardKey.keyK) {
      _openSearch();
      return KeyEventResult.handled;
    }
    if (!_isTyping && command && key == LogicalKeyboardKey.keyB) {
      _toggleSidebar();
      return KeyEventResult.handled;
    }
    if (!_isTyping && command && key == LogicalKeyboardKey.keyO) {
      _navigate(AppRouterNames.importMusic);
      return KeyEventResult.handled;
    }
    if (!_isTyping && key == LogicalKeyboardKey.space) {
      context.read<PlayerBloc>().add(PlayerPlayPauseToggled());
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.mediaPlayPause) {
      context.read<PlayerBloc>().add(PlayerPlayPauseToggled());
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.mediaTrackNext) {
      context.read<PlayerBloc>().add(PlayerSkippedNext());
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.mediaTrackPrevious) {
      context.read<PlayerBloc>().add(PlayerSkippedPrevious());
      return KeyEventResult.handled;
    }
    if (!_isTyping && key == LogicalKeyboardKey.escape) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
        return KeyEventResult.handled;
      }
      if (_contextChoice != false) {
        setState(() => _contextChoice = false);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = AppLayout.isCompactDesktop(width);
    final hasTrack = context.select<PlayerBloc, bool>(
      (bloc) => bloc.state.currentTrack != null,
    );
    final docked = _docked(width, hasTrack);
    return BlocListener<ImportWorkspaceCubit, ImportWorkspaceState>(
      listenWhen: (previous, current) =>
          previous.completionSerial != current.completionSerial,
      listener: _onImportFinished,
      child: Focus(
        autofocus: true,
        onKeyEvent: _handleKey,
        child: Scaffold(
          backgroundColor: AppColors.bg,
          body: DesktopDropTarget(
            onPaths: _handleDrop,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      AnimatedSize(
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeOut,
                        alignment: Alignment.centerLeft,
                        child: _sidebarHidden
                            ? const SizedBox.shrink()
                            : DesktopSidebar(
                                compact: compact,
                                onSearch: _openSearch,
                              ),
                      ),
                      Expanded(child: widget.child),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeOut,
                        alignment: Alignment.centerRight,
                        child: docked
                            ? DesktopContextPanel(
                                onClose: () =>
                                    setState(() => _contextChoice = false),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                DesktopPlayerBar(
                  onOpenPlayer: _openPlayer,
                  onToggleContext: () => _toggleContext(width, docked),
                  contextOpen: docked,
                  onToggleSidebar: _toggleSidebar,
                  sidebarOpen: !_sidebarHidden,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
