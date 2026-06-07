import 'package:flutter/material.dart';

import '../util/global.dart';

/// Standard 320×50 banner loaded via [MultiAds], shown above the bottom tabs.
class AppBannerAd extends StatefulWidget {
  const AppBannerAd({super.key});

  @override
  State<AppBannerAd> createState() => _AppBannerAdState();
}

class _AppBannerAdState extends State<AppBannerAd> {
  final _bannerKey = UniqueKey();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() {
    if (!gAdsReady || !gAds.hasBanners) return;

    gAds.bannerInstance.loadBannerAd(() {
      if (mounted) setState(() => _loaded = true);
    }, _bannerKey);
  }

  @override
  void dispose() {
    if (gAdsReady) {
      gAds.bannerInstance.disposeBanner(_bannerKey);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!gAdsReady || !gAds.hasBanners) {
      return const SizedBox.shrink();
    }

    if (!_loaded) {
      return const SizedBox(
        height: 50,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return SizedBox(
      height: 50,
      width: double.infinity,
      child: gAds.bannerInstance.getBannerAdWidget(_bannerKey),
    );
  }
}
