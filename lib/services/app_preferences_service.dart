import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_locale.dart';

enum RecordingModePreference { manual, meeting, callNote }

class AppPreferencesService {
  static const hasSeenOnboardingKey = 'has_seen_safety_onboarding';
  static const recordingModeKey = 'recording_mode_preference';
  static const localeKey = 'app_locale';

  static const _legacyModeLabels = {
    'Enregistrement manuel': RecordingModePreference.manual,
    'Réunion': RecordingModePreference.meeting,
    'Note après appel': RecordingModePreference.callNote,
  };

  Future<bool> hasSeenSafetyOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(hasSeenOnboardingKey) ?? false;
  }

  Future<void> setSafetyOnboardingSeen(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(hasSeenOnboardingKey, value);
  }

  Future<RecordingModePreference> getRecordingMode() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(recordingModeKey);
    if (stored == null) return RecordingModePreference.manual;

    for (final mode in RecordingModePreference.values) {
      if (mode.name == stored) return mode;
    }
    return _legacyModeLabels[stored] ?? RecordingModePreference.manual;
  }

  Future<void> setRecordingMode(RecordingModePreference mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(recordingModeKey, mode.name);
  }

  Future<AppLocale> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return AppLocale.fromCode(prefs.getString(localeKey));
  }

  Future<void> setLocale(AppLocale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(localeKey, locale.code);
  }

  /// Clears onboarding flag so the safety screen shows again on next launch.
  Future<void> resetOnboardingForTesting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(hasSeenOnboardingKey);
  }
}
