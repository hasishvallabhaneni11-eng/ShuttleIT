import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/route_model.dart';
import '../../providers/bus_provider.dart';
import '../../widgets/glass_card.dart';
import 'payment_screen.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  String? _expandedRouteId;

  @override
  Widget build(BuildContext context) {
    final busProv = Provider.of<BusProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Campus Shuttle Routes',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.surfaceGradient,
        ),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: busProv.routes.length,
          itemBuilder: (context, index) {
            final route = busProv.routes[index];
            final isExpanded = _expandedRouteId == route.routeId;
            final assignedBuses =
                busProv.buses.where((b) => b.routeId == route.routeId).toList();
            final activeCount = assignedBuses.where((b) => b.active).length;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: GlassCard(
                padding: EdgeInsets.zero,
                borderColor: isExpanded ? route.color : null,
                child: Column(
                  children: [
                    // Main Route Banner Tile
                    InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        setState(() {
                          _expandedRouteId = isExpanded ? null : route.routeId;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Code Badge
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: route.color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: route.color.withValues(alpha: 0.6)),
                              ),
                              child: Center(
                                child: Text(
                                  route.code,
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: route.color,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    route.name,
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    route.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _buildPill(
                                        icon: Icons.pin_drop_outlined,
                                        label: '${route.stops.length} Stops',
                                        color: AppTheme.textSecondary,
                                      ),
                                      const SizedBox(width: 8),
                                      _buildPill(
                                        icon: route.isActive
                                            ? Icons.directions_bus_rounded
                                            : Icons.block_rounded,
                                        label: route.isActive
                                            ? '$activeCount Live'
                                            : 'Route Closed',
                                        color: !route.isActive
                                            ? AppTheme.error
                                            : activeCount > 0
                                                ? AppTheme.success
                                                : AppTheme.textMuted,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: AppTheme.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Expanded Stops Timeline
                    if (isExpanded) ...[
                      const Divider(color: AppTheme.cardBorder, height: 1),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ROUTE STOPS & HUBS',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textMuted,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Stops list timeline
                            for (int i = 0; i < route.stops.length; i++)
                              _buildTimelineStop(
                                stop: route.stops[i],
                                isFirst: i == 0,
                                isLast: i == route.stops.length - 1,
                                routeColor: route.color,
                              ),

                            const SizedBox(height: 16),

                            // Book pass for this route
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: route.isActive ? route.color : Colors.grey.shade800,
                                  foregroundColor: route.isActive ? Colors.black : Colors.white60,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: route.isActive
                                    ? () {
                                        PaymentModal.show(
                                          context,
                                          initialRoute: route,
                                        );
                                      }
                                    : null,
                                child: Text(
                                  route.isActive
                                      ? 'Book ₹20 Pass on ${route.code}'
                                      : 'Route Currently Closed by Control',
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTimelineStop({
    required RouteStop stop,
    required bool isFirst,
    required bool isLast,
    required Color routeColor,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Node
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: stop.isMajorHub ? 14 : 10,
                  height: stop.isMajorHub ? 14 : 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: stop.isMajorHub ? routeColor : AppTheme.surfaceLight,
                    border: Border.all(
                      color: routeColor,
                      width: stop.isMajorHub ? 2 : 1.5,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppTheme.cardBorder,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Stop Name & Hub Badge
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      stop.name,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: stop.isMajorHub ? FontWeight.w600 : FontWeight.normal,
                        color: stop.isMajorHub ? Colors.white : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  if (stop.isMajorHub)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: routeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'HUB',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: routeColor,
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

  Widget _buildPill({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}


