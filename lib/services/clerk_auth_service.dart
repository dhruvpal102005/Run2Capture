import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';

/// ClerkAuthService - Matches TypeScript Clerk auth implementation
/// Uses the Clerk Flutter SDK for authentication matching the React Native project
class ClerkAuthService extends ChangeNotifier {
  // Clerk state from ClerkAuthProvider
  bool _isLoading = true;
  bool _isSignedIn = false;
  ClerkUser? _user;
  
  bool get isLoading => _isLoading;
  bool get isSignedIn => _isSignedIn;
  ClerkUser? get user => _user;
  String? get userId => _user?.id;
  
  /// Initialize and check auth state
  void setAuthState({required bool isSignedIn, ClerkUser? user}) {
    _isSignedIn = isSignedIn;
    _user = user;
    _isLoading = false;
    notifyListeners();
  }
  
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

/// ClerkUser model matching Clerk's user object
class ClerkUser {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? email;
  final String? imageUrl;
  
  ClerkUser({
    required this.id,
    this.firstName,
    this.lastName,
    this.fullName,
    this.email,
    this.imageUrl,
  });
  
  /// Create from Clerk SDK User object
  factory ClerkUser.fromClerk(User user) {
    return ClerkUser(
      id: user.id,
      firstName: user.firstName,
      lastName: user.lastName,
      fullName: '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim(),
      email: user.primaryEmailAddress?.email,
      imageUrl: user.imageUrl,
    );
  }
}
