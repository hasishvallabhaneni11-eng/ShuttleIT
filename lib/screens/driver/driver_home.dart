import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/route_model.dart';
import '../../models/ticket_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bus_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/stat_tile.dart';
import '../login_screen.dart';
import '../student/student_home.dart';
import '../admin/admin_dashboard.dart';
import 'driver_scanner_screen.dart';
import 'driver_cash_screen.dart';

class DriverHome extends StatelessWidget {
  const DriverHome({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final busProv = Provider.of<BusProvider>(context);
    final ticketProv = Provider.of<TicketProvider>(context);

    final user = auth.user;
    final assignedBusId = user?.assignedBusId ?? 'BUS-01';

    final bus = busProv.buses.firstWhere(
      (b) => b.busId == assignedBusId,
      orElse: () => busProv.buses.first,
    );

    final isTripActive = bus.active;
    final busLocation = busProv.getLocationForBus(bus.busId);

    final assignedRoute = busProv.routes.cast<ShuttleRoute?>().firstWhere(
      (r) => r?.routeId == bus.routeId,
      orElse: () => null,
    );
    final isRouteActive = assignedRoute?.isActive ?? bus.active;

    // Filter tickets boarded on this bus today
    final boardedCount = ticketProv.tickets
        .where((t) => t.busId == bus.busId && t.status == TicketStatus.used)
        .length;

    final cashCollected = ticketProv.tickets
        .where((t) =>
            t.busId == bus.busId &&
            t.paymentMethod == PaymentMethod.cash &&
            t.status == TicketStatus.used)
        .fold<int>(0, (sum, t) => sum + t.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Driver Console',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
            tooltip: 'Sign Out',
            onPressed: () async {
              await auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.surfaceGradient,
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Driver Profile Header Card
            GlassCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.accentGradient,
                    ),
                    child: const Icon(Icons.drive_eta_rounded, color: Colors.black, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Driver 01',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Driver ID: ${user?.driverId ?? 'DRV-101'}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isTripActive
                          ? AppTheme.success.withValues(alpha: 0.15)
                          : AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isTripActive ? AppTheme.success : AppTheme.cardBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isTripActive ? AppTheme.success : AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isTripActive ? 'ON DUTY' : 'OFFLINE',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isTripActive ? AppTheme.success : AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Assigned Shuttle Vehicle Card
            GlassCard(
              padding: const EdgeInsets.all(18),
              borderColor: isTripActive ? AppTheme.accent : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ASSIGNED VEHICLE',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textMuted,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          bus.busId,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    bus.busNumber,
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    bus.routeName,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppTheme.accentGlow,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // GPS Transmitter Banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isTripActive ? Icons.satellite_alt_rounded : Icons.gps_off_rounded,
                          color: isTripActive ? AppTheme.primary : AppTheme.textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isTripActive
                                ? 'Transmitting Live GPS (${busLocation?.speed.toStringAsFixed(1) ?? '18'} km/h)'
                                : 'GPS Transceiver Standby',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isTripActive ? Colors.white : AppTheme.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Route Open / Close Conductor Switch
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isRouteActive
                            ? AppTheme.success.withValues(alpha: 0.4)
                            : AppTheme.error.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isRouteActive
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.block_rounded,
                              color: isRouteActive ? AppTheme.success : AppTheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isRouteActive ? 'ROUTE OPEN' : 'ROUTE CLOSED',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isRouteActive ? AppTheme.success : AppTheme.error,
                                  ),
                                ),
                                Text(
                                  isRouteActive
                                      ? 'Students can book passes on this route'
                                      : 'Route closed — bookings paused',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Switch(
                          value: isRouteActive,
                          activeThumbColor: AppTheme.success,
                          onChanged: (val) async {
                            await busProv.toggleRouteActive(bus.routeId, val);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // START / END TRIP Primary Button
                  GradientButton(
                    text: isTripActive ? 'END CAMPUS TRIP' : 'START CAMPUS TRIP',
                    icon: isTripActive ? Icons.stop_circle_outlined : Icons.play_arrow_rounded,
                    gradient: isTripActive
                        ? const LinearGradient(
                            colors: [Color(0xFFFF5252), Color(0xFFD50000)],
                          )
                        : AppTheme.accentGradient,
                    textColor: isTripActive ? Colors.white : Colors.black,
                    onPressed: () async {
                      if (isTripActive) {
                        await busProv.endTrip(bus.busId);
                      } else {
                        await busProv.startTrip(bus.busId);
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Live Metrics
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    title: 'Boarded Passengers',
                    value: '$boardedCount',
                    icon: Icons.people_outline_rounded,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    title: 'Cash Collected',
                    value: '₹$cashCollected',
                    icon: Icons.payments_outlined,
                    color: AppTheme.success,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Primary Conductor Actions
            Text(
              'PASSENGER AUTHENTICATION & BOARDING',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMuted,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),

            // 1. Scan QR Card
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DriverScannerScreen()),
                );
              },
              borderRadius: BorderRadius.circular(18),
              child: GlassCard(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.black, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scan Passenger Pass QR',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Verify single-use ₹20 digital ticket',
                            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.primary),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 2. Collect Cash Card
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => DriverCashScreen(assignedBus: bus)),
                );
              },
              borderRadius: BorderRadius.circular(18),
              child: GlassCard(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: AppTheme.accentGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.currency_rupee_rounded, color: Colors.black, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Collect ₹20 Cash Fare',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'For outsiders or students without the app',
                            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.accent),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Demo Role Switcher
            GlassCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DEMO MODE: SWITCH INTERFACE',
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.primary),
                          ),
                          onPressed: () {
                            auth.switchDemoRole(UserRole.student);
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const StudentHome()),
                            );
                          },
                          child: const Text('Student App', style: TextStyle(color: AppTheme.primary)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE040FB)),
                          ),
                          onPressed: () {
                            auth.switchDemoRole(UserRole.admin);
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const AdminDashboard()),
                            );
                          },
                          child: const Text('Admin Console', style: TextStyle(color: Color(0xFFE040FB))),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


