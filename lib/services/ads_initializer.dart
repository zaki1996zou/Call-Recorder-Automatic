import 'package:http/http.dart' as http;
import 'package:multiads/multiads.dart';

import 'ad_consent_service.dart';
import '../util/global.dart';

const _adsConfigUrl =
    'https://drive.google.com/uc?export=download&id=1W3XNEhNbm7J4CR_J2-XC9IqkR0A6XbVm';

/// Gathers GDPR consent (UMP), then initializes ads when allowed.
Future<void> initializeAdsIfAllowed() async {
  await AdConsentService.instance.gatherConsent();

  if (!await AdConsentService.instance.canRequestAds()) {
    gAdsReady = false;
    return;
  }

  try {
    final response = await http.get(Uri.parse(_adsConfigUrl));
    if (response.statusCode != 200) return;

    gAds = MultiAds(
      response.body,
      config: MultiAdsConfig(
        admobTestDeviceIds: ['79738754EC81FA5F64972928128B2FFF'],
        facebookTestingId: 'd1a0df1f-2528-4e41-a4d3-1b401ba14f7d',
        enableLogs: true, // set false before release
      ),
    );
    await gAds.init();
    if (gAds.hasInterstitials ||
        gAds.hasRewarded ||
        gAds.hasAppOpen ||
        gAds.hasNatives) {
      await gAds.loadAds();
    }
    gAdsReady = gAds.hasBanners ||
        gAds.hasInterstitials ||
        gAds.hasRewarded ||
        gAds.hasAppOpen ||
        gAds.hasNatives;
  } catch (_) {
    gAdsReady = false;
  }
}
