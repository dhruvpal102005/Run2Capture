import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../services/leaderboard_service.dart';
import '../../models/models.dart';

class LeaderboardView extends StatefulWidget {
  const LeaderboardView({super.key});

  @override
  State<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView> {
  final LeaderboardService _leaderboardService = LeaderboardService();
  List<LeaderboardEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);
    
    final entries = await _leaderboardService.getAreaLeaderboard();
    
    if (mounted) {
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        ),
      );
    }

    if (_entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.leaderboard_outlined,
              size: 48,
              color: AppTheme.textMuted.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No entries yet',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Be the first to capture territory!',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLeaderboard,
      color: AppTheme.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _entries.length,
        itemBuilder: (context, index) {
          return _buildLeaderboardItem(_entries[index]);
        },
      ),
    );
  }

  Widget _buildLeaderboardItem(LeaderboardEntry entry) {
    final isTopThree = entry.rank <= 3;
    
    Color? rankColor;
    IconData? rankIcon;
    
    switch (entry.rank) {
      case 1:
        rankColor = const Color(0xFFFFD700); // Gold
        rankIcon = Icons.emoji_events;
        break;
      case 2:
        rankColor = const Color(0xFFC0C0C0); // Silver
        rankIcon = Icons.emoji_events;
        break;
      case 3:
        rankColor = const Color(0xFFCD7F32); // Bronze
        rankIcon = Icons.emoji_events;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isTopThree 
            ? rankColor?.withOpacity(0.1)
            : AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTopThree ? rankColor! : AppTheme.borderColor,
          width: isTopThree ? 1.5 : 0.5,
        ),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 40,
            child: isTopThree
                ? Icon(rankIcon, color: rankColor, size: 24)
                : Text(
                    '${entry.rank}',
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
          const SizedBox(width: 12),

          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isTopThree 
                    ? [rankColor!, rankColor.withOpacity(0.6)]
                    : AppTheme.territoryGradient,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: entry.avatarUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      entry.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          entry.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      entry.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 12),

          // Name and runs
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: TextStyle(
                    color: isTopThree ? rankColor : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${entry.runCount} runs',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              entry.formattedArea,
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
