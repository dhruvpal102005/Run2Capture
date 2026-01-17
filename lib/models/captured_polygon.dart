import 'location_point.dart';

/// Captured territory polygon during a run
class CapturedPolygon {
  final List<LatLng> coordinates;
  final double area; // in square meters
  final bool isLoop; // true if user completed a loop, false if auto-closed

  CapturedPolygon({
    required this.coordinates,
    required this.area,
    required this.isLoop,
  });

  factory CapturedPolygon.fromJson(Map<String, dynamic> json) {
    final coordsList = json['coordinates'] as List<dynamic>;
    return CapturedPolygon(
      coordinates: coordsList.map((c) => LatLng(
        latitude: (c['latitude'] as num).toDouble(),
        longitude: (c['longitude'] as num).toDouble(),
      )).toList(),
      area: (json['area'] as num).toDouble(),
      isLoop: json['isLoop'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coordinates': coordinates.map((c) => {
        'latitude': c.latitude,
        'longitude': c.longitude,
      }).toList(),
      'area': area,
      'isLoop': isLoop,
    };
  }
}

/// Simple LatLng class for coordinates
class LatLng {
  final double latitude;
  final double longitude;

  LatLng({required this.latitude, required this.longitude});

  factory LatLng.fromLocationPoint(LocationPoint point) {
    return LatLng(latitude: point.latitude, longitude: point.longitude);
  }
}
