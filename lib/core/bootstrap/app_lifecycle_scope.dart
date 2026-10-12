import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:owlsonic/layers/presentation/features/player/bloc/player/player_bloc.dart';

class AppLifecycleScope extends StatefulWidget {
  const AppLifecycleScope({super.key, required this.child, this.onFirstFrame});

  final Widget child;
  final Future<void> Function()? onFirstFrame;

  @override
  State<AppLifecycleScope> createState() => _AppLifecycleScopeState();
}

class _AppLifecycleScopeState extends State<AppLifecycleScope>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_afterFirstFrame());
    });
  }

  Future<void> _afterFirstFrame() async {
    try {
      await widget.onFirstFrame?.call();
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        context.read<PlayerBloc>().add(PlayerSessionFlushRequested());
      case AppLifecycleState.resumed:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
