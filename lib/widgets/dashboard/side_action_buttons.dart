import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

/// SideActionButtons - Matches TypeScript SideActionButtons.tsx exactly
/// Action buttons on the right side of play screen
class SideActionButtons extends StatefulWidget {
  final VoidCallback? onHelpPress;
  final VoidCallback? onProfilePress;
  final VoidCallback? onAddPress;
  final Function(bool)? onVisibilityToggle;

  const SideActionButtons({
    super.key,
    this.onHelpPress,
    this.onProfilePress,
    this.onAddPress,
    this.onVisibilityToggle,
  });

  @override
  State<SideActionButtons> createState() => _SideActionButtonsState();
}

class _SideActionButtonsState extends State<SideActionButtons> {
  bool _isVisible = true;

  void _handleVisibilityToggle() {
    setState(() => _isVisible = !_isVisible);
    widget.onVisibilityToggle?.call(_isVisible);
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.appUser;
    final initials = user?.initials ?? 'U';

    return Column(
      children: [
        // Profile avatar - matching TS avatarButton
        GestureDetector(
          onTap: widget.onProfilePress,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3), width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: user?.imageUrl != null
                ? Image.network(user!.imageUrl!, fit: BoxFit.cover)
                : Container(
                    color: const Color(0xFF333333),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),

        // Visibility toggle button - matching TS visibilityButton (Purple)
        GestureDetector(
          onTap: _handleVisibilityToggle,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _isVisible
                  ? const Color(0xFF8B5CF6)
                  : const Color(0xFF8B5CF6).withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isVisible ? Icons.visibility : Icons.visibility_off,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Help button - matching TS helpIcon (Red border)
        GestureDetector(
          onTap: widget.onHelpPress,
          child: Container(
            width: 32,
            height: 32,
            color: Colors.transparent, // For gesture detection
            child: Center(
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFF6B6B), width: 2),
                ),
                child: const Center(
                  child: Text(
                    '?',
                    style: TextStyle(
                      color: Color(0xFFFF6B6B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Add button - matching TS addButton (Cyan tint)
        GestureDetector(
          onTap: widget.onAddPress,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF00D9FF).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add,
              size: 18,
              color: Color(0xFF00D9FF),
            ),
          ),
        ),
      ],
    );
  }
}
