import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _firebaseUser;
  AppUser? _appUser;
  bool _isLoading = true;
  bool _isOnboardingComplete = false;

  AuthService() {
    _init();
  }

  User? get firebaseUser => _firebaseUser;
  AppUser? get appUser => _appUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _firebaseUser != null;
  bool get isOnboardingComplete => _isOnboardingComplete;
  String? get userId => _firebaseUser?.uid;

  Future<void> _init() async {
    _auth.authStateChanges().listen((User? user) async {
      _firebaseUser = user;
      if (user != null) {
        await _loadUserData();
      } else {
        _appUser = null;
        _isOnboardingComplete = false;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _loadUserData() async {
    if (_firebaseUser == null) return;

    try {
      final doc = await _firestore.collection('users').doc(_firebaseUser!.uid).get();
      if (doc.exists) {
        _appUser = AppUser.fromFirestore(doc);
        _isOnboardingComplete = _appUser?.onboardingComplete ?? false;
      } else {
        // User exists in Auth but not in Firestore, create document
        await _createUserDocument();
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _createUserDocument() async {
    if (_firebaseUser == null) return;

    final userData = {
      'email': _firebaseUser!.email ?? '',
      'firstName': _firebaseUser!.displayName?.split(' ').first,
      'lastName': _firebaseUser!.displayName?.split(' ').skip(1).join(' '),
      'fullName': _firebaseUser!.displayName,
      'imageUrl': _firebaseUser!.photoURL,
      'provider': 'google',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'onboardingComplete': false,
      'followersCount': 0,
      'followingCount': 0,
    };

    await _firestore.collection('users').doc(_firebaseUser!.uid).set(userData);
    await _loadUserData();
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      return true;
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign in with email and password
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Error signing in with email: ${e.message}');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign up with email and password
  Future<bool> signUpWithEmail(String email, String password, String name) async {
    try {
      _isLoading = true;
      notifyListeners();

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(name);
      
      // Create user document
      await _createUserDocument();
      
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Error signing up: ${e.message}');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Complete onboarding
  Future<void> completeOnboarding({
    String unit = 'km',
    String? territoryColor,
  }) async {
    if (_firebaseUser == null) return;

    try {
      await _firestore.collection('users').doc(_firebaseUser!.uid).update({
        'onboardingComplete': true,
        'unit': unit,
        'territoryColor': territoryColor,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _isOnboardingComplete = true;
      await _loadUserData();
      notifyListeners();
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      _appUser = null;
      _isOnboardingComplete = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? unit,
    String? territoryColor,
  }) async {
    if (_firebaseUser == null) return;

    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (firstName != null) updates['firstName'] = firstName;
      if (lastName != null) updates['lastName'] = lastName;
      if (unit != null) updates['unit'] = unit;
      if (territoryColor != null) updates['territoryColor'] = territoryColor;

      await _firestore.collection('users').doc(_firebaseUser!.uid).update(updates);
      await _loadUserData();
    } catch (e) {
      debugPrint('Error updating profile: $e');
    }
  }
}
