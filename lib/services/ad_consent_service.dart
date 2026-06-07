import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Google UMP (User Messaging Platform) — AdMob's certified CMP for GDPR/EEA.
class AdConsentService {
  AdConsentService._();

  static final instance = AdConsentService._();

  bool _gathered = false;

  /// Requests consent info and shows the GDPR form when required.
  /// Call before [MobileAds.initialize] and any ad load.
  Future<void> gatherConsent() async {
    if (_gathered) return;

    final params = ConsentRequestParameters(
      consentDebugSettings: kDebugMode
          ? ConsentDebugSettings(
              debugGeography: DebugGeography.debugGeographyEea,
              testIdentifiers: const ['79738754EC81FA5F64972928128B2FFF'],
            )
          : null,
    );

    await _requestConsentInfoUpdate(params);
    await _loadAndShowFormIfRequired();
    _gathered = true;
  }

  Future<void> _requestConsentInfoUpdate(ConsentRequestParameters params) {
    final completer = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () {
        if (!completer.isCompleted) completer.complete();
      },
      (_) {
        // Fail-open: app still works if consent service is unreachable.
        if (!completer.isCompleted) completer.complete();
      },
    );
    return completer.future;
  }

  Future<void> _loadAndShowFormIfRequired() {
    final completer = Completer<void>();
    ConsentForm.loadAndShowConsentFormIfRequired((_) {
      if (!completer.isCompleted) completer.complete();
    });
    return completer.future;
  }

  Future<bool> canRequestAds() => ConsentInformation.instance.canRequestAds();

  Future<bool> isPrivacyOptionsRequired() async {
    final status =
        await ConsentInformation.instance.getPrivacyOptionsRequirementStatus();
    return status == PrivacyOptionsRequirementStatus.required;
  }

  Future<void> showPrivacyOptionsForm() {
    final completer = Completer<void>();
    ConsentForm.showPrivacyOptionsForm((_) {
      if (!completer.isCompleted) completer.complete();
    });
    return completer.future;
  }
}
