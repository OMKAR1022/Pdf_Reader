import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'config/flavor_config.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/home/presentation/pages/home_page.dart';

void main() {
  // Initialize default flavor config if not already set
  try {
    FlavorConfig.instance;
  } catch (e) {
    FlavorConfig(
      flavor: Flavor.production,
      name: 'PROD',
      appName: 'Free PDF Maker',
      packageId: 'com.freepdfmaker',
      enableLogging: false,
    );
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: FlavorConfig.instance.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      // Start with splash screen
      home: const SplashPage(),
      // Define routes
      routes: {
        '/splash': (context) => const SplashPage(),
        '/onboarding': (context) => const OnboardingPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
