import 'package:flutter/material.dart';
import '../models/bus_model.dart';
import '../models/route_model.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';

class BusProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final LocationService _locationService = LocationService();

  List<Bus> _buses = [];
  List<ShuttleRoute> _routes = [];
  Map<String, BusLocation> _locations = {};

  String? _selectedBusId;
  String? _selectedRouteId;

  List<Bus> get buses => _buses;
  List<ShuttleRoute> get routes => _routes;
  Map<String, BusLocation> get locations => _locations;

  List<Bus> get activeBuses => _buses.where((b) => b.active).toList();

  String? get selectedBusId => _selectedBusId;
  String? get selectedRouteId => _selectedRouteId;

  Bus? get selectedBus =>
      _buses.cast<Bus?>().firstWhere((b) => b?.busId == _selectedBusId, orElse: () => null);

  ShuttleRoute? get selectedRoute =>
      _routes.cast<ShuttleRoute?>().firstWhere((r) => r?.routeId == _selectedRouteId, orElse: () => null);

  bool get isDriverTracking => _locationService.isTracking;
  String? get trackingBusId => _locationService.trackingBusId;
  bool get isSimulationActive => _locationService.isSimulationActive;

  BusProvider() {
    _init();
  }

  void _init() {
    _buses = _dbService.currentBuses;
    _routes = _dbService.currentRoutes;
    _locations = _locationService.currentLocations;

    if (_routes.isNotEmpty) {
      _selectedRouteId = _routes.first.routeId;
    }

    _dbService.busesStream.listen((busesList) {
      _buses = busesList;
      notifyListeners();
    });

    _dbService.routesStream.listen((routesList) {
      _routes = routesList;
      notifyListeners();
    });

    _locationService.locationsStream.listen((locMap) {
      _locations = locMap;
      notifyListeners();
    });
  }

  void selectBus(String? busId) {
    _selectedBusId = busId;
    notifyListeners();
  }

  void selectRoute(String? routeId) {
    _selectedRouteId = routeId;
    notifyListeners();
  }

  BusLocation? getLocationForBus(String busId) {
    return _locations[busId];
  }

  bool isRouteActive(String routeId) {
    final route = _routes.cast<ShuttleRoute?>().firstWhere(
      (r) => r?.routeId == routeId,
      orElse: () => null,
    );
    return route?.isActive ?? false;
  }

  // Driver & Admin Route Open/Close Action
  Future<void> toggleRouteActive(String routeId, bool active) async {
    await _dbService.toggleRouteActive(routeId, active);
    notifyListeners();
  }

  // Driver actions
  Future<bool> startTrip(String busId) async {
    final bus = _buses.firstWhere((b) => b.busId == busId, orElse: () => _buses.first);
    await _dbService.toggleRouteActive(bus.routeId, true);
    await _dbService.toggleBusActive(busId, true);
    final success = await _locationService.startDriverGpsTracking(busId);
    notifyListeners();
    return success;
  }

  Future<void> endTrip(String busId) async {
    _locationService.stopDriverGpsTracking();
    final bus = _buses.firstWhere((b) => b.busId == busId, orElse: () => _buses.first);
    await _dbService.toggleBusActive(busId, false);
    await _dbService.toggleRouteActive(bus.routeId, false);
    notifyListeners();
  }

  void toggleSimulation() {
    _locationService.toggleSimulation();
    notifyListeners();
  }

  // Admin actions
  Future<void> toggleBusActive(String busId, bool active) async {
    await _dbService.toggleBusActive(busId, active);
  }

  Future<void> assignDriver(String busId, String driverId, String driverName) async {
    await _dbService.assignDriverToBus(busId, driverId, driverName);
  }
}

