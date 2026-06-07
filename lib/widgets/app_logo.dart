import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 120,
  });

  static const assetPath = 'assets/icons/app_logo.png';

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.border,
          width: size * 0.02,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: size * 0.06,
            offset: Offset(0, size * 0.03),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          assetPath,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class EmptyListIcon extends StatelessWidget {
  const EmptyListIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppLogo(size: 72);
  }
}
