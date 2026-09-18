import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/bus_provider.dart';
import '../../widgets/glass_card.dart';

class ManageBusesScreen extends StatelessWidget {
  const ManageBusesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final busProv = Provider.of<BusProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Campus Fleet',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.surfaceGradient,
        ),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: busProv.buses.length,
          itemBuilder: (context, index) {
            final bus = busProv.buses[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                borderColor: bus.active ? AppTheme.primary : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: bus.active
                                    ? AppTheme.primary.withValues(alpha: 0.15)
                                    : AppTheme.surfaceLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.directions_bus_rounded,
                                color: bus.active ? AppTheme.primary : AppTheme.textMuted,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bus.busNumber,
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  bus.busId,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Active Toggle Switch
                        Row(
                          children: [
                            Text(
                              bus.active ? 'ACTIVE' : 'OFFLINE',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: bus.active ? AppTheme.success : AppTheme.textMuted,
                              ),
                            ),
                            Switch(
                              value: bus.active,
                              activeThumbColor: AppTheme.primary,
                              onChanged: (val) {
                                busProv.toggleBusActive(bus.busId, val);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    const Divider(color: AppTheme.cardBorder, height: 20),

                    // Route Info
                    Row(
                      children: [
                        const Icon(Icons.alt_route_rounded, size: 14, color: AppTheme.accent),
                        const SizedBox(width: 6),
                        Text(
                          'Route: ',
                          style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted),
                        ),
                        Expanded(
                          child: Text(
                            bus.routeName,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Driver Info
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 14, color: AppTheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Assigned Driver: ',
                          style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted),
                        ),
                        Expanded(
                          child: Text(
                            bus.driverName ?? 'Unassigned Driver',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: bus.driverName != null ? Colors.white : AppTheme.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Occupancy
                    Row(
                      children: [
                        const Icon(Icons.people_outline_rounded, size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          'Capacity: ',
                          style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted),
                        ),
                        Text(
                          '${bus.currentOccupancy} / ${bus.capacity} Passengers',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


