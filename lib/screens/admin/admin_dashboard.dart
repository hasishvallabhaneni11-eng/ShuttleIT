import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bus_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/stat_tile.dart';
import '../login_screen.dart';
import '../student/student_home.dart';
import '../driver/driver_home.dart';
import '../../models/ticket_model.dart';
import 'manage_buses_screen.dart';
import 'admin_tickets_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final busProv = Provider.of<BusProvider>(context);
    final ticketProv = Provider.of<TicketProvider>(context);

    final allTickets = ticketProv.tickets;
    final totalRevenue = allTickets.fold<int>(0, (sum, t) => sum + t.amount);
    final totalTicketsToday = allTickets.length;
    final totalBoarded = allTickets.where((t) => t.status == TicketStatus.used).length;
    final activeBuses = busProv.activeBuses;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFE040FB).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFFE040FB), size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'Fleet Command Center',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ],
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
            // Admin Overview Header
            GlassCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VIT Transport Administration',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Campus Fleet Operations & Digital Pass Revenue',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.success.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      'SYSTEM HEALTHY',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Simulation Mode Ticker Banner
            GestureDetector(
              onTap: () => busProv.toggleSimulation(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: busProv.isSimulationActive
                      ? AppTheme.accentGradient
                      : AppTheme.cardGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: busProv.isSimulationActive
                      ? [
                          BoxShadow(
                            color: AppTheme.accent.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      busProv.isSimulationActive
                          ? Icons.motion_photos_on_rounded
                          : Icons.motion_photos_off_rounded,
                      color: busProv.isSimulationActive ? Colors.black : AppTheme.textMuted,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            busProv.isSimulationActive
                                ? 'Demo Simulation Active'
                                : 'Demo Simulation Paused',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: busProv.isSimulationActive ? Colors.black : Colors.white,
                            ),
                          ),
                          Text(
                            busProv.isSimulationActive
                                ? 'Virtual shuttles actively moving across campus waypoints'
                                : 'Tap to simulate live bus movements for demonstration',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: busProv.isSimulationActive
                                  ? Colors.black87
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: busProv.isSimulationActive,
                      activeThumbColor: Colors.black,
                      onChanged: (_) => busProv.toggleSimulation(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 4 Grid Metric Tiles
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    title: 'Active Fleet',
                    value: '${activeBuses.length} / ${busProv.buses.length}',
                    icon: Icons.directions_bus_rounded,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    title: 'Today Revenue',
                    value: '₹$totalRevenue',
                    icon: Icons.currency_rupee_rounded,
                    color: AppTheme.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    title: 'Total Passes Issued',
                    value: '$totalTicketsToday',
                    icon: Icons.confirmation_number_outlined,
                    color: AppTheme.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    title: 'Boarded Passengers',
                    value: '$totalBoarded',
                    icon: Icons.people_outline_rounded,
                    color: const Color(0xFFE040FB),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Campus Routes Operations Control (Open / Close Routes)
            Text(
              'CAMPUS ROUTES CONTROL (OPEN / CLOSE)',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMuted,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            for (final route in busProv.routes) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  borderColor: route.isActive
                      ? route.color.withValues(alpha: 0.5)
                      : AppTheme.error.withValues(alpha: 0.3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: route.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: route.color.withValues(alpha: 0.6)),
                            ),
                            child: Center(
                              child: Text(
                                route.code,
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  color: route.color,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                route.name,
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: route.isActive ? AppTheme.success : AppTheme.error,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    route.isActive ? 'OPEN & RUNNING' : 'CLOSED / OFFLINE',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: route.isActive ? AppTheme.success : AppTheme.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: route.isActive,
                        activeThumbColor: route.color,
                        onChanged: (val) {
                          busProv.toggleRouteActive(route.routeId, val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Navigation Cards
            Text(
              'MANAGEMENT CONSOLES',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMuted,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),

            // 1. Manage Fleet
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ManageBusesScreen()),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.commute_rounded, color: AppTheme.primary, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Manage Fleet & Drivers',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Assign drivers, activate shuttles, check capacities',
                            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.textSecondary),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 2. Financial Log
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminTicketsScreen()),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.receipt_long_rounded, color: AppTheme.success, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pass Audit & Revenue Logs',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Detailed transactions: UPI vs Cash fares collected',
                            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.textSecondary),
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
                            side: const BorderSide(color: AppTheme.accent),
                          ),
                          onPressed: () {
                            auth.switchDemoRole(UserRole.driver);
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const DriverHome()),
                            );
                          },
                          child: const Text('Driver App', style: TextStyle(color: AppTheme.accent)),
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


