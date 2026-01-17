import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../services/leaderboard_service.dart';
import '../../models/models.dart';
import 'leaderboard_view.dart';

class DraggableBottomSheet extends StatefulWidget {
  final String activeTab;
  final Function(String) onTabChange;

  const DraggableBottomSheet({
    super.key,
    this.activeTab = 'leaderboard',
    required this.onTabChange,
  });

  @override
  State<DraggableBottomSheet> createState() => _DraggableBottomSheetState();
}

class _DraggableBottomSheetState extends State<DraggableBottomSheet> {
  // Sheet positions (fraction of screen height)
  static const double _peek = 0.12;   // Just showing tabs
  static const double _half = 0.45;   // Half screen
  static const double _full = 0.9;    // Almost full

  double _sheetPosition = _peek;
  double _dragStartPosition = 0;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final sheetHeight = screenHeight * _sheetPosition;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: sheetHeight,
      child: GestureDetector(
        onVerticalDragStart: (details) {
          _dragStartPosition = _sheetPosition;
        },
        onVerticalDragUpdate: (details) {
          setState(() {
            _sheetPosition -= details.delta.dy / screenHeight;
            _sheetPosition = _sheetPosition.clamp(_peek, _full);
          });
        },
        onVerticalDragEnd: (details) {
          // Snap to nearest position
          final velocity = details.velocity.pixelsPerSecond.dy;
          
          if (velocity.abs() > 500) {
            // Fast swipe
            if (velocity > 0) {
              // Swipe down
              _snapTo(_sheetPosition > _half ? _half : _peek);
            } else {
              // Swipe up
              _snapTo(_sheetPosition < _half ? _half : _full);
            }
          } else {
            // Slow drag - snap to nearest
            if (_sheetPosition < (_peek + _half) / 2) {
              _snapTo(_peek);
            } else if (_sheetPosition < (_half + _full) / 2) {
              _snapTo(_half);
            } else {
              _snapTo(_full);
            }
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Tab bar
              _buildTabBar(),

              // Content
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildTab('leaderboard', 'Leaderboard', Icons.leaderboard),
          const SizedBox(width: 16),
          _buildTab('clubs', 'Clubs', Icons.groups),
        ],
      ),
    );
  }

  Widget _buildTab(String id, String label, IconData icon) {
    final isActive = widget.activeTab == id;
    return GestureDetector(
      onTap: () => widget.onTabChange(id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppTheme.primaryColor : AppTheme.borderColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? AppTheme.primaryColor : AppTheme.textMuted,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppTheme.primaryColor : AppTheme.textMuted,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (widget.activeTab) {
      case 'leaderboard':
        return const LeaderboardView();
      case 'clubs':
        return _buildClubsContent();
      default:
        return const LeaderboardView();
    }
  }

  Widget _buildClubsContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Create club button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppTheme.territoryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create a Club',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Start your own running community',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          'Popular Clubs',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // Mock clubs
        _buildClubItem('Mumbai Runners', 'Mumbai, India', 1234),
        _buildClubItem('Delhi Running Club', 'Delhi, India', 892),
        _buildClubItem('Bangalore Pacers', 'Bangalore, India', 756),
      ],
    );
  }

  Widget _buildClubItem(String name, String location, int members) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                name[0],
                style: const TextStyle(
                  color: AppTheme.accentColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$location • $members members',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
            ),
            child: const Text('Join', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _snapTo(double position) {
    setState(() {
      _sheetPosition = position;
    });
  }
}
