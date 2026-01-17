import 'package:flutter/material.dart';

/// TopNavBar - Matches TypeScript TopNavBar.tsx
/// Navigation tabs for lobby/single/club modes
class TopNavBar extends StatelessWidget {
  final String activeTab;
  final Function(String) onTabChange;

  const TopNavBar({
    super.key,
    required this.activeTab,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTab('lobby', 'Lobby'),
          const SizedBox(width: 24),
          _buildTab('single', 'Single'),
          const SizedBox(width: 24),
          _buildTab('club', 'Club'),
        ],
      ),
    );
  }

  Widget _buildTab(String id, String label) {
    final isActive = activeTab == id;
    return GestureDetector(
      onTap: () => onTabChange(id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isActive 
              ? Border.all(color: Colors.white.withOpacity(0.3))
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
