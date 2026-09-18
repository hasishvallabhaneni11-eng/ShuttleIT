import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class RouteStop {
  final String stopId;
  final String name;
  final LatLng location;
  final int order;
  final bool isMajorHub;

  RouteStop({
    required this.stopId,
    required this.name,
    required this.location,
    required this.order,
    this.isMajorHub = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'stopId': stopId,
      'name': name,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'order': order,
      'isMajorHub': isMajorHub,
    };
  }

  factory RouteStop.fromMap(Map<String, dynamic> map) {
    return RouteStop(
      stopId: map['stopId'] ?? '',
      name: map['name'] ?? '',
      location: LatLng(
        (map['latitude'] as num?)?.toDouble() ?? 0.0,
        (map['longitude'] as num?)?.toDouble() ?? 0.0,
      ),
      order: map['order'] ?? 0,
      isMajorHub: map['isMajorHub'] ?? false,
    );
  }
}

class ShuttleRoute {
  final String routeId;
  final String name;
  final String code; // e.g. R1, R2, R3
  final String description;
  final Color color;
  final List<RouteStop> stops;
  final List<LatLng> polyline;
  final bool isActive;

  ShuttleRoute({
    required this.routeId,
    required this.name,
    required this.code,
    required this.description,
    required this.color,
    required this.stops,
    required this.polyline,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'routeId': routeId,
      'name': name,
      'code': code,
      'description': description,
      'colorHex': color.toARGB32().toRadixString(16),
      'stops': stops.map((s) => s.toMap()).toList(),
      'polyline': polyline.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      'isActive': isActive,
    };
  }

  ShuttleRoute copyWith({
    String? name,
    String? code,
    String? description,
    Color? color,
    List<RouteStop>? stops,
    List<LatLng>? polyline,
    bool? isActive,
  }) {
    return ShuttleRoute(
      routeId: routeId,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      color: color ?? this.color,
      stops: stops ?? this.stops,
      polyline: polyline ?? this.polyline,
      isActive: isActive ?? this.isActive,
    );
  }

  factory ShuttleRoute.fromMap(Map<String, dynamic> map, {String? routeId}) {
    List<RouteStop> stopsList = [];
    if (map['stops'] != null) {
      stopsList = (map['stops'] as List)
          .map((s) => RouteStop.fromMap(Map<String, dynamic>.from(s)))
          .toList();
    }

    List<LatLng> polylineList = [];
    if (map['polyline'] != null) {
      polylineList = (map['polyline'] as List)
          .map((p) => LatLng(
                (p['lat'] as num).toDouble(),
                (p['lng'] as num).toDouble(),
              ))
          .toList();
    }

    Color parsedColor = const Color(0xFF00D2FF);
    if (map['colorHex'] != null) {
      parsedColor = Color(int.parse(map['colorHex'], radix: 16));
    }

    return ShuttleRoute(
      routeId: routeId ?? map['routeId'] ?? '',
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      description: map['description'] ?? '',
      color: parsedColor,
      stops: stopsList,
      polyline: polylineList,
      isActive: map['isActive'] ?? true,
    );
  }
}

