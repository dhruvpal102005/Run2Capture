import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../config/app_theme.dart';
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
  String? _locationError;
  String _activeTab = 'single'; // 'lobby' | 'single' | 'club'
  String _activeSheetTab = 'leaderboard'; // 'leaderboard' | 'events' | 'territories' | 'history'

  final GlobalKey<Globe3DWebViewState> _globeKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _requestLocationAndGetPosition();
  }

  Future<void> _requestLocationAndGetPosition() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'Location permission denied';
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
              children: [
                // Top section
                Column(
                  children: [
                    const SizedBox(height: 40),
                    // Notification bell - top left
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _buildNotificationButton(),
                      ),
                    ),
                  ],
                ),

                // Top navigation tabs - matching TypeScript TopNavBar
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: TopNavBar(
                    activeTab: _activeTab,
                    onTabChange: (tab) => setState(() => _activeTab = tab),
                  ),
                ),

                // My runs label - matching TypeScript myRunsContainer
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

                // Side action buttons - matching TypeScript SideActionButtons
                Positioned(
                  right: 16,
                  top: 180,
                  child: SideActionButtons(
                    onHelpPress: () {
                      // Zoom to user's location when question mark button is pressed
                      if (_userLat != null && _userLng != null) {
                        _globeKey.currentState?.zoomToLocation(_userLat!, _userLng!);
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
        // TODO: Open notifications
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
