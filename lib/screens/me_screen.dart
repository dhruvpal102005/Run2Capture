import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_theme.dart';
import '../services/auth_service.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.appUser;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Colors.white),
                    onPressed: () {
                      // TODO: Open settings
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Profile card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderColor, width: 0.5),
                ),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppTheme.territoryGradient,
                        ),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: user?.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: Image.network(
                                user!.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Text(
                                    user.initials,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                user?.initials ?? '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),

                    // Name
                    Text(
                      user?.displayName ?? 'Anonymous',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem('Following', '${user?.followingCount ?? 0}'),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppTheme.borderColor,
                        ),
                        _buildStatItem('Followers', '${user?.followersCount ?? 0}'),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppTheme.borderColor,
                        ),
                        _buildStatItem('Runs', '0'), // TODO: Fetch from service
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Stats section
              const Text(
                'Your Stats',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Stats grid
              Row(
                children: [
                  Expanded(child: _buildStatCard('Total Distance', '0.0 km', Icons.straighten)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Territory', '0 m²', Icons.hexagon_outlined)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Runs', '0', Icons.directions_run)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Time', '0:00', Icons.timer_outlined)),
                ],
              ),
              const SizedBox(height: 32),

              // Menu items
              _buildMenuItem(
                icon: Icons.history,
                title: 'Run History',
                onTap: () {},
              ),
              _buildMenuItem(
                icon: Icons.emoji_events_outlined,
                title: 'Achievements',
                onTap: () {},
              ),
              _buildMenuItem(
                icon: Icons.people_outline,
                title: 'Friends',
                onTap: () {},
              ),
              _buildMenuItem(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {},
              ),
              const SizedBox(height: 16),

              // Sign out button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppTheme.surfaceColor,
                        title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                        content: const Text(
                          'Are you sure you want to sign out?',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              authService.signOut();
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Sign Out',
                              style: TextStyle(color: AppTheme.errorColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout, color: AppTheme.errorColor),
                  label: const Text('Sign Out', style: TextStyle(color: AppTheme.errorColor)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.errorColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppTheme.borderColor, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textSecondary, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
