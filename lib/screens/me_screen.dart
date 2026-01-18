import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.appUser;

    // Mock Data for UI to match TS me.tsx
    final challenges = [
      {
        'id': 1,
        'title': 'Add a profile picture',
        'xp': 10,
        'icon': Icons.person_add_outlined
      },
      {
        'id': 2,
        'title': 'Enter referral code',
        'xp': 30,
        'icon': Icons.card_giftcard_outlined
      },
      {
        'id': 3,
        'title': 'Add geofence privacy',
        'xp': 10,
        'icon': Icons.public_outlined
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(user?.imageUrl, user?.displayName),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildProfileSection(user?.imageUrl, user?.displayName),
                    _buildXPChallenges(challenges),
                    _buildCompetitions(),
                    _buildEntryVault(),
                    _buildLocalBattles(),
                    _buildInsights(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String? imageUrl, String? name) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none,
                color: Colors.white, size: 24),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const Text(
            'ME',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: imageUrl != null
                ? Image.network(imageUrl, fit: BoxFit.cover)
                : const Icon(Icons.person, color: Colors.black, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(String? imageUrl, String? name) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: imageUrl != null
                    ? Image.network(imageUrl, fit: BoxFit.cover)
                    : Container(
                        color: const Color(0xFF333333),
                        child: Center(
                          child: Text(
                            name?.isNotEmpty == true
                                ? name![0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
              ),
              Positioned(
                bottom: -5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white),
                  ),
                  child: const Text('LO',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('10XP to next level',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              Text('Level 1',
                  style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            clipBehavior: Clip.antiAlias,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.1,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5555),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Next unlock: Level 2',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    Text('Community Feed',
                        style: TextStyle(color: Colors.black54, fontSize: 14)),
                  ],
                ),
                Icon(Icons.chevron_right, color: Colors.black, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildXPChallenges(List<Map<String, dynamic>> challenges) {
    return Column(
      children: [
        _buildSectionHeader(Icons.military_tech_outlined, 'XP Challenges',
            'earn XP to level up'),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: challenges.length,
            itemBuilder: (context, index) {
              final challenge = challenges[index];
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(challenge['icon'] as IconData,
                        size: 32, color: Colors.black),
                    Text(challenge['title'] as String,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE5E5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('+ ${challenge['xp']} XP',
                          style: const TextStyle(
                              color: Color(0xFFFF5555),
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildCompetitions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildSectionHeader(Icons.emoji_events_outlined, 'Competitions',
              'Unlocks at level 7'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Terra Comp 26.1 | \$1,277 AUD in Prizes',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text('Starts in: 2d 12h 44m 11s',
                    style: TextStyle(color: Color(0xFF555555), fontSize: 14)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildBrandBox('GARMIN.'),
                    const SizedBox(width: 8),
                    _buildBrandBox('GARMIN.'),
                    const SizedBox(width: 8),
                    _buildBrandBox('WHOOP'),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Start 2026 with some wearables to track your runs, this competition includes Garmin watches and Whoop, available to enter from anywhere in the world.',
                  style: TextStyle(
                      color: Color(0xFF333333), fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('View competition',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildBrandBox(String text) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildEntryVault() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildSectionHeader(Icons.confirmation_num_outlined, 'Entry Vault',
              'Unlocks at level 8'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildVaultStat('0', 'Entries in vault'),
                    _buildVaultStat('0', 'Active Entries'),
                    _buildVaultStat('0', 'Used Entries'),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Vault milestones',
                    style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 14)),
                const SizedBox(height: 12),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 12,
                      left: 20,
                      right: 20,
                      child: Container(
                          height: 4, color: Colors.red.withValues(alpha: 0.1)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMilestoneDot(const Color(0xFFFF8888), 'Level 0'),
                        _buildMilestoneIcon(
                            Icons.card_giftcard_outlined, 'Level 10'),
                        _buildMilestoneIcon(
                            Icons.card_giftcard_outlined, 'Level 12'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBBBBBB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('Open vault',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildVaultStat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Color(0xFFAAAAAA),
                  fontSize: 24,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMilestoneDot(Color color, String label) {
    return Column(
      children: [
        Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 12)),
      ],
    );
  }

  Widget _buildMilestoneIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 24, color: const Color(0xFFAAAAAA)),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 12)),
      ],
    );
  }

  Widget _buildLocalBattles() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildSectionHeader(
              Icons.close, 'Local battles', 'Unlocks at level 9'),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Text('No local battles yet',
                    style: TextStyle(
                        color: Color(0xFF555555),
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: 8),
                Text(
                  'Once you steal someone\'s territory or they steal yours, it will show up here',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color(0xFFAAAAAA), fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInsights() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              _buildSectionHeader(
                  Icons.pie_chart_outline, 'Insights', 'Unlocks at level 18'),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFC5A365),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('PRO',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.pie_chart_outline,
                            size: 20, color: Color(0xFFAAAAAA)),
                        SizedBox(width: 12),
                        Text('Insights',
                            style: TextStyle(
                                color: Color(0xFFAAAAAA),
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 50,
                  height: 52,
                  color: const Color(0xFFDDDDDD),
                  child: const Icon(Icons.arrow_forward,
                      size: 20, color: Color(0xFFAAAAAA)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.black, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text(subtitle,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6), fontSize: 14)),
          ],
        ),
      ],
    );
  }
}
