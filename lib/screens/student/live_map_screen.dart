import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../models/bus_model.dart';
import '../../models/route_model.dart';
import '../../providers/bus_provider.dart';
import '../../widgets/bus_marker_widget.dart';
import '../../widgets/glass_card.dart';
import 'payment_screen.dart';

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  String? _selectedBusId = 'BUS-01';

  // Student GPS location
  LatLng? _studentLocation;
  StreamSubscription<Position>? _locationSubscription;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _startLocationTracking();
  }

  Future<void> _startLocationTracking() async {
    if (kIsWeb) {
      // Web: try HTML5 geolocation via geolocator
      try {
        LocationPermission perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied) {
          perm = await Geolocator.requestPermission();
        }
        if (perm == LocationPermission.deniedForever) return;
        final pos = await Geolocator.getCurrentPosition();
        if (mounted) {
          setState(() {
            _studentLocation = LatLng(pos.latitude, pos.longitude);
          });
        }
      } catch (_) {
        // On web if permission denied, show campus center
        if (mounted) {
          setState(() {
            _studentLocation = AppConstants.vitCenter;
          });
        }
      }
      return;
    }

    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) return;
      }
      if (perm == LocationPermission.deniedForever) return;

      _locationSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      ).listen((pos) {
        if (mounted) {
          setState(() {
            _studentLocation = LatLng(pos.latitude, pos.longitude);
          });
        }
      });
    } catch (_) {}
  }

  void _centerOnMyLocation() {
    if (_studentLocation != null) {
      _mapController.move(_studentLocation!, 17.5);
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final busProv = Provider.of<BusProvider>(context);
    final activeBuses = busProv.activeBuses;
    final locations = busProv.locations;

    // Determine targeted bus for bottom drawer
    Bus? activeSelectedBus = activeBuses.cast<Bus?>().firstWhere(
      (b) => b?.busId == _selectedBusId,
      orElse: () => activeBuses.isNotEmpty ? activeBuses.first : null,
    );

    BusLocation? selectedBusLoc = activeSelectedBus != null
        ? locations[activeSelectedBus.busId]
        : null;

    return Scaffold(
      body: Stack(
        children: [
          // 1. OPENSTREETMAP TILE LAYER
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: AppConstants.vitCenter,
              initialZoom: 16.0,
              minZoom: 14.0,
              maxZoom: 18.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.vit.shuttle.vit_shuttle',
              ),

              // 2. ROUTE POLYLINES LAYER
              PolylineLayer(
                polylines: busProv.routes.map((r) {
                  final isSelected = busProv.selectedRouteId == r.routeId;
                  return Polyline(
                    points: r.polyline,
                    strokeWidth: isSelected ? 5.5 : 3.5,
                    color: !r.isActive
                        ? Colors.grey.withValues(alpha: 0.3)
                        : isSelected
                            ? r.color
                            : r.color.withValues(alpha: 0.65),
                  );
                }).toList(),
              ),

              // 3. CAMPUS STOPS & BUS MARKERS
              MarkerLayer(
                markers: [
                  // Campus stops
                  for (final route in busProv.routes)
                    for (final stop in route.stops)
                      Marker(
                        point: stop.location,
                        width: 24,
                        height: 24,
                        child: Tooltip(
                          message: stop.name,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: stop.isMajorHub ? AppTheme.accent : Colors.white,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              stop.isMajorHub
                                  ? Icons.location_on
                                  : Icons.circle,
                              color: stop.isMajorHub ? AppTheme.accent : Colors.white70,
                              size: stop.isMajorHub ? 14 : 8,
                            ),
                          ),
                        ),
                      ),

                  // Active Buses
                  for (final bus in activeBuses)
                    if (locations.containsKey(bus.busId))
                      Marker(
                        point: locations[bus.busId]!.coordinates,
                        width: 80,
                        height: 70,
                        child: BusMarkerWidget(
                          busNumber: bus.busNumber.replaceAll('VIT Shuttle ', 'S-'),
                          speed: locations[bus.busId]!.speed,
                          isSelected: _selectedBusId == bus.busId,
                          routeColor: busProv.routes
                              .cast<ShuttleRoute?>()
                              .firstWhere((r) => r?.routeId == bus.routeId, orElse: () => null)
                              ?.color,
                          onTap: () {
                            setState(() {
                              _selectedBusId = bus.busId;
                              busProv.selectRoute(bus.routeId);
                            });
                          },
                        ),
                      ),

                  // STUDENT LOCATION (pulsing blue dot)
                  if (_studentLocation != null)
                    Marker(
                      point: _studentLocation!,
                      width: 50,
                      height: 50,
                      child: AnimatedBuilder(
                        animation: _pulseAnim,
                        builder: (_, __) => Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer pulse ring
                            Container(
                              width: 40 * _pulseAnim.value,
                              height: 40 * _pulseAnim.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue.withValues(alpha: 0.15 * _pulseAnim.value),
                                border: Border.all(
                                  color: Colors.blue.withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            // Inner solid dot
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue.shade600,
                                border: Border.all(color: Colors.white, width: 2.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // MY LOCATION FAB
          Positioned(
            bottom: 220,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'my_location',
              onPressed: _centerOnMyLocation,
              backgroundColor: _studentLocation != null
                  ? Colors.blue.shade600
                  : Colors.grey.shade700,
              child: const Icon(Icons.my_location, color: Colors.white, size: 20),
            ),
          ),

          // 4. TOP FLOATING APP BAR & ROUTE FILTER
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status Header
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppTheme.success,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.success,
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'VIT VELLORE CAMPUS',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.cardBorder),
                          ),
                          child: Text(
                            '${activeBuses.length} Active Shuttles',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Route Filter Pills
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildRoutePill(
                          id: null,
                          label: 'All Routes',
                          color: AppTheme.primary,
                          isSelected: busProv.selectedRouteId == null,
                          onTap: () => busProv.selectRoute(null),
                        ),
                        for (final r in busProv.routes)
                          _buildRoutePill(
                            id: r.routeId,
                            label: r.isActive ? '${r.code} - ${r.name}' : '${r.code} [CLOSED]',
                            color: r.isActive ? r.color : Colors.grey,
                            isSelected: busProv.selectedRouteId == r.routeId,
                            onTap: () => busProv.selectRoute(r.routeId),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. FLOATING CONTROLS (Recenter & Simulation Toggle)
          Positioned(
            right: 16,
            bottom: 230,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'recenter_btn',
                  backgroundColor: AppTheme.surfaceLight,
                  foregroundColor: AppTheme.primary,
                  onPressed: () {
                    _mapController.move(AppConstants.vitCenter, 16.0);
                  },
                  child: const Icon(Icons.my_location_rounded, size: 20),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'sim_toggle_btn',
                  backgroundColor: busProv.isSimulationActive
                      ? AppTheme.accent
                      : AppTheme.surfaceLight,
                  foregroundColor: busProv.isSimulationActive
                      ? Colors.black
                      : AppTheme.textSecondary,
                  tooltip: 'Toggle Demo Simulation',
                  onPressed: () => busProv.toggleSimulation(),
                  child: const Icon(Icons.motion_photos_on_rounded, size: 20),
                ),
              ],
            ),
          ),

          // 6. BOTTOM SHUTTLE INFO DRAWER
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: activeSelectedBus == null
                ? GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'No shuttles currently active on campus',
                        style: GoogleFonts.inter(color: AppTheme.textSecondary),
                      ),
                    ),
                  )
                : GlassCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.directions_bus_filled_rounded,
                                    color: Colors.black,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activeSelectedBus.busNumber,
                                      style: GoogleFonts.outfit(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      activeSelectedBus.routeName,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // ETA Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppTheme.accent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppTheme.accent),
                              ),
                              child: Text(
                                selectedBusLoc?.etaMinutes != null
                                    ? '~${selectedBusLoc!.etaMinutes} min away'
                                    : 'Live on campus',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accent,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Next Stop readout
                        Row(
                          children: [
                            const Icon(Icons.near_me_rounded, size: 14, color: AppTheme.primary),
                            const SizedBox(width: 6),
                            Text(
                              'Next Stop: ',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                selectedBusLoc?.nextStop ?? 'Approaching Central Bay',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '${selectedBusLoc?.speed.toStringAsFixed(1) ?? '18'} km/h',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Action: Book ₹20 Pass
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              PaymentModal.show(
                                context,
                                initialBus: activeSelectedBus,
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.confirmation_number_outlined, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Book ₹20 Digital Pass',
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutePill({
    required String? id,
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? color : AppTheme.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.7)),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}


