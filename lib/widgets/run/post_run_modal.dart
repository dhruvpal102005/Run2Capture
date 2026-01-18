import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../models/run_stats.dart';

class PostRunModal extends StatelessWidget {
  final RunStats stats;
  final VoidCallback onSave;
  final VoidCallback onDiscard;

  const PostRunModal({
    super.key,
    required this.stats,
    required this.onSave,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundColor.withValues(alpha: 0.95),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header
              const Text(
                'Run Complete! 🎉',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // Stats card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  children: [
                    // Duration
                    _buildStatRow(
                      icon: Icons.timer_outlined,
                      label: 'Duration',
                      value: stats.formattedDuration,
                    ),
                    const Divider(color: AppTheme.borderColor, height: 32),

                    // Distance
                    _buildStatRow(
                      icon: Icons.straighten,
                      label: 'Distance',
                      value: '${stats.formattedDistance} km',
                    ),
                    const Divider(color: AppTheme.borderColor, height: 32),

                    // Average Pace
                    _buildStatRow(
                      icon: Icons.speed,
                      label: 'Avg Pace',
                      value: '${stats.formattedPace} /km',
                    ),
                    const Divider(color: AppTheme.borderColor, height: 32),

                    // Territory captured
                    _buildStatRow(
                      icon: Icons.hexagon_outlined,
                      label: 'Territory Captured',
                      value: stats.formattedArea,
                      isHighlighted: true,
                    ),
                  ],
                ),
              ),

              // Loop indicator
              if (stats.capturedPolygon?.isLoop == true)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.successColor.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle,
                          color: AppTheme.successColor, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Perfect Loop! Maximum area captured',
                        style: TextStyle(
                          color: AppTheme.successColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDiscard,
                      icon: const Icon(Icons.delete_outline,
                          color: AppTheme.errorColor),
                      label: const Text('Discard',
                          style: TextStyle(color: AppTheme.errorColor)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.errorColor),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: onSave,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Save Run'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    bool isHighlighted = false,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isHighlighted
                ? AppTheme.primaryColor.withValues(alpha: 0.1)
                : AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isHighlighted ? AppTheme.primaryColor : AppTheme.textMuted,
            size: 22,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isHighlighted ? AppTheme.primaryColor : Colors.white,
            fontSize: isHighlighted ? 20 : 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
