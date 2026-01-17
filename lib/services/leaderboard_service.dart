import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

/// Service for fetching and managing leaderboard data
class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Gets the area leaderboard - users ranked by total captured territory
  Future<List<LeaderboardEntry>> getAreaLeaderboard({int limit = 50}) async {
    try {
      // Get all completed runs
      final runsSnapshot = await _firestore
          .collection('runs')
          .where('status', isEqualTo: 'completed')
          .get();

      // Aggregate by user
      final Map<String, Map<String, dynamic>> userStats = {};

      for (final doc in runsSnapshot.docs) {
        final data = doc.data();
        final userId = data['userId'] as String?;
        final area = (data['capturedArea'] as num?)?.toDouble() ?? 0.0;

        if (userId != null) {
          if (userStats.containsKey(userId)) {
            userStats[userId]!['totalArea'] = 
                (userStats[userId]!['totalArea'] as double) + area;
            userStats[userId]!['runCount'] = 
                (userStats[userId]!['runCount'] as int) + 1;
          } else {
            userStats[userId] = {
              'totalArea': area,
              'runCount': 1,
            };
          }
        }
      }

      // Convert to list and sort by total area
      final sortedUsers = userStats.entries.toList()
        ..sort((a, b) => (b.value['totalArea'] as double)
            .compareTo(a.value['totalArea'] as double));

      // Take top entries
      final topUsers = sortedUsers.take(limit).toList();

      // Fetch user details
      final List<LeaderboardEntry> leaderboard = [];

      for (int i = 0; i < topUsers.length; i++) {
        final entry = topUsers[i];
        String name = 'Anonymous';
        String? avatarUrl;

        try {
          final userDoc = await _firestore
              .collection('users')
              .doc(entry.key)
              .get();
          
          if (userDoc.exists) {
            final userData = userDoc.data()!;
            name = userData['name'] as String? ?? 
                   userData['firstName'] as String? ?? 
                   'Anonymous';
            avatarUrl = userData['imageUrl'] as String? ?? 
                       userData['avatarUrl'] as String?;
          }
        } catch (e) {
          // User doc might not exist, use default name
        }

        leaderboard.add(LeaderboardEntry(
          rank: i + 1,
          userId: entry.key,
          name: name,
          totalArea: entry.value['totalArea'] as double,
          runCount: entry.value['runCount'] as int,
          avatarUrl: avatarUrl,
        ));
      }

      return leaderboard;
    } catch (e) {
      print('Error fetching leaderboard: $e');
      return [];
    }
  }

  /// Gets a specific user's rank and stats
  Future<Map<String, dynamic>> getUserRankAndStats(String userId) async {
    try {
      // Get user's completed runs
      final userRunsSnapshot = await _firestore
          .collection('runs')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .get();

      double userTotalArea = 0;
      int userRunCount = 0;

      for (final doc in userRunsSnapshot.docs) {
        final data = doc.data();
        userTotalArea += (data['capturedArea'] as num?)?.toDouble() ?? 0.0;
        userRunCount++;
      }

      // Get full leaderboard to determine rank
      final leaderboard = await getAreaLeaderboard(limit: 1000);
      final userEntry = leaderboard.where((e) => e.userId == userId).firstOrNull;

      return {
        'rank': userEntry?.rank,
        'totalArea': userTotalArea,
        'runCount': userRunCount,
      };
    } catch (e) {
      print('Error getting user rank: $e');
      return {
        'rank': null,
        'totalArea': 0.0,
        'runCount': 0,
      };
    }
  }

  /// Format area for display
  static String formatArea(double areaInSquareMeters) {
    if (areaInSquareMeters >= 1000000) {
      return '${(areaInSquareMeters / 1000000).toStringAsFixed(2)}KM²';
    } else if (areaInSquareMeters >= 1000) {
      return '${(areaInSquareMeters / 1000).toStringAsFixed(1)}KM²';
    } else {
      return '${areaInSquareMeters.round()}M²';
    }
  }
}
