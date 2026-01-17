import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'config/firebase_config.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (matching TypeScript Firebase config)
  await Firebase.initializeApp(
    options: FirebaseConfig.currentPlatform,
  );
  
  runApp(const KaptureApp());
}

/// KaptureApp - Main app with authentication
/// Matches TypeScript _layout.tsx auth flow
class KaptureApp extends StatelessWidget {
  const KaptureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MaterialApp(
        title: 'Kapture',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AuthWrapper(),
        routes: {
          '/sign-in': (context) => const SignInScreen(),
          '/sign-up': (context) => const SignUpPlaceholder(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}

/// AuthWrapper - Conditionally shows screens based on auth state
/// Matches TypeScript useAuth().isSignedIn pattern from Clerk
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    
    // Loading state - show splash
    if (authService.isLoading) {
      return const SplashScreen();
    }
    
    // Check if user is authenticated
    if (authService.isAuthenticated) {
      // Check if onboarding is complete
      if (authService.isOnboardingComplete) {
        return const HomeScreen();
      } else {
        return const OnboardingScreen();
      }
    }
    
    // Not authenticated - show sign in
    return const SignInScreen();
  }
}

/// Sign up placeholder - will implement later
class SignUpPlaceholder extends StatelessWidget {
  const SignUpPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: const Center(
        child: Text('Sign up coming soon'),
      ),
    );
  }
}
