import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';

import '../models/location_point.dart';
import '../models/run_stats.dart';
import '../models/captured_polygon.dart';

/// RunTrackingService - Matches TypeScript runTrackingService.ts exactly
class RunTrackingService {
  // Location subscription
  StreamSubscription<Position>? _locationSubscription;
  
  // Timing
  int _startTime = 0;
  int _pauseTime = 0;
  int _totalPausedDuration = 0;
  
  // Location storage
  List<LocationPoint> _locations = [];
  List<LocationPoint> _validLocations = []; // Only locations that passed filtering
  List<LocationPoint> _smoothedLocations = []; // Smoothed locations for route display
  
  // Callbacks
  void Function(LocationPoint)? _onLocationUpdate;
  void Function(RunStats)? _onStatsUpdate;
  Timer? _updateInterval;

  // GPS filtering constants - matching TypeScript exactly
  static const double minDistanceThreshold = 0.005; // ~5 meters in kilometers
  static const double maxAccuracy = 30; // Ignore readings with accuracy worse than 30 meters
  static const int paceSmoothingWindow = 10; // Number of recent pace values for smoothing
  static const double minDistanceForPace = 0.01; // Minimum 10m before calculating pace

  // Loop detection threshold
  static const double loopThresholdMeters = 50; // Distance to consider start/end as a loop

  // Pace tracking
  List<double> _recentPaces = [];
  double _lastCalculatedDistance = 0;
  double _cachedDistance = 0;

  /// Get current locations
  List<LocationPoint> get locations => List.unmodifiable(_locations);

  /// Request location permissions
  Future<bool> requestPermissions() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Start tracking - matches TypeScript startTracking()
  Future<bool> startTracking({
    required void Function(LocationPoint) onLocationUpdate,
    required void Function(RunStats) onStatsUpdate,
  }) async {
    try {
      final hasPermission = await requestPermissions();
      if (!hasPermission) return false;

      _onLocationUpdate = onLocationUpdate;
      _onStatsUpdate = onStatsUpdate;
      _startTime = DateTime.now().millisecondsSinceEpoch;
      _totalPausedDuration = 0;
      _locations = [];
      _validLocations = [];
      _smoothedLocations = [];
      _recentPaces = [];
      _cachedDistance = 0;
      _lastCalculatedDistance = 0;

      // Start location tracking with high accuracy
      _locationSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 5, // Update every 5 meters
        ),
      ).listen((position) {
        final point = LocationPoint(
          latitude: position.latitude,
          longitude: position.longitude,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          accuracy: position.accuracy,
        );

        // Always add to all locations for route display
        _locations.add(point);
        _onLocationUpdate?.call(point);

        // Filter and validate location before adding to valid locations
        if (_isValidLocation(point)) {
          _validLocations.add(point);
          // Smooth the location for cleaner route display
          _smoothLocation(point);
          // Update stats only when we have valid movement
          _updateStats();
        } else {
          // Still update stats periodically
          _updateStats();
        }
      });

      // Update stats every second for smooth UI updates
      _updateInterval = Timer.periodic(const Duration(seconds: 1), (_) {
        _updateStats();
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if location is valid - matches TypeScript isValidLocation()
  bool _isValidLocation(LocationPoint point) {
    // Check accuracy - ignore readings with poor accuracy
    if (point.accuracy != null && point.accuracy! > maxAccuracy) {
      return false;
    }

    // If this is the first location, always accept it
    if (_validLocations.isEmpty) {
      return true;
    }

    // Check if movement is significant enough (filters GPS drift/noise)
    final lastValidLocation = _validLocations.last;
    final distance = _calculateDistance(lastValidLocation, point);

    // Only accept if moved more than threshold
    return distance >= minDistanceThreshold;
  }

  /// Smooth location using weighted average - matches TypeScript smoothLocation()
  LocationPoint _smoothLocation(LocationPoint point) {
    const smoothingWindow = 3;

    _smoothedLocations.add(point);

    if (_smoothedLocations.length < smoothingWindow) {
      return point;
    }

    final recentPoints = _smoothedLocations.skip(
      _smoothedLocations.length - smoothingWindow
    ).toList();

    double totalLat = 0;
    double totalLng = 0;
    double totalWeight = 0;

    for (int i = 0; i < recentPoints.length; i++) {
      final weight = (i + 1).toDouble();
      totalLat += recentPoints[i].latitude * weight;
      totalLng += recentPoints[i].longitude * weight;
      totalWeight += weight;
    }

    final smoothedPoint = LocationPoint(
      latitude: totalLat / totalWeight,
      longitude: totalLng / totalWeight,
      timestamp: point.timestamp,
      accuracy: point.accuracy,
    );

    _smoothedLocations[_smoothedLocations.length - 1] = smoothedPoint;
    return smoothedPoint;
  }

  /// Pause tracking
  void pauseTracking() {
    _pauseTime = DateTime.now().millisecondsSinceEpoch;
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _updateInterval?.cancel();
    _updateInterval = null;
  }

  /// Resume tracking
  void resumeTracking() {
    if (_pauseTime > 0) {
      _totalPausedDuration += DateTime.now().millisecondsSinceEpoch - _pauseTime;
      _pauseTime = 0;
    }

    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    ).listen((position) {
      final point = LocationPoint(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        accuracy: position.accuracy,
      );

      _locations.add(point);
      _onLocationUpdate?.call(point);

      if (_isValidLocation(point)) {
        _validLocations.add(point);
        _updateStats();
      } else {
        _updateStats();
      }
    });

    _updateInterval = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateStats();
    });
  }

  /// Stop tracking and return final stats
  RunStats stopTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _updateInterval?.cancel();
    _updateInterval = null;

    final finalStats = _getStats();
    reset();
    return finalStats;
  }

  /// Update stats - notify callback
  void _updateStats() {
    final stats = _getStats();
    _onStatsUpdate?.call(stats);
  }

  /// Get current stats - matches TypeScript getStats()
  RunStats _getStats() {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final elapsedTime = currentTime - _startTime - _totalPausedDuration;
    final duration = (elapsedTime / 1000).floor().clamp(0, double.maxFinite.toInt());

    // Calculate distance using only valid locations
    if (_validLocations.length > 1) {
      double totalDistance = 0;
      for (int i = 1; i < _validLocations.length; i++) {
        final prev = _validLocations[i - 1];
        final curr = _validLocations[i];
        totalDistance += _calculateDistance(prev, curr);
      }
      if (totalDistance > _cachedDistance) {
        _cachedDistance = totalDistance;
      }
    }

    final distance = _cachedDistance;

    // Calculate smoothed average pace
    double averagePace = 0;
    if (distance >= minDistanceForPace && duration > 0) {
      final distanceChange = distance - _lastCalculatedDistance;
      if (distanceChange >= 0.005) {
        final currentPace = duration / distance; // seconds per kilometer
        if (currentPace >= 120 && currentPace <= 1800) {
          _recentPaces.add(currentPace);
          if (_recentPaces.length > paceSmoothingWindow) {
            _recentPaces.removeAt(0);
          }
          _lastCalculatedDistance = distance;
        }
      }

      if (_recentPaces.length >= 2) {
        double weightedSum = 0;
        double totalWeight = 0;
        for (int i = 0; i < _recentPaces.length; i++) {
          final weight = (i + 1).toDouble();
          weightedSum += _recentPaces[i] * weight;
          totalWeight += weight;
        }
        averagePace = weightedSum / totalWeight;
      } else if (_recentPaces.length == 1) {
        averagePace = _recentPaces[0];
      }
    }

    // Calculate captured polygon
    final capturedPolygon = getCapturedPolygon(_validLocations);
    final capturedArea = capturedPolygon.area;

    return RunStats(
      distance: distance,
      duration: duration,
      averagePace: averagePace,
      capturedArea: capturedArea,
      locations: List.from(_smoothedLocations),
      capturedPolygon: capturedPolygon,
    );
  }

  /// Calculate distance using Haversine formula - matches TypeScript calculateDistance()
  double _calculateDistance(LocationPoint point1, LocationPoint point2) {
    const R = 6371.0; // Earth's radius in kilometers
    final dLat = _toRad(point2.latitude - point1.latitude);
    final dLon = _toRad(point2.longitude - point1.longitude);
    final lat1 = _toRad(point1.latitude);
    final lat2 = _toRad(point2.latitude);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRad(double degrees) {
    return degrees * pi / 180;
  }

  /// Check if route forms a loop - matches TypeScript isLoop()
  bool _isLoop(List<LocationPoint> locations) {
    if (locations.length < 3) return false;

    final start = locations.first;
    final end = locations.last;
    final distanceKm = _calculateDistance(start, end);
    final distanceMeters = distanceKm * 1000;

    return distanceMeters <= loopThresholdMeters;
  }

  /// Get captured polygon - matches TypeScript getCapturedPolygon()
  CapturedPolygon getCapturedPolygon(List<LocationPoint> locations) {
    if (locations.length < 3) {
      return CapturedPolygon(
        coordinates: [],
        area: 0,
        isLoop: false,
      );
    }

    final isLoop = _isLoop(locations);

    // Create coordinates array
    final coordinates = locations
        .map((loc) => LatLng(latitude: loc.latitude, longitude: loc.longitude))
        .toList();

    // If not a loop, close the polygon by adding start point
    if (!isLoop && coordinates.isNotEmpty) {
      coordinates.add(LatLng(
        latitude: locations.first.latitude,
        longitude: locations.first.longitude,
      ));
    }

    // Calculate area using Shoelace formula
    final area = _calculatePolygonArea(coordinates);

    return CapturedPolygon(
      coordinates: coordinates,
      area: area,
      isLoop: isLoop,
    );
  }

  /// Calculate polygon area using Shoelace formula - matches TypeScript calculatePolygonArea()
  double _calculatePolygonArea(List<LatLng> coordinates) {
    if (coordinates.length < 3) return 0;

    // Convert lat/lng to meters relative to first point
    final origin = coordinates[0];
    const metersPerDegreeLat = 111320.0;
    final metersPerDegreeLng = 111320 * cos(_toRad(origin.latitude));

    final points = coordinates.map((coord) => _Point(
      x: (coord.longitude - origin.longitude) * metersPerDegreeLng,
      y: (coord.latitude - origin.latitude) * metersPerDegreeLat,
    )).toList();

    // Shoelace formula
    double area = 0;
    for (int i = 0; i < points.length; i++) {
      final j = (i + 1) % points.length;
      area += points[i].x * points[j].y;
      area -= points[j].x * points[i].y;
    }

    return (area / 2).abs();
  }

  /// Reset all state
  void reset() {
    _startTime = 0;
    _pauseTime = 0;
    _totalPausedDuration = 0;
    _locations = [];
    _validLocations = [];
    _smoothedLocations = [];
    _recentPaces = [];
    _onLocationUpdate = null;
    _onStatsUpdate = null;
    _lastCalculatedDistance = 0;
    _cachedDistance = 0;
  }
}

/// Helper class for area calculation
class _Point {
  final double x;
  final double y;
  _Point({required this.x, required this.y});
}
