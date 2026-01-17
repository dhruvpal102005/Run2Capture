import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'config/app_theme.dart';
import 'config/firebase_config.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with options
  await Firebase.initializeApp(
    options: FirebaseConfig.currentPlatform,
  );
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.backgroundColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const KaptureApp());
}

class KaptureApp extends StatelessWidget {
  const KaptureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'Kapture',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AuthWrapper(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/sign-in': (context) => const SignInScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        // Show splash while checking auth state
        if (authService.isLoading) {
          return const SplashScreen();
        }

        // Not authenticated - show sign in
        if (!authService.isAuthenticated) {
          return const SignInScreen();
        }

        // Authenticated but needs onboarding
        if (!authService.isOnboardingComplete) {
          return const OnboardingScreen();
        }

        // Fully authenticated
        return const HomeScreen();
      },
    );
  }
}
