import 'package:flutter/material.dart';

/// SideActionButtons - Matches TypeScript SideActionButtons.tsx
/// Action buttons on the right side of play screen
class SideActionButtons extends StatelessWidget {
  final VoidCallback? onHelpPress;

  const SideActionButtons({
    super.key,
    this.onHelpPress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Help/locate button
        _buildActionButton(
          icon: Icons.help_outline,
          onTap: onHelpPress,
        ),
        const SizedBox(height: 12),
        // Chat button
        _buildActionButton(
          icon: Icons.chat_bubble_outline,
          onTap: () {
            // TODO: Open chat
          },
        ),
        const SizedBox(height: 12),
        // Settings button
        _buildActionButton(
          icon: Icons.settings_outlined,
          onTap: () {
            // TODO: Open settings
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 20,
        ),
      ),
    );
  }
}
