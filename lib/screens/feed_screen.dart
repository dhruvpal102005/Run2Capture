import 'package:flutter/material.dart';

import '../config/app_theme.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        title: const Text(
          'Feed',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryColor),
            onPressed: () {
              // TODO: Open create post modal
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: Colors.white,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [
            Tab(text: 'Explore'),
            Tab(text: 'Following'),
            Tab(text: 'Groups'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExploreTab(),
          _buildFollowingTab(),
          _buildGroupsTab(),
        ],
      ),
    );
  }

  Widget _buildExploreTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5, // Mock data
      itemBuilder: (context, index) {
        return _buildPostCard(
          username: 'Runner ${index + 1}',
          timeAgo: '${index + 1}h',
          content: 'Just captured ${(index + 1) * 0.5} km² in my morning run! 🏃‍♂️',
          likes: 12 + index * 5,
          comments: 3 + index,
        );
      },
    );
  }

  Widget _buildFollowingTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: AppTheme.textMuted.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Follow runners to see their activity',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Open search users
            },
            icon: const Icon(Icons.search),
            label: const Text('Find Runners'),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.groups_outlined,
            size: 64,
            color: AppTheme.textMuted.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Join Terra Clubs',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Connect with runners in your area',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/clubs');
            },
            icon: const Icon(Icons.explore),
            label: const Text('Explore Clubs'),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard({
    required String username,
    required String timeAgo,
    required String content,
    required int likes,
    required int comments,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppTheme.territoryGradient,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    username[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz, color: AppTheme.textMuted),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Content
          Text(
            content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              _buildActionButton(Icons.favorite_border, likes.toString()),
              const SizedBox(width: 24),
              _buildActionButton(Icons.chat_bubble_outline, comments.toString()),
              const Spacer(),
              _buildActionButton(Icons.share_outlined, ''),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textMuted, size: 20),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 13,
            ),
          ),
        ],
      ],
    );
  }
}
