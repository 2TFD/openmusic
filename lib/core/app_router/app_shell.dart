import 'package:flutter/material.dart';
import 'package:openmusic/layers/presentation/widgets/clipboard_detector.dart';
import 'package:openmusic/layers/presentation/widgets/mini_player_bar.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return ClipboardDetector(
      child: Scaffold(
        body: Stack(
          children: [
            child,
            const Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: MiniPlayerBar(),
            ),
          ],
        ),
      ),
    );
  }
}
