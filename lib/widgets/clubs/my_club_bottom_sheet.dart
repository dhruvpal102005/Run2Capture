import 'package:flutter/material.dart';

import '../../config/app_theme.dart';

/// MyClubBottomSheet - Matches TypeScript MyClubBottomSheet.tsx
/// Bottom sheet for club tab showing user's club or create option
class MyClubBottomSheet extends StatelessWidget {
  final bool visible;
  final VoidCallback onCreateClub;

  const MyClubBottomSheet({
    super.key,
    required this.visible,
    required this.onCreateClub,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // No club state
                Icon(
                  Icons.groups_outlined,
                  size: 64,
                  color: AppTheme.textMuted.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Join a Terra Club',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Connect with runners in your area and compete together',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),

                // Create club button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onCreateClub,
                    icon: const Icon(Icons.add),
                    label: const Text('Create a Club'),
                  ),
                ),
                const SizedBox(height: 12),

                // Browse clubs button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Club browsing coming soon')),
                      );
                    },
                    icon: const Icon(Icons.explore),
                    label: const Text('Browse Clubs'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
