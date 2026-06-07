import '../util/global.dart';

/// Controls when App Open ads are shown so core flows stay uninterrupted.
class AppOpenAdService {
  AppOpenAdService._();

  static final AppOpenAdService instance = AppOpenAdService._();

  static const _resumeCooldown = Duration(hours: 4);

  bool _coldStartHandled = false;
  DateTime? _lastShownAt;

  /// Set while recording or other full-screen critical flows are active.
  bool suppressed = false;

  bool get canShow =>
      gAdsReady && gAds.hasAppOpen && !suppressed && !isInterShowed;

  /// Called once after the splash screen, before navigating to home/onboarding.
  Future<void> showOnColdStart({required bool skipForOnboarding}) async {
    if (_coldStartHandled) return;
    _coldStartHandled = true;

    if (skipForOnboarding || !canShow) return;

    await _showWithLoadGracePeriod();
  }

  /// Called when the app returns to the foreground after the initial launch.
  void onAppResumed() {
    if (!_coldStartHandled || !canShow) return;

    final lastShown = _lastShownAt;
    if (lastShown != null &&
        DateTime.now().difference(lastShown) < _resumeCooldown) {
      return;
    }

    gAds.openAdsInstance.showAdIfAvailableOpenAds();
    _lastShownAt = DateTime.now();
  }

  Future<void> _showWithLoadGracePeriod() async {
    // Splash + main() init usually give enough time; brief grace if still loading.
    for (var attempt = 0; attempt < 3; attempt++) {
      if (!canShow) return;
      gAds.openAdsInstance.showAdIfAvailableOpenAds();
      _lastShownAt = DateTime.now();
      if (attempt == 2) return;
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }
  }
}
