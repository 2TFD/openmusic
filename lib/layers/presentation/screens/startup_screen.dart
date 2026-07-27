import 'package:flutter/material.dart';
import 'package:openmusic/core/themes/app_theme.dart';

class StartupScreen extends StatelessWidget {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.bg,
      child: Center(
        child: Semantics(
          label: 'OpenMusic',
          image: true,
          child: const SizedBox.square(
            dimension: 180,
            child: Image(
              image: AssetImage('assets/icon/icon.png'),
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
          ),
        ),
      ),
    );
  }
}
