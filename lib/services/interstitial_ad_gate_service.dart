import 'package:flutter/foundation.dart';
import 'package:multiads/multiads.dart';

import '../models/recording_filter_tab.dart';
import '../util/global.dart';

/// Interstitial gates. Shows an ad when ready; otherwise [onContinue] runs now.
class InterstitialAdGateService {
  InterstitialAdGateService._();

  static final InterstitialAdGateService instance =
      InterstitialAdGateService._();

  static const cancelGate = 'cancel';
  static const backGate = 'back';
  static const callNoteAfterGate = 'call_note_after';
  static const callNoteIncomingGate = 'call_note_incoming';
  static const editGate = 'edit';
  static const favoriteGate = 'favorite';
  static const tabIncomingGate = 'tab_incoming';
  static const tabOutgoingGate = 'tab_outgoing';
  static const tabFavoritesGate = 'tab_favorites';

  bool _isShowing = false;

  void runBefore(String gateId, VoidCallback onContinue) {
    if (_isShowing) {
      onContinue();
      return;
    }

    if (!gAdsReady || !gAds.hasInterstitials) {
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

  void runBeforeCancel(VoidCallback onContinue) =>
      runBefore(cancelGate, onContinue);

  void runBeforeBack(VoidCallback onContinue) =>
      runBefore(backGate, onContinue);

  void runBeforeCallNoteAfter(VoidCallback onContinue) =>
      runBefore(callNoteAfterGate, onContinue);

  void runBeforeCallNoteIncoming(VoidCallback onContinue) =>
      runBefore(callNoteIncomingGate, onContinue);

  void runBeforeEdit(VoidCallback onContinue) =>
      runBefore(editGate, onContinue);

  void runBeforeFavorite(VoidCallback onContinue) =>
      runBefore(favoriteGate, onContinue);

  void runBeforeTab(RecordingFilterTab tab, VoidCallback onContinue) {
    final gateId = switch (tab) {
      RecordingFilterTab.incoming => tabIncomingGate,
      RecordingFilterTab.outgoing => tabOutgoingGate,
      RecordingFilterTab.favorites => tabFavoritesGate,
      RecordingFilterTab.all => null,
    };
    if (gateId == null) {
      onContinue();
      return;
    }
    runBefore(gateId, onContinue);
  }
}
