import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../config/app_theme.dart';
import '../services/run_tracking_service.dart';
import '../models/location_point.dart';
import '../models/run_stats.dart';
import '../widgets/run/gps_permission_modal.dart';
import '../widgets/run/post_run_modal.dart';

// Run state enum matching TypeScript
enum RunState { idle, running, paused, finished }

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> with TickerProviderStateMixin {
  // Map controller
  GoogleMapController? _mapController;
  
  // Tracking service
  final RunTrackingService _trackingService = RunTrackingService();
  
  // State matching TypeScript
  LatLng? _userLocation;
  bool _mapReady = false;
  bool _showPermissionModal = false;
  bool _hasPermission = false;
  RunState _runState = RunState.idle;
  bool _showPostRunModal = false;
  List<LocationPoint> _routeCoordinates = [];
  bool _isHoldingFinish = false;
  bool _followUser = true; // Camera follows user like Strava

  // Stats
  double _distance = 0;
  int _duration = 0;
  double _pace = 0;
  int _capturedArea = 0;
  RunStats? _finalStats;

  // Animation controllers matching TypeScript
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _finishProgressController;

  @override
  void initState() {
    super.initState();
    
    // Pulse animation for location marker
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.8).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Finish button progress animation
    _finishProgressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _checkPermissions();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _finishProgressController.dispose();
    _mapController?.dispose();
    _trackingService.reset();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    final status = await Geolocator.checkPermission();
    if (status == LocationPermission.always || status == LocationPermission.whileInUse) {
      setState(() {
        _hasPermission = true;
        _showPermissionModal = false;
      });
      await _initializeLocation();
    } else {
      setState(() => _showPermissionModal = true);
    }
  }

  Future<void> _initializeLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
      setState(() {
        _userLocation = const LatLng(19.076, 72.8777); // Mumbai default
      });
    }
  }

  Future<void> _handlePermissionAccept() async {
    setState(() => _showPermissionModal = false);
    final granted = await _trackingService.requestPermissions();
    if (granted) {
      setState(() => _hasPermission = true);
      await _initializeLocation();
    }
  }

  void _handlePermissionDeny() {
    setState(() => _showPermissionModal = false);
  }

  Future<void> _handleStartRun() async {
    if (!_hasPermission) {
      setState(() => _showPermissionModal = true);
      return;
    }

    final started = await _trackingService.startTracking(
      onLocationUpdate: (location) {
        final newLocation = LatLng(location.latitude, location.longitude);
        setState(() {
          _userLocation = newLocation;
          _routeCoordinates = [..._routeCoordinates, location];
        });

        // Animate camera to follow user if followUser is enabled
        if (_followUser && _mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: newLocation,
                zoom: 17, // Closer zoom during run
              ),
            ),
          );
        }
      },
      onStatsUpdate: (stats) {
        setState(() {
          _distance = stats.distance;
          _duration = stats.duration;
          _pace = stats.averagePace;
          _capturedArea = stats.capturedArea.floor();
        });
      },
    );

    if (started) {
      setState(() {
        _runState = RunState.running;
        _routeCoordinates = [];
        _followUser = true;
      });
    }
  }

  void _handlePauseRun() {
    _trackingService.pauseTracking();
    setState(() => _runState = RunState.paused);
  }

  void _handleResumeRun() {
    _trackingService.resumeTracking();
    setState(() => _runState = RunState.running);
  }

  void _handleFinishPressIn() {
    setState(() => _isHoldingFinish = true);
    _finishProgressController.forward().then((_) {
      if (_isHoldingFinish) {
        _handleFinishRun();
      }
    });
  }

  void _handleFinishPressOut() {
    setState(() => _isHoldingFinish = false);
    _finishProgressController.reverse();
  }

  void _handleFinishRun() {
    setState(() => _isHoldingFinish = false);
    _finishProgressController.reset();
    final stats = _trackingService.stopTracking();
    setState(() {
      _finalStats = stats;
      _runState = RunState.finished;
      _showPostRunModal = true;
    });
  }

  void _handleSaveRun() {
    // TODO: Save run to backend/database
    debugPrint('Saving run: $_finalStats');
    setState(() => _showPostRunModal = false);
    _resetRun();
  }

  void _handleDiscardRun() {
    setState(() => _showPostRunModal = false);
    _resetRun();
  }

  void _resetRun() {
    setState(() {
      _runState = RunState.idle;
      _distance = 0;
      _duration = 0;
      _pace = 0;
      _capturedArea = 0;
      _routeCoordinates = [];
      _finalStats = null;
    });
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatPace(double paceSeconds) {
    if (paceSeconds == 0 || paceSeconds.isInfinite || paceSeconds.isNaN) {
      return '0:00';
    }
    final mins = paceSeconds ~/ 60;
    final secs = (paceSeconds % 60).floor();
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  // Light map style matching TypeScript customMapStyle
  static const String _lightMapStyle = '''
[
  {"elementType": "geometry", "stylers": [{"color": "#f5f1eb"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#8a8a8a"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#ffffff"}]},
  {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#c9c0b6"}]},
  {"featureType": "road", "elementType": "geometry.stroke", "stylers": [{"color": "#b8b0a6"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#e8e4de"}]},
  {"featureType": "poi", "stylers": [{"visibility": "off"}]},
  {"featureType": "transit", "stylers": [{"visibility": "off"}]}
]
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // Map background
          _buildMapContainer(),

          // Bottom stats panel
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildStatsPanel(),
          ),

          // GPS Permission modal
          if (_showPermissionModal)
            GpsPermissionModal(
              onRequestPermission: _handlePermissionAccept,
              onDismiss: _handlePermissionDeny,
            ),

          // Post run modal
          if (_showPostRunModal && _finalStats != null)
            PostRunModal(
              stats: _finalStats!,
              onSave: _handleSaveRun,
              onDiscard: _handleDiscardRun,
            ),
        ],
      ),
    );
  }

  Widget _buildMapContainer() {
    if (_userLocation == null) {
      return Container(
        color: const Color(0xFFF5F5F5),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
        ),
      );
    }

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _userLocation!,
            zoom: 15,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
            _mapController?.setMapStyle(_lightMapStyle);
            setState(() => _mapReady = true);
          },
          onCameraMoveStarted: () {
            // Disable auto-follow when user pans
            setState(() => _followUser = false);
          },
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: false,
          mapToolbarEnabled: false,
          polylines: _routeCoordinates.length > 1
              ? {
                  Polyline(
                    polylineId: const PolylineId('route'),
                    points: _routeCoordinates
                        .map((loc) => LatLng(loc.latitude, loc.longitude))
                        .toList(),
                    color: const Color(0xFF3B82F6),
                    width: 4,
                  ),
                }
              : {},
          markers: _userLocation != null
              ? {
                  Marker(
                    markerId: const MarkerId('user'),
                    position: _userLocation!,
                    anchor: const Offset(0.5, 0.5),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueAzure,
                    ),
                  ),
                }
              : {},
        ),

        // Back button - matching TypeScript headerOverlay
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: GestureDetector(
              onTap: () {}, // TODO: Navigate back
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.arrow_back, color: Color(0xFF333333), size: 24),
              ),
            ),
          ),
        ),

        // Center on location button - matching TypeScript centerButton
        Positioned(
          top: 100,
          right: 16,
          child: GestureDetector(
            onTap: () {
              if (_mapController != null && _userLocation != null) {
                setState(() => _followUser = true);
                _mapController!.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: _userLocation!, zoom: 17),
                  ),
                );
              }
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: !_followUser && _runState == RunState.running
                    ? Border.all(color: const Color(0xFF3B82F6), width: 2)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _followUser ? Icons.my_location : Icons.location_searching,
                size: 20,
                color: !_followUser && _runState == RunState.running
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFF666666),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsPanel() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // GPS Status - matching TypeScript gpsRow
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.signal_cellular_alt,
                    size: 20,
                    color: _hasPermission ? Colors.green : const Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'GPS',
                    style: TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Captured area - matching TypeScript areaContainer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$_capturedArea',
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      height: 1.1,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12, left: 2),
                    child: Text(
                      'm²',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ],
              ),

              // Capture status text
              Text(
                _runState == RunState.running
                    ? 'Capture in Progress'
                    : _runState == RunState.paused
                        ? 'Paused'
                        : 'Ready to Start',
                style: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Stats row - matching TypeScript statsRow
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(
                    '${_distance.toStringAsFixed(2)}',
                    'km',
                    'Distance',
                  ),
                  _buildStatItem(
                    _formatTime(_duration),
                    '',
                    'Duration',
                  ),
                  _buildStatItem(
                    _formatPace(_pace),
                    '',
                    'Average pace',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Action buttons based on run state
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String unit, String label) {
    return Expanded(
      child: Column(
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
              children: [
                TextSpan(text: value),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: unit,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    switch (_runState) {
      case RunState.idle:
        return Column(
          children: [
            // Start button - matching TypeScript startButton
            GestureDetector(
              onTap: _handleStartRun,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE5E5E5)),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Start Run',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {}, // TODO: View other options
              child: const Text(
                'View other options',
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        );

      case RunState.running:
      case RunState.paused:
        return Row(
          children: [
            // Pause/Resume button
            Expanded(
              child: GestureDetector(
                onTap: _runState == RunState.running
                    ? _handlePauseRun
                    : _handleResumeRun,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE5E5E5)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _runState == RunState.running
                            ? Icons.pause
                            : Icons.play_arrow,
                        size: 20,
                        color: const Color(0xFF1A1A1A),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _runState == RunState.running ? 'Pause Run' : 'Resume Run',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Hold to Finish button - matching TypeScript finishButton
            Expanded(
              child: GestureDetector(
                onTapDown: (_) => _handleFinishPressIn(),
                onTapUp: (_) => _handleFinishPressOut(),
                onTapCancel: _handleFinishPressOut,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // Progress indicator
                      AnimatedBuilder(
                        animation: _finishProgressController,
                        builder: (context, child) {
                          return Positioned.fill(
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: _finishProgressController.value,
                              child: Container(
                                color: const Color(0xFFEF4444),
                              ),
                            ),
                          );
                        },
                      ),
                      // Button content
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.stop, size: 20, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Hold to Finish',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );

      case RunState.finished:
        return const SizedBox.shrink();
    }
  }
}
