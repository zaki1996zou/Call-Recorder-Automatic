import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../l10n/app_locale.dart';
import '../l10n/locale_scope.dart';

Future<void> showLanguageSelector(BuildContext context) {
  final localeService = LocaleScope.serviceOf(context);
  final l10n = context.l10n;

  return showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                child: Text(
                  l10n.selectLanguage,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              ...AppLocale.values.map(
                (locale) => ListTile(
                  leading: Icon(
                    locale == localeService.locale
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: locale == localeService.locale
                        ? AppColors.primary
                        : AppColors.iconMuted,
                  ),
                  title: Text(locale.displayName),
                  onTap: () async {
                    await localeService.setLocale(locale);
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
