import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_theme.dart';
import '../services/auth_service.dart';

/// SignInScreen - Matches TypeScript sign-in.tsx exactly
/// Uses Firebase Auth with Google OAuth (same as Clerk Google OAuth)
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _googleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    setState(() => _loading = true);

    try {
      final authService = context.read<AuthService>();
      final success = await authService.signInWithEmail(email, password);

      if (!success && mounted) {
        _showError('Sign in failed. Please check your credentials.');
      }
      // If successful, AuthWrapper will automatically navigate
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _googleLoading = true);

    try {
      final authService = context.read<AuthService>();
      final success = await authService.signInWithGoogle();

      if (!success && mounted) {
        _showError('Google sign in failed. Please try again.');
      }
      // If successful, AuthWrapper will automatically navigate
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // Background image - matching TypeScript ImageBackground with runner.jpg
          image: DecorationImage(
            image: AssetImage('assets/images/runner.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                children: [
                  // Spacer - matching TypeScript spacer (flex: 1, minHeight: 30%)
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.35,
                  ),

                  // Form section - matching TypeScript formSection
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title - matching TypeScript titleText
                        const Text(
                          'WELCOME',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Email input - matching TypeScript input style
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          style: const TextStyle(color: Colors.black, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'Email address',
                            hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Password input
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.black, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'Enter password',
                            hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Sign in button - matching TypeScript button style
                        GestureDetector(
                          onTap: _loading ? null : _handleSignIn,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            margin: const EdgeInsets.only(top: 8, bottom: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: _loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Sign in',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        // Divider - matching TypeScript dividerContainer
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'or',
                                  style: TextStyle(color: Colors.white, fontSize: 14),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Google sign in button - matching TypeScript googleButton
                        GestureDetector(
                          onTap: _googleLoading ? null : _handleGoogleSignIn,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_googleLoading)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                      strokeWidth: 2,
                                    ),
                                  )
                                else ...[
                                  // Google icon - matching TypeScript GoogleIcon SVG
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CustomPaint(
                                      painter: _GoogleLogoPainter(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Continue with Google',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        // Forgot password link
                        GestureDetector(
                          onTap: () {
                            // TODO: Forgot password
                          },
                          child: const Text(
                            'Forgot password?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Sign up link
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/sign-up');
                          },
                          child: const Text(
                            "Don't have an account? Sign up",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for Google logo - matches TypeScript GoogleIcon SVG paths
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24;
    
    // Blue path
    final bluePaint = Paint()..color = const Color(0xFF4285F4);
    final bluePath = Path()
      ..moveTo(22.56 * scale, 12.25 * scale)
      ..cubicTo(22.56 * scale, 11.47 * scale, 22.49 * scale, 10.72 * scale, 22.36 * scale, 10 * scale)
      ..lineTo(12 * scale, 10 * scale)
      ..lineTo(12 * scale, 14.26 * scale)
      ..lineTo(17.92 * scale, 14.26 * scale)
      ..cubicTo(17.66 * scale, 15.63 * scale, 16.88 * scale, 16.79 * scale, 15.71 * scale, 17.57 * scale)
      ..lineTo(15.71 * scale, 20.34 * scale)
      ..lineTo(19.28 * scale, 20.34 * scale)
      ..cubicTo(21.36 * scale, 18.42 * scale, 22.56 * scale, 15.6 * scale, 22.56 * scale, 12.25 * scale)
      ..close();
    canvas.drawPath(bluePath, bluePaint);
    
    // Green path
    final greenPaint = Paint()..color = const Color(0xFF34A853);
    final greenPath = Path()
      ..moveTo(12 * scale, 23 * scale)
      ..cubicTo(14.97 * scale, 23 * scale, 17.46 * scale, 22.02 * scale, 19.28 * scale, 20.34 * scale)
      ..lineTo(15.71 * scale, 17.57 * scale)
      ..cubicTo(14.73 * scale, 18.23 * scale, 13.48 * scale, 18.63 * scale, 12 * scale, 18.63 * scale)
      ..cubicTo(9.14 * scale, 18.63 * scale, 6.71 * scale, 16.7 * scale, 5.84 * scale, 14.1 * scale)
      ..lineTo(2.18 * scale, 14.1 * scale)
      ..lineTo(2.18 * scale, 16.94 * scale)
      ..cubicTo(3.99 * scale, 20.53 * scale, 7.7 * scale, 23 * scale, 12 * scale, 23 * scale)
      ..close();
    canvas.drawPath(greenPath, greenPaint);
    
    // Yellow path
    final yellowPaint = Paint()..color = const Color(0xFFFBBC05);
    final yellowPath = Path()
      ..moveTo(5.84 * scale, 14.09 * scale)
      ..cubicTo(5.62 * scale, 13.43 * scale, 5.49 * scale, 12.73 * scale, 5.49 * scale, 12 * scale)
      ..cubicTo(5.49 * scale, 11.27 * scale, 5.62 * scale, 10.57 * scale, 5.84 * scale, 9.91 * scale)
      ..lineTo(5.84 * scale, 7.07 * scale)
      ..lineTo(2.18 * scale, 7.07 * scale)
      ..cubicTo(1.43 * scale, 8.55 * scale, 1 * scale, 10.22 * scale, 1 * scale, 12 * scale)
      ..cubicTo(1 * scale, 13.78 * scale, 1.43 * scale, 15.45 * scale, 2.18 * scale, 16.93 * scale)
      ..lineTo(5.03 * scale, 14.71 * scale)
      ..lineTo(5.84 * scale, 14.09 * scale)
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);
    
    // Red path
    final redPaint = Paint()..color = const Color(0xFFEA4335);
    final redPath = Path()
      ..moveTo(12 * scale, 5.38 * scale)
      ..cubicTo(13.62 * scale, 5.38 * scale, 15.06 * scale, 5.94 * scale, 16.21 * scale, 7.02 * scale)
      ..lineTo(19.36 * scale, 3.87 * scale)
      ..cubicTo(17.45 * scale, 2.09 * scale, 14.97 * scale, 1 * scale, 12 * scale, 1 * scale)
      ..cubicTo(7.7 * scale, 1 * scale, 3.99 * scale, 3.47 * scale, 2.18 * scale, 7.07 * scale)
      ..lineTo(5.84 * scale, 9.91 * scale)
      ..cubicTo(6.71 * scale, 7.31 * scale, 9.14 * scale, 5.38 * scale, 12 * scale, 5.38 * scale)
      ..close();
    canvas.drawPath(redPath, redPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
