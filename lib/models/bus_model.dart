import 'package:latlong2/latlong.dart';

class Bus {
  final String busId;
  final String busNumber;
  final String routeId;
  final String routeName;
  final String? driverId;
  final String? driverName;
  final bool active;
  final int capacity;
  final int currentOccupancy;

  Bus({
    required this.busId,
    required this.busNumber,
    required this.routeId,
    required this.routeName,
    this.driverId,
    this.driverName,
    this.active = false,
    this.capacity = 30,
    this.currentOccupancy = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'busId': busId,
      'busNumber': busNumber,
      'routeId': routeId,
      'routeName': routeName,
      'driverId': driverId,
      'driverName': driverName,
      'active': active,
      'capacity': capacity,
      'currentOccupancy': currentOccupancy,
    };
  }

  factory Bus.fromMap(Map<String, dynamic> map, {String? busId}) {
    return Bus(
      busId: busId ?? map['busId'] ?? '',
      busNumber: map['busNumber'] ?? 'Shuttle',
      routeId: map['routeId'] ?? '',
      routeName: map['routeName'] ?? '',
      driverId: map['driverId'],
      driverName: map['driverName'],
      active: map['active'] ?? false,
      capacity: map['capacity'] ?? 30,
      currentOccupancy: map['currentOccupancy'] ?? 0,
    );
  }

  Bus copyWith({
    String? busNumber,
    String? routeId,
    String? routeName,
    String? driverId,
    String? driverName,
    bool? active,
    int? capacity,
    int? currentOccupancy,
  }) {
    return Bus(
      busId: busId,
      busNumber: busNumber ?? this.busNumber,
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      active: active ?? this.active,
      capacity: capacity ?? this.capacity,
      currentOccupancy: currentOccupancy ?? this.currentOccupancy,
    );
  }
}

class BusLocation {
  final String busId;
  final double latitude;
  final double longitude;
  final double speed; // km/h
  final double heading; // 0-360 degrees
  final int timestamp;
  final bool active;
  final String? nextStop;
  final int? etaMinutes;

  BusLocation({
    required this.busId,
    required this.latitude,
    required this.longitude,
    this.speed = 0.0,
    this.heading = 0.0,
    required this.timestamp,
    this.active = true,
    this.nextStop,
    this.etaMinutes,
  });

  LatLng get coordinates => LatLng(latitude, longitude);

  Map<String, dynamic> toMap() {
    return {
      'busId': busId,
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'heading': heading,
      'timestamp': timestamp,
      'active': active,
      'nextStop': nextStop,
      'etaMinutes': etaMinutes,
    };
  }

  factory BusLocation.fromMap(Map<String, dynamic> map, {String? busId}) {
    return BusLocation(
      busId: busId ?? map['busId'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      speed: (map['speed'] as num?)?.toDouble() ?? 0.0,
      heading: (map['heading'] as num?)?.toDouble() ?? 0.0,
      timestamp: map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      active: map['active'] ?? true,
      nextStop: map['nextStop'],
      etaMinutes: map['etaMinutes'],
    );
  }
}

