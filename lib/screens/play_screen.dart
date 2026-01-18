import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/dashboard/globe_3d_webview.dart';
import '../widgets/dashboard/bottom_sheet.dart';
import '../widgets/dashboard/top_nav_bar.dart';
import '../widgets/dashboard/side_action_buttons.dart';
import '../widgets/clubs/my_club_bottom_sheet.dart';

/// PlayScreen - Matches TypeScript play.tsx exactly
class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  double? _userLat;
  double? _userLng;
  String _activeTab = 'single'; // 'lobby' | 'single' | 'club'
  String _activeSheetTab =
      'leaderboard'; // 'leaderboard' | 'events' | 'territories' | 'history'
  final GlobalKey<Globe3DWebViewState> _globeKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _requestLocationAndGetPosition();
  }

  Future<void> _requestLocationAndGetPosition() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Handle denied
        setState(() {
          // Default to Mumbai
          _userLat = 19.076;
          _userLng = 72.8777;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _userLat = position.latitude;
        _userLng = position.longitude;
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
      // Default to Mumbai
      setState(() {
        _userLat = 19.076;
        _userLng = 72.8777;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05090D),
      body: Stack(
        children: [
          // 3D globe background
          if (_userLat != null && _userLng != null)
            Positioned.fill(
              child: Globe3DWebView(
                key: _globeKey,
                userLat: _userLat!,
                userLng: _userLng!,
                territories: const [],
              ),
            ),

          // Safe area content overlay
          SafeArea(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Top navigation tabs - starts at padding 40 in TS
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: TopNavBar(
                    activeTab: _activeTab,
                    onTabChange: (tab) => setState(() => _activeTab = tab),
                  ),
                ),

                // Notification bell - matching TS absolute top: 70, left: 16
                Positioned(
                  top: 70,
                  left: 16,
                  child: _buildNotificationButton(),
                ),

                // My runs label - matching TS absolute top: 130, left: 16
                const Positioned(
                  top: 130,
                  left: 16,
                  child: Text(
                    'My runs',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Side action buttons - matching TS component absolute top: 100, right: 16
                Positioned(
                  top: 100,
                  right: 16,
                  child: SideActionButtons(
                    onHelpPress: () {
                      // Zoom to user's location when question mark button is pressed
                      if (_userLat != null && _userLng != null) {
                        _globeKey.currentState
                            ?.zoomToLocation(_userLat!, _userLng!);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Bottom sheet - rendered outside SafeArea for proper gesture handling
          if (_activeTab != 'club')
            DraggableBottomSheet(
              activeTab: _activeSheetTab,
              onTabChange: (tab) => setState(() => _activeSheetTab = tab),
            ),

          // Club bottom sheet
          if (_activeTab == 'club')
            MyClubBottomSheet(
              visible: true,
              onCreateClub: () {
                // Navigate to create club screen
                Navigator.pushNamed(context, '/clubs/create');
              },
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationButton() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifications coming soon')),
        );
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Icon(
          Icons.notifications_outlined,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
