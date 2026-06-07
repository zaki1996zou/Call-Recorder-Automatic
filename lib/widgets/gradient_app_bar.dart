import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GradientAppBar({
    super.key,
    required this.title,
    this.onMenuTap,
    this.leadingIcon = Icons.menu,
    this.actions,
  });

  final String title;
  final VoidCallback? onMenuTap;
  final IconData leadingIcon;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.appBarGradient,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: AppColors.statusBarPurple,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      leading: IconButton(
        icon: Icon(leadingIcon, color: AppColors.appBarForeground),
        onPressed: onMenuTap ?? () => Scaffold.of(context).openDrawer(),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.appBarForeground,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: actions,
    );
  }
}
