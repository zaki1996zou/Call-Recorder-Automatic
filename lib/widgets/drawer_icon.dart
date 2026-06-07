import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Branded circular icon used in the settings drawer.
class DrawerBrandIcon extends StatelessWidget {
  const DrawerBrandIcon({
    super.key,
    required this.icon,
    this.accent = DrawerIconAccent.maroon,
  });

  final IconData icon;
  final DrawerIconAccent accent;

  @override
  Widget build(BuildContext context) {
    final color = switch (accent) {
      DrawerIconAccent.maroon => AppColors.logoRed,
      DrawerIconAccent.green => AppColors.logoGreen,
      DrawerIconAccent.purple => AppColors.primary,
    };

    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

enum DrawerIconAccent { maroon, green, purple }
