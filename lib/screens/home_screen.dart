import 'package:flutter/material.dart';

import 'start_screen.dart';
import 'play_screen.dart';
import 'feed_screen.dart';
import 'me_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          PlayScreen(),
          MeScreen(),
          FeedScreen(),
          StartScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0D0D0D), // Matching TS styles.tabBar backgroundColor
          border: Border(
            top: BorderSide(
              color: Colors.transparent, // TS has borderTopWidth: 0
              width: 0,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.sports_esports_outlined, 'Play'),
                _buildNavItem(1, Icons.person_outline, 'Me'),
                _buildNavItem(2, Icons.people_outline, 'Feed'),
                _buildNavItem(3, Icons.directions_run, 'Start'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(
                        alpha: 0.5), // Matching TS active/inactive tints
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
                fontWeight: isSelected
                    ? FontWeight.w600
                    : FontWeight.w500, // Matching TS tabBarLabel fontWeight
              ),
            ),
          ],
        ),
      ),
    );
  }
}
