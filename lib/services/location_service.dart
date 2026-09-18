import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:latlong2/latlong.dart';
import '../models/bus_model.dart';
import '../models/route_model.dart';
import 'seed_data.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  FirebaseDatabase? _database;
  bool _firebaseReady = false;

  // Stream of active bus locations (keyed by busId)
  final Map<String, BusLocation> _busLocations = {};
  final StreamController<Map<String, BusLocation>> _locationsController =
      StreamController<Map<String, BusLocation>>.broadcast();

  Stream<Map<String, BusLocation>> get locationsStream => _locationsController.stream;
  Map<String, BusLocation> get currentLocations => _busLocations;

  // GPS Tracking for driver
  StreamSubscription<Position>? _positionSubscription;
  String? _trackingBusId;
  bool _isTracking = false;

  bool get isTracking => _isTracking;
  String? get trackingBusId => _trackingBusId;

  // Simulation timer for indoor demo testing
  Timer? _simulationTimer;
  bool _simulationActive = false;
  int _simulationStep = 0;

  bool get isSimulationActive => _simulationActive;

  void init() {
    try {
      if (Firebase.apps.isNotEmpty) {
        _database = FirebaseDatabase.instance;
        _firebaseReady = true;
        _listenToRemoteLocations();
      }
    } catch (_) {
      _firebaseReady = false;
    }

    // Seed initial locations
    for (final loc in SeedData.initialLocations) {
      _busLocations[loc.busId] = loc;
    }
    _locationsController.add(Map.unmodifiable(_busLocations));

    // Automatically start simulation in demo mode so map looks alive immediately
    startSimulation();
  }

  void _listenToRemoteLocations() {
    if (!_firebaseReady || _database == null) return;
    try {
      _database!.ref('bus_locations').onValue.listen((event) {
        final data = event.snapshot.value;
        if (data is Map) {
          data.forEach((key, val) {
            if (val is Map) {
              final loc = BusLocation.fromMap(Map<String, dynamic>.from(val), busId: key.toString());
              _busLocations[loc.busId] = loc;
            }
          });
          _locationsController.add(Map.unmodifiable(_busLocations));
        }
      });
    } catch (_) {}
  }

  // Driver starts transmitting physical GPS
  Future<bool> startDriverGpsTracking(String busId) async {
    _trackingBusId = busId;

    if (kIsWeb) {
      // Web fallback to simulation or web geolocation
      _isTracking = true;
      _startSimulatedTrackingForBus(busId);
      return true;
    }

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _startSimulatedTrackingForBus(busId);
          _isTracking = true;
          return true;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _startSimulatedTrackingForBus(busId);
        _isTracking = true;
        return true;
      }

      _isTracking = true;

      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // update every 5 meters
      );

      _positionSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen((Position position) {
        _updateBusPosition(
          busId: busId,
          lat: position.latitude,
          lng: position.longitude,
          speed: position.speed * 3.6, // m/s to km/h
          heading: position.heading,
        );
      });

      return true;
    } catch (e) {
      _startSimulatedTrackingForBus(busId);
      _isTracking = true;
      return true;
    }
  }

  void stopDriverGpsTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _isTracking = false;
    _trackingBusId = null;
  }

  void _updateBusPosition({
    required String busId,
    required double lat,
    required double lng,
    required double speed,
    required double heading,
    String? nextStop,
    int? etaMinutes,
  }) {
    final location = BusLocation(
      busId: busId,
      latitude: lat,
      longitude: lng,
      speed: speed,
      heading: heading,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      active: true,
      nextStop: nextStop,
      etaMinutes: etaMinutes,
    );

    _busLocations[busId] = location;
    _locationsController.add(Map.unmodifiable(_busLocations));

    // Also write to Firebase Realtime Database if connected
    if (_firebaseReady && _database != null) {
      try {
        _database!.ref('bus_locations/$busId').set(location.toMap());
      } catch (_) {}
    }
  }

  // --- DEMO / CAMPUS SIMULATION ENGINE ---
  void startSimulation() {
    if (_simulationActive) return;
    _simulationActive = true;

    final routes = SeedData.initialRoutes;
    final route1 = routes.isNotEmpty ? routes[0] : null;
    final route2 = routes.length > 1 ? routes[1] : null;
    final route3 = routes.length > 2 ? routes[2] : null;

    _simulationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _simulationStep++;

      // 1. Move Shuttle 01 along Route 1 (Men's Hostel → TT → Main Gate)
      if (route1 != null && route1.polyline.isNotEmpty) {
        _simulateBusStep(
          busId: 'BUS-01',
          route: route1,
          stepOffset: 0,
          speed: 18.0,
        );
      }

      // 2. Move Shuttle 02 along Route 2 (Main Gate → SJT Express)
      if (route2 != null && route2.polyline.isNotEmpty) {
        _simulateBusStep(
          busId: 'BUS-02',
          route: route2,
          stepOffset: 2,
          speed: 20.0,
        );
      }

      // 3. Move Shuttle 03 along Route 3 (Ladies Hostel → Academic Zone - GREEN PATH)
      if (route3 != null && route3.polyline.isNotEmpty) {
        _simulateBusStep(
          busId: 'BUS-03',
          route: route3,
          stepOffset: 4,
          speed: 16.0,
        );
      }
    });
  }

  void _simulateBusStep({
    required String busId,
    required ShuttleRoute route,
    required int stepOffset,
    required double speed,
  }) {
    final polyline = route.polyline;
    if (polyline.isEmpty) return;

    final index = (_simulationStep + stepOffset) % polyline.length;
    final nextIndex = (index + 1) % polyline.length;
    final currentPt = polyline[index];
    final nextPt = polyline[nextIndex];

    final angle = _calculateBearing(currentPt, nextPt);

    // Determine nearest upcoming stop from route stops
    String nextStopName = 'Next Stop';
    if (route.stops.isNotEmpty) {
      final stopIndex = ((index / polyline.length) * route.stops.length).floor() % route.stops.length;
      nextStopName = route.stops[stopIndex].name;
    }

    _updateBusPosition(
      busId: busId,
      lat: currentPt.latitude,
      lng: currentPt.longitude,
      speed: speed + (index % 3),
      heading: angle,
      nextStop: nextStopName,
      etaMinutes: max(1, 4 - (index % 4)),
    );
  }

  void stopSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
    _simulationActive = false;
  }

  void toggleSimulation() {
    if (_simulationActive) {
      stopSimulation();
    } else {
      startSimulation();
    }
  }

  void _startSimulatedTrackingForBus(String busId) {
    // Keeps driver bus moving if testing indoors
    if (!_simulationActive) {
      startSimulation();
    }
  }

  double _calculateBearing(LatLng from, LatLng to) {
    final lat1 = from.latitudeInRad;
    final lon1 = from.longitudeInRad;
    final lat2 = to.latitudeInRad;
    final lon2 = to.longitudeInRad;

    final dLon = lon2 - lon1;
    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    final radians = atan2(y, x);
    return (radians * 180 / pi + 360) % 360;
  }
}

