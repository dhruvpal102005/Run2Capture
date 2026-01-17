import 'package:cloud_firestore/cloud_firestore.dart';

/// User model stored in Firebase
class AppUser {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String provider; // 'google' or 'email'
  final String unit; // 'km' or 'mi'
  final String? territoryColor;
  final bool onboardingComplete;
  final int followersCount;
  final int followingCount;

  AppUser({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.fullName,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
    this.provider = 'email',
    this.unit = 'km',
    this.territoryColor,
    this.onboardingComplete = false,
    this.followersCount = 0,
    this.followingCount = 0,
  });

  String get displayName {
    if (fullName != null && fullName!.isNotEmpty) return fullName!;
    if (firstName != null && firstName!.isNotEmpty) {
      if (lastName != null && lastName!.isNotEmpty) {
        return '$firstName $lastName';
      }
      return firstName!;
    }
    return email.split('@').first;
  }

  String get initials {
    final name = displayName;
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data is null');
    }

    return AppUser(
      id: doc.id,
      email: data['email'] as String? ?? '',
      firstName: data['firstName'] as String?,
      lastName: data['lastName'] as String?,
      fullName: data['fullName'] as String?,
      imageUrl: data['imageUrl'] as String?,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      provider: data['provider'] as String? ?? 'email',
      unit: data['unit'] as String? ?? 'km',
      territoryColor: data['territoryColor'] as String?,
      onboardingComplete: data['onboardingComplete'] as bool? ?? false,
      followersCount: data['followersCount'] as int? ?? 0,
      followingCount: data['followingCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'imageUrl': imageUrl,
      'provider': provider,
      'unit': unit,
      'territoryColor': territoryColor,
      'onboardingComplete': onboardingComplete,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  AppUser copyWith({
    String? firstName,
    String? lastName,
    String? fullName,
    String? imageUrl,
    String? unit,
    String? territoryColor,
    bool? onboardingComplete,
    int? followersCount,
    int? followingCount,
  }) {
    return AppUser(
      id: id,
      email: email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      provider: provider,
      unit: unit ?? this.unit,
      territoryColor: territoryColor ?? this.territoryColor,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
    );
  }
}
