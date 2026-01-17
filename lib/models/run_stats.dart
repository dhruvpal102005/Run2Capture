import 'location_point.dart';
import 'captured_polygon.dart';

/// Run statistics collected during tracking
class RunStats {
  final double distance; // in kilometers
  final int duration; // in seconds
  final double averagePace; // in seconds per kilometer
  final double capturedArea; // in square meters
  final List<LocationPoint> locations;
  final CapturedPolygon? capturedPolygon;

  RunStats({
    required this.distance,
    required this.duration,
    required this.averagePace,
    required this.capturedArea,
    required this.locations,
    this.capturedPolygon,
  });

  factory RunStats.empty() {
    return RunStats(
      distance: 0,
      duration: 0,
      averagePace: 0,
      capturedArea: 0,
      locations: [],
    );
  }

  factory RunStats.fromJson(Map<String, dynamic> json) {
    return RunStats(
      distance: (json['distance'] as num).toDouble(),
      duration: json['duration'] as int,
      averagePace: (json['averagePace'] as num).toDouble(),
      capturedArea: (json['capturedArea'] as num).toDouble(),
      locations: (json['locations'] as List<dynamic>)
          .map((l) => LocationPoint.fromJson(l as Map<String, dynamic>))
          .toList(),
      capturedPolygon: json['capturedPolygon'] != null
          ? CapturedPolygon.fromJson(json['capturedPolygon'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'distance': distance,
      'duration': duration,
      'averagePace': averagePace,
      'capturedArea': capturedArea,
      'locations': locations.map((l) => l.toJson()).toList(),
      if (capturedPolygon != null) 'capturedPolygon': capturedPolygon!.toJson(),
    };
  }

  /// Format duration as HH:MM:SS
  String get formattedDuration {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    final seconds = duration % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format pace as MM:SS/km
  String get formattedPace {
    if (averagePace <= 0 || averagePace.isInfinite || averagePace.isNaN) {
      return '--:--';
    }
    final minutes = averagePace ~/ 60;
    final seconds = (averagePace % 60).round();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format distance as X.XX km
  String get formattedDistance {
    return distance.toStringAsFixed(2);
  }

  /// Format captured area with appropriate unit
  String get formattedArea {
    if (capturedArea >= 1000000) {
      return '${(capturedArea / 1000000).toStringAsFixed(2)} km²';
    } else if (capturedArea >= 1000) {
      return '${(capturedArea / 1000).toStringAsFixed(1)} km²';
    } else {
      return '${capturedArea.round()} m²';
    }
  }
}
