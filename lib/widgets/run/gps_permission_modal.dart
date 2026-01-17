import 'package:flutter/material.dart';

import '../../config/app_theme.dart';

class GpsPermissionModal extends StatelessWidget {
  final VoidCallback onRequestPermission;
  final VoidCallback onDismiss;

  const GpsPermissionModal({
    super.key,
    required this.onRequestPermission,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: AppTheme.primaryColor,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Enable Location',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                'Kapture needs access to your location to track your runs and capture territory. Your location data is only used while running.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Enable button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRequestPermission,
                  icon: const Icon(Icons.my_location, size: 20),
                  label: const Text('Enable Location'),
                ),
              ),
              const SizedBox(height: 12),

              // Not now button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: onDismiss,
                  child: Text(
                    'Not Now',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
