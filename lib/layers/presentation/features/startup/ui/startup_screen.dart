import 'package:flutter/material.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/owlsonic_logo.dart';

class StartupScreen extends StatelessWidget {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.bg,
      child: Center(child: OwlSonicLogo(width: 196)),
    );
  }
}
