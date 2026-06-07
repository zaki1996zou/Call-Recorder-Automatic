import 'package:flutter/material.dart';

enum AppLocale {
  fr('fr', 'Français'),
  en('en', 'English'),
  ar('ar', 'العربية'),
  es('es', 'Español');

  const AppLocale(this.code, this.displayName);

  final String code;
  final String displayName;

  Locale get flutterLocale => Locale(code);

  static AppLocale fromCode(String? code) {
    if (code == null) return AppLocale.fr;
    for (final locale in AppLocale.values) {
      if (locale.code == code) return locale;
    }
    return AppLocale.fr;
  }
}
