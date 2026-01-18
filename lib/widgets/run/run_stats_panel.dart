import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../models/run_stats.dart';

class RunStatsPanel extends StatelessWidget {
  final RunStats stats;
  final bool isPaused;

  const RunStatsPanel({
    super.key,
    required this.stats,
    this.isPaused = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Paused indicator
          if (isPaused)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.pause, color: AppTheme.warningColor, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'PAUSED',
                    style: TextStyle(
                      color: AppTheme.warningColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),

          // Duration (main stat)
          Text(
            stats.formattedDuration,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 56,
              fontWeight: FontWeight.w300,
              letterSpacing: 2,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 20),

          // Other stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                label: 'Distance',
                value: stats.formattedDistance,
                unit: 'km',
              ),
              _buildDivider(),
              _buildStatItem(
                label: 'Pace',
                value: stats.formattedPace,
                unit: '/km',
              ),
              _buildDivider(),
              _buildStatItem(
                label: 'Area',
                value: _formatAreaValue(stats.capturedArea),
                unit: _formatAreaUnit(stats.capturedArea),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required String unit,
  }) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppTheme.borderColor,
    );
  }

  String _formatAreaValue(double area) {
    if (area >= 1000000) {
      return (area / 1000000).toStringAsFixed(2);
    } else if (area >= 1000) {
      return (area / 1000).toStringAsFixed(1);
    } else {
      return area.round().toString();
    }
  }

  String _formatAreaUnit(double area) {
    if (area >= 1000) {
      return 'km²';
    }
    return 'm²';
  }
}
