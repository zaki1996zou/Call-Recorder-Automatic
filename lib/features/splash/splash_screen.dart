import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../services/ads_initializer.dart';
import '../../services/app_open_ad_service.dart';
import '../../services/app_preferences_service.dart';
import '../home/home_screen.dart';
import '../onboarding/safety_onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const _splashAsset = 'assets/images/splash_call_recorder.png';

  static const _systemUiStyle = SystemUiOverlayStyle(
    statusBarColor: AppColors.brandMaroon,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.brandMaroon,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _preferences = AppPreferencesService();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SplashScreen._systemUiStyle);
    Future.delayed(const Duration(seconds: 2), _navigateNext);
  }

  Future<void> _navigateNext() async {
    if (!mounted) return;

    await initializeAdsIfAllowed();
    if (!mounted) return;

    final seenOnboarding = await _preferences.hasSeenSafetyOnboarding();
    if (!mounted) return;

    await AppOpenAdService.instance.showOnColdStart(
      skipForOnboarding: !seenOnboarding,
    );
    if (!mounted) return;

    final nextScreen =
        seenOnboarding ? const HomeScreen() : const SafetyOnboardingScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SplashScreen._systemUiStyle,
      child: ColoredBox(
        color: AppColors.brandMaroon,
        child: Image.asset(
          SplashScreen._splashAsset,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
