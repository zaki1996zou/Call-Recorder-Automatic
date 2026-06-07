import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../l10n/locale_scope.dart';
import 'app_logo.dart';

/// Header block: logo + title + optional subtitle for the home screen.
class HomeListHeader extends StatelessWidget {
  const HomeListHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const EmptyListIcon(),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }
}

/// Standalone empty placeholder (kept for reuse outside the home scroll layout).
class EmptyListView extends StatelessWidget {
  const EmptyListView({
    super.key,
    this.subtitle,
  });

  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: HomeListHeader(
        title: l10n.emptyList,
        subtitle: subtitle ?? l10n.emptyCategory,
      ),
    );
  }
}
