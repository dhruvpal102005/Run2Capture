/// GPS location point with timestamp and accuracy
class LocationPoint {
  final double latitude;
  final double longitude;
  final int timestamp;
  final double? accuracy;

  LocationPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.accuracy,
  });

  factory LocationPoint.fromJson(Map<String, dynamic> json) {
    return LocationPoint(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: json['timestamp'] as int,
      accuracy: json['accuracy'] != null ? (json['accuracy'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp,
      if (accuracy != null) 'accuracy': accuracy,
    };
  }

  @override
  String toString() {
    return 'LocationPoint(lat: $latitude, lng: $longitude, ts: $timestamp)';
  }
}
