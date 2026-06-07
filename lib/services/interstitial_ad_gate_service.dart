import 'package:flutter/foundation.dart';
import 'package:multiads/multiads.dart';

import '../util/global.dart';

/// Interstitial ad gates with independent every-other-attempt counters per action.
///
/// Pattern per gate: 1st direct, 2nd ad, 3rd direct, 4th ad, ...
/// If the ad is unavailable, [onContinue] still runs immediately.
class InterstitialAdGateService {
  InterstitialAdGateService._();

  static final InterstitialAdGateService instance = InterstitialAdGateService._();

  static const cancelGate = 'cancel';
  static const deleteGate = 'delete';
  static const shareGate = 'share';
  static const backGate = 'back';

  final _attempts = <String, int>{};
  bool _isShowing = false;

  void runBefore(String gateId, VoidCallback onContinue) {
    if (_isShowing) {
      onContinue();
      return;
    }

    final count = (_attempts[gateId] ?? 0) + 1;
    _attempts[gateId] = count;

    final showAd = gAdsReady && gAds.hasInterstitials && count.isEven;

    if (!showAd) {
      onContinue();
      return;
    }

    _isShowing = true;
    AdCallbacks.onInterstitialDismissed = () {
      _isShowing = false;
      onContinue();
    };
    gAds.interInstance.showInterstitialAd();
  }

  void runBeforeCancel(VoidCallback onContinue) => runBefore(cancelGate, onContinue);

  void runBeforeDelete(VoidCallback onContinue) => runBefore(deleteGate, onContinue);

  void runBeforeShare(VoidCallback onContinue) => runBefore(shareGate, onContinue);

  void runBeforeBack(VoidCallback onContinue) => runBefore(backGate, onContinue);
}
