import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'l10n/app_locale.dart';
import 'l10n/locale_scope.dart';
import 'services/app_open_ad_service.dart';
import 'services/app_preferences_service.dart';
import 'services/locale_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.brandMaroon,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.brandMaroon,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const CallRecorderApp());
}

class CallRecorderApp extends StatefulWidget {
  const CallRecorderApp({super.key});

  @override
  State<CallRecorderApp> createState() => _CallRecorderAppState();
}

class _CallRecorderAppState extends State<CallRecorderApp>
    with WidgetsBindingObserver {
  late final LocaleService _localeService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _localeService = LocaleService(AppPreferencesService());
    _localeService.load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AppOpenAdService.instance.onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LocaleScope(
      localeService: _localeService,
      child: ListenableBuilder(
        listenable: _localeService,
        builder: (context, _) {
          if (!_localeService.isLoaded) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          return MaterialApp(
            title: 'Call Recorder Automatic',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            locale: _localeService.locale.flutterLocale,
            supportedLocales: AppLocale.values
                .map((locale) => locale.flutterLocale)
                .toList(),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
