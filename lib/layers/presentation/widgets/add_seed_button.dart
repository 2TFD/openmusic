import 'package:flutter/material.dart';
import 'package:openmusic/core/themes/app_theme.dart';

class AddSeedButton extends StatelessWidget {
  final VoidCallback onTap;
  const AddSeedButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.muted2, style: BorderStyle.solid),
        ),
        child: const Center(child: Icon(Icons.add, color: AppColors.muted)),
      ),
    );
  }
}
