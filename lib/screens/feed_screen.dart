import 'package:flutter/material.dart';
import '../models/models.dart';

enum FeedTab { explore, groups, following }

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  FeedTab _activeTab = FeedTab.explore;

  // Mock data to match TS implementation
  final Map<String, int> _followCounts = {'following': 12, 'followers': 105};
  // The following line was part of the instruction but is syntactically incorrect for a List initialization.
  // It appears to be intended for the _buildExploreTab method.
  // final List<Post> _explorePosts = [
  //   return const Column(
  //     children: [
  //       FeedPostCard(
  //         userName: 'Marcus R.',
  //         content:
  //             'Just finished a morning run through Central Park. The new territory capture feature is addictive! Anyone else hitting the park today?',
  //         createdAt: '2h',
  //         likesCount: 12,
  //         commentsCount: 4,
  //       ),
  //       SizedBox(height: 16),
  //       FeedPostCard(
  //         userName: 'Elena S.',
  //         content:
  //             'Join our group "Elite Runners" for the weekend challenge. We are aiming to capture the entire downtown area!',
  //         createdAt: '5h',
  //         likesCount: 24,
  //         commentsCount: 8,
  //       ),
  //     ],
  //   );
  // ];
  // Keeping the original _explorePosts for now, as the instruction for it was malformed.
  final List<Post> _explorePosts = [
    Post(
      id: '1',
      userId: 'user1',
      userName: 'Alex Hoffman',
      content:
          'Just smashed my PB in Central Park! The new territory capture feature is addicting.',
      type: 'status',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      likesCount: 24,
      commentsCount: 5,
    ),
    Post(
      id: '2',
      userId: 'user2',
      userName: 'Sarah Chen',
      content:
          'Looking for a running partner in Sydney CBD. Level 150+ preferred!',
      type: 'status',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      likesCount: 12,
      commentsCount: 8,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none,
                color: Colors.white, size: 22),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const Text(
            'FEED',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline,
                color: Color(0xFF0D0D0D), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: FeedTab.values.map((tab) {
          final isSelected = _activeTab == tab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = tab),
              child: Column(
                children: [
                  Text(
                    tab == FeedTab.explore
                        ? 'Explore'
                        : (tab == FeedTab.groups ? 'Groups' : 'Following'),
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.6),
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isSelected)
                    Container(
                      height: 2,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    )
                  else
                    const SizedBox(height: 2),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_activeTab) {
      case FeedTab.following:
        return _buildFollowingTab();
      case FeedTab.groups:
        return _buildGroupsTab();
      case FeedTab.explore:
        return _buildExploreTab();
    }
  }

  Widget _buildExploreTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // Leaderboard Button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF151515),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            // Added const
            children: [
              Icon(Icons.emoji_events_outlined, color: Colors.white, size: 18),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Country territory leaderboards',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.white, size: 18),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Pinned Post
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF151515),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF6E6E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kapture',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Pinned post',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.7,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6E6E),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      // Added const
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('257XP to next level',
                            style: TextStyle(
                                color: Color(0xFF555555),
                                fontSize: 11,
                                fontWeight: FontWeight.w500)),
                        Text('Level 135',
                            style: TextStyle(
                                color: Color(0xFF555555),
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Column(
                        // Added const
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Next unlock: Level 150',
                              style: TextStyle(
                                  color: Color(0xFF111111),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                          Text('Diamond skin',
                              style: TextStyle(
                                  color: Color(0xFF555555), fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '🎉 New Year\'s Day Challenge 🎉',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'To kick off 2026, we\'re giving you a reason to get moving. Run with Kapture on New Year\'s Day, and you\'ll unlock a limited-edition NYD Skin for your profile, only available for this one day.',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                    height: 1.4),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        const Text(
          'Recent Posts',
          style: TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        // The instruction for _explorePosts was malformed, so keeping original logic.
        // If the intent was to replace with FeedPostCard, that would require a different instruction.
        ..._explorePosts.map((post) => _buildPostCard(post)),
      ],
    );
  }

  Widget _buildFollowingTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCountItem(_followCounts['following']!, 'Following'),
              const SizedBox(width: 40),
              _buildCountItem(_followCounts['followers']!, 'Followers'),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: const Center(
              child: Text(
                'Add friends',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF151515),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.people_outline,
                    size: 40, color: Colors.white.withValues(alpha: 0.4)),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Share your thoughts or ask a question…',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No one you follow completed a run yet.',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCountItem(int count, String label) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildGroupsTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        const Text(
          'Enter a group code or join an existing group below!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) => _buildCodeBox()),
        ),
        const SizedBox(height: 28),
        const Text(
          'Suggested groups',
          style: TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _buildGroupCard('Kapture Runners'),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF151515),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'View all groups',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeBox() {
    return Container(
      width: 42,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
      ),
    );
  }

  Widget _buildGroupCard(String name) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(height: 80, color: const Color(0xFF333333)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                const Text(
                  'JOIN GROUP',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF6E6E),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    post.userName[0].toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.userName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    Text(
                      _formatTime(post.createdAt),
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            post.content,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
                height: 1.4),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
