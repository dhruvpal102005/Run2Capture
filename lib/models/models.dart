import 'package:cloud_firestore/cloud_firestore.dart';

/// Leaderboard entry for territory rankings
class LeaderboardEntry {
  final int rank;
  final String userId;
  final String name;
  final double totalArea; // in square meters
  final int runCount;
  final String? avatarUrl;

  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.name,
    required this.totalArea,
    required this.runCount,
    this.avatarUrl,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json, int rank) {
    return LeaderboardEntry(
      rank: rank,
      userId: json['userId'] as String,
      name: json['name'] as String? ?? 'Anonymous',
      totalArea: (json['totalArea'] as num?)?.toDouble() ?? 0.0,
      runCount: json['runCount'] as int? ?? 0,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  /// Format area for display
  String get formattedArea {
    if (totalArea >= 1000000) {
      return '${(totalArea / 1000000).toStringAsFixed(2)}KM²';
    } else if (totalArea >= 1000) {
      return '${(totalArea / 1000).toStringAsFixed(1)}KM²';
    } else {
      return '${totalArea.round()}M²';
    }
  }
}

/// Club model for Terra Clubs
class Club {
  final String id;
  final String name;
  final String? logoUrl;
  final String country;
  final String countryCode;
  final int memberCount;
  final bool isPublic;
  final DateTime? createdAt;
  final String createdBy;
  final String status; // 'pending', 'approved', 'rejected'

  Club({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.country,
    required this.countryCode,
    required this.memberCount,
    required this.isPublic,
    this.createdAt,
    required this.createdBy,
    required this.status,
  });

  factory Club.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Club document data is null');
    }

    return Club(
      id: doc.id,
      name: data['name'] as String? ?? '',
      logoUrl: data['logoUrl'] as String?,
      country: data['country'] as String? ?? '',
      countryCode: data['countryCode'] as String? ?? '',
      memberCount: data['memberCount'] as int? ?? 0,
      isPublic: data['isPublic'] as bool? ?? true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      createdBy: data['createdBy'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'logoUrl': logoUrl,
      'country': country,
      'countryCode': countryCode,
      'memberCount': memberCount,
      'isPublic': isPublic,
      'createdBy': createdBy,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

/// Post model for feed
class Post {
  final String id;
  final String userId;
  final String userName;
  final String? userImageUrl;
  final String content;
  final String type; // 'status' or 'poll'
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    this.userImageUrl,
    required this.content,
    required this.type,
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Post document data is null');
    }

    return Post(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? 'Anonymous',
      userImageUrl: data['userImageUrl'] as String?,
      content: data['content'] as String? ?? '',
      type: data['type'] as String? ?? 'status',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      likesCount: data['likesCount'] as int? ?? 0,
      commentsCount: data['commentsCount'] as int? ?? 0,
    );
  }

  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays > 365) {
      return '${difference.inDays ~/ 365}y';
    } else if (difference.inDays > 30) {
      return '${difference.inDays ~/ 30}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
